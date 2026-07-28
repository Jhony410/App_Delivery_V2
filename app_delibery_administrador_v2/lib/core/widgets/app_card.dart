import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

/// Tarjeta base del panel: fondo blanco, borde `#EEF1EE`, radio 16 y la sombra
/// suave `0 3px 12px rgba(0,0,0,.05)`.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.cardPadding),
    this.borderColor = AppColors.border,
    this.onTap,
    this.borderRadius = AppRadius.card,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  /// El diseño tiñe el borde cuando la tarjeta comunica un estado
  /// (`#F0E0C0` atención, `#F6D5D1` crítico).
  final Color borderColor;
  final VoidCallback? onTap;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    final contenido = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: borderRadius,
        border: Border.all(color: borderColor),
      ),
      child: child,
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: AppColors.cardShadow,
      ),
      child: onTap == null
          ? contenido
          : Material(
              color: Colors.transparent,
              borderRadius: borderRadius,
              child: InkWell(
                onTap: onTap,
                borderRadius: borderRadius,
                child: contenido,
              ),
            ),
    );
  }
}

/// Tarjeta con un título y, opcionalmente, una acción a la derecha
/// («Ver todos →», «Ver mapa completo →»).
class AppSectionCard extends StatelessWidget {
  const AppSectionCard({
    super.key,
    required this.title,
    required this.child,
    this.subtitle,
    this.trailing,
    this.actionLabel,
    this.onAction,
    this.padding = const EdgeInsets.all(AppSpacing.cardPadding),
  });

  final String title;
  final Widget child;

  /// Línea de apoyo bajo el título («Pico: 13:00 – 14:00»).
  final String? subtitle;

  /// Contenido libre a la derecha del título (métrica, indicador en vivo).
  final Widget? trailing;

  final String? actionLabel;
  final VoidCallback? onAction;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.cardTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              ?trailing,
              if (actionLabel != null && onAction != null)
                _AccionEnlace(label: actionLabel!, onTap: onAction!),
            ],
          ),
          if (subtitle != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              subtitle!,
              style: AppTextStyles.label.copyWith(color: AppColors.textMuted),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          child,
        ],
      ),
    );
  }
}

class _AccionEnlace extends StatelessWidget {
  const _AccionEnlace({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        foregroundColor: AppColors.primary,
      ),
      child: Text(
        '$label →',
        style: AppTextStyles.labelBold.copyWith(color: AppColors.primary),
      ),
    );
  }
}

/// Tarjeta KPI del frame 14: rótulo, cifra grande, icono en cuadro de color y
/// una fila inferior de apoyo (variación o insignias).
class AppKpiCard extends StatelessWidget {
  const AppKpiCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.valueColor = AppColors.textPrimary,
    this.iconColor = AppColors.primary,
    this.iconBackground = AppColors.primarySoft,
    this.suffix,
    this.footer,
    this.onTap,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color valueColor;
  final Color iconColor;
  final Color iconBackground;

  /// Segunda parte de la cifra en gris («31 **/ 58**»).
  final String? suffix;

  /// Fila inferior: variación, insignias o texto de contexto.
  final Widget? footer;

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.cardPaddingTight),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: RichText(
                        text: TextSpan(
                          text: value,
                          style: AppTextStyles.kpiValue.copyWith(
                            color: valueColor,
                          ),
                          children: [
                            if (suffix != null)
                              TextSpan(
                                text: ' $suffix',
                                style: AppTextStyles.cardTitle.copyWith(
                                  color: AppColors.textMuted,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Container(
                width: AppSizes.avatarLg,
                height: AppSizes.avatarLg,
                decoration: BoxDecoration(
                  color: iconBackground,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
                child: Icon(icon, size: 22, color: iconColor),
              ),
            ],
          ),
          if (footer != null) ...[
            const SizedBox(height: AppSpacing.md),
            footer!,
          ],
        ],
      ),
    );
  }
}

/// Fila de variación de un KPI: flecha + porcentaje + comparativa.
class AppKpiTrend extends StatelessWidget {
  const AppKpiTrend({
    super.key,
    required this.text,
    this.positive = true,
    this.neutral = false,
  });

  final String text;
  final bool positive;

  /// Métricas donde subir no es bueno (tiempo de entrega) se pintan en gris.
  final bool neutral;

  @override
  Widget build(BuildContext context) {
    final color = neutral
        ? AppColors.textSecondary
        : positive
        ? AppColors.successText
        : AppColors.dangerText;
    return Row(
      children: [
        Icon(
          positive ? Icons.trending_up : Icons.trending_down,
          size: 14,
          color: color,
        ),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.labelStrong.copyWith(color: color),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

/// Punto verde que late para indicar «en vivo».
class AppLiveDot extends StatefulWidget {
  const AppLiveDot({super.key, this.size = 8, this.color = AppColors.success});

  final double size;
  final Color color;

  @override
  State<AppLiveDot> createState() => _AppLiveDotState();
}

class _AppLiveDotState extends State<AppLiveDot>
    with SingleTickerProviderStateMixin {
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
    return FadeTransition(
      opacity: Tween<double>(
        begin: 0.4,
        end: 0.9,
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut)),
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(color: widget.color, shape: BoxShape.circle),
      ),
    );
  }
}
