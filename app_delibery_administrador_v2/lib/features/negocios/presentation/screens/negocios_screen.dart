import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/models/estado_negocio.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/admin_screen.dart';
import '../../../../core/widgets/admin_shell.dart';
import '../../../../core/widgets/app_avatar.dart';
import '../../../../core/widgets/app_badge.dart';
import '../../../../core/widgets/app_buttons.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_dialogs.dart';
import '../../../../core/widgets/app_table.dart';
import '../../../../core/widgets/vista_async.dart';
import '../../../auth/providers/sesion_provider.dart';
import '../../data/models/negocio.dart';
import '../../providers/negocios_provider.dart';
import '../widgets/hoja_registrar_negocio.dart';

/// Tono de la insignia de estado de un negocio.
AppBadgeTone tonoDeNegocio(EstadoNegocio estado) => switch (estado) {
  EstadoNegocio.abierto => AppBadgeTone.ok,
  EstadoNegocio.cerrado => AppBadgeTone.neutral,
  EstadoNegocio.retrasos => AppBadgeTone.danger,
};

/// Frame 07 · Negocios.
///
/// Único módulo del panel con acento rojo, como fija la identidad del diseño.
class NegociosScreen extends StatefulWidget {
  const NegociosScreen({super.key});

  @override
  State<NegociosScreen> createState() => _NegociosScreenState();
}

