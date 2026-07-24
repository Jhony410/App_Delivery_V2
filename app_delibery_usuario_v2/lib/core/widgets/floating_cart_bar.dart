import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../router/app_routes.dart';
import '../../theme/app_theme.dart';
import '../state/cart_controller.dart';

/// Barra flotante de carrito, persistente en Home, Categoría, Detalle de
/// negocio y Detalle de producto mientras haya ítems. Al tocarla navega a
/// `/checkout`. Se oculta sola cuando el carrito está vacío.
class FloatingCartBar extends StatelessWidget {
  const FloatingCartBar({super.key, this.bottom = 20});

  final double bottom;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: cart,
      builder: (context, _) {
        if (cart.isEmpty) return const SizedBox.shrink();
        return Positioned(
          left: 16,
          right: 16,
          bottom: bottom,
          child: GestureDetector(
            onTap: () => context.push(AppRoutes.checkout),
            child: Container(
              height: 58,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(AppRadius.button),
                boxShadow: AppTheme.raisedShadow,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 30,
                        height: 30,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.18),
                          shape: BoxShape.circle,
                        ),
                        child: Text('${cart.count}',
                            style: AppText.label.copyWith(color: Colors.white)),
                      ),
                      const SizedBox(width: 12),
                      Text('Ver carrito',
                          style: AppText.cardTitle.copyWith(color: Colors.white)),
                    ],
                  ),
                  Text('S/ ${cart.subtotal.toStringAsFixed(2)}',
                      style: AppText.cardTitle.copyWith(color: Colors.white)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
