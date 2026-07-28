import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

/// Variantes de botón del frame 14 del diseño.
enum AppButtonVariant {
  /// Verde sistema, sombra proyectada. Acción principal de la pantalla.
  primary,

  /// Contorno verde sobre blanco.
  secondary,

  /// Contorno neutro sobre blanco.
  neutral,

  /// Rojo. Reservado al módulo de Negocios y a acciones destructivas.
  destructive,
}

/// Botón del design system.
///
/// Con `onPressed: null` adopta el aspecto «Deshabilitado» del diseño
/// (fondo `#F1F3F0`, texto `#B4B7B0`, borde neutro) sea cual sea la variante.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.icon,
    this.height = 46,
    this.expand = false,
  });

  const AppButton.primary({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.height = 46,
    this.expand = false,
  }) : variant = AppButtonVariant.primary;

  const AppButton.secondary({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.height = 46,
    this.expand = false,
  }) : variant = AppButtonVariant.secondary;

  const AppButton.neutral({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.height = 46,
    this.expand = false,
  }) : variant = AppButtonVariant.neutral;

  const AppButton.destructive({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.height = 46,
    this.expand = false,
  }) : variant = AppButtonVariant.destructive;

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final IconData? icon;
  final double height;

  /// Ocupa todo el ancho disponible (`width:100%` en el diseño).
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;

    late final Color background;
    late final Color foreground;
    late final BorderSide side;
    late final List<BoxShadow> shadow;

    if (!enabled) {
      background = AppColors.surfaceNeutral;
      foreground = AppColors.textDisabled;
      side = const BorderSide(color: AppColors.borderStrong);
      shadow = const [];
    } else {
      switch (variant) {
        case AppButtonVariant.primary:
          background = AppColors.primary;
          foreground = AppColors.textOnPrimary;
          side = BorderSide.none;
          shadow = AppColors.primaryButtonShadow;
        case AppButtonVariant.secondary:
          background = AppColors.surface;
          foreground = AppColors.primary;
          side = const BorderSide(color: AppColors.primary, width: 1.5);
          shadow = const [];
        case AppButtonVariant.neutral:
          background = AppColors.surface;
          foreground = AppColors.textPrimary;
          side = const BorderSide(color: AppColors.borderStrong);
          shadow = const [];
        case AppButtonVariant.destructive:
          background = AppColors.danger;
          foreground = AppColors.textOnPrimary;
          side = BorderSide.none;
          shadow = const [
            BoxShadow(
              color: Color(0x73E53935),
              blurRadius: 20,
              spreadRadius: -8,
              offset: Offset(0, 8),
            ),
          ];
      }
    }

    // El tamaño de la etiqueta acompaña al alto: 15px en botones de 46px,
    // 14px en los de 44px y 13px en los compactos de la barra de acciones.
    final labelStyle =
        (height >= 46
                ? AppTextStyles.bodyLargeStrong.copyWith(
                    fontWeight: FontWeight.w700,
                  )
                : height >= 44
                ? AppTextStyles.navActive
                : AppTextStyles.amount)
            .copyWith(color: foreground);

    final button = DecoratedBox(
      decoration: BoxDecoration(
        boxShadow: shadow,
        borderRadius: BorderRadius.circular(
          height >= 46 ? AppRadius.lg : AppRadius.md + 1,
        ),
      ),
      child: Material(
        color: background,
        borderRadius: BorderRadius.circular(
          height >= 46 ? AppRadius.lg : AppRadius.md + 1,
        ),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(
            height >= 46 ? AppRadius.lg : AppRadius.md + 1,
          ),
          mouseCursor: enabled
              ? SystemMouseCursors.click
              : SystemMouseCursors.forbidden,
          child: Container(
            height: height,
            padding: EdgeInsets.symmetric(
              horizontal: expand ? 0 : AppSpacing.lg,
            ),
            decoration: BoxDecoration(
              border: side == BorderSide.none
                  ? null
                  : Border.fromBorderSide(side),
              borderRadius: BorderRadius.circular(
                height >= 46 ? AppRadius.lg : AppRadius.md + 1,
              ),
            ),
            child: Row(
              mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 18, color: foreground),
                  const SizedBox(width: AppSpacing.sm),
                ],
                Flexible(
                  child: Text(
                    label,
                    style: labelStyle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    return expand ? SizedBox(width: double.infinity, child: button) : button;
  }
}

/// Botón compacto de fila y de cabecera (`height:40px`/`42px`) con etiqueta
/// coloreada sobre fondo blanco y borde neutro, como «Revisar», «Atender»,
/// «Ver perfil» o «Editar».
class AppTextActionButton extends StatelessWidget {
  const AppTextActionButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.color = AppColors.primary,
    this.height = AppSizes.controlHeightSmall,
  });

  final String label;
  final VoidCallback? onPressed;
  final Color color;
  final double height;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    return Material(
      color: enabled ? AppColors.surface : AppColors.surfaceNeutral,
      borderRadius: AppRadius.control,
      child: InkWell(
        onTap: onPressed,
        borderRadius: AppRadius.control,
        child: Container(
          height: height,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.borderStrong),
            borderRadius: AppRadius.control,
          ),
          child: Text(
            label,
            style: AppTextStyles.amount.copyWith(
              color: enabled ? color : AppColors.textDisabled,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}

/// Botón icónico cuadrado del app bar (notificaciones) y de las barras de
/// herramientas del mapa.
class AppIconButton extends StatelessWidget {
  const AppIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.showDot = false,
    this.size = AppSizes.controlHeightSmall,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;

  /// Punto rojo de «hay novedades sin leer».
  final bool showDot;
  final double size;

  @override
  Widget build(BuildContext context) {
    final button = Material(
      color: AppColors.surfaceSoft,
      borderRadius: AppRadius.control,
      child: InkWell(
        onTap: onPressed,
        borderRadius: AppRadius.control,
        child: SizedBox(
          width: size,
          height: size,
          child: Stack(
            children: [
              Center(child: Icon(icon, size: 20, color: AppColors.textPrimary)),
              if (showDot)
                Positioned(
                  top: 6,
                  right: 7,
                  child: Container(
                    width: 9,
                    height: 9,
                    decoration: BoxDecoration(
                      color: AppColors.notificationDot,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.surface, width: 2),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );

    return tooltip == null ? button : Tooltip(message: tooltip!, child: button);
  }
}
