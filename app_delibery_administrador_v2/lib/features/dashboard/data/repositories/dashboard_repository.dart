import '../../../../core/data/dely_mock_store.dart';
import '../../../../core/data/latencia_mock.dart';
import '../../../negocios/data/models/negocio.dart';
import '../../../pedidos/data/models/pedido.dart';
import '../models/resumen_operativo.dart';

/// Acceso a las cifras y listas del dashboard.
abstract interface class DashboardRepository {
  Future<ResumenOperativo> obtenerResumen();

  /// Últimos pedidos registrados, los que muestra la tarjeta del frame 01.
  Future<List<Pedido>> obtenerUltimosPedidos({int limite = 4});

  Future<List<Incidencia>> obtenerIncidenciasRecientes();
}

class DashboardRepositoryMock implements DashboardRepository {
  DashboardRepositoryMock([DelyMockStore? store])
    : _store = store ?? DelyMockStore.instance;

  final DelyMockStore _store;

  @override
  Future<ResumenOperativo> obtenerResumen() async {
    await LatenciaMock.esperarLectura();
    return _store.resumen;
  }

  @override
  Future<List<Pedido>> obtenerUltimosPedidos({int limite = 4}) async {
    await LatenciaMock.esperarLectura();
    return List<Pedido>.unmodifiable(_store.pedidos.take(limite));
  }

  @override
  Future<List<Incidencia>> obtenerIncidenciasRecientes() async {
    await LatenciaMock.esperarLectura();
    return List<Incidencia>.unmodifiable(_store.incidenciasRecientes);
  }
}
