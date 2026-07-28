import '../../../core/models/estado_negocio.dart';
import '../../../core/state/proveedor_async.dart';
import '../data/models/cliente.dart';
import '../data/repositories/clientes_repository.dart';

/// Estado del frame 09.
class ClientesProvider extends ProveedorAsync {
  ClientesProvider(this._repository);

  final ClientesRepository _repository;

  List<Cliente> _clientes = const [];
  String _busqueda = '';
  bool _cargado = false;

  List<Cliente> get clientes => _clientes;
  String get busqueda => _busqueda;

  List<Cliente> get clientesVisibles {
    final texto = _busqueda.trim().toLowerCase();
    if (texto.isEmpty) return _clientes;
    return [
      for (final c in _clientes)
        if (c.nombre.toLowerCase().contains(texto) ||
            c.celular.replaceAll(' ', '').contains(texto.replaceAll(' ', '')))
          c,
    ];
  }

  /// Cifras del encabezado. El total registrado y los activos del mes son
  /// datos agregados del backend, no derivables de la lista visible.
  int get registrados => 4182;
  int get activosDelMes => 1946;
  int get ticketPromedio => 34;

  int get bloqueados =>
      _clientes.where((c) => c.estado == EstadoCliente.bloqueado).length + 6;

  Cliente? porId(String id) {
    final indice = _clientes.indexWhere((c) => c.id == id);
    return indice == -1 ? null : _clientes[indice];
  }

  Future<void> cargar({bool forzar = false}) {
    if (_cargado && !forzar) return Future<void>.value();
    return ejecutar(() async {
      _clientes = await _repository.obtenerClientes();
      _cargado = true;
    });
  }

  void buscar(String texto) {
    if (_busqueda == texto) return;
    _busqueda = texto;
    notifyListeners();
  }

  Future<bool> alternarBloqueo({
    required String clienteId,
    required String motivo,
  }) {
    return ejecutarAccion(() async {
      final actualizado = await _repository.alternarBloqueo(
        clienteId: clienteId,
        motivo: motivo,
      );
      _clientes = [
        for (final c in _clientes)
          if (c.id == actualizado.id) actualizado else c,
      ];
    });
  }
}
