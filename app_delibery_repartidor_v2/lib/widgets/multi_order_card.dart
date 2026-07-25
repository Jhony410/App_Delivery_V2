import 'package:flutter/material.dart';

import '../data/models.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import 'badges.dart';

/// Tarjeta de un pedido dentro de un lote. Frame 27 · "Tarjeta multi-pedido"
/// y carrusel horizontal del frame 13.
///
/// El color de acento lo decide la posición en el lote (1 verde · 2 ámbar ·
/// 3 morado), no el negocio.
class MultiOrderCard extends StatelessWidget {
  const MultiOrderCard({
    super.key,
    required this.order,
    required this.index,
    required this.badge,
    this.onTap,
    this.width = 168,
  });

  final DeliveryOrder order;

  /// Posición dentro del lote, base 0.
  final int index;

  /// Etiqueta corta del estado en el lote ("RECOGER", "EN COLA").
  final String badge;

  final VoidCallback? onTap;
  final double width;

  @override
  Widget build(BuildContext context) {
    final accent = AppColors.orderAccent(index);
    final accentSoft = AppColors.orderAccentSoft(index);

    return SizedBox(
      width: width,
      child: Material(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppTheme.rCard),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppTheme.rCard),
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppTheme.rCard),
              border: Border.all(color: AppColors.borderSoft),
              boxShadow: AppTheme.cardShadow,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppTheme.rCard),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(width: 6, color: accent),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(13, 13, 13, 15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'PEDIDO ${index + 1}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppText.body(11, weight: FontWeight.w700, color: accent),
                                  ),
                                ),
                                StatusChip.custom(
                                  label: badge,
                                  foreground: accent,
                                  background: accentSoft,
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              order.businessName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppText.display(14, weight: FontWeight.w700),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '→ ${order.dropoffAddress}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppText.body(11),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'S/ ${order.earnings.toStringAsFixed(2)}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppText.display(15, color: accent),
                                  ),
                                ),
                                Text(
                                  '${order.distanceKm} km',
                                  maxLines: 1,
                                  style: AppText.body(11),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
