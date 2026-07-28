import '../../../core/state/proveedor_async.dart';
import '../data/models/reporte_mensual.dart';
import '../data/repositories/reportes_repository.dart';

/// Estado del frame 11.
class ReportesProvider extends ProveedorAsync {
  ReportesProvider(this._repository);

  final ReportesRepository _repository;

  ReporteMensual? _reporte;
  List<String> _periodos = const [];
  String? _periodo;
  bool _cargado = false;

  ReporteMensual? get reporte => _reporte;
  List<String> get periodos => _periodos;
  String? get periodo => _periodo;

  /// Valor máximo de la serie, para escalar las barras sin dividir por cero.
  double get maximoIngresos {
    final serie = _reporte?.ingresosPorSemana ?? const <PuntoSerie>[];
    if (serie.isEmpty) return 1;
    return serie.map((p) => p.valor).reduce((a, b) => a > b ? a : b);
  }

  Future<void> cargar({bool forzar = false}) {
    if (_cargado && !forzar) return Future<void>.value();
    return ejecutar(() async {
      _periodos = await _repository.obtenerPeriodos();
      _periodo ??= _periodos.isEmpty ? null : _periodos.first;
      if (_periodo != null) {
        _reporte = await _repository.obtenerReporte(_periodo!);
      }
      _cargado = true;
    });
  }

  Future<void> cambiarPeriodo(String periodo) {
    if (_periodo == periodo) return Future<void>.value();
    _periodo = periodo;
    return ejecutar(() async {
      _reporte = await _repository.obtenerReporte(periodo);
    });
  }

  /// Devuelve el nombre del archivo generado, o `null` si falló.
  Future<String?> exportar(FormatoExportacion formato) async {
    if (_periodo == null) return null;
    String? archivo;
    final ok = await ejecutarAccion(() async {
      archivo = await _repository.exportar(
        periodo: _periodo!,
        formato: formato,
      );
    });
    return ok ? archivo : null;
  }
}
