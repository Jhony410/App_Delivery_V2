import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

/// Encabezado de sección: título en Poppins + enlace opcional "Ver todo".
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: AppText.title),
        if (actionLabel != null)
          GestureDetector(
            onTap: onAction,
            child: Text(actionLabel!, style: AppText.link),
          ),
      ],
    );
  }
}

/// Insignia de estado (EN CAMINO, ENTREGADO, ENVÍO GRATIS...).
class StatusBadge extends StatelessWidget {
  const StatusBadge({
    super.key,
    required this.label,
    required this.color,
    required this.background,
    this.icon,
  });

  final String label;
  final Color color;
  final Color background;
  final IconData? icon;

  factory StatusBadge.enRoute() => const StatusBadge(
        label: 'EN CAMINO',
        color: AppColors.primaryDark,
        background: AppColors.greenLight,
      );

  factory StatusBadge.delivered() => const StatusBadge(
        label: 'ENTREGADO',
        color: AppColors.successDark,
        background: Color(0xFFE8F7EE),
        icon: Icons.check,
      );

  factory StatusBadge.freeShipping() => const StatusBadge(
        label: 'ENVÍO GRATIS',
        color: Colors.white,
        background: AppColors.success,
      );

  factory StatusBadge.unavailable() => const StatusBadge(
        label: 'NO DISPONIBLE',
        color: Color(0xFFC0503F),
        background: AppColors.dangerBg,
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 11, color: color),
            const SizedBox(width: 4),
          ],
          Text(label, style: AppText.badge.copyWith(color: color)),
        ],
      ),
    );
  }
}

/// Fila de estrella + rating usada en tarjetas.
class RatingPill extends StatelessWidget {
  const RatingPill({super.key, required this.rating, this.trailing});

  final double rating;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.star, size: 13, color: AppColors.star),
        const SizedBox(width: 3),
        Text(
          rating.toString(),
          style: AppText.small.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: 10),
          Text(trailing!, style: AppText.small),
        ],
      ],
    );
  }
}

/// Botón secundario (borde verde, fondo blanco). Complementa el ElevatedButton
/// primario definido en el tema.
class SecondaryButton extends StatelessWidget {
  const SecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: icon != null
          ? Icon(icon, size: 16, color: AppColors.primaryDark)
          : const SizedBox.shrink(),
      label: Text(label),
    );
  }
}

/// Círculo con ícono, usado como avatar/leading de filas de opciones.
class IconBadge extends StatelessWidget {
  const IconBadge({
    super.key,
    required this.icon,
    this.background = AppColors.greenLight,
    this.iconColor = AppColors.primary,
    this.size = 40,
    this.radius,
  });

  final IconData icon;
  final Color background;
  final Color iconColor;
  final double size;
  final double? radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(radius ?? size / 2),
      ),
      child: Icon(icon, color: iconColor, size: size * 0.48),
    );
  }
}
