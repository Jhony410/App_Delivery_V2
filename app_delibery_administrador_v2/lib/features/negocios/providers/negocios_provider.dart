import '../../../core/models/estado_negocio.dart';
import '../../../core/state/proveedor_async.dart';
import '../data/models/negocio.dart';
import '../data/repositories/negocios_repository.dart';

/// Estado de los frames 07 (listado) y 08 (soporte al negocio).
class NegociosProvider extends ProveedorAsync {
  NegociosProvider(this._repository);

  final NegociosRepository _repository;

  List<Negocio> _negocios = const [];
  String _busqueda = '';
  bool _cargado = false;

  List<Negocio> get negocios => _negocios;
  String get busqueda => _busqueda;

  List<Negocio> get negociosVisibles {
    final texto = _busqueda.trim().toLowerCase();
    if (texto.isEmpty) return _negocios;
    return [
      for (final n in _negocios)
        if (n.nombre.toLowerCase().contains(texto) ||
            n.categoria.toLowerCase().contains(texto) ||
            n.direccion.toLowerCase().contains(texto))
          n,
    ];
  }

  /// Los tres primeros del listado se muestran como tarjetas destacadas y el
  /// resto en tabla, igual que en el frame 07.
  List<Negocio> get destacados => negociosVisibles.take(3).toList();

  List<Negocio> get resto => negociosVisibles.skip(3).toList();

  int get abiertos => _negocios.where((n) => n.estado.atiende).length;

  int get conIncidencias => _negocios.where((n) => n.tieneIncidencias).length;

  int get comisionPromedio {
    if (_negocios.isEmpty) return 0;
    final suma = _negocios.fold<int>(0, (t, n) => t + n.comision);
    return (suma / _negocios.length).round();
  }

  Negocio? porId(String id) {
    final indice = _negocios.indexWhere((n) => n.id == id);
    return indice == -1 ? null : _negocios[indice];
  }

  Future<void> cargar({bool forzar = false}) {
    if (_cargado && !forzar) return Future<void>.value();
    return ejecutar(() async {
      _negocios = await _repository.obtenerNegocios();
      _cargado = true;
    });
  }

  void buscar(String texto) {
    if (_busqueda == texto) return;
    _busqueda = texto;
    notifyListeners();
  }

  Future<bool> actualizarProducto({
    required String negocioId,
    required Producto producto,
  }) {
    return ejecutarAccion(() async {
      _reemplazar(
        await _repository.actualizarProducto(
          negocioId: negocioId,
          producto: producto,
        ),
      );
    });
  }

  Future<bool> actualizarHorario({
    required String negocioId,
    required String horario,
  }) {
    return ejecutarAccion(() async {
      _reemplazar(
        await _repository.actualizarHorario(
          negocioId: negocioId,
          horario: horario,
        ),
      );
    });
  }

  Future<bool> actualizarComision({
    required String negocioId,
    required int comision,
  }) {
    return ejecutarAccion(() async {
      _reemplazar(
        await _repository.actualizarComision(
          negocioId: negocioId,
          comision: comision,
        ),
      );
    });
  }

  Future<bool> forzarEstado({
    required String negocioId,
    required EstadoNegocio estado,
  }) {
    return ejecutarAccion(() async {
      _reemplazar(
        await _repository.forzarEstado(negocioId: negocioId, estado: estado),
      );
    });
  }

  Future<bool> resolverIncidencia({
    required String negocioId,
    required String incidenciaId,
  }) {
    return ejecutarAccion(() async {
      _reemplazar(
        await _repository.resolverIncidencia(
          negocioId: negocioId,
          incidenciaId: incidenciaId,
        ),
      );
    });
  }

  Future<Negocio?> registrar({
    required String nombre,
    required String categoria,
    required String direccion,
    required String horario,
    required int comision,
  }) async {
    Negocio? creado;
    final ok = await ejecutarAccion(() async {
      creado = await _repository.registrar(
        nombre: nombre,
        categoria: categoria,
        direccion: direccion,
        horario: horario,
        comision: comision,
      );
      _negocios = [..._negocios, creado!];
    });
    return ok ? creado : null;
  }

  void _reemplazar(Negocio negocio) {
    _negocios = [
      for (final n in _negocios)
        if (n.id == negocio.id) negocio else n,
    ];
  }
}
