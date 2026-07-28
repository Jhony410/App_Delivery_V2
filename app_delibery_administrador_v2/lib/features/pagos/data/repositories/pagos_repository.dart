import '../../../../core/data/dely_mock_store.dart';
import '../../../../core/data/latencia_mock.dart';
import '../models/liquidacion.dart';

/// Acceso a las liquidaciones semanales.
abstract interface class PagosRepository {
  Future<ResumenPagos> obtenerResumen();

  Future<List<Liquidacion>> obtenerLiquidaciones(TipoBeneficiario tipo);

  /// Marca como pagadas todas las liquidaciones pendientes de la semana.
  Future<int> procesarLiquidacion();

  Future<List<String>> obtenerSemanas();
}

class PagosRepositoryMock implements PagosRepository {
  PagosRepositoryMock([DelyMockStore? store])
    : _store = store ?? DelyMockStore.instance;

  final DelyMockStore _store;

  @override
  Future<ResumenPagos> obtenerResumen() async {
    await LatenciaMock.esperarLectura();
    return _store.resumenPagos;
  }

  @override
  Future<List<Liquidacion>> obtenerLiquidaciones(TipoBeneficiario tipo) async {
    await LatenciaMock.esperarLectura();
    return List<Liquidacion>.unmodifiable(
      _store.liquidaciones.where((l) => l.tipo == tipo),
    );
  }

  @override
  Future<int> procesarLiquidacion() async {
    await LatenciaMock.esperarEscritura();
    var procesadas = 0;
    for (var i = 0; i < _store.liquidaciones.length; i++) {
      final liquidacion = _store.liquidaciones[i];
      if (liquidacion.estado == EstadoLiquidacion.pendiente) {
        _store.liquidaciones[i] = liquidacion.copyWith(
          estado: EstadoLiquidacion.pagado,
        );
        procesadas++;
      }
    }
    final resumen = _store.resumenPagos;
    _store.resumenPagos = ResumenPagos(
      porPagarNegocios: resumen.porPagarNegocios,
      porPagarRepartidores: resumen.porPagarRepartidores,
      comisionDelyPuno: resumen.comisionDelyPuno,
      pagosPendientes: resumen.pagosPendientes - procesadas < 0
          ? 0
          : resumen.pagosPendientes - procesadas,
      semana: resumen.semana,
    );
    return procesadas;
  }

  @override
  Future<List<String>> obtenerSemanas() async => const [
    'Semana 27 jul',
    'Semana 20 jul',
    'Semana 13 jul',
  ];
}
