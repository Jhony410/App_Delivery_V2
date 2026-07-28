import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/admin_screen.dart';
import '../../../../core/widgets/admin_shell.dart';
import '../../../../core/widgets/app_badge.dart';
import '../../../../core/widgets/app_buttons.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_charts.dart';
import '../../../../core/widgets/app_dialogs.dart';
import '../../../../core/widgets/app_mapa.dart';
import '../../../../core/widgets/vista_async.dart';
import '../../../auth/providers/sesion_provider.dart';
import '../../../negocios/data/models/negocio.dart';
import '../../../pedidos/data/models/pedido.dart';
import '../../../pedidos/providers/pedidos_provider.dart';
import '../../data/models/resumen_operativo.dart';
import '../../providers/dashboard_provider.dart';
import '../widgets/tarjeta_accion.dart';
import '../widgets/lista_incidencias.dart';

/// Frame 01 · Dashboard.
///
/// KPIs del día, tarjetas de acción hacia Repartidores y Negocios, ventas de
/// la semana, pedidos por hora, actividad en el mapa, últimos pedidos e
/// incidencias recientes.
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sesion = context.watch<SesionProvider>();
    final dashboard = context.watch<DashboardProvider>();
    final resumen = dashboard.resumen;

    return AdminScreen(
      titulo: 'Dashboard',
      nombreOperador: sesion.nombre,
      rolOperador: sesion.rol,
      hintBusqueda: 'Buscar pedido, repartidor o negocio…',
      onBuscar: (texto) {
        // El buscador global lleva a la tabla de pedidos ya filtrada.
        if (texto.trim().isEmpty) return;
        context.read<PedidosProvider>().buscar(texto);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AdminPageHeader(
            migaDePan: 'Inicio / Dashboard',
            titulo: 'Resumen de hoy',
            acciones: [
              AppTextActionButton(
                label: 'Hoy ▾',
                color: AppColors.textPrimary,
                height: AppSizes.controlHeight,
                onPressed: () => mostrarAviso(
                  context,
                  'El resumen muestra la operación de hoy, '
                  '${_fechaLarga()}.',
                ),
              ),
              AppButton.primary(
                label: 'Exportar',
                height: AppSizes.controlHeight,
                onPressed: () => context.go(AppRoutes.reportes),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          VistaAsync(
            cargando: dashboard.cargando,
            error: dashboard.error,
            vacio: resumen == null,
            onReintentar: dashboard.cargar,
            tituloVacio: 'Sin datos de la operación',
            mensajeVacio:
                'Todavía no hay actividad registrada para el día de hoy.',
            iconoVacio: Icons.insights_outlined,
            skeletons: 4,
            builder: (context) => _Contenido(
              resumen: resumen!,
              ultimosPedidos: dashboard.ultimosPedidos,
              incidencias: dashboard.incidencias,
            ),
          ),
        ],
      ),
    );
  }

  static String _fechaLarga() => 'lunes 27 de julio de 2026';
}

class _Contenido extends StatelessWidget {
  const _Contenido({
    required this.resumen,
    required this.ultimosPedidos,
    required this.incidencias,
  });

