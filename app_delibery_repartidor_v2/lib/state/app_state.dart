import 'dart:async';

import 'package:flutter/foundation.dart';

import '../data/demo_data.dart';
import '../data/models.dart';

/// Fases del núcleo operativo. Cada una corresponde a un frame del diseño,
/// pero TODAS viven dentro de la misma pantalla (`OperationsScreen`): cambian
/// el contenido de la hoja inferior y los overlays del mapa, nunca la ruta.
enum OperationPhase {
  /// Frame 21 — desconectado, no recibe pedidos.
  desconectado,

  /// Frame 06 — conectado, buscando pedidos cerca.
  buscando,

  /// Frame 25 — conectado pero sin oferta en el radio.
  sinPedidos,

  /// Frame 08 — oferta entrante con temporizador de 20s.
  pedidoEntrante,

  /// Frame 09 — aceptado, en ruta al restaurante.
  rutaAlRestaurante,

  /// Frame 10 — en el restaurante, esperando que salga el pedido.
  esperandoEnRestaurante,

  /// Frame 11 — recogido, en ruta al cliente.
  rutaAlCliente,

  /// Frame 12 — llegó donde el cliente, confirmar entrega.
  confirmarEntrega,

  /// Frame 13 — lote de varios pedidos con ruta optimizada.
  pedidosMultiples,
}

/// Estado global de CHASQUI.
///
/// Un único `ChangeNotifier` expuesto por `AppStateScope`. Concentra:
/// - la fase del núcleo operativo (frames 06–13, 21, 25),
/// - los estados del sistema (frames 22 sin internet, 23 GPS, 24 carga, 26 error),
/// - las preferencias de configuración (frame 18).
///
/// Los estados del sistema son **banderas**, no pantallas: la UI reacciona
/// mostrando un overlay encima de lo que ya hay, así ninguna queda huérfana.
class AppState extends ChangeNotifier {
  // ---- Núcleo operativo ----
  OperationPhase _phase = OperationPhase.desconectado;
  OperationPhase get phase => _phase;

  /// `true` cuando el repartidor está en línea (interruptor del frame 06).
  bool get isOnline => _phase != OperationPhase.desconectado;

  /// Frame 07 — overlay de heatmap sobre el mapa.
  bool _showHeatmap = false;
  bool get showHeatmap => _showHeatmap;

  DeliveryOrder _currentOrder = DemoData.incomingOrder;
  DeliveryOrder get currentOrder => _currentOrder;

  /// Segundos restantes de la oferta entrante (frame 08).
  int _offerSeconds = DemoData.offerSeconds;
  int get offerSeconds => _offerSeconds;
  Timer? _offerTimer;

  // ---- Estados del sistema (frames 22–26) ----
  bool _hasInternet = true;
  bool get hasInternet => _hasInternet;

  bool _gpsEnabled = true;
  bool get gpsEnabled => _gpsEnabled;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;

  // ---- Configuración (frame 18) ----
  bool newOrderAlerts = true;
  bool soundAlerts = true;
  bool vibration = false;
  String mapsApp = 'Google Maps';
  String language = 'Español';

  // ---- Sesión ----
  bool _locationGranted = false;
  bool get locationGranted => _locationGranted;

  @override
  void dispose() {
    _offerTimer?.cancel();
    super.dispose();
  }

  // ---------------------------------------------------------------- núcleo

  /// Interruptor conectado / desconectado del frame 06.
  void setOnline(bool online) {
    if (online) {
      // Al conectarse, sin GPS no se puede trabajar: el frame 23 se dispara solo.
      _phase = OperationPhase.buscando;
    } else {
      _cancelOffer();
      _phase = OperationPhase.desconectado;
    }
    notifyListeners();
  }

  void toggleHeatmap() {
    _showHeatmap = !_showHeatmap;
    notifyListeners();
  }

  void showHeatmapLayer() {
    _showHeatmap = true;
    notifyListeners();
  }

  /// Simula que no hay ofertas en el radio (frame 25).
  void setNoOrdersNearby() {
    _cancelOffer();
    _phase = OperationPhase.sinPedidos;
    notifyListeners();
  }

  /// Vuelve a buscar tras un estado vacío.
  void resumeSearching() {
    _phase = OperationPhase.buscando;
    notifyListeners();
  }

