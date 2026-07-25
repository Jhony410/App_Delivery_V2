import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../data/models.dart';
import '../../router/app_routes.dart';
import '../../state/app_state_scope.dart';
import '../../theme/app_theme.dart';
import '../../widgets/buttons.dart';

/// **Pantalla 07 · Alerta de pedido nuevo.**
///
/// La abre `NewOrderAlertGate` al escuchar `AppState.nuevosPedidos`, sobre la
/// pantalla que estuviera activa (Inicio o Pedidos).
///
/// Se monta en la ruta [AppRoutes.newOrderAlert], que es **transparente** en el
/// Navigator raíz: la pantalla de abajo nunca se desmonta, así que cerrar la
/// alerta la devuelve con su scroll y su pestaña intactos.
///
/// Salidas:
/// - "Aceptar pedido" → acepta y lleva a la pestaña Pedidos
/// - "Rechazar" → descarta el pedido y vuelve a la pantalla de abajo
/// - botón atrás → vuelve sin decidir; el pedido sigue en la lista como nuevo
class NewOrderAlertScreen extends StatefulWidget {
  const NewOrderAlertScreen({super.key, this.order});

  /// Pedido que disparó la alerta. Si es `null` (por ejemplo al entrar a la
  /// ruta directamente) se toma el primero pendiente de aceptar.
  final Order? order;

  @override
  State<NewOrderAlertScreen> createState() => _NewOrderAlertScreenState();
}

class _NewOrderAlertScreenState extends State<NewOrderAlertScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat();

  @override
  void initState() {
    super.initState();
    // Sustituto del sonido del canvas mientras no haya audio: el celular
    // suele estar sobre el mostrador, la vibración se siente.
    HapticFeedback.heavyImpact();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  void _cerrar() {
    if (context.canPop()) {
      context.pop();
    } else {
      // Entrada directa a /alerta-pedido sin nada debajo: no dejamos al
      // comerciante en un callejón sin salida.
      context.go(AppRoutes.orders);
    }
  }

  void _aceptar(Order order) {
    AppStateScope.read(context).aceptarPedido(order.code);
    // `go` reemplaza la ubicación: retira la alerta y deja el shell en la
    // pestaña Pedidos de una sola vez.
    context.go(AppRoutes.orders);
  }

  void _rechazar(Order order) {
    AppStateScope.read(context).rechazarPedido(order.code);
    _cerrar();
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    final pendientes = state.pedidosNuevos;

    final order =
        widget.order ?? (pendientes.isNotEmpty ? pendientes.first : null);

    // Si el pedido ya se resolvió desde otro lado, la alerta se retira sola en
    // vez de quedarse mostrando datos muertos.
    if (order == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _cerrar();
      });
      return const SizedBox.shrink();
    }

    // El botón atrás cierra la alerta sin decidir: el pedido sigue pendiente
    // en la lista y la pantalla de abajo reaparece tal como estaba.
    return Scaffold(
      backgroundColor: Colors.transparent,
      // El degradado debe cubrir la pantalla entera: hoy lo hace porque los
      // botones fuerzan el ancho, pero eso es un accidente, no una garantía.
      body: SizedBox.expand(
        child: DecoratedBox(
          decoration: const BoxDecoration(gradient: AppColors.brandGradient),
          child: SafeArea(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    onPressed: _cerrar,
                    icon: const Icon(Icons.close_rounded, color: Colors.white),
                    tooltip: 'Cerrar y decidir después',
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _campana(),
                        const SizedBox(height: 26),
                        Text(
                          '¡NUEVO PEDIDO!',
                          style: AppText.body(
                            15,
                            weight: FontWeight.w700,
                            color: AppColors.textOnBrandSoft,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          order.customer,
                          textAlign: TextAlign.center,
                          style: AppText.display(32, color: Colors.white),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${order.itemCount} productos · ${order.address}',
                          textAlign: TextAlign.center,
                          style: AppText.body(
                            17,
                            weight: FontWeight.w500,
                            color: AppColors.textOnBrandStrong,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(AppTheme.rCard),
                          ),
                          child: Column(
                            children: [
                              Text(
                                'Total del pedido',
                                style: AppText.body(
                                  15,
                                  weight: FontWeight.w500,
                                  color: AppColors.textOnBrandStrong,
                                ),
                              ),
                              Text(
                                'S/ ${order.total.toStringAsFixed(2)}',
                                style: AppText.display(
                                  40,
                                  color: Colors.white,
                                  height: 1.1,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(26, 0, 26, 30),
                  child: Column(
                    children: [
                      OnBrandButton(
                        label: 'Aceptar pedido',
                        onPressed: () => _aceptar(order),
                      ),
                      const SizedBox(height: 12),
                      OnBrandButton(
                        label: 'Rechazar',
                        filled: false,
                        onPressed: () => _rechazar(order),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Campana que tiembla dentro de un halo que late (`dn-shake` + `dn-pulse`).
  Widget _campana() {
    return SizedBox(
      width: 130,
      height: 130,
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, child) {
          final t = _c.value;
          final shake = [0.0, -5.0, 5.0, -5.0, 5.0, 0.0];
          final i = (t * (shake.length - 1)).floor();
          final dx = shake[i];

          return Stack(
            alignment: Alignment.center,
            children: [
              Transform.scale(
                scale: 1 + 0.12 * (1 - (t - 0.5).abs() * 2),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Transform.translate(offset: Offset(dx, 0), child: child),
            ],
          );
        },
        child: Container(
          width: 100,
          height: 100,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.notifications_active_outlined,
            size: 52,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }
}
