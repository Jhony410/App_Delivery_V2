import '../../../../core/data/dely_mock_store.dart';
import '../../../../core/data/latencia_mock.dart';
import '../../../../core/models/estado_negocio.dart';
import '../models/cliente.dart';

/// Acceso a los clientes de la app de usuario.
abstract interface class ClientesRepository {
  Future<List<Cliente>> obtenerClientes();

  Future<Cliente?> obtenerCliente(String id);

  /// Bloquea o desbloquea a un cliente.
  Future<Cliente> alternarBloqueo({
    required String clienteId,
    required String motivo,
  });
}

class ClientesRepositoryMock implements ClientesRepository {
  ClientesRepositoryMock([DelyMockStore? store])
    : _store = store ?? DelyMockStore.instance;

  final DelyMockStore _store;

  @override
  Future<List<Cliente>> obtenerClientes() async {
    await LatenciaMock.esperarLectura();
    return List<Cliente>.unmodifiable(_store.clientes);
  }

  @override
  Future<Cliente?> obtenerCliente(String id) async {
    await LatenciaMock.esperarLectura();
    final indice = _store.clientes.indexWhere((c) => c.id == id);
    return indice == -1 ? null : _store.clientes[indice];
  }

  @override
  Future<Cliente> alternarBloqueo({
    required String clienteId,
    required String motivo,
  }) async {
    await LatenciaMock.esperarEscritura();
    final indice = _store.clientes.indexWhere((c) => c.id == clienteId);
    if (indice == -1) {
      throw StateError('El cliente ya no está registrado en DelyPuno.');
    }
    final cliente = _store.clientes[indice];
    final actualizado = cliente.copyWith(
      estado: cliente.estado == EstadoCliente.bloqueado
          ? (cliente.pedidos >= 40
                ? EstadoCliente.frecuente
                : EstadoCliente.activo)
          : EstadoCliente.bloqueado,
    );
    _store.clientes[indice] = actualizado;
    return actualizado;
  }
}
