import '../../../../core/data/dely_mock_store.dart';
import '../../../../core/data/latencia_mock.dart';
import '../../../../core/models/estado_pedido.dart';
import '../models/pedido.dart';

/// Acceso a los pedidos de la operación.
///
/// La interfaz es lo único que conoce la capa de presentación; hoy la
/// implementa [PedidosRepositoryMock] y mañana una versión sobre Firestore.
abstract interface class PedidosRepository {
  Future<List<Pedido>> obtenerPedidos();

  Future<Pedido?> obtenerPedido(String id);

  /// Pedidos que siguen en curso, para el mapa en vivo.
  Future<List<Pedido>> obtenerPedidosActivos();

  Future<List<Pedido>> obtenerPedidosDeNegocio(String negocioId);

  /// Cambia el repartidor de un pedido y deja el motivo en el historial.
  Future<Pedido> reasignarRepartidor({
    required String pedidoId,
    required String repartidorId,
    required String motivo,
  });

  Future<Pedido> cancelarPedido({
    required String pedidoId,
    required String motivo,
  });

  /// Total de pedidos registrados hoy (incluye los ya cerrados).
  Future<int> contarPedidosDeHoy();
}

class PedidosRepositoryMock implements PedidosRepository {
  PedidosRepositoryMock([DelyMockStore? store])
    : _store = store ?? DelyMockStore.instance;

  final DelyMockStore _store;

  @override
  Future<List<Pedido>> obtenerPedidos() async {
    await LatenciaMock.esperarLectura();
    return List<Pedido>.unmodifiable(_store.pedidos);
  }

  @override
  Future<Pedido?> obtenerPedido(String id) async {
    await LatenciaMock.esperarLectura();
    final indice = _store.pedidos.indexWhere((p) => p.id == id);
    return indice == -1 ? null : _store.pedidos[indice];
  }

  @override
  Future<List<Pedido>> obtenerPedidosActivos() async {
    await LatenciaMock.esperarLectura();
    return List<Pedido>.unmodifiable(
      _store.pedidos.where((p) => p.estado.estaActivo),
    );
  }

  @override
  Future<List<Pedido>> obtenerPedidosDeNegocio(String negocioId) async {
    await LatenciaMock.esperarLectura();
    final indice = _store.negocios.indexWhere((n) => n.id == negocioId);
    if (indice == -1) return const [];
    final nombre = _store.negocios[indice].nombre;
    return List<Pedido>.unmodifiable(
      _store.pedidos.where((p) => p.negocio == nombre && p.estado.estaActivo),
    );
  }

  @override
  Future<Pedido> reasignarRepartidor({
    required String pedidoId,
    required String repartidorId,
    required String motivo,
  }) async {
    await LatenciaMock.esperarEscritura();

    final indicePedido = _store.pedidos.indexWhere((p) => p.id == pedidoId);
    if (indicePedido == -1) {
      throw StateError('El pedido $pedidoId ya no está en la operación.');
    }
    final indiceRepartidor = _store.repartidores.indexWhere(
      (r) => r.id == repartidorId,
    );
    if (indiceRepartidor == -1) {
      throw StateError('El repartidor seleccionado ya no está disponible.');
    }

    final pedido = _store.pedidos[indicePedido];
    final nuevo = _store.repartidores[indiceRepartidor];
    final anterior = pedido.repartidor;

    final actualizado = pedido.copyWith(
      repartidorId: nuevo.id,
      repartidor: nuevo.nombre,
      repartidorCalificacion: nuevo.calificacion,
      estado: pedido.estado == EstadoPedido.buscandoRepartidor
          ? EstadoPedido.aceptado
          : pedido.estado,
      historial: [
        ...pedido.historial,
        EventoPedido(
          titulo: anterior == null
              ? 'Repartidor asignado · ${nuevo.nombre}'
              : '${nuevo.nombre} ← $anterior',
          hora: DelyMockStore.horaPanel,
          origen: '${DelyMockStore.operadorNombre} · «$motivo»',
          enCurso: true,
        ),
      ],
    );
    _store.pedidos[indicePedido] = actualizado;

    // El historial del centro de reasignación es compartido por las tres
    // pantallas desde las que se abre.
    _store.historialReasignaciones.insert(
      0,
      '${nuevo.nombre} ← ${anterior ?? 'sin asignar'}|'
      '${DelyMockStore.horaPanel} · ${DelyMockStore.operadorNombre} · «$motivo»',
    );

    // La carga de trabajo de ambos repartidores cambia.
    _store.repartidores[indiceRepartidor] = nuevo.copyWith(
      pedidosActivos: nuevo.pedidosActivos + 1,
    );
    if (pedido.repartidorId != null) {
      final indiceAnterior = _store.repartidores.indexWhere(
        (r) => r.id == pedido.repartidorId,
      );
      if (indiceAnterior != -1) {
        final previo = _store.repartidores[indiceAnterior];
        _store.repartidores[indiceAnterior] = previo.copyWith(
          pedidosActivos: previo.pedidosActivos > 0
              ? previo.pedidosActivos - 1
              : 0,
        );
      }
    }

    return actualizado;
  }

  @override
  Future<Pedido> cancelarPedido({
    required String pedidoId,
    required String motivo,
  }) async {
    await LatenciaMock.esperarEscritura();
    final indice = _store.pedidos.indexWhere((p) => p.id == pedidoId);
    if (indice == -1) {
      throw StateError('El pedido $pedidoId ya no está en la operación.');
    }
    final pedido = _store.pedidos[indice];
    final actualizado = pedido.copyWith(
      estado: EstadoPedido.cancelado,
      historial: [
        ...pedido.historial,
        EventoPedido(
          titulo: 'Pedido cancelado desde Operaciones',
          hora: DelyMockStore.horaPanel,
          origen: '${DelyMockStore.operadorNombre} · «$motivo»',
        ),
      ],
    );
    _store.pedidos[indice] = actualizado;
    return actualizado;
  }

  @override
  Future<int> contarPedidosDeHoy() async => DelyMockStore.pedidosHoy;
}
