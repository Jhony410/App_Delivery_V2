import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_avatar.dart';
import '../../../../core/widgets/app_badge.dart';
import '../../../../core/widgets/app_buttons.dart';
import '../../../../core/widgets/app_dialogs.dart';
import '../../../../core/widgets/app_mapa.dart';
import '../../data/models/pedido.dart';
import '../../providers/pedidos_provider.dart';

/// Panel de detalle del frame 02: mapa con la ruta, negocio y cliente,
/// productos, repartidor asignado, historial y acciones.
class PanelDetallePedido extends StatelessWidget {
  const PanelDetallePedido({
    super.key,
    required this.pedido,
    this.mostrarBotonAtras = false,
  });

  final Pedido pedido;

  /// En pantallas estrechas el panel es una pantalla completa y necesita su
  /// propio botón de retroceso.
  final bool mostrarBotonAtras;

  Future<void> _cancelar(BuildContext context) async {
    final motivo = await mostrarConfirmacion(
      context,
      titulo: '¿Cancelar el pedido ${pedido.id}?',
      mensaje:
          'Se avisará al cliente y al negocio. La cancelación no se puede '
          'deshacer desde el panel.',
      etiquetaConfirmar: 'Cancelar pedido',
      etiquetaCancelar: 'Volver',
      pedirMotivo: true,
      motivoHint: 'Motivo de la cancelación…',
    );
    if (motivo == null || !context.mounted) return;

    final ok = await context.read<PedidosProvider>().cancelar(
      pedidoId: pedido.id,
      motivo: motivo,
    );
    if (!context.mounted) return;
    mostrarAviso(
      context,
      ok
          ? 'Pedido ${pedido.id} cancelado. Se notificó al cliente y al negocio.'
          : context.read<PedidosProvider>().error ??
                'No se pudo cancelar el pedido.',
      exito: ok,
    );
  }

