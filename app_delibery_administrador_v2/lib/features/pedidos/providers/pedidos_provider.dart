import '../../../core/models/estado_pedido.dart';
import '../../../core/state/proveedor_async.dart';
import '../data/models/pedido.dart';
import '../data/repositories/pedidos_repository.dart';

/// Estado del frame 02 (tabla + panel de detalle) y fuente de los pedidos
/// para el mapa en vivo y el centro de reasignación.
class PedidosProvider extends ProveedorAsync {
  PedidosProvider(this._repository);

  final PedidosRepository _repository;

  List<Pedido> _pedidos = const [];
  FiltroPedido _filtro = FiltroPedido.todos;
  String _busqueda = '';
  String? _seleccionadoId;
  int _totalHoy = 0;
  bool _cargado = false;

  List<Pedido> get pedidos => _pedidos;
  FiltroPedido get filtro => _filtro;
  String get busqueda => _busqueda;
  int get totalHoy => _totalHoy;

  /// Pedidos tras aplicar el chip de filtro y el buscador.
  List<Pedido> get pedidosVisibles {
    final texto = _busqueda.trim().toLowerCase();
    return [
      for (final pedido in _pedidos)
        if (_filtro.aceptar(pedido) && _coincide(pedido, texto)) pedido,
    ];
  }

  List<Pedido> get pedidosActivos => [
    for (final pedido in _pedidos)
      if (pedido.estado.estaActivo) pedido,
  ];

  /// Pedido abierto en el panel de detalle. Si el filtro deja fuera al
  /// seleccionado, se abre el primero visible; nunca queda en `null` con la
  /// lista llena.
  Pedido? get seleccionado {
    final visibles = pedidosVisibles;
    if (visibles.isEmpty) return null;
    final indice = visibles.indexWhere((p) => p.id == _seleccionadoId);
    return indice == -1 ? visibles.first : visibles[indice];
  }

  int contarPorFiltro(FiltroPedido filtro) => filtro == FiltroPedido.todos
      ? _totalHoy
      : _pedidos.where(filtro.aceptar).length;

  Pedido? porId(String id) {
    final indice = _pedidos.indexWhere((p) => p.id == id);
    return indice == -1 ? null : _pedidos[indice];
  }

  Future<void> cargar({bool forzar = false}) {
    if (_cargado && !forzar) return Future<void>.value();
    return ejecutar(() async {
      final resultados = await Future.wait([
        _repository.obtenerPedidos(),
        _repository.contarPedidosDeHoy(),
      ]);
      _pedidos = resultados[0] as List<Pedido>;
      _totalHoy = resultados[1] as int;
      _cargado = true;
    });
  }

  void seleccionar(String pedidoId) {
    if (_seleccionadoId == pedidoId) return;
    _seleccionadoId = pedidoId;
    notifyListeners();
  }

  void cambiarFiltro(FiltroPedido filtro) {
    if (_filtro == filtro) return;
    _filtro = filtro;
    notifyListeners();
  }

  void buscar(String texto) {
    if (_busqueda == texto) return;
    _busqueda = texto;
    notifyListeners();
  }

  Future<bool> reasignar({
    required String pedidoId,
    required String repartidorId,
    required String motivo,
  }) {
    return ejecutarAccion(() async {
      final actualizado = await _repository.reasignarRepartidor(
        pedidoId: pedidoId,
        repartidorId: repartidorId,
        motivo: motivo,
      );
      _reemplazar(actualizado);
      _seleccionadoId = actualizado.id;
    });
  }

  Future<bool> cancelar({required String pedidoId, required String motivo}) {
    return ejecutarAccion(() async {
      final actualizado = await _repository.cancelarPedido(
        pedidoId: pedidoId,
        motivo: motivo,
      );
      _reemplazar(actualizado);
    });
  }

  void _reemplazar(Pedido pedido) {
    _pedidos = [
      for (final p in _pedidos)
        if (p.id == pedido.id) pedido else p,
    ];
  }

  static bool _coincide(Pedido pedido, String texto) {
    if (texto.isEmpty) return true;
    return pedido.id.toLowerCase().contains(texto) ||
        pedido.negocio.toLowerCase().contains(texto) ||
        pedido.cliente.toLowerCase().contains(texto) ||
        (pedido.repartidor?.toLowerCase().contains(texto) ?? false);
  }
}

/// Filtros de marcadores del frame 03.
enum FiltroMapa {
  todos('Todos'),
  repartidores('Repartidores'),
  negocios('Negocios'),
  conProblema('Con problema');

  const FiltroMapa(this.etiqueta);

  final String etiqueta;

  bool aceptar(Pedido pedido) => switch (this) {
    FiltroMapa.todos => true,
    FiltroMapa.repartidores => pedido.tieneRepartidor,
    FiltroMapa.negocios => true,
    FiltroMapa.conProblema => pedido.estado == EstadoPedido.problema,
  };
}

/// Estado propio del mapa en vivo: filtro de marcadores y pedido abierto en
/// el panel lateral. Los datos vienen de [PedidosProvider].
class MapaProvider extends ProveedorAsync {
  FiltroMapa _filtro = FiltroMapa.todos;
  String? _pedidoSeleccionadoId;

  FiltroMapa get filtro => _filtro;
  String? get pedidoSeleccionadoId => _pedidoSeleccionadoId;

  void cambiarFiltro(FiltroMapa filtro) {
    if (_filtro == filtro) return;
    _filtro = filtro;
    notifyListeners();
  }

  void seleccionar(String pedidoId) {
    if (_pedidoSeleccionadoId == pedidoId) return;
    _pedidoSeleccionadoId = pedidoId;
    notifyListeners();
  }

  /// Elige el pedido a mostrar en el panel: el marcado por el operador o, si
  /// no hay ninguno, el primero de la lista filtrada.
  Pedido? resolverSeleccionado(List<Pedido> pedidos) {
    final visibles = [
      for (final p in pedidos)
        if (_filtro.aceptar(p)) p,
    ];
    if (visibles.isEmpty) return null;
    final indice = visibles.indexWhere((p) => p.id == _pedidoSeleccionadoId);
    return indice == -1 ? visibles.first : visibles[indice];
  }
}
