import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../data/models.dart';
import '../../router/app_routes.dart';
import '../../state/app_state_scope.dart';
import '../../theme/app_theme.dart';
import '../../widgets/buttons.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/store_logo.dart';
import '../../widgets/system_states.dart';

/// **Pantalla 05 · Inicio (dashboard).** Primera pestaña del bottom nav.
///
/// Resume el día del local: abierto/cerrado, pedidos por aceptar, ventas y
/// último pedido. "Ver pedidos nuevos" salta a la pestaña Pedidos.
///
/// Estados del sistema que monta: **Sin conexión** (frame 10) cuando
/// `AppState.enLinea` es `false`.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);

    if (!state.enLinea) {
      return _Fondo(child: OfflineState(onRetry: state.reintentar));
    }

    final nuevos = state.pedidosNuevos.length;
    final ultimo = state.ultimoPedido;

    return _Fondo(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          _Cabecera(nombre: state.business.name, abierto: state.abierto),
          if (nuevos > 0)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: _TarjetaPedidosNuevos(cantidad: nuevos),
            )
          else
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: _SinPedidosPendientes(abierto: state.abierto),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('HOY', style: AppText.sectionLabel()),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _Metrica(
                        titulo: 'Ventas',
                        valor:
                            'S/ ${state.reportSummary.sales.toStringAsFixed(0)}',
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _Metrica(
                        titulo: 'Pedidos',
                        valor: '${state.reportSummary.orderCount}',
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('ÚLTIMO PEDIDO', style: AppText.sectionLabel()),
                const SizedBox(height: 12),
                if (ultimo == null)
                  const _TarjetaVacia()
                else
                  _UltimoPedido(order: ultimo),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Fondo extends StatelessWidget {
  const _Fondo({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) =>
      ColoredBox(color: AppColors.surface, child: child);
}

class _Cabecera extends StatelessWidget {
  const _Cabecera({required this.nombre, required this.abierto});

  final String nombre;
  final bool abierto;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.brandGradient,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(26)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 16, 22, 24),
          child: Row(
            children: [
              const StoreLogo(size: 52, radius: 16),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nombre,
                      style: AppText.display(
                        19,
                        weight: FontWeight.w700,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    OpenBadge(abierto: abierto),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Llamada a la acción con borde rojo: el corazón de la pantalla.
class _TarjetaPedidosNuevos extends StatelessWidget {
  const _TarjetaPedidosNuevos({required this.cantidad});

  final int cantidad;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        border: Border.all(color: AppColors.primary, width: 2),
        borderRadius: BorderRadius.circular(AppTheme.rCard),
        boxShadow: AppTheme.alertShadow,
      ),
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppColors.primarySoft,
                      borderRadius: BorderRadius.circular(AppTheme.rThumb),
                    ),
                    child: const Icon(
                      Icons.receipt_long_outlined,
                      size: 30,
                      color: AppColors.primary,
                    ),
                  ),
                  Positioned(
                    top: -6,
                    right: -6,
                    child: Container(
                      constraints: const BoxConstraints(minWidth: 24),
                      height: 24,
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '$cantidad',
                        style: AppText.display(
                          13,
                          color: Colors.white,
                          height: 1,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$cantidad ${cantidad == 1 ? 'pedido' : 'pedidos'}',
                      style: AppText.display(26, height: 1),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'esperando que aceptes',
                      style: AppText.body(16, weight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          PrimaryButton(
            label: 'Ver pedidos nuevos',
            height: 58,
            // Salta a la pestaña Pedidos del mismo shell: el bottom nav sigue
            // ahí y la pestaña Inicio conserva su estado.
            onPressed: () => context.go(AppRoutes.orders),
          ),
        ],
      ),
    );
  }
}

/// Variante tranquila de la tarjeta anterior cuando no hay nada por aceptar.
class _SinPedidosPendientes extends StatelessWidget {
  const _SinPedidosPendientes({required this.abierto});

  final bool abierto;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppTheme.cardDecoration,
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: abierto ? AppColors.successSoft : AppColors.fillStrong,
              borderRadius: BorderRadius.circular(AppTheme.rThumb),
            ),
            child: Icon(
              abierto ? Icons.check_circle_outline : Icons.pause_circle_outline,
              size: 30,
              color: abierto ? AppColors.success : AppColors.neutral,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  abierto ? 'Todo al día' : 'Negocio cerrado',
                  style: AppText.display(20, weight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  abierto
                      ? 'No tienes pedidos por aceptar'
                      : 'Ábrelo desde Perfil para recibir pedidos',
                  style: AppText.body(16, weight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Metrica extends StatelessWidget {
  const _Metrica({
    required this.titulo,
    required this.valor,
    required this.color,
  });

  final String titulo;
  final String valor;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppTheme.cardDecoration,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titulo, style: AppText.body(15, weight: FontWeight.w500)),
          const SizedBox(height: 4),
          Text(valor, style: AppText.display(26, color: color)),
        ],
      ),
    );
  }
}

class _UltimoPedido extends StatelessWidget {
  const _UltimoPedido({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.go(AppRoutes.orders),
      borderRadius: BorderRadius.circular(AppTheme.rCard),
      child: Container(
        decoration: AppTheme.cardDecoration,
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: order.status.softColor,
                borderRadius: BorderRadius.circular(14),
              ),
              alignment: Alignment.center,
              child: Text(order.emoji, style: const TextStyle(fontSize: 24)),
            ),
            const SizedBox(width: 14),
            // La píldora va debajo y no al lado: en 390 px, "● NUEVO PEDIDO"
            // junto al código dejaba el texto partido en cuatro líneas.
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pedido ${order.code}',
                    style: AppText.display(18, weight: FontWeight.w700),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '${order.customer} · S/ ${order.total.toStringAsFixed(2)}',
                    style: AppText.body(15, weight: FontWeight.w500),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: StatusBadge(order.status),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Hueco de "Último pedido" cuando el local todavía no vendió nada.
class _TarjetaVacia extends StatelessWidget {
  const _TarjetaVacia();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppTheme.cardDecoration,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
      child: Row(
        children: [
          const Icon(
            Icons.receipt_long_outlined,
            size: 26,
            color: AppColors.neutral,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Todavía no hay pedidos hoy',
              style: AppText.body(16, weight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
