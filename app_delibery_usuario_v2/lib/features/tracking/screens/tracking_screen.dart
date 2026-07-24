import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/map_backdrop.dart';
import '../../../router/app_routes.dart';
import '../../../theme/app_theme.dart';

/// 13 · Seguimiento del pedido. Mapa en vivo, timeline y repartidor. Botón
/// volver -> /home. Al completar la entrega -> /rating/:orderId.
class TrackingScreen extends StatelessWidget {
  const TrackingScreen({super.key, required this.orderId});

  final String orderId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.screenBg,
      body: Stack(
        children: [
          // Mapa (parte superior).
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 500,
            child: MapBackdrop(showRoute: true),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 20,
            child: _circleBtn(
              Icons.arrow_back_ios_new,
              () => context.go(AppRoutes.home),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppRadius.chip),
                boxShadow: AppTheme.cardShadow,
              ),
              child: Text('Llega 9:58', style: AppText.cardTitle.copyWith(fontSize: 13)),
            ),
          ),
          // Panel inferior.
          Align(
            alignment: Alignment.bottomCenter,
            child: _bottomPanel(context),
          ),
        ],
      ),
    );
  }

  Widget _circleBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: AppTheme.cardShadow,
        ),
        child: Icon(icon, size: 18, color: AppColors.textPrimary),
      ),
    );
  }

  Widget _bottomPanel(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
          20, 18, 20, 20 + MediaQuery.of(context).padding.bottom),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.sheet)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: const Color(0xFFE1E4DE),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                    color: AppColors.success, shape: BoxShape.circle),
              ),
              const SizedBox(width: 6),
              Text('EN CAMINO',
                  style: AppText.small.copyWith(
                      color: AppColors.successDark, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 4),
          Text('Tu pedido llega en ~12 min', style: AppText.h3),
          const SizedBox(height: 18),
          _timeline(),
          const SizedBox(height: 22),
          _courierCard(context),
          const SizedBox(height: 14),
          ElevatedButton(
            onPressed: () => context.go(AppRoutes.ratingTo(orderId)),
            child: const Text('Confirmar entrega y calificar'),
          ),
        ],
      ),
    );
  }

  Widget _timeline() {
    const steps = [
      ('Confirmado', true),
      ('Preparando', true),
      ('En camino', true),
      ('Entregado', false),
    ];
    return Row(
      children: [
        for (var i = 0; i < steps.length; i++)
          Expanded(
            child: Column(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: steps[i].$2
                        ? (i == 2 ? AppColors.primary : AppColors.success)
                        : AppColors.surfaceMuted,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    steps[i].$2
                        ? (i == 2 ? Icons.pedal_bike : Icons.check)
                        : Icons.home_outlined,
                    color: steps[i].$2 ? Colors.white : const Color(0xFFB4B7B0),
                    size: 17,
                  ),
                ),
                const SizedBox(height: 6),
                Text(steps[i].$1,
                    style: AppText.small.copyWith(
                        fontSize: 10,
                        color: steps[i].$2
                            ? AppColors.textPrimary
                            : AppColors.textMuted)),
                const SizedBox(height: 8),
                if (i < steps.length - 1)
                  Container(
                    height: 3,
                    decoration: BoxDecoration(
                      color: steps[i + 1].$2 || steps[i].$2
                          ? AppColors.success
                          : const Color(0xFFE9ECE8),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _courierCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted2,
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [Color(0xFFBEE6CE), Color(0xFF5FB98A)]),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Miguel Q.', style: AppText.cardTitle),
                Row(
                  children: [
                    const Icon(Icons.star, size: 13, color: AppColors.star),
                    const SizedBox(width: 4),
                    Text('4.9 · Tu repartidor', style: AppText.small),
                  ],
                ),
              ],
            ),
          ),
          _actionBtn(Icons.call, Colors.white, AppColors.primary,
              () => _snack(context, 'Llamando al repartidor…')),
          const SizedBox(width: 10),
          _actionBtn(Icons.chat_bubble_outline, AppColors.primary, Colors.white,
              () => _snack(context, 'Abriendo chat…')),
        ],
      ),
    );
  }

  Widget _actionBtn(IconData icon, Color bg, Color fg, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border, width: 1.5),
        ),
        child: Icon(icon, color: fg, size: 20),
      ),
    );
  }

  void _snack(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}
