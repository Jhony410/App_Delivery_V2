import 'package:flutter/material.dart';

import '../data/models.dart';
import '../theme/app_theme.dart';
import 'buttons.dart';
import 'status_badge.dart';

/// Tarjeta de producto del frame 07: miniatura, precio, disponibilidad,
/// interruptor y botón "Editar".
///
/// Un producto agotado se atenúa entero y su miniatura pierde el color, tal
/// como en el canvas.
class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.product,
    required this.onToggle,
    required this.onEdit,
  });

  final Product product;
  final ValueChanged<bool> onToggle;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: product.available ? 1 : 0.72,
      child: Container(
        decoration: AppTheme.cardDecoration,
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            _miniatura(),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    // 17 en vez de 18: deja los nombres cortos en una sola
                    // línea sin bajar del piso de legibilidad del canvas.
                    style: AppText.display(17, weight: FontWeight.w700),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'S/ ${product.price.toStringAsFixed(2)}',
                    style: AppText.display(
                      20,
                      color: product.available
                          ? AppColors.primary
                          : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  AvailabilityLabel(available: product.available),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Switch(
                  value: product.available,
                  onChanged: onToggle,
                  activeThumbColor: Colors.white,
                  activeTrackColor: AppColors.primary,
                  inactiveThumbColor: Colors.white,
                  inactiveTrackColor: AppColors.trackOff,
                  trackOutlineColor: const WidgetStatePropertyAll(
                    Colors.transparent,
                  ),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                const SizedBox(height: 10),
                SmallOutlineButton(label: 'Editar', onPressed: onEdit),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _miniatura() {
    final agotado = !product.available;

    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: agotado ? AppColors.thumbMuted : null,
        gradient: agotado
            ? null
            : (product.thumb == ProductThumb.orange
                  ? AppColors.thumbOrange
                  : AppColors.thumbWarm),
        borderRadius: BorderRadius.circular(AppTheme.rThumb),
      ),
      alignment: Alignment.center,
      child: agotado
          // Escala de grises, como el `filter:grayscale(1)` del canvas.
          ? ColorFiltered(
              colorFilter: const ColorFilter.matrix(<double>[
                0.2126, 0.7152, 0.0722, 0, 0, //
                0.2126, 0.7152, 0.0722, 0, 0, //
                0.2126, 0.7152, 0.0722, 0, 0, //
                0, 0, 0, 1, 0, //
              ]),
              child: Text(product.emoji, style: const TextStyle(fontSize: 34)),
            )
          : Text(product.emoji, style: const TextStyle(fontSize: 34)),
    );
  }
}