  @override
  Widget build(BuildContext context) {
    final puedeReasignar = pedido.estado.admiteReasignacion;
    final puedeCancelar = pedido.estado.estaActivo;

    return Container(
      width: AppSizes.detailPanelWidth,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(left: BorderSide(color: AppColors.borderStrong)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(22, 22, 22, AppSpacing.xxl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (mostrarBotonAtras)
                  Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.sm),
                    child: IconButton(
                      tooltip: 'Volver a pedidos',
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => context.go(AppRoutes.pedidos),
                    ),
                  ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        pedido.id,
                        style: AppTextStyles.panelTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Hoy ${pedido.hora} · ${pedido.negocio}',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                AppBadge.pedido(pedido.estado),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            AppMapaCanvas(
              alto: 170,
              marcadores: [
                MarcadorMapa(
                  x: 0.22,
                  y: 0.76,
                  tipo: pedido.tieneRepartidor
                      ? TipoMarcador.repartidor
                      : TipoMarcador.problema,
                  pulsante: pedido.tieneRepartidor,
                  etiqueta: pedido.repartidor ?? 'Sin repartidor asignado',
                ),
                MarcadorMapa(
                  x: 0.7,
                  y: 0.31,
                  tipo: TipoMarcador.negocio,
                  etiqueta: pedido.negocio,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            _Extremo(
              icono: Icons.storefront_outlined,
              color: AppColors.primary,
              fondo: AppColors.primarySoft,
              titulo: pedido.negocio,
              subtitulo: pedido.negocioDireccion,
            ),
            const SizedBox(height: AppSpacing.md),
            _Extremo(
              icono: Icons.person_outline,
              color: AppColors.warning,
              fondo: AppColors.warningSoft,
              titulo: pedido.cliente,
              subtitulo: pedido.clienteDireccion,
            ),
            const SizedBox(height: AppSpacing.xl),
            if (pedido.items.isNotEmpty) ...[
              for (final item in pedido.items)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${item.cantidad} × ${item.nombre}',
                          style: AppTextStyles.bodySmall,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        'S/ ${item.precio.toStringAsFixed(2)}',
                        style: AppTextStyles.bodySmallStrong,
                      ),
                    ],
                  ),
                ),
              const Divider(height: AppSpacing.lg),
              Row(
                children: [
                  Expanded(
                    child: Text('Total', style: AppTextStyles.cardTitleSmall),
                  ),
                  Text(
                    pedido.monto == null
                        ? '—'
                        : 'S/ ${pedido.monto!.toStringAsFixed(2)}',
                    style: AppTextStyles.cardTitleSmall.copyWith(
                      color: pedido.monto == null
                          ? AppColors.textMuted
                          : AppColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
            _BloqueRepartidor(pedido: pedido, puedeReasignar: puedeReasignar),
            const SizedBox(height: AppSpacing.xl),
            Text('Historial', style: AppTextStyles.cardTitle),
            const SizedBox(height: AppSpacing.md),
            if (pedido.historial.isEmpty)
              Text(
                'Todavía no hay hitos registrados para este pedido.',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              )
            else
              for (var i = 0; i < pedido.historial.length; i++)
                _HitoHistorial(
                  evento: pedido.historial[i],
                  ultimo: i == pedido.historial.length - 1,
                ),
            const SizedBox(height: AppSpacing.xl),
            Row(
              children: [
                Expanded(
                  child: AppButton.neutral(
                    label: 'Chat',
                    expand: true,
                    height: 44,
                    icon: Icons.chat_bubble_outline,
                    onPressed: () => mostrarAviso(
                      context,
                      'Chat con ${pedido.cliente} y ${pedido.negocio} '
                      'abierto para ${pedido.id}.',
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm + 2),
                Expanded(
                  child: AppButton.destructive(
                    label: 'Cancelar pedido',
                    expand: true,
                    height: 44,
                    onPressed: puedeCancelar ? () => _cancelar(context) : null,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Extremo extends StatelessWidget {
  const _Extremo({
    required this.icono,
    required this.color,
    required this.fondo,
    required this.titulo,
    required this.subtitulo,
  });

  final IconData icono;
  final Color color;
  final Color fondo;
  final String titulo;
  final String subtitulo;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AppIconTile(icon: icono, color: color, background: fondo),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                titulo,
                style: AppTextStyles.bodySmallStrong,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                subtitulo,
                style: AppTextStyles.captionSmall.copyWith(
                  color: AppColors.textSecondary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _BloqueRepartidor extends StatelessWidget {
  const _BloqueRepartidor({required this.pedido, required this.puedeReasignar});

  final Pedido pedido;
  final bool puedeReasignar;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(13),
      ),
      child: Row(
        children: [
          if (pedido.tieneRepartidor)
            AppAvatar(nombre: pedido.repartidor!, online: true)
          else
            const AppIconTile(
              icon: Icons.person_search_outlined,
              color: AppColors.textMuted,
              background: AppColors.surfaceNeutral,
              size: AppSizes.avatarMd,
            ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  pedido.repartidor ?? 'Sin asignar',
                  style: AppTextStyles.bodySmallStrong.copyWith(
                    color: pedido.tieneRepartidor
                        ? AppColors.textPrimary
                        : AppColors.textMuted,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  _detalle(),
                  style: AppTextStyles.captionSmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          AppTextActionButton(
            label: pedido.tieneRepartidor ? 'Reasignar' : 'Asignar',
            onPressed: puedeReasignar
                ? () => context.push(AppRoutes.aReasignar(pedido.id))
                : null,
          ),
        ],
      ),
    );
  }

  String _detalle() {
    if (!pedido.tieneRepartidor) return 'Buscando repartidor en la zona';
    final calificacion = pedido.repartidorCalificacion;
    final distancia = pedido.repartidorDistanciaKm;
    final partes = <String>[
      if (calificacion != null) '★ ${calificacion.toStringAsFixed(1)}',
      if (distancia != null) '${distancia.toStringAsFixed(1)} km',
    ];
    return partes.isEmpty ? 'Asignado' : partes.join(' · ');
  }
}

class _HitoHistorial extends StatelessWidget {
  const _HitoHistorial({required this.evento, required this.ultimo});

  final EventoPedido evento;
  final bool ultimo;

  @override
  Widget build(BuildContext context) {
    final color = evento.enCurso ? AppColors.primary : AppColors.primarySoft;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 11,
                height: 11,
                margin: const EdgeInsets.only(top: 4),
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primary, width: 2),
                ),
              ),
              if (!ultimo)
                Expanded(child: Container(width: 2, color: AppColors.border)),
            ],
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: ultimo ? 0 : AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    evento.titulo,
                    style: AppTextStyles.bodySmallStrong,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '${evento.hora} · ${evento.origen}',
                    style: AppTextStyles.captionSmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
