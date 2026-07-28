import '../../../core/state/proveedor_async.dart';
import '../data/models/repartidor.dart';
import '../data/repositories/repartidores_repository.dart';

/// Estado de los frames 04 (listado) y 05 (ficha).
class RepartidoresProvider extends ProveedorAsync {
  RepartidoresProvider(this._repository);

  final RepartidoresRepository _repository;

  List<Repartidor> _repartidores = const [];
  FiltroRepartidor _filtro = FiltroRepartidor.todos;
  String _busqueda = '';
  String? _zona;
  bool _cargado = false;

  List<Repartidor> get repartidores => _repartidores;
  FiltroRepartidor get filtro => _filtro;
  String get busqueda => _busqueda;

  /// `null` equivale a «Zona: todas».
  String? get zona => _zona;

  List<Repartidor> get repartidoresVisibles {
    final texto = _busqueda.trim().toLowerCase();
    return [
      for (final r in _repartidores)
        if (_filtro.aceptar(r) && _coincide(r, texto) && _enZona(r)) r,
    ];
  }

  int contarPorFiltro(FiltroRepartidor filtro) =>
      _repartidores.where(filtro.aceptar).length;

  int get conectados => _repartidores.where((r) => r.estado.estaEnLinea).length;

  int get conPedidoActivo =>
      _repartidores.where((r) => r.pedidosActivos > 0).length;

  int get documentosPorVerificar =>
      _repartidores.where((r) => r.tieneDocumentosPendientes).length;

  double get calificacionPromedio {
    final activos = _repartidores.where((r) => r.calificacion > 0).toList();
    if (activos.isEmpty) return 0;
    final suma = activos.fold<double>(0, (t, r) => t + r.calificacion);
    return suma / activos.length;
  }

  Repartidor? porId(String id) {
    final indice = _repartidores.indexWhere((r) => r.id == id);
    return indice == -1 ? null : _repartidores[indice];
  }

  /// Candidatos ordenados para el centro de reasignación.
  List<Repartidor> candidatos({String? excluirId}) {
    final lista =
        [
          for (final r in _repartidores)
            if (r.id != excluirId && !r.suspendido && !r.bloqueado) r,
        ]..sort((a, b) {
          final disponibleA = a.estado.puedeRecibirPedido ? 0 : 1;
          final disponibleB = b.estado.puedeRecibirPedido ? 0 : 1;
          if (disponibleA != disponibleB) {
            return disponibleA.compareTo(disponibleB);
          }
          if (a.pedidosActivos != b.pedidosActivos) {
            return a.pedidosActivos.compareTo(b.pedidosActivos);
          }
          return b.calificacion.compareTo(a.calificacion);
        });
    return lista;
  }

  Future<void> cargar({bool forzar = false}) {
    if (_cargado && !forzar) return Future<void>.value();
    return ejecutar(() async {
      _repartidores = await _repository.obtenerRepartidores();
      _cargado = true;
    });
  }

  void cambiarFiltro(FiltroRepartidor filtro) {
    if (_filtro == filtro) return;
    _filtro = filtro;
    notifyListeners();
  }

  void buscar(String texto) {
    if (_busqueda == texto) return;
    _busqueda = texto;
    notifyListeners();
  }

  void cambiarZona(String? zona) {
    if (_zona == zona) return;
    _zona = zona;
    notifyListeners();
  }

  Future<bool> resolverDocumento({
    required String repartidorId,
    required String tipoDocumento,
    required bool aprobado,
  }) {
    return ejecutarAccion(() async {
      _reemplazar(
        await _repository.resolverDocumento(
          repartidorId: repartidorId,
          tipoDocumento: tipoDocumento,
          aprobado: aprobado,
        ),
      );
    });
  }

  Future<bool> suspender({
    required String repartidorId,
    required String motivo,
  }) {
    return ejecutarAccion(() async {
      _reemplazar(
        await _repository.suspender(repartidorId: repartidorId, motivo: motivo),
      );
    });
  }

  Future<bool> bloquear({
    required String repartidorId,
    required String motivo,
  }) {
    return ejecutarAccion(() async {
      _reemplazar(
        await _repository.bloquear(repartidorId: repartidorId, motivo: motivo),
      );
    });
  }

  Future<Repartidor?> registrar({
    required String nombre,
    required String dni,
    required String celular,
    required String vehiculo,
    required String placa,
  }) async {
    Repartidor? creado;
    final ok = await ejecutarAccion(() async {
      creado = await _repository.registrar(
        nombre: nombre,
        dni: dni,
        celular: celular,
        vehiculo: vehiculo,
        placa: placa,
      );
      _repartidores = [..._repartidores, creado!];
    });
    return ok ? creado : null;
  }

  /// Refresca la lista desde el repositorio: la reasignación cambia la carga
  /// de trabajo de dos repartidores y hay que reflejarlo.
  Future<void> refrescar() => cargar(forzar: true);

  void _reemplazar(Repartidor repartidor) {
    _repartidores = [
      for (final r in _repartidores)
        if (r.id == repartidor.id) repartidor else r,
    ];
  }

  bool _enZona(Repartidor repartidor) {
    if (_zona == null) return true;
    return repartidor.zonaActual?.contains(_zona!) ?? false;
  }

  static bool _coincide(Repartidor repartidor, String texto) {
    if (texto.isEmpty) return true;
    return repartidor.nombre.toLowerCase().contains(texto) ||
        (repartidor.dni?.toLowerCase().contains(texto) ?? false) ||
        (repartidor.placa?.toLowerCase().contains(texto) ?? false);
  }
}

/// Etiqueta de estado para la insignia del listado.
extension EstadoRepartidorEtiqueta on Repartidor {
  String get etiquetaEstado {
    if (bloqueado) return 'BLOQUEADO';
    if (suspendido) return 'SUSPENDIDO';
    return estado.etiqueta;
  }

  bool get accesoRestringido => bloqueado || suspendido;

  /// Zona mostrada en la tabla; el diseño pinta «—» cuando no está en ruta.
  String get zonaTexto => zonaActual ?? '—';

  String get gananciaTexto =>
      gananciaHoy == null ? '—' : 'S/ ${gananciaHoy!.toStringAsFixed(1)}';

  String get conectadoTexto => tiempoConectado ?? '—';

  bool get enLinea => !accesoRestringido && estado.estaEnLinea;
}
