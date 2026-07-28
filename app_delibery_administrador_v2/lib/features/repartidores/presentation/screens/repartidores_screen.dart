import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/data/dely_mock_store.dart';
import '../../../../core/models/estado_repartidor.dart';
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
import '../../data/models/repartidor.dart';
import '../../providers/repartidores_provider.dart';
import '../widgets/hoja_registrar_repartidor.dart';

/// Tono de insignia de cada estado de repartidor, según el diseño.
AppBadgeTone tonoDeRepartidor(EstadoRepartidor estado) => switch (estado) {
  EstadoRepartidor.enCamino => AppBadgeTone.okStrong,
  EstadoRepartidor.multiPedido => AppBadgeTone.highlight,
  EstadoRepartidor.conectado => AppBadgeTone.ok,
  EstadoRepartidor.buscando => AppBadgeTone.neutral,
  EstadoRepartidor.docsPendientes => AppBadgeTone.amber,
  EstadoRepartidor.desconectado => AppBadgeTone.neutral,
};

/// Frame 04 · Repartidores · listado.
class RepartidoresScreen extends StatefulWidget {
  const RepartidoresScreen({super.key});

  @override
  State<RepartidoresScreen> createState() => _RepartidoresScreenState();
}

class _RepartidoresScreenState extends State<RepartidoresScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<RepartidoresProvider>().cargar();
    });
  }

  @override
  Widget build(BuildContext context) {
    final sesion = context.watch<SesionProvider>();
    final provider = context.watch<RepartidoresProvider>();
    final visibles = provider.repartidoresVisibles;

    return AdminScreen(
      titulo: 'Repartidores',
      nombreOperador: sesion.nombre,
      rolOperador: sesion.rol,
      hintBusqueda: 'Buscar repartidor por nombre o DNI…',
      onBuscar: provider.buscar,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AdminPageHeader(
            migaDePan: 'Inicio / Repartidores',
            titulo: 'Repartidores',
            acciones: [
              AppButton.primary(
                label: '+ Registrar repartidor',
                height: AppSizes.controlHeight,
                onPressed: () => mostrarHoja<void>(
                  context,
                  builder: (_) =>
                      ChangeNotifierProvider<RepartidoresProvider>.value(
                        value: provider,
                        child: const HojaRegistrarRepartidor(),
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          VistaAsync(
            cargando: provider.cargando,
            error: provider.error,
            vacio: provider.repartidores.isEmpty,
            onReintentar: () => provider.cargar(forzar: true),
            tituloVacio: 'Todavía no hay repartidores',
            mensajeVacio:
                'Registra al primer repartidor para que aparezca en CHASQUI.',
            iconoVacio: Icons.two_wheeler_outlined,
            skeletons: 4,
            builder: (context) => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AdminGrid(
                  anchoMinimo: 220,
                  children: [
                    _MiniKpi(
                      titulo: 'Conectados',
                      valor: '${provider.conectados}',
                    ),
                    _MiniKpi(
                      titulo: 'Con pedido activo',
                      valor: '${provider.conPedidoActivo}',
                    ),
                    _MiniKpi(
                      titulo: 'Documentos por verificar',
                      valor: '${provider.documentosPorVerificar}',
                      color: AppColors.warning,
                    ),
                    _MiniKpi(
                      titulo: 'Calificación promedio',
                      valor: provider.calificacionPromedio.toStringAsFixed(1),
                      color: AppColors.primary,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.gridGap),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    for (final filtro in FiltroRepartidor.values)
                      AppFilterChip(
                        label: filtro.etiqueta,
                        count: provider.contarPorFiltro(filtro),
                        selected: provider.filtro == filtro,
                        tone: filtro == FiltroRepartidor.docsPendientes
                            ? AppBadgeTone.amber
                            : null,
                        onTap: () => provider.cambiarFiltro(filtro),
                      ),
                    _SelectorZona(
                      zona: provider.zona,
                      onCambiar: provider.cambiarZona,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                if (visibles.isEmpty)
                  const _SinResultados()
                else
                  _TablaRepartidores(repartidores: visibles),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SinResultados extends StatelessWidget {
  const _SinResultados();

  @override
  Widget build(BuildContext context) {
    final provider = context.read<RepartidoresProvider>();
    return AppCard(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxxl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.search_off, size: 28, color: AppColors.textMuted),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Ningún repartidor coincide con el filtro',
            style: AppTextStyles.cardTitle,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSpacing.md),
          AppButton.secondary(
            label: 'Ver todos',
            onPressed: () {
              provider
                ..cambiarFiltro(FiltroRepartidor.todos)
                ..cambiarZona(null)
                ..buscar('');
            },
          ),
        ],
      ),
    );
  }
}

class _SelectorZona extends StatelessWidget {
  const _SelectorZona({required this.zona, required this.onCambiar});

  final String? zona;
  final ValueChanged<String?> onCambiar;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String?>(
      tooltip: 'Filtrar por zona',
      onSelected: onCambiar,
      color: AppColors.surface,
      itemBuilder: (context) => [
        const PopupMenuItem<String?>(value: null, child: Text('Todas')),
        for (final z in DelyMockStore.zonas)
          PopupMenuItem<String?>(value: z, child: Text(z)),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.chip,
          border: Border.all(color: AppColors.borderStrong),
        ),
        child: Text(
          'Zona: ${zona ?? 'todas'} ▾',
          style: AppTextStyles.labelStrong.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _MiniKpi extends StatelessWidget {
  const _MiniKpi({
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

class _TablaRepartidores extends StatelessWidget {
  const _TablaRepartidores({required this.repartidores});

  final List<Repartidor> repartidores;

  @override
  Widget build(BuildContext context) {
    return AppDataTable(
      stackedTitleIndex: 0,
      stackedTrailingIndex: 1,
      columns: const [
        AppTableColumn('Repartidor', flex: 16),
        AppTableColumn.fixed('Estado', width: 132),
        AppTableColumn('Zona actual', flex: 10),
        AppTableColumn.fixed('Activos', width: 62),
        AppTableColumn.fixed('Calif.', width: 62),
        AppTableColumn.fixed('Hoy', width: 76),
        AppTableColumn.fixed('Conectado', width: 84),
        AppTableColumn.fixed('', width: 96, alignment: Alignment.centerRight),
      ],
      rows: [
        for (final repartidor in repartidores)
          AppTableRow(
            onTap: () => context.go(AppRoutes.aFichaRepartidor(repartidor.id)),
            accentColor: repartidor.accesoRestringido
                ? AppColors.dangerSoftBorder
                : null,
            cells: [
              Row(
                children: [
                  AppAvatar(
                    nombre: repartidor.nombre,
                    online: repartidor.enLinea,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          repartidor.nombre,
                          style: AppTextStyles.bodySmallStrong,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          repartidor.notaEstado ?? repartidor.vehiculoTexto,
                          style: AppTextStyles.captionSmall.copyWith(
                            color: repartidor.notaEstado == null
                                ? AppColors.textSecondary
                                : AppColors.warning,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              AppBadge(
                label: repartidor.etiquetaEstado,
                tone: repartidor.accesoRestringido
                    ? AppBadgeTone.danger
                    : tonoDeRepartidor(repartidor.estado),
                dense: true,
              ),
              AppTableText(
                repartidor.zonaTexto,
                color: repartidor.zonaActual == null
                    ? AppColors.textMuted
                    : AppColors.textSecondary,
              ),
              AppTableText(
                '${repartidor.pedidosActivos}',
                style: AppTextStyles.amount,
              ),
              AppTableText(
                '★ ${repartidor.calificacion.toStringAsFixed(1)}',
                style: AppTextStyles.amount,
              ),
              AppTableText(
                repartidor.gananciaTexto,
                style: AppTextStyles.amount,
                color: repartidor.gananciaHoy == null
                    ? AppColors.textMuted
                    : AppColors.textPrimary,
              ),
              AppTableText(
                repartidor.conectadoTexto,
                color: AppColors.textSecondary,
              ),
              AppTextActionButton(
                label: repartidor.tieneDocumentosPendientes
                    ? 'Verificar'
                    : 'Ver perfil',
                color: repartidor.tieneDocumentosPendientes
                    ? AppColors.warning
                    : AppColors.primary,
                onPressed: () =>
                    context.go(AppRoutes.aFichaRepartidor(repartidor.id)),
              ),
            ],
          ),
      ],
    );
  }
}
