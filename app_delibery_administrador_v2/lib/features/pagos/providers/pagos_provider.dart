import '../../../core/state/proveedor_async.dart';
import '../data/models/liquidacion.dart';
import '../data/repositories/pagos_repository.dart';

/// Estado del frame 12.
class PagosProvider extends ProveedorAsync {
  PagosProvider(this._repository);

  final PagosRepository _repository;

  ResumenPagos? _resumen;
  List<Liquidacion> _liquidaciones = const [];
  List<String> _semanas = const [];
  String? _semana;
  TipoBeneficiario _tab = TipoBeneficiario.negocios;
  bool _cargado = false;

  ResumenPagos? get resumen => _resumen;
  List<Liquidacion> get liquidaciones => _liquidaciones;
  List<String> get semanas => _semanas;
  String? get semana => _semana;
  TipoBeneficiario get tab => _tab;

  bool get hayPendientes =>
      _liquidaciones.any((l) => l.estado == EstadoLiquidacion.pendiente);

  Future<void> cargar({bool forzar = false}) {
    if (_cargado && !forzar) return Future<void>.value();
    return ejecutar(() async {
      final resultados = await Future.wait([
        _repository.obtenerResumen(),
        _repository.obtenerLiquidaciones(_tab),
        _repository.obtenerSemanas(),
      ]);
      _resumen = resultados[0] as ResumenPagos;
      _liquidaciones = resultados[1] as List<Liquidacion>;
      _semanas = resultados[2] as List<String>;
      _semana ??= _resumen?.semana;
      _cargado = true;
    });
  }

  Future<void> cambiarTab(TipoBeneficiario tab) {
    if (_tab == tab) return Future<void>.value();
    _tab = tab;
    return ejecutar(() async {
      _liquidaciones = await _repository.obtenerLiquidaciones(tab);
    });
  }

  Future<void> cambiarSemana(String semana) {
    if (_semana == semana) return Future<void>.value();
    _semana = semana;
    return ejecutar(() async {
      _liquidaciones = await _repository.obtenerLiquidaciones(_tab);
    });
  }

  /// Devuelve cuántas liquidaciones quedaron pagadas.
  Future<int> procesarLiquidacion() async {
    var procesadas = 0;
    await ejecutarAccion(() async {
      procesadas = await _repository.procesarLiquidacion();
      _resumen = await _repository.obtenerResumen();
      _liquidaciones = await _repository.obtenerLiquidaciones(_tab);
    });
    return procesadas;
  }
}