class _NegociosScreenState extends State<NegociosScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<NegociosProvider>().cargar();
    });
  }

  @override
  Widget build(BuildContext context) {
    final sesion = context.watch<SesionProvider>();
    final provider = context.watch<NegociosProvider>();

    return AdminScreen(
      titulo: 'Negocios',
      nombreOperador: sesion.nombre,
      rolOperador: sesion.rol,
      hintBusqueda: 'Buscar negocio…',
      onBuscar: provider.buscar,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AdminPageHeader(
            migaDePan: 'Inicio / Negocios',
            titulo: 'Negocios',
            acciones: [
              AppButton.destructive(
                label: '+ Registrar negocio',
                height: AppSizes.controlHeight,
                onPressed: () => mostrarHoja<void>(
                  context,
                  builder: (_) =>
                      ChangeNotifierProvider<NegociosProvider>.value(
                        value: provider,
                        child: const HojaRegistrarNegocio(),
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          VistaAsync(
            cargando: provider.cargando,
            error: provider.error,
            vacio: provider.negociosVisibles.isEmpty,
            onReintentar: () => provider.cargar(forzar: true),
            tituloVacio: 'Ningún negocio coincide',
            mensajeVacio: 'Prueba con otro texto en el buscador.',
            iconoVacio: Icons.storefront_outlined,
            accionVacio: 'Ver todos',
            onAccionVacio: () => provider.buscar(''),
            skeletons: 3,
            builder: (context) => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AdminGrid(
                  anchoMinimo: 220,
                  children: [
                    _MiniKpiNegocio(
                      titulo: 'Abiertos ahora',
                      valor: '${provider.abiertos}',
                      color: AppColors.primary,
                    ),
                    _MiniKpiNegocio(
                      titulo: 'Total registrados',
                      valor: '${provider.negocios.length}',
                    ),
                    _MiniKpiNegocio(
                      titulo: 'Con incidencias',
                      valor: '${provider.conIncidencias}',
                      color: AppColors.dangerText,
                    ),
                    _MiniKpiNegocio(
                      titulo: 'Comisión promedio',
                      valor: '${provider.comisionPromedio}%',
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.gridGap),
                for (final negocio in provider.destacados) ...[
                  _TarjetaNegocio(negocio: negocio),
                  const SizedBox(height: AppSpacing.md),
                ],
                if (provider.resto.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.xs),
                  _TablaNegocios(negocios: provider.resto),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniKpiNegocio extends StatelessWidget {
  const _MiniKpiNegocio({
    required this.titulo,
    required this.valor,
    this.color = AppColors.textPrimary,
  });

  final String titulo;
  final String valor;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.cardPaddingTight),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            titulo,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            valor,
            style: AppTextStyles.pageTitle.copyWith(color: color),
            maxLines: 1,
          ),
        ],
      ),
    );
  }
}

class _TarjetaNegocio extends StatelessWidget {
  const _TarjetaNegocio({required this.negocio});

  final Negocio negocio;

  @override
  Widget build(BuildContext context) {
    final conIncidencias = negocio.tieneIncidencias;

    return AppCard(
      borderColor: conIncidencias
          ? AppColors.dangerSoftBorder
          : AppColors.border,
      onTap: () => context.go(AppRoutes.aSoporteNegocio(negocio.id)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (conIncidencias) ...[
            AppBadge(
              label: 'INCIDENCIA',
              tone: AppBadgeTone.dangerStrong,
              dense: true,
            ),
            const SizedBox(height: AppSpacing.md),
          ],
          LayoutBuilder(
            builder: (context, constraints) {
              final compacta =
                  constraints.maxWidth < AppSizes.compactBreakpoint;
              final identidad = Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppEmojiTile(emoji: negocio.emoji),
                  const SizedBox(width: AppSpacing.lg),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                negocio.nombre,
                                style: AppTextStyles.cardTitleSmall,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            AppBadge(
                              label: negocio.estado.etiqueta,
                              tone: tonoDeNegocio(negocio.estado),
                              dense: true,
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${negocio.categoria} · ${negocio.direccion}',
                          style: AppTextStyles.captionSmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              );

              final boton = AppTextActionButton(
                label: conIncidencias ? 'Atender incidencia' : 'Abrir soporte',
                color: conIncidencias
                    ? AppColors.dangerText
                    : AppColors.primary,
                onPressed: () =>
                    context.go(AppRoutes.aSoporteNegocio(negocio.id)),
              );

              if (compacta) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    identidad,
                    const SizedBox(height: AppSpacing.md),
                    Align(alignment: Alignment.centerLeft, child: boton),
                  ],
                );
              }
              return Row(
                children: [
                  Expanded(child: identidad),
                  const SizedBox(width: AppSpacing.md),
                  boton,
                ],
              );
            },
          ),
          const SizedBox(height: AppSpacing.lg),
          Wrap(
            spacing: AppSpacing.xl,
            runSpacing: AppSpacing.sm,
            children: [
              _DatoNegocio(titulo: 'Ventas hoy', valor: negocio.ventasTexto),
              _DatoNegocio(
                titulo: 'Pendientes',
                valor: '${negocio.pedidosPendientes}',
              ),
              _DatoNegocio(
                titulo: 'Calif.',
                valor: negocio.calificacion == null
                    ? '—'
                    : negocio.calificacion!.toStringAsFixed(1),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DatoNegocio extends StatelessWidget {
  const _DatoNegocio({required this.titulo, required this.valor});

  final String titulo;
  final String valor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$titulo ',
          style: AppTextStyles.captionSmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        Text(valor, style: AppTextStyles.amount),
      ],
    );
  }
}

class _TablaNegocios extends StatelessWidget {
  const _TablaNegocios({required this.negocios});

  final List<Negocio> negocios;

  @override
  Widget build(BuildContext context) {
    return AppDataTable(
      stackedTitleIndex: 0,
      stackedTrailingIndex: 3,
      columns: const [
        AppTableColumn('Negocio', flex: 14),
        AppTableColumn('Categoría', flex: 9),
        AppTableColumn.fixed('Horario', width: 116),
        AppTableColumn.fixed('Estado', width: 108),
        AppTableColumn.fixed('Ventas hoy', width: 96),
        AppTableColumn.fixed('Comisión', width: 88),
      ],
      rows: [
        for (final negocio in negocios)
          AppTableRow(
            onTap: () => context.go(AppRoutes.aSoporteNegocio(negocio.id)),
            cells: [
              Row(
                children: [
                  AppEmojiTile(emoji: negocio.emoji, size: 30),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: AppTableText(
                      negocio.nombre,
                      style: AppTextStyles.bodySmallStrong,
                    ),
                  ),
                ],
              ),
              AppTableText(negocio.categoria, color: AppColors.textSecondary),
              AppTableText(negocio.horario, color: AppColors.textSecondary),
              AppBadge(
                label: negocio.estado.etiqueta,
                tone: tonoDeNegocio(negocio.estado),
                dense: true,
              ),
              AppTableText(
                negocio.ventasTexto,
                style: AppTextStyles.amount,
                color: negocio.ventasHoy == null
                    ? AppColors.textMuted
                    : AppColors.textPrimary,
              ),
              AppTableText(
                negocio.comisionTexto,
                style: AppTextStyles.amount,
                color: negocio.comisionPreferente
                    ? AppColors.primary
                    : AppColors.textPrimary,
              ),
            ],
          ),
      ],
    );
  }
}
