import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import 'buttons.dart';
import 'chasqui_logo.dart';

/// Plantilla común de los estados a pantalla completa: frames 22 (sin
/// internet), 23 (GPS desactivado) y 26 (error genérico).
///
/// Los tres comparten la misma composición —caja de ícono, título, texto,
/// acción— así que viven en un solo widget parametrizado. Nunca son rutas:
/// se montan como overlay encima de lo que ya está en pantalla.
class SystemStateView extends StatelessWidget {
  const SystemStateView({
    super.key,
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onAction,
    this.iconBackground = AppColors.fillStrong,
    this.iconColor = AppColors.neutral,
    this.icon,
    this.useChasquiMark = false,
    this.secondaryLabel,
    this.onSecondary,
  });

  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback onAction;
  final Color iconBackground;
  final Color iconColor;
  final IconData? icon;

  /// Frame 26 usa la silueta del chasqui en vez de un ícono de sistema.
  final bool useChasquiMark;

  final String? secondaryLabel;
  final VoidCallback? onSecondary;

  /// Frame 22 — sin conexión a internet.
  factory SystemStateView.noInternet({required VoidCallback onRetry}) => SystemStateView(
        icon: Icons.wifi_off_rounded,
        iconBackground: AppColors.dangerSoft,
        iconColor: AppColors.danger,
        title: 'Sin conexión a internet',
        message: 'Revisa tus datos móviles o el Wi-Fi. CHASQUI seguirá guardando tu pedido en curso.',
        actionLabel: 'Reintentar',
        onAction: onRetry,
      );

  /// Frame 23 — GPS desactivado.
  factory SystemStateView.gpsOff({required VoidCallback onEnable}) => SystemStateView(
        icon: Icons.location_off_rounded,
        iconBackground: AppColors.warningSoft,
        iconColor: AppColors.warning,
        title: 'Activa tu GPS',
        message: 'Sin ubicación no podemos asignarte pedidos ni guiarte por la ruta. Activa el GPS en alta precisión.',
        actionLabel: 'Activar ubicación',
        onAction: onEnable,
      );

  /// Frame 26 — error genérico.
  factory SystemStateView.genericError({
    required VoidCallback onRetry,
    required VoidCallback onHome,
    String? message,
  }) =>
      SystemStateView(
        useChasquiMark: true,
        iconBackground: AppColors.fillStrong,
        iconColor: AppColors.neutral,
        title: 'Algo salió mal',
        message: message ?? 'Nuestro chasqui tropezó. Vuelve a intentarlo en unos segundos.',
        actionLabel: 'Reintentar',
        onAction: onRetry,
        secondaryLabel: 'Volver al inicio',
        onSecondary: onHome,
      );

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.surface,
      child: SafeArea(
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
                        width: 100,
                        height: 100,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: iconBackground,
                          borderRadius: BorderRadius.circular(32),
                        ),
                        child: useChasquiMark
                            ? Opacity(
                                opacity: 0.6,
                                child: ChasquiLogo(size: 56, color: iconColor),
                              )
                            : Icon(icon, size: 50, color: iconColor),
                      ),
                    ),
                    const SizedBox(height: 26),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: AppText.display(24),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: AppText.body(14, height: 1.55),
                    ),
                    const SizedBox(height: 28),
                    PrimaryButton(label: actionLabel, onPressed: onAction),
                    if (secondaryLabel != null) ...[
                      const SizedBox(height: 12),
                      GhostButton(
                        label: secondaryLabel!,
                        onPressed: onSecondary,
                        color: AppColors.textSecondary,
                      ),
                    ],
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

/// Contenido del estado vacío (frame 25): vive dentro de la hoja del mapa,
/// no ocupa la pantalla entera.
class EmptyStateSheet extends StatelessWidget {
  const EmptyStateSheet({super.key, required this.onSeeHeatmap});

  final VoidCallback onSeeHeatmap;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Container(
            width: 120,
            height: 120,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: AppColors.primarySoft,
              shape: BoxShape.circle,
            ),
            child: const RunningChasqui(
              size: 64,
              color: AppColors.primary,
              duration: Duration(milliseconds: 1400),
            ),
          ),
        ),
        const SizedBox(height: 18),
        Text(
          'Sin pedidos cerca por ahora',
          textAlign: TextAlign.center,
          style: AppText.display(22),
        ),
        const SizedBox(height: 10),
        Text(
          'Quédate conectado —te avisamos apenas llegue uno. O muévete a una zona con más demanda.',
          textAlign: TextAlign.center,
          style: AppText.body(14, height: 1.55),
        ),
        const SizedBox(height: 22),
        OutlinedBrandButton(
          label: 'Ver mapa de demanda',
          icon: Icons.local_fire_department_rounded,
          onPressed: onSeeHeatmap,
        ),
      ],
    );
  }
}

/// Estado vacío compacto para listas (historial sin registros).
/// Frame 27 · "Estado vacío".
class EmptyStateCard extends StatelessWidget {
  const EmptyStateCard({
    super.key,
    this.title = 'Sin pedidos cerca',
    this.message = 'Te avisamos apenas llegue uno',
  });

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.rCard),
        border: Border.all(color: AppColors.borderSoft),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: AppColors.primarySoft,
              shape: BoxShape.circle,
            ),
            child: const ChasquiLogo(size: 34, color: AppColors.primary),
          ),
          const SizedBox(height: 12),
          Text(title, textAlign: TextAlign.center, style: AppText.display(15, weight: FontWeight.w700)),
          const SizedBox(height: 5),
          Text(message, textAlign: TextAlign.center, style: AppText.body(12)),
        ],
      ),
    );
  }
}
