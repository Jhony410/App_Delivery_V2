import 'package:flutter/material.dart';

import '../models/estado_pedido.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

/// Tonos de insignia del diseño: ok · atención · crítico · destacado, más el
/// neutro y las dos variantes sólidas.
enum AppBadgeTone {
  /// Gris `#F1F3F0` — pendiente, buscando repartidor.
  neutral,

  /// Verde claro `#E6F4EC` — aceptado, recogido, abierto.
  ok,

  /// Verde sólido `#0E7A4F` — en camino, filtro activo.
  okStrong,

  /// Verde éxito `#E8F7EE` — entregado, pagado.
  success,

  /// Ámbar profundo `#FFF6E0` — preparando.
  amberDeep,

  /// Ámbar `#FBEFD9` — listo, documentos por verificar.
  amber,

  /// Rojo `#FDECEA` — cancelado, problema, bloqueado.
  danger,

  /// Rojo sólido `#E53935` — incidencia abierta.
  dangerStrong,

  /// Morado `#EEE8FA` — multi-pedido, destacado.
  highlight,
}

extension AppBadgeToneColors on AppBadgeTone {
  Color get background => switch (this) {
    AppBadgeTone.neutral => AppColors.surfaceNeutral,
    AppBadgeTone.ok => AppColors.primarySoft,
    AppBadgeTone.okStrong => AppColors.primary,
    AppBadgeTone.success => AppColors.successSoft,
    AppBadgeTone.amberDeep => AppColors.warningDeepSoft,
    AppBadgeTone.amber => AppColors.warningSoft,
    AppBadgeTone.danger => AppColors.dangerSoft,
    AppBadgeTone.dangerStrong => AppColors.danger,
    AppBadgeTone.highlight => AppColors.highlightSoft,
  };

  Color get foreground => switch (this) {
    AppBadgeTone.neutral => AppColors.textSecondary,
    AppBadgeTone.ok => AppColors.primaryDark,
    AppBadgeTone.okStrong => AppColors.textOnPrimary,
    AppBadgeTone.success => AppColors.successText,
    AppBadgeTone.amberDeep => AppColors.warningDeep,
    AppBadgeTone.amber => AppColors.warning,
    AppBadgeTone.danger => AppColors.dangerText,
    AppBadgeTone.dangerStrong => AppColors.textOnPrimary,
    AppBadgeTone.highlight => AppColors.highlight,
  };

  Color? get borderColor => switch (this) {
    AppBadgeTone.ok => AppColors.primarySoftBorder,
    AppBadgeTone.amber => AppColors.warningSoftBorder,
    AppBadgeTone.danger => AppColors.dangerSoftBorder,
    AppBadgeTone.highlight => AppColors.highlightSoftBorder,
    _ => null,
  };
}

/// Insignia en píldora del diseño (`font:700 10px Inter`, mayúsculas,
/// `border-radius:20px`).
class AppBadge extends StatelessWidget {
  const AppBadge({
    super.key,
    required this.label,
    this.tone = AppBadgeTone.neutral,
    this.icon,
    this.showBorder = false,
    this.dense = false,
  });

  /// Insignia del estado de un pedido, con el tono que fija el frame 14.
  AppBadge.pedido(
    EstadoPedido estado, {
    super.key,
    bool corta = false,
    this.showBorder = false,
    this.dense = false,
  }) : label = corta ? estado.etiquetaCorta : estado.etiqueta,
       tone = _tonoDePedido(estado),
       icon = estado == EstadoPedido.entregado ? Icons.check_circle : null;

  final String label;
  final AppBadgeTone tone;
  final IconData? icon;
  final bool showBorder;

  /// Relleno reducido para usarla dentro de una celda de tabla.
  final bool dense;

  static AppBadgeTone _tonoDePedido(EstadoPedido estado) => switch (estado) {
    EstadoPedido.pendiente ||
    EstadoPedido.buscandoRepartidor => AppBadgeTone.neutral,
    EstadoPedido.aceptado || EstadoPedido.recogido => AppBadgeTone.ok,
    EstadoPedido.preparando => AppBadgeTone.amberDeep,
    EstadoPedido.listo => AppBadgeTone.amber,
    EstadoPedido.enCamino => AppBadgeTone.okStrong,
    EstadoPedido.entregado => AppBadgeTone.success,
    EstadoPedido.cancelado || EstadoPedido.problema => AppBadgeTone.danger,
    EstadoPedido.multiPedido => AppBadgeTone.highlight,
  };

  @override
  Widget build(BuildContext context) {
    final border = showBorder ? tone.borderColor : null;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: dense ? 9 : 13,
        vertical: dense ? 5 : 7,
      ),
      decoration: BoxDecoration(
        color: tone.background,
        borderRadius: AppRadius.chip,
        border: border == null ? null : Border.all(color: border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: tone.foreground),
            const SizedBox(width: 5),
          ],
          Flexible(
            child: Text(
              label,
              style: AppTextStyles.badge.copyWith(
                color: tone.foreground,
                letterSpacing: 0.5,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

/// Contador en píldora del ítem de navegación (`font:700 11px Inter`).
class AppCounterBadge extends StatelessWidget {
  const AppCounterBadge({
    super.key,
    required this.value,
    this.tone = AppBadgeTone.okStrong,
  });

  final int value;
  final AppBadgeTone tone;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: tone.background,
        borderRadius: AppRadius.chip,
      ),
      child: Text(
        '$value',
        style: AppTextStyles.counter.copyWith(color: tone.foreground),
      ),
    );
  }
}

/// Chip de filtro (`padding:8px 14px`, `border-radius:20px`). El activo va en
/// verde sólido; el inactivo, blanco con borde neutro.
class AppFilterChip extends StatelessWidget {
  const AppFilterChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.count,
    this.tone,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  /// Se muestra tras el rótulo como «Preparando · 18».
  final int? count;

  /// Tono del chip inactivo. Por defecto, blanco con borde neutro.
  final AppBadgeTone? tone;

  @override
  Widget build(BuildContext context) {
    final texto = count == null ? label : '$label · $count';

    final Color background;
    final Color foreground;
    final Color? borderColor;

    if (selected) {
      background = AppColors.primary;
      foreground = AppColors.textOnPrimary;
      borderColor = null;
    } else if (tone != null) {
      background = tone!.background;
      foreground = tone!.foreground;
      borderColor = tone!.borderColor ?? AppColors.borderStrong;
    } else {
      background = AppColors.surface;
      foreground = AppColors.textSecondary;
      borderColor = AppColors.borderStrong;
    }

    return Material(
      color: background,
      borderRadius: AppRadius.chip,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.chip,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            borderRadius: AppRadius.chip,
            border: borderColor == null ? null : Border.all(color: borderColor),
          ),
          child: Text(
            texto,
            style:
                (selected ? AppTextStyles.labelBold : AppTextStyles.labelStrong)
                    .copyWith(color: foreground),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}
