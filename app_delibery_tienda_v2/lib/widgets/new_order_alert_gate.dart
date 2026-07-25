import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data/models.dart';
import '../router/app_router.dart';
import '../router/app_routes.dart';
import '../state/app_state.dart';
import '../state/app_state_scope.dart';

/// Disparador de la alerta de pedido nuevo (frame 06).
///
/// Envuelve al `Navigator` entero desde `main.dart`, escucha
/// [AppState.nuevosPedidos] y, cuando llega uno, empuja
/// [AppRoutes.newOrderAlert] en el Navigator raíz.
///
/// Esa ruta es transparente (`opaque: false`), así que **la pantalla de abajo
/// sigue montada**: al cerrar la alerta, Inicio o Pedidos reaparecen con su
/// scroll, su pestaña y su estado intactos.
///
/// Hoy el flujo lo alimenta `AppState.simularPedidoNuevo()`; cuando exista el
/// backend bastará con emitir en ese mismo `Stream` desde el push de Firebase.
class NewOrderAlertGate extends StatefulWidget {
  const NewOrderAlertGate({super.key, required this.child});

  final Widget child;

  @override
  State<NewOrderAlertGate> createState() => _NewOrderAlertGateState();
}

class _NewOrderAlertGateState extends State<NewOrderAlertGate> {
  StreamSubscription<Order>? _sub;
  AppState? _state;

  /// Evita apilar dos alertas si entran dos pedidos casi a la vez.
  bool _alertaAbierta = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final state = AppStateScope.of(context);
    if (identical(state, _state)) return;

    _state = state;
    _sub?.cancel();
    _sub = state.nuevosPedidos.listen(_mostrarAlerta);
  }

  Future<void> _mostrarAlerta(Order pedido) async {
    if (!mounted || _alertaAbierta) return;

    // El contexto del Navigator raíz sí ve el `InheritedGoRouter`; el de este
    // gate no, porque vive por encima del Router (`MaterialApp.builder`).
    final rootContext = AppRouter.rootNavigatorKey.currentContext;
    if (rootContext == null) return;

    _alertaAbierta = true;
    await rootContext.pushNamed(AppRoutes.nNewOrderAlert, extra: pedido);
    _alertaAbierta = false;
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
