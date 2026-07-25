import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../data/models.dart';
import '../../router/app_routes.dart';
import '../../state/app_state.dart';
import '../../state/app_state_scope.dart';
import '../../theme/app_theme.dart';
import '../../widgets/order_card.dart';
import '../../widgets/skeleton.dart';
import '../../widgets/system_states.dart';

/// **Pantalla 06 · Pedidos.** Segunda pestaña del bottom nav.
///
/// Lista los pedidos en sus cinco estados y ofrece Aceptar, Rechazar y Marcar
/// como listo según corresponda.
///
/// Estados del sistema que monta, todos por debajo del bottom nav:
/// - **Sin conexión** (frame 10) con `LoadStatus.sinConexion`
/// - **Error genérico** (frame 13) con `LoadStatus.error`
/// - **Estado vacío** (frame 12) cuando la lista queda sin pedidos
/// - **Carga · skeleton** (frame 11) con `LoadStatus.cargando`
class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text('Pedidos'),
      ),
      body: SafeArea(top: false, child: _cuerpo(context, state)),
    );
  }

  Widget _cuerpo(BuildContext context, AppState state) {
    switch (state.ordersStatus) {
      case LoadStatus.cargando:
        return const OrdersSkeleton();

      case LoadStatus.sinConexion:
        return OfflineState(onRetry: state.reintentar);

      case LoadStatus.error:
        return GenericErrorState(
          onRetry: state.reintentar,
          onGoHome: () => context.go(AppRoutes.home),
        );

      case LoadStatus.listo:
        if (state.orders.isEmpty) return const SectionEmptyState();
        return _lista(state);
    }
  }

  Widget _lista(AppState state) {
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: state.reintentar,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 6, 20, 24),
        itemCount: state.orders.length,
        separatorBuilder: (_, _) => const SizedBox(height: 16),
        itemBuilder: (context, i) {
          final order = state.orders[i];
          return OrderCard(
            order: order,
            onAccept: order.status == OrderStatus.nuevo
                ? () => state.aceptarPedido(order.code)
                : null,
            onReject: order.status == OrderStatus.nuevo
                ? () => _confirmarRechazo(context, state, order)
                : null,
            onReady: order.status == OrderStatus.preparando
                ? () => state.marcarListo(order.code)
                : null,
          );
        },
      ),
    );
  }

  /// Rechazar es irreversible para el cliente, así que se confirma primero.
  Future<void> _confirmarRechazo(
    BuildContext context,
    AppState state,
    Order order,
  ) async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.rCard),
        ),
        title: Text(
          '¿Rechazar el pedido ${order.code}?',
          style: AppText.display(20, weight: FontWeight.w700),
        ),
        content: Text(
          'Se avisará a ${order.customer} que su pedido no se pudo atender.',
          style: AppText.body(16, weight: FontWeight.w500, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.textSecondary,
              textStyle: AppText.body(16, weight: FontWeight.w600),
            ),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.danger,
              textStyle: AppText.body(16, weight: FontWeight.w700),
            ),
            child: const Text('Rechazar'),
          ),
        ],
      ),
    );

    if (confirmado ?? false) state.rechazarPedido(order.code);
  }
}
