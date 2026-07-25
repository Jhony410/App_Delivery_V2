import 'package:flutter/material.dart';

import '../data/models.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

/// Píldora de estado del pedido. Frame 27 · "Chips de estado · 11 estados".
class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.status})
      : label = null,
        foreground = null,
        background = null;

  /// Píldora con texto libre, para etiquetas del lote multi-pedido
  /// ("RECOGER", "EN COLA") que no son un [OrderStatus] completo.
  const StatusChip.custom({
    super.key,
    required this.label,
    required this.foreground,
    required this.background,
  }) : status = null;

  final OrderStatus? status;
  final String? label;
  final Color? foreground;
  final Color? background;

  String get _text => status?.label ?? label ?? '';
  Color get _fg => status?.foreground ?? foreground ?? AppColors.textSecondary;
  Color get _bg => status?.background ?? background ?? AppColors.fillStrong;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(_text, style: AppText.chip(_fg)),
    );
  }
}

/// Insignia de disponibilidad. Frame 27 · "Disponibilidad".
class AvailabilityBadge extends StatelessWidget {
  const AvailabilityBadge({super.key, required this.online});

  final bool online;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
      decoration: BoxDecoration(
        color: online ? AppColors.primarySoft : AppColors.fillStrong,
        borderRadius: BorderRadius.circular(AppTheme.rPill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 11,
            height: 11,
            decoration: BoxDecoration(
              color: online ? AppColors.online : AppColors.neutral,
              shape: BoxShape.circle,
              boxShadow: online
                  ? [BoxShadow(color: AppColors.online.withValues(alpha: 0.2), spreadRadius: 4)]
                  : null,
            ),
          ),
          const SizedBox(width: 9),
          Text(
            online ? 'Conectado' : 'Desconectado',
            style: AppText.display(
              14,
              weight: FontWeight.w700,
              color: online ? AppColors.primaryOnSoft : AppColors.neutral,
            ),
          ),
        ],
      ),
    );
  }
}

/// Interruptor conectado/desconectado del diseño (56×32, pastilla blanca).
/// Frame 27 · "Disponibilidad" y cabecera del frame 06.
class ChasquiSwitch extends StatelessWidget {
  const ChasquiSwitch({super.key, required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      toggled: value,
      label: 'Conectarse para recibir pedidos',
      child: GestureDetector(
        onTap: onChanged == null ? null : () => onChanged!(!value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          width: 56,
          height: 32,
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: value ? AppColors.primary : AppColors.trackOff,
            borderRadius: BorderRadius.circular(20),
          ),
          child: AnimatedAlign(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            alignment: value ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              width: 26,
              height: 26,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: Color(0x40000000), blurRadius: 5, offset: Offset(0, 2)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Avatar circular con inicial y punto de presencia opcional.
/// Se repite en la cabecera del mapa, el drawer y el perfil.
class RiderAvatar extends StatelessWidget {
  const RiderAvatar({
    super.key,
    required this.initials,
    this.size = 44,
    this.online,
    this.ringColor = Colors.white,
    this.muted = false,
  });

  final String initials;
  final double size;

  /// `null` oculta el punto de presencia.
  final bool? online;
  final Color ringColor;

  /// Versión en gris para el estado desconectado (frame 21).
  final bool muted;

  @override
  Widget build(BuildContext context) {
    final dot = size * 0.3;
    return SizedBox.square(
      dimension: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: size,
            height: size,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: muted ? null : AppColors.brandGradient,
              color: muted ? AppColors.trackOff : null,
              shape: BoxShape.circle,
            ),
            child: Text(
              initials,
              style: AppText.display(
                size * 0.36,
                weight: FontWeight.w700,
                color: muted ? AppColors.neutral : Colors.white,
              ),
            ),
          ),
          if (online != null)
            Positioned(
              right: -1,
              bottom: -1,
              child: Container(
                width: dot,
                height: dot,
                decoration: BoxDecoration(
                  color: online! ? AppColors.online : AppColors.neutral,
                  shape: BoxShape.circle,
                  border: Border.all(color: ringColor, width: 2.5),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Píldora de calificación con estrella ("4.9 · Chasqui Oro").
class RatingPill extends StatelessWidget {
  const RatingPill({
    super.key,
    required this.label,
    this.background = const Color(0x26FFFFFF),
    this.foreground = Colors.white,
  });

  final String label;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, size: 14, color: AppColors.star),
          const SizedBox(width: 5),
          Text(label, style: AppText.display(12, weight: FontWeight.w700, color: foreground)),
        ],
      ),
    );
  }
}
