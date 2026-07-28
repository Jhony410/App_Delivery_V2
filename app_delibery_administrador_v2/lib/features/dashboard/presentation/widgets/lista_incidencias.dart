import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_avatar.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_dialogs.dart';
import '../../../negocios/data/models/negocio.dart';

/// Colores e icono de cada severidad, según el diseño.
extension SeveridadEstilo on SeveridadIncidencia {
  Color get color => switch (this) {
    SeveridadIncidencia.critica => AppColors.dangerText,
    SeveridadIncidencia.atencion => AppColors.warning,
    SeveridadIncidencia.reclamo => AppColors.highlight,
  };

  Color get fondo => switch (this) {
    SeveridadIncidencia.critica => AppColors.dangerSoft,
    SeveridadIncidencia.atencion => AppColors.warningSoft,
    SeveridadIncidencia.reclamo => AppColors.highlightSoft,
  };

  IconData get icono => switch (this) {
    SeveridadIncidencia.critica => Icons.warning_amber_rounded,
    SeveridadIncidencia.atencion => Icons.schedule,
    SeveridadIncidencia.reclamo => Icons.chat_bubble_outline,
  };
}

/// Tarjeta «Incidencias recientes» del dashboard.
///
/// Cada fila lleva al lugar donde se resuelve: al soporte del negocio si la
/// incidencia tiene negocio, o al detalle del pedido en caso contrario.
class ListaIncidencias extends StatelessWidget {
  const ListaIncidencias({super.key, required this.incidencias});

  final List<Incidencia> incidencias;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.cardPaddingTight,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Incidencias recientes', style: AppTextStyles.cardTitle),
          const SizedBox(height: AppSpacing.md),
          if (incidencias.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              child: Text(
                'No hay incidencias abiertas en este momento.',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            )
          else
            for (var i = 0; i < incidencias.length; i++) ...[
              if (i > 0) const SizedBox(height: AppSpacing.sm),
              _FilaIncidencia(incidencia: incidencias[i]),
            ],
        ],
      ),
    );
  }
}

class _FilaIncidencia extends StatelessWidget {
  const _FilaIncidencia({required this.incidencia});

  final Incidencia incidencia;

  void _abrir(BuildContext context) {
    final negocioId = incidencia.negocioId;
    if (negocioId != null) {
      context.go(AppRoutes.aSoporteNegocio(negocioId));
      return;
    }
    final pedidoId = incidencia.pedidoId;
    if (pedidoId != null) {
      context.go(AppRoutes.aDetallePedido(pedidoId));
      return;
    }
    mostrarAviso(context, 'Esta incidencia no tiene un pedido asociado.');
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _abrir(context),
      borderRadius: AppRadius.control,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            AppIconTile(
              icon: incidencia.severidad.icono,
              color: incidencia.severidad.color,
              background: incidencia.severidad.fondo,
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    incidencia.titulo,
                    style: AppTextStyles.bodySmallStrong,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    incidencia.detalle,
                    style: AppTextStyles.captionSmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              size: 18,
              color: AppColors.textMuted,
            ),
          ],
        ),
      ),
    );
  }
}
