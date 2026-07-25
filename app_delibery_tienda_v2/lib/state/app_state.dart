import 'dart:async';

import 'package:flutter/foundation.dart';

import '../data/demo_data.dart';
import '../data/models.dart';

/// Cómo va la carga de una lista. Determina qué widget monta la pantalla:
/// esqueleto, sin conexión, error, vacío o contenido.
enum LoadStatus {
  /// Esqueleto shimmer (frame 11).
  cargando,

  /// Contenido normal, o [SectionEmptyState] si la lista quedó vacía.
  listo,

  /// [OfflineState] (frame 10).
  sinConexion,

  /// [GenericErrorState] embebido (frame 13).
  error,
}

/// Estado compartido de DelyPuno Negocios.
///
/// Un solo `ChangeNotifier` con todo lo que las pantallas necesitan: sesión,
/// datos del local, pedidos, productos y estado de red. Cuando exista backend,
/// solo cambian los métodos de esta clase; ninguna pantalla se entera.
class AppState extends ChangeNotifier {
  AppState({bool seedOrders = true}) {
    if (seedOrders) {
      _orders.addAll(DemoData.orders);
    }
  }

  // ---------------------------------------------------------------- Sesión --

  bool _onboardingVisto = false;
  bool _sesionIniciada = false;
  bool _negocioRegistrado = false;

  /// El splash manda a Onboarding la primera vez y a Login después.
  bool get onboardingVisto => _onboardingVisto;

  /// Con sesión iniciada el splash entra directo al shell con bottom nav.
  bool get sesionIniciada => _sesionIniciada;

  /// El local ya completó "Datos de tu negocio".
  bool get negocioRegistrado => _negocioRegistrado;

  void marcarOnboardingVisto() {
    if (_onboardingVisto) return;
    _onboardingVisto = true;
    notifyListeners();
  }

  /// Login (frame 02). Sin backend todavía: acepta cualquier credencial.
  void iniciarSesion() {
    _onboardingVisto = true;
    _sesionIniciada = true;
    _negocioRegistrado = true;
    notifyListeners();
  }

  /// Alta desde Verificación del negocio (frame 03).
  void registrarNegocio(BusinessProfile datos) {
    _business = datos;
    _onboardingVisto = true;
    _sesionIniciada = true;
    _negocioRegistrado = true;
    notifyListeners();
  }

  void cerrarSesion() {
    _sesionIniciada = false;
    notifyListeners();
  }

  // ----------------------------------------------------------------- Local --

  BusinessProfile _business = DemoData.business;
  BusinessProfile get business => _business;

  bool _abierto = true;

  /// Abierto/cerrado: se muestra en Inicio y se conmuta desde Perfil.
  bool get abierto => _abierto;

  void alternarNegocioAbierto() {
    _abierto = !_abierto;
    notifyListeners();
  }

  void actualizarNegocio(BusinessProfile datos) {
    _business = datos;
    notifyListeners();
  }

  // --------------------------------------------------------------- Pedidos --

  final List<Order> _orders = [];
  List<Order> get orders => List.unmodifiable(_orders);

  /// Pedidos que aún esperan Aceptar/Rechazar: alimentan el contador de Inicio.
  List<Order> get pedidosNuevos =>
      _orders.where((o) => o.status == OrderStatus.nuevo).toList();

  Order? get ultimoPedido => _orders.isEmpty ? null : _orders.first;

  LoadStatus _ordersStatus = LoadStatus.listo;
  LoadStatus get ordersStatus => _ordersStatus;

  void _setOrdersStatus(LoadStatus status) {
    if (_ordersStatus == status) return;
    _ordersStatus = status;
    notifyListeners();
  }

  void aceptarPedido(String code) =>
      _cambiarEstado(code, OrderStatus.preparando);

  void marcarListo(String code) => _cambiarEstado(
    code,
    OrderStatus.esperandoRepartidor,
    nota: 'Listo · buscando chasqui',
  );

  void rechazarPedido(String code) {
    _orders.removeWhere((o) => o.code == code);
    notifyListeners();
  }

  void _cambiarEstado(String code, OrderStatus status, {String? nota}) {
    final i = _orders.indexWhere((o) => o.code == code);
    if (i == -1) return;
    _orders[i] = _orders[i].copyWith(status: status, statusNote: nota);
    notifyListeners();
  }

