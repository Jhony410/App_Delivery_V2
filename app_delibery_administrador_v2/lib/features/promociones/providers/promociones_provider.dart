import '../../../core/state/proveedor_async.dart';
import '../data/models/promocion.dart';
import '../data/repositories/promociones_repository.dart';

/// Estado del frame 10: listado de promociones activas y borrador del
/// creador con su vista previa.
class PromocionesProvider extends ProveedorAsync {
  PromocionesProvider(this._repository);

  final PromocionesRepository _repository;

  List<Promocion> _promociones = const [];
  bool _cargado = false;

  // Borrador del creador. La vista previa del banner lee estos campos en vivo.
  String _titulo = '2×1 en pollo a la brasa';
  TipoPromocion _tipo = TipoPromocion.dosPorUno;
  String _valor = '25%';
  String _desde = '28 jul. 2026';
  String _hasta = '04 ago. 2026';
  List<String> _negociosIncluidos = const [
    'Pollería El Cholo',
    'Chifa Titicaca',
  ];

  List<Promocion> get promociones => _promociones;

  String get titulo => _titulo;
  TipoPromocion get tipo => _tipo;
  String get valor => _valor;
  String get desde => _desde;
  String get hasta => _hasta;
  List<String> get negociosIncluidos => _negociosIncluidos;

  bool get borradorValido =>
      _titulo.trim().isNotEmpty && _valor.trim().isNotEmpty;

  /// Segunda línea del banner de la vista previa.
  String get textoBanner {
    final descuento = switch (_tipo) {
      TipoPromocion.descuento => '$_valor de descuento',
      TipoPromocion.dosPorUno => '$_valor de descuento',
      TipoPromocion.envio => 'Envío gratis',
    };
    return '$descuento · hasta el ${_hastaLegible()}';
  }

  Future<void> cargar({bool forzar = false}) {
    if (_cargado && !forzar) return Future<void>.value();
    return ejecutar(() async {
      _promociones = await _repository.obtenerPromociones();
      _cargado = true;
    });
  }

  void cambiarTitulo(String valor) {
    _titulo = valor;
    notifyListeners();
  }

  void cambiarTipo(TipoPromocion tipo) {
    if (_tipo == tipo) return;
    _tipo = tipo;
    notifyListeners();
  }

  void cambiarValor(String valor) {
    _valor = valor;
    notifyListeners();
  }

  void cambiarDesde(String valor) {
    _desde = valor;
    notifyListeners();
  }

  void cambiarHasta(String valor) {
    _hasta = valor;
    notifyListeners();
  }

  void agregarNegocio(String nombre) {
    if (_negociosIncluidos.contains(nombre)) return;
    _negociosIncluidos = [..._negociosIncluidos, nombre];
    notifyListeners();
  }

  void quitarNegocio(String nombre) {
    _negociosIncluidos = [
      for (final n in _negociosIncluidos)
        if (n != nombre) n,
    ];
    notifyListeners();
  }

  Future<bool> guardar({required bool publicar}) {
    return ejecutarAccion(() async {
      final creada = await _repository.guardar(
        titulo: _titulo,
        tipo: _tipo,
        valor: _valor,
        desde: _desde,
        hasta: _hasta,
        negocios: _negociosIncluidos,
        publicar: publicar,
      );
      _promociones = [creada, ..._promociones];
    });
  }

  Future<bool> finalizar(String promocionId) {
    return ejecutarAccion(() async {
      await _repository.finalizar(promocionId);
      _promociones = await _repository.obtenerPromociones();
    });
  }

  /// «04 ago. 2026» → «4 de agosto», como escribe el banner del diseño.
  String _hastaLegible() {
    const meses = {
      'ene': 'enero',
      'feb': 'febrero',
      'mar': 'marzo',
      'abr': 'abril',
      'may': 'mayo',
      'jun': 'junio',
      'jul': 'julio',
      'ago': 'agosto',
      'set': 'setiembre',
      'oct': 'octubre',
      'nov': 'noviembre',
      'dic': 'diciembre',
    };
    final partes = _hasta.split(' ');
    if (partes.length < 2) return _hasta;
    final dia = int.tryParse(partes[0]) ?? 0;
    final mes = meses[partes[1].replaceAll('.', '')] ?? partes[1];
    return dia == 0 ? _hasta : '$dia de $mes';
  }
}
