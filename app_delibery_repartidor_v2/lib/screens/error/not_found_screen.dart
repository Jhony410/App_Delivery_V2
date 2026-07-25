import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../router/app_routes.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../widgets/buttons.dart';
import '../../widgets/chasqui_logo.dart';

/// Pantalla 28 — ruta no encontrada, con identidad CHASQUI.
///
/// Es la red de seguridad del router: sustituye a la pantalla roja de Flutter.
/// En condiciones normales nunca debería verse, porque las 13 rutas del
/// [AppRoutes.all] siempre resuelven; existe para que un enlace roto o un
/// `deep link` inválido no rompa la app.
class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key, this.location});

  /// Ruta que se intentó abrir. Se muestra en pequeño para depurar.
  final String? location;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: 110,
                        height: 110,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppColors.primarySoft,
                          borderRadius: BorderRadius.circular(34),
                        ),
                        child: const RunningChasqui(
                          size: 62,
                          color: AppColors.primary,
                          duration: Duration(milliseconds: 1400),
                        ),
                      ),
                    ),
                    const SizedBox(height: 26),
                    Text(
                      'Este camino no existe',
                      textAlign: TextAlign.center,
                      style: AppText.display(24),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'El chasqui buscó por todo el altiplano y no encontró esta pantalla. '
                      'Volvamos al mapa para seguir repartiendo.',
                      textAlign: TextAlign.center,
                      style: AppText.body(14, height: 1.55),
                    ),
                    if (location != null && location!.isNotEmpty) ...[
                      const SizedBox(height: 18),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppColors.fill,
                          borderRadius: BorderRadius.circular(AppTheme.rField),
                        ),
                        child: Text(
                          location!,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppText.body(12, color: AppColors.neutral),
                        ),
                      ),
                    ],
                    const SizedBox(height: 28),
                    PrimaryButton(
                      label: 'Volver al mapa',
                      icon: Icons.map_outlined,
                      onPressed: () => context.go(AppRoutes.operations),
                    ),
                    const SizedBox(height: 12),
                    GhostButton(
                      label: 'Ir al centro de ayuda',
                      onPressed: () => context.go(AppRoutes.help),
                      color: AppColors.textSecondary,
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