  /// Dispara la oferta entrante y arranca la cuenta regresiva (frame 08).
  void receiveOffer([DeliveryOrder? order]) {
    _currentOrder = (order ?? DemoData.incomingOrder).copyWith(status: OrderStatus.buscando);
    _offerSeconds = DemoData.offerSeconds;
    _phase = OperationPhase.pedidoEntrante;
    notifyListeners();

    _offerTimer?.cancel();
    _offerTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _offerSeconds--;
      if (_offerSeconds <= 0) {
        timer.cancel();
        // La oferta expiró: se cae al estado vacío, nunca a una pantalla rota.
        _phase = OperationPhase.sinPedidos;
        _offerSeconds = DemoData.offerSeconds;
      }
      notifyListeners();
    });
  }

  void _cancelOffer() {
    _offerTimer?.cancel();
    _offerTimer = null;
    _offerSeconds = DemoData.offerSeconds;
  }

  /// Frame 08 → 09.
  void acceptOffer() {
    _cancelOffer();
    _currentOrder = _currentOrder.copyWith(status: OrderStatus.aceptado);
    _phase = OperationPhase.rutaAlRestaurante;
    notifyListeners();
  }

  /// Frame 08 → vuelve a buscar.
  void rejectOffer() {
    _cancelOffer();
    _phase = OperationPhase.buscando;
    notifyListeners();
  }

  /// Frame 09 → 10.
  void arrivedAtRestaurant() {
    _currentOrder = _currentOrder.copyWith(status: OrderStatus.enCocina);
    _phase = OperationPhase.esperandoEnRestaurante;
    notifyListeners();
  }

  /// Frame 10 → 11.
  void confirmPickup() {
    _currentOrder = _currentOrder.copyWith(status: OrderStatus.enCamino);
    _phase = OperationPhase.rutaAlCliente;
    notifyListeners();
  }

  /// Frame 11 → 12.
  void arrivedAtCustomer() {
    _currentOrder = _currentOrder.copyWith(status: OrderStatus.cercaDelCliente);
    _phase = OperationPhase.confirmarEntrega;
    notifyListeners();
  }

  /// Frame 12 → cierra el ciclo y vuelve a buscar.
  void completeDelivery() {
    _currentOrder = _currentOrder.copyWith(status: OrderStatus.entregado);
    _phase = OperationPhase.buscando;
    notifyListeners();
  }

  /// Frame 13 — lote multi-pedido.
  void receiveMultiOrders() {
    _cancelOffer();
    _phase = OperationPhase.pedidosMultiples;
    notifyListeners();
  }

  /// Empieza el primer pedido del lote: se reincorpora al flujo normal.
  void startFirstOfBatch() {
    _currentOrder = DemoData.multiOrders.first.copyWith(status: OrderStatus.aceptado);
    _phase = OperationPhase.rutaAlRestaurante;
    notifyListeners();
  }

  /// Vuelve al mapa base sin perder la sesión (usado por el drawer y el
  /// botón "volver al inicio" de los estados de error).
  void backToMap() {
    _cancelOffer();
    _phase = isOnline ? OperationPhase.buscando : OperationPhase.desconectado;
    _showHeatmap = false;
    notifyListeners();
  }

  // -------------------------------------------------- estados del sistema

  /// Frame 22 — sin internet.
  void setInternet(bool value) {
    if (_hasInternet == value) return;
    _hasInternet = value;
    notifyListeners();
  }

  /// Frame 23 — GPS desactivado.
  void setGps(bool value) {
    if (_gpsEnabled == value) return;
    _gpsEnabled = value;
    notifyListeners();
  }

  /// Frame 24 — skeleton de carga.
  void setLoading(bool value) {
    if (_isLoading == value) return;
    _isLoading = value;
    notifyListeners();
  }

  /// Frame 26 — error genérico.
  void raiseError([String message = 'Nuestro chasqui tropezó. Vuelve a intentarlo en unos segundos.']) {
    _errorMessage = message;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Reintento común a los frames 22 y 26.
  Future<void> retry() async {
    _errorMessage = null;
    _isLoading = true;
    notifyListeners();
    await Future<void>.delayed(const Duration(milliseconds: 900));
    _hasInternet = true;
    _isLoading = false;
    notifyListeners();
  }

  /// Carga inicial del mapa (frame 24) al entrar al núcleo operativo.
  Future<void> warmUp() async {
    _isLoading = true;
    notifyListeners();
    await Future<void>.delayed(const Duration(milliseconds: 1100));
    _isLoading = false;
    notifyListeners();
  }

  // ------------------------------------------------------------- sesión

  void grantLocation() {
    _locationGranted = true;
    _gpsEnabled = true;
    notifyListeners();
  }

  void skipLocation() {
    _locationGranted = false;
    _gpsEnabled = false;
    notifyListeners();
  }

  void signOut() {
    _cancelOffer();
    _phase = OperationPhase.desconectado;
    _showHeatmap = false;
    _locationGranted = false;
    _errorMessage = null;
    notifyListeners();
  }

  // ---------------------------------------------- preferencias (frame 18)

  void setNewOrderAlerts(bool value) {
    newOrderAlerts = value;
    notifyListeners();
  }

  void setSoundAlerts(bool value) {
    soundAlerts = value;
    notifyListeners();
  }

  void setVibration(bool value) {
    vibration = value;
    notifyListeners();
  }

  void setMapsApp(String value) {
    mapsApp = value;
    notifyListeners();
  }

  void setLanguage(String value) {
    language = value;
    notifyListeners();
  }
}