  // ---------------------------------------- Llegada de pedidos (alerta 06) --

  final StreamController<Order> _nuevosPedidos =
      StreamController<Order>.broadcast();

  /// Flujo que escucha `NewOrderAlertGate` para abrir la alerta emergente.
  ///
  /// Hoy lo alimenta [simularPedidoNuevo]; mañana lo alimentará el push de
  /// Firebase o un `snapshots()` de Firestore. El resto de la app no cambia.
  Stream<Order> get nuevosPedidos => _nuevosPedidos.stream;

  int _incomingIndex = 0;

  /// Inserta un pedido nuevo y lo emite por [nuevosPedidos].
  ///
  /// Lo invoca el botón "Simular pedido nuevo" del panel de demo en Perfil.
  void simularPedidoNuevo() {
    final plantilla =
        DemoData.incoming[_incomingIndex % DemoData.incoming.length];
    _incomingIndex++;
    final pedido = Order(
      // Código único aunque se simule varias veces la misma plantilla.
      code: _incomingIndex <= DemoData.incoming.length
          ? plantilla.code
          : '${plantilla.code}-$_incomingIndex',
      customer: plantilla.customer,
      address: plantilla.address,
      total: plantilla.total,
      items: plantilla.items,
      status: OrderStatus.nuevo,
      emoji: plantilla.emoji,
      receivedAt: DateTime.now(),
    );
    _orders.insert(0, pedido);
    _setOrdersStatus(LoadStatus.listo);
    notifyListeners();
    _nuevosPedidos.add(pedido);
  }

  // ------------------------------------------------------------- Productos --

  final List<Product> _products = [...DemoData.products];
  List<Product> get products => List.unmodifiable(_products);

  LoadStatus _productsStatus = LoadStatus.listo;
  LoadStatus get productsStatus => _productsStatus;

  void alternarDisponibilidad(String id) {
    final i = _products.indexWhere((p) => p.id == id);
    if (i == -1) return;
    _products[i] = _products[i].copyWith(available: !_products[i].available);
    notifyListeners();
  }

  // --------------------------------------------------------------- Reportes --

  ReportRange _reportRange = ReportRange.hoy;
  ReportRange get reportRange => _reportRange;

  ReportSummary get reportSummary =>
      DemoData.reports[_reportRange] ?? DemoData.reports[ReportRange.hoy]!;

  void cambiarRangoReporte(ReportRange rango) {
    if (_reportRange == rango) return;
    _reportRange = rango;
    notifyListeners();
  }

  // ------------------------------------------------- Estados del sistema --
  //
  // Estas banderas son las que hacen visibles los frames 10 (sin conexión),
  // 12 (estado vacío) y 13 (error genérico) dentro de Inicio, Pedidos y
  // Productos. Se conmutan desde el panel de demo de Perfil.

  bool _enLinea = true;

  /// `false` monta [OfflineState] en Inicio, Pedidos y Productos.
  bool get enLinea => _enLinea;

  void alternarConexion() {
    _enLinea = !_enLinea;
    _ordersStatus = _enLinea ? LoadStatus.listo : LoadStatus.sinConexion;
    _productsStatus = _enLinea ? LoadStatus.listo : LoadStatus.sinConexion;
    notifyListeners();
  }

  /// Vacía o repuebla la lista de pedidos para ver el frame 12.
  void alternarPedidosVacios() {
    if (_orders.isEmpty) {
      _orders.addAll(DemoData.orders);
    } else {
      _orders.clear();
    }
    _setOrdersStatus(LoadStatus.listo);
    notifyListeners();
  }

  /// Fuerza el frame 13 dentro de Pedidos, sin romper la navegación.
  void forzarErrorPedidos() => _setOrdersStatus(LoadStatus.error);

  /// Reintento de los tres estados de error: vuelve a "cargando" y, tras un
  /// instante, a "listo" si hay red.
  Future<void> reintentar() async {
    _enLinea = true;
    _ordersStatus = LoadStatus.cargando;
    _productsStatus = LoadStatus.cargando;
    notifyListeners();

    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (_disposed) return;

    _ordersStatus = LoadStatus.listo;
    _productsStatus = LoadStatus.listo;
    notifyListeners();
  }

  bool _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    _nuevosPedidos.close();
    super.dispose();
  }
}
