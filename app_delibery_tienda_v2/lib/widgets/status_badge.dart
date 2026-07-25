import 'package:flutter/material.dart';

import '../data/models.dart';
import '../theme/app_theme.dart';

/// Píldora de estado del pedido.
///
/// Los cinco estilos del canvas (frame 14) salen de [OrderStatusView]: el mismo
/// color y el mismo texto que en las apps de usuario y de repartidor.
class StatusBadge extends StatelessWidget {
  const StatusBadge(this.status, {super.key});

  final OrderStatus status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: status.softColor,
        borderRadius: BorderRadius.circular(AppTheme.rPill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (status == OrderStatus.entregado) ...[
            Icon(Icons.check_circle, size: 13, color: status.color),
            const SizedBox(width: 5),
          ],
          // "ESPERANDO REPARTIDOR" es la etiqueta más larga: en 390 px la
          // píldora tiene que poder encogerse en vez de desbordar.
          Flexible(
            child: Text(
              status.label,
              style: AppText.chip(status.color),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

/// Píldora "Abierto ahora" / "Cerrado" sobre el degradado de marca.
class OpenBadge extends StatelessWidget {
  const OpenBadge({super.key, required this.abierto});

  final bool abierto;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(AppTheme.rPill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: abierto ? AppColors.openDot : AppColors.textOnBrandSoft,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            abierto ? 'Abierto ahora' : 'Cerrado',
            style: AppText.body(
              13,
              weight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

/// Punto + texto de disponibilidad de un producto ("Disponible" / "Agotado").
class AvailabilityLabel extends StatelessWidget {
  const AvailabilityLabel({super.key, required this.available});

  final bool available;

  @override
  Widget build(BuildContext context) {
    final color = available ? AppColors.success : AppColors.neutral;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            available ? 'Disponible' : 'Agotado',
            style: AppText.body(14, weight: FontWeight.w600, color: color),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
