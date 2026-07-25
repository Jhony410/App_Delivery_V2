import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../router/app_routes.dart';
import '../../state/app_state_scope.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../widgets/buttons.dart';
import '../../widgets/map_backdrop.dart';

/// Frame 04 — Permisos de ubicación.
///
/// CHASQUI necesita la ubicación "siempre". Conceder avanza al alta de
/// documentos; "Ahora no" también avanza, pero deja el GPS apagado y el
/// frame 23 se disparará solo al intentar conectarse.
class LocationPermissionScreen extends StatelessWidget {
  const LocationPermissionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const MapBackdrop(),

          // Marcador de ubicación pulsante en el tercio superior.
          const Align(
            alignment: Alignment(0, -0.55),
            child: _LocationPin(),
          ),

          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                boxShadow: AppTheme.sheetShadow,
              ),
              child: SafeArea(
                top: false,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(26, 20, 26, 30),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 5,
                          decoration: BoxDecoration(
                            color: AppColors.handle,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Activa tu ubicación',
                        textAlign: TextAlign.center,
                        style: AppText.display(23, letterSpacing: -0.3),
                      ),
                      const SizedBox(height: 10),
                      Text.rich(
                        TextSpan(
                          style: AppText.body(14, height: 1.55),
                          children: [
                            const TextSpan(text: 'CHASQUI necesita tu ubicación '),
                            TextSpan(
                              text: 'siempre',
                              style: AppText.body(14, weight: FontWeight.w700, color: AppColors.textPrimary),
                            ),
                            const TextSpan(
                              text: ' —incluso en segundo plano— para asignarte pedidos cercanos '
                                  'y guiar al cliente hasta tu moto.',
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),

                      const _Benefit(
                        icon: Icons.access_time_rounded,
                        label: 'Recibe pedidos apenas te conectas',
                      ),
                      const SizedBox(height: 12),
                      const _Benefit(
                        icon: Icons.near_me_rounded,
                        label: 'Navegación exacta al restaurante y cliente',
                      ),
                      const SizedBox(height: 26),

                      PrimaryButton(
                        label: 'Permitir ubicación',
                        onPressed: () {
                          state.grantLocation();
                          context.go(AppRoutes.documentVerification);
                        },
                      ),
                      const SizedBox(height: 6),
                      GhostButton(
                        label: 'Ahora no',
                        onPressed: () {
                          state.skipLocation();
                          context.go(AppRoutes.documentVerification);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Benefit extends StatelessWidget {
  const _Benefit({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
      decoration: BoxDecoration(
        color: AppColors.fill,
        borderRadius: BorderRadius.circular(AppTheme.rField),
      ),
      child: Row(
        children: [
          Icon(icon, size: 22, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: AppText.body(13, weight: FontWeight.w600, color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}

/// Punto de ubicación con halo pulsante (`@keyframes chq-pulse`).
class _LocationPin extends StatefulWidget {
  const _LocationPin();

  @override
  State<_LocationPin> createState() => _LocationPinState();
}

class _LocationPinState extends State<_LocationPin> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 2),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 96,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              final t = Curves.easeInOut.transform(_controller.value);
              return Transform.scale(
                scale: 1 + 0.12 * t,
                child: Opacity(
                  opacity: 0.85 - 0.45 * t,
                  child: Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.18),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              );
            },
          ),
          Container(
            width: 64,
            height: 64,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 4),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.6),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                  spreadRadius: -6,
                ),
              ],
            ),
            child: const Icon(Icons.location_on_rounded, size: 30, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
