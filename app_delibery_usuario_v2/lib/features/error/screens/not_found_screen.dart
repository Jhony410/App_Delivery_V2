import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/brand.dart';
import '../../../router/app_routes.dart';
import '../../../theme/app_theme.dart';

/// Pantalla amigable de "no encontrado". La usa el errorBuilder / onException
/// global del router para que nunca aparezca la pantalla roja de error de
/// Flutter ni una pantalla en blanco.
class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key, this.detail});

  final String? detail;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.screenBg,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const DelyLogo(size: 84, radius: 26),
                const SizedBox(height: 24),
                Text('Página no encontrada',
                    style: AppText.h2, textAlign: TextAlign.center),
                const SizedBox(height: 10),
                Text(
                  detail ??
                      'No pudimos encontrar lo que buscabas. Puede que el enlace '
                          'ya no exista.',
                  style: AppText.bodySecondary,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 26),
                SizedBox(
                  width: 220,
                  child: ElevatedButton.icon(
                    onPressed: () => context.go(AppRoutes.home),
                    icon: const Icon(Icons.home_rounded, size: 18),
                    label: const Text('Volver al inicio'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
