import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_avatar.dart';
import '../../../../core/widgets/app_buttons.dart';
import '../../../../core/widgets/app_card.dart';

/// Tarjeta de acción del dashboard: cifra grande, título, descripción y un
/// botón que lleva al módulo donde se resuelve.
class TarjetaAccion extends StatelessWidget {
  const TarjetaAccion({
    super.key,
    required this.valor,
    required this.titulo,
    required this.descripcion,
    required this.icono,
    required this.color,
    required this.fondoIcono,
    required this.colorBorde,
    required this.etiquetaAccion,
    required this.onAccion,
  });

  final String valor;
  final String titulo;
  final String descripcion;
  final IconData icono;
  final Color color;
  final Color fondoIcono;
  final Color colorBorde;
  final String etiquetaAccion;
  final VoidCallback onAccion;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      borderColor: colorBorde,
      padding: const EdgeInsets.all(AppSpacing.cardPaddingTight),
      child: Row(
        children: [
          AppIconTile(
            icon: icono,
            color: color,
            background: fondoIcono,
            size: AppSizes.avatarXl,
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  valor,
                  style: AppTextStyles.actionValue.copyWith(color: color),
                  maxLines: 1,
                ),
                const SizedBox(height: 4),
                Text(
                  titulo,
                  style: AppTextStyles.bodyStrong,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  descripcion,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          AppTextActionButton(
            label: etiquetaAccion,
            color: color,
            onPressed: onAccion,
          ),
        ],
      ),
    );
  }
}
