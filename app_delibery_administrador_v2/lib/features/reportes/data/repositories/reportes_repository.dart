import '../../../../core/data/dely_mock_store.dart';
import '../../../../core/data/latencia_mock.dart';
import '../models/reporte_mensual.dart';

/// Formatos de exportación que ofrece el frame 11.
enum FormatoExportacion {
  excel('Excel'),
  pdf('PDF');

  const FormatoExportacion(this.etiqueta);

  final String etiqueta;
}

/// Acceso a los reportes analíticos.
abstract interface class ReportesRepository {
  /// Periodos disponibles, del más reciente al más antiguo.
  Future<List<String>> obtenerPeriodos();

  Future<ReporteMensual> obtenerReporte(String periodo);

  /// Genera el archivo y devuelve el nombre con el que se descargaría.
  Future<String> exportar({
    required String periodo,
    required FormatoExportacion formato,
  });
}

class ReportesRepositoryMock implements ReportesRepository {
  ReportesRepositoryMock([DelyMockStore? store])
    : _store = store ?? DelyMockStore.instance;

  final DelyMockStore _store;

  static const List<String> _periodos = [
    'Julio 2026',
    'Junio 2026',
    'Mayo 2026',
  ];

  @override
  Future<List<String>> obtenerPeriodos() async => _periodos;

  @override
  Future<ReporteMensual> obtenerReporte(String periodo) async {
    await LatenciaMock.esperarLectura();
    final base = _store.reporte;
    if (periodo == base.periodo) return base;

    // Los meses anteriores se derivan del mes en curso para que el módulo
    // tenga datos coherentes en todo el selector.
    final factor = periodo == 'Junio 2026' ? 0.85 : 0.72;
    return ReporteMensual(
      periodo: periodo,
      metricas: [
        for (final m in base.metricas)
          MetricaReporte(
            titulo: m.titulo,
            valor: m.valor,
            variacion: 'cerrado',
            positiva: m.positiva,
            neutral: true,
          ),
      ],
      ingresosPorSemana: [
        for (final p in base.ingresosPorSemana)
          PuntoSerie(
            etiqueta: p.etiqueta,
            valor: p.valor * factor,
            destacado: p.destacado,
          ),
      ],
      categorias: base.categorias,
      topNegocios: base.topNegocios,
    );
  }

  @override
  Future<String> exportar({
    required String periodo,
    required FormatoExportacion formato,
  }) async {
    await LatenciaMock.esperarEscritura();
    final nombre = periodo.toLowerCase().replaceAll(' ', '-');
    final extension = formato == FormatoExportacion.excel ? 'xlsx' : 'pdf';
    return 'delypuno-reporte-$nombre.$extension';
  }
}
