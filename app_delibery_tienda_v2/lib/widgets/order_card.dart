import 'package:flutter/material.dart';

import '../data/models.dart';
import '../theme/app_theme.dart';
import 'buttons.dart';
import 'status_badge.dart';

/// Tarjeta de pedido con sus cinco variantes de estado (frames 05 y 14).
///
/// La acción disponible depende del estado, igual que en el canvas:
/// - `nuevo` → Aceptar / Rechazar
/// - `preparando` → Marcar como listo
/// - `esperandoRepartidor`, `enCamino`, `entregado` → solo lectura
class OrderCard extends StatelessWidget {
  const OrderCard({
    super.key,
    required this.order,
    this.onAccept,
    this.onReject,
    this.onReady,
  });

  final Order order;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;
  final VoidCallback? onReady;

  @override
  Widget build(BuildContext context) {
    if (order.status == OrderStatus.nuevo) return _nuevo(context);
    if (order.status == OrderStatus.preparando) return _preparando(context);
    return _soloLectura(context);
  }

  /// Variante destacada: borde rojo, cabecera y dos botones.
  Widget _nuevo(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        border: Border.all(color: AppColors.primary, width: 2),
        borderRadius: BorderRadius.circular(AppTheme.rCard),
        boxShadow: AppTheme.alertShadow,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            color: AppColors.primarySoft,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    OrderStatus.nuevo.label,
                    style: AppText.body(
                      13,
                      weight: FontWeight.w700,
                      color: AppColors.primary,
                      letterSpacing: 0.5,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _antiguedad(order.receivedAt),
                  style: AppText.body(
                    14,
                    weight: FontWeight.w600,
                    color: AppColors.primaryDark,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Pedido ${order.code}',
                            style: AppText.display(18, weight: FontWeight.w700),
                          ),
                          Text(
                            '${order.customer} · ${order.itemCount} productos',
                            style: AppText.body(16, weight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      'S/ ${_monto(order.total)}',
                      style: AppText.display(26),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.fill,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    order.items.join(' · '),
                    style: AppText.body(
                      16,
                      weight: FontWeight.w500,
                      color: AppColors.textPrimary,
                      height: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                // El canvas reparte 66/34, pero en 390 px eso deja "Rechazar"
                // sin ancho para una sola línea; 60/40 mantiene la jerarquía
                // (Aceptar sigue siendo claramente el botón grande) y ambas
                // etiquetas caben enteras.
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: PrimaryButton(
                        label: 'Aceptar',
                        onPressed: onAccept,
                        height: AppTheme.hButton,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: SecondaryButton(
                        label: 'Rechazar',
                        onPressed: onReject,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Variante "Preparando": píldora ámbar y un solo botón de avance.
  Widget _preparando(BuildContext context) {
    return Container(
      decoration: AppTheme.cardDecoration,
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _cabecera(),
          const SizedBox(height: 12),
          _cliente(),
          const SizedBox(height: 14),
          PrimaryButton(
            label: 'Marcar como listo',
            onPressed: onReady,
            height: AppTheme.hButton,
          ),
        ],
      ),
    );
  }

  /// Variantes sin acción: esperando repartidor, en camino y entregado.
  Widget _soloLectura(BuildContext context) {
    return Opacity(
      opacity: order.status == OrderStatus.entregado ? 0.9 : 1,
      child: Container(
        decoration: AppTheme.cardDecoration,
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [_cabecera(), const SizedBox(height: 12), _cliente()],
        ),
      ),
    );
  }

  Widget _cabecera() => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Flexible(child: StatusBadge(order.status)),
      const SizedBox(width: 8),
      Text(order.code, style: AppText.body(15, weight: FontWeight.w600)),
    ],
  );

  Widget _cliente() => Row(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              order.customer,
              style: AppText.display(18, weight: FontWeight.w700),
            ),
            Text(
              order.statusNote ?? order.itemsSummary,
              style: AppText.body(16, weight: FontWeight.w500),
            ),
          ],
        ),
      ),
      Text('S/ ${_monto(order.total)}', style: AppText.display(22)),
    ],
  );
}

/// "S/ 42" si es entero, "S/ 42.50" si tiene céntimos.
String _monto(double valor) => valor == valor.roundToDouble()
    ? valor.toStringAsFixed(0)
    : valor.toStringAsFixed(2);

/// "hace 30 s", "hace 4 min"… como en la cabecera del pedido nuevo.
String _antiguedad(DateTime? desde) {
  if (desde == null) return 'recién';
  final s = DateTime.now().difference(desde).inSeconds;
  if (s < 60) return 'hace ${s < 5 ? 5 : s} s';
  final m = s ~/ 60;
  if (m < 60) return 'hace $m min';
  return 'hace ${m ~/ 60} h';
}