  final ResumenOperativo resumen;
  final List<Pedido> ultimosPedidos;
  final List<Incidencia> incidencias;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AdminGrid(
          anchoMinimo: 250,
          children: [
            AppKpiCard(
              label: 'Pedidos activos',
              value: '${resumen.pedidosActivos}',
              icon: Icons.shopping_bag_outlined,
              onTap: () => context.go(AppRoutes.pedidos),
              footer: Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.xs,
                children: [
                  AppBadge(
                    label: '${resumen.pedidosPreparando} PREPARANDO',
                    tone: AppBadgeTone.amberDeep,
                    dense: true,
                  ),
                  AppBadge(
                    label: '${resumen.pedidosEnCamino} EN CAMINO',
                    tone: AppBadgeTone.ok,
                    dense: true,
                  ),
                ],
              ),
            ),
            AppKpiCard(
              label: 'Ventas del día',
              value: 'S/ ${_miles(resumen.ventasDia)}',
              valueColor: AppColors.primary,
              icon: Icons.attach_money,
              onTap: () => context.go(AppRoutes.reportes),
              footer: AppKpiTrend(text: resumen.variacionVentas),
            ),
            AppKpiCard(
              label: 'Repartidores activos',
              value: '${resumen.repartidoresActivos}',
              suffix: '/ ${resumen.repartidoresTotales}',
              icon: Icons.two_wheeler_outlined,
              onTap: () => context.go(AppRoutes.repartidores),
              footer: Row(
                children: [
                  const AppLiveDot(),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Text(
                      '${resumen.repartidoresConPedido} con pedido · '
                      '${resumen.repartidoresBuscando} buscando',
                      style: AppTextStyles.labelStrong.copyWith(
                        color: AppColors.successText,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            AppKpiCard(
              label: 'Negocios abiertos',
              value: '${resumen.negociosAbiertos}',
              suffix: '/ ${resumen.negociosTotales}',
              icon: Icons.storefront_outlined,
              // Negocios es el único módulo con acento rojo.
              iconColor: AppColors.danger,
              iconBackground: AppColors.dangerSoft,
              onTap: () => context.go(AppRoutes.negocios),
              footer: Text(
                '${resumen.clientesConectados} clientes conectados ahora',
                style: AppTextStyles.labelStrong.copyWith(
                  color: AppColors.textSecondary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.gridGap),
        AdminTwoColumns(
          puntoDeCorte: AppSizes.compactBreakpoint + 200,
          izquierda: TarjetaAccion(
            valor: '${resumen.documentosPorVerificar}',
            titulo: 'Repartidores por verificar',
            descripcion: 'Documentos pendientes de aprobar',
            icono: Icons.assignment_turned_in_outlined,
            color: AppColors.warning,
            fondoIcono: AppColors.warningSoft,
            colorBorde: AppColors.warningSoftBorder,
            etiquetaAccion: 'Revisar',
            onAccion: () => context.go(AppRoutes.repartidores),
          ),
          derecha: TarjetaAccion(
            valor: '${resumen.negociosConIncidencias}',
            titulo: 'Negocios con incidencias',
            descripcion: 'Reclamos o retrasos sin resolver',
            icono: Icons.warning_amber_rounded,
            color: AppColors.dangerText,
            fondoIcono: AppColors.dangerSoft,
            colorBorde: AppColors.dangerSoftBorder,
            etiquetaAccion: 'Atender',
            onAccion: () => context.go(AppRoutes.negocios),
          ),
        ),
        const SizedBox(height: AppSpacing.gridGap),
        AdminTwoColumns(
          flexIzquierda: 27,
          flexDerecha: 20,
          izquierda: AppSectionCard(
            title: 'Ventas de la semana',
            trailing: Text(
              'S/ ${_miles(resumen.ventasSemanaAcumulado)} acumulado',
              style: AppTextStyles.labelStrong.copyWith(
                color: AppColors.textMuted,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            child: AppBarChart(puntos: resumen.ventasSemana),
          ),
          derecha: AppSectionCard(
            title: 'Pedidos por hora',
            subtitle: 'Pico: ${resumen.horaPico}',
            child: AppAreaChart(
              puntos: resumen.pedidosPorHora,
              etiquetasEjeX: const ['8h', '11h', '14h', '17h', '20h', '23h'],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.gridGap),
        AdminTwoColumns(
          flexIzquierda: 10,
          flexDerecha: 11,
          izquierda: AppSectionCard(
            title: 'Actividad en el mapa',
            actionLabel: 'Ver mapa completo',
            onAction: () => context.go(AppRoutes.mapa),
            child: const AppMapaCanvas(
              alto: 210,
              mostrarLeyenda: true,
              marcadores: [
                MarcadorMapa(
                  x: 0.32,
                  y: 0.71,
                  tipo: TipoMarcador.repartidor,
                  pulsante: true,
                  etiqueta: 'Rubén Mamani · en ruta',
                ),
                MarcadorMapa(
                  x: 0.6,
                  y: 0.33,
                  tipo: TipoMarcador.negocio,
                  etiqueta: 'Pollería El Cholo',
                ),
                MarcadorMapa(
                  x: 0.78,
                  y: 0.52,
                  tipo: TipoMarcador.cliente,
                  etiqueta: 'Luis Mamani · esperando',
                ),
              ],
            ),
          ),
          derecha: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              AppSectionCard(
                title: 'Últimos pedidos',
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xl,
                  vertical: AppSpacing.cardPaddingTight,
                ),
                actionLabel: 'Ver todos',
                onAction: () => context.go(AppRoutes.pedidos),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (var i = 0; i < ultimosPedidos.length; i++)
                      _FilaUltimoPedido(
                        pedido: ultimosPedidos[i],
                        ultima: i == ultimosPedidos.length - 1,
                      ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.gridGap),
              ListaIncidencias(incidencias: incidencias),
            ],
          ),
        ),
      ],
    );
  }

  static String _miles(double valor) {
    final entero = valor.round().toString();
    final buffer = StringBuffer();
    for (var i = 0; i < entero.length; i++) {
      if (i > 0 && (entero.length - i) % 3 == 0) buffer.write(',');
      buffer.write(entero[i]);
    }
    return buffer.toString();
  }
}

class _FilaUltimoPedido extends StatelessWidget {
  const _FilaUltimoPedido({required this.pedido, required this.ultima});

  final Pedido pedido;
  final bool ultima;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.go(AppRoutes.aDetallePedido(pedido.id)),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: BoxDecoration(
          border: Border(
            bottom: ultima
                ? BorderSide.none
                : const BorderSide(color: AppColors.divider),
          ),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 64,
              child: Text(
                pedido.id,
                style: AppTextStyles.labelBold.copyWith(
                  color: AppColors.textSecondary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                pedido.negocio,
                style: AppTextStyles.bodySmallStrong,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              pedido.montoTexto,
              style: AppTextStyles.amount.copyWith(
                color: pedido.monto == null
                    ? AppColors.textMuted
                    : AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            SizedBox(
              width: 106,
              child: Align(
                alignment: Alignment.centerRight,
                child: AppBadge.pedido(pedido.estado, corta: true, dense: true),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
