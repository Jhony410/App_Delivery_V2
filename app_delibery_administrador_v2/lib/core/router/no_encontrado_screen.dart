import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../widgets/admin_shell.dart';
import '../widgets/app_buttons.dart';
import '../widgets/app_card.dart';
import 'app_routes.dart';

/// Pantalla que atiende cualquier ruta desconocida.
///
/// Es la que evita la pantalla roja de Flutter: el `errorBuilder` del router
/// la usa tanto para rutas mal escritas como para identificadores que ya no
/// existen.
class NoEncontradoScreen extends StatelessWidget {
  const NoEncontradoScreen({super.key, this.ruta, this.mensaje});

  /// Ruta que se intentó abrir.
  final String? ruta;

  /// Explicación concreta cuando el fallo no es de ruta sino de dato
  /// («el pedido #A-9999 ya no está en la operación»).
  final String? mensaje;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.xxl),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: AppCard(
                padding: const EdgeInsets.all(AppSpacing.xxxl),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const AdminLogo(size: 64),
                    const SizedBox(height: AppSpacing.xl),
                    Text(
                      'Esta pantalla no existe',
                      style: AppTextStyles.sectionTitle,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      mensaje ??
                          'La dirección que intentaste abrir no forma parte '
                              'del panel de operaciones de DelyPuno.',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (ruta != null) ...[
                      const SizedBox(height: AppSpacing.md),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.sm,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceSoft,
                          borderRadius: AppRadius.control,
                        ),
                        child: Text(
                          ruta!,
                          style: AppTextStyles.captionMedium.copyWith(
                            color: AppColors.textMuted,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.xl),
                    AppButton.primary(
                      label: 'Volver al inicio',
                      expand: true,
                      onPressed: () => context.go(AppRoutes.dashboard),
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
