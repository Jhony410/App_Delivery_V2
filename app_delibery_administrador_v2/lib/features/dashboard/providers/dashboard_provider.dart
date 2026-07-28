import '../../../core/state/proveedor_async.dart';
import '../../negocios/data/models/negocio.dart';
import '../../pedidos/data/models/pedido.dart';
import '../data/models/resumen_operativo.dart';
import '../data/repositories/dashboard_repository.dart';

/// Estado del frame 01.
///
/// También alimenta los contadores de la barra lateral (42 pedidos activos,
/// 4 documentos por verificar), por eso se crea al arrancar la app y no al
/// entrar en el dashboard.
class DashboardProvider extends ProveedorAsync {
  DashboardProvider(this._repository) {
    cargar();
  }

  final DashboardRepository _repository;

  ResumenOperativo? _resumen;
  List<Pedido> _ultimosPedidos = const [];
  List<Incidencia> _incidencias = const [];

  ResumenOperativo? get resumen => _resumen;
  List<Pedido> get ultimosPedidos => _ultimosPedidos;
  List<Incidencia> get incidencias => _incidencias;

  /// Contador verde del ítem «Pedidos» de la barra lateral.
  int get pedidosActivos => _resumen?.pedidosActivos ?? 0;

  /// Contador ámbar del ítem «Repartidores» de la barra lateral.
  int get documentosPorVerificar => _resumen?.documentosPorVerificar ?? 0;

  Future<void> cargar() => ejecutar(() async {
    final resultados = await Future.wait([
      _repository.obtenerResumen(),
      _repository.obtenerUltimosPedidos(),
      _repository.obtenerIncidenciasRecientes(),
    ]);
    _resumen = resultados[0] as ResumenOperativo;
    _ultimosPedidos = resultados[1] as List<Pedido>;
    _incidencias = resultados[2] as List<Incidencia>;
  });
}
