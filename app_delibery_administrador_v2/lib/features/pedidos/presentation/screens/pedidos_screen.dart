import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/data/dely_mock_store.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/admin_screen.dart';
import '../../../../core/widgets/admin_shell.dart';
import '../../../../core/widgets/app_badge.dart';
import '../../../../core/widgets/app_table.dart';
import '../../../../core/widgets/vista_async.dart';
import '../../../auth/providers/sesion_provider.dart';
import '../../data/models/pedido.dart';
import '../../providers/pedidos_provider.dart';
import '../widgets/panel_detalle_pedido.dart';

/// Frame 02 · Gestión de pedidos.
///
/// En escritorio reproduce el diseño: tabla a la izquierda y panel de detalle
/// fijo de 430 px a la derecha. En pantallas estrechas la tabla se apila en
/// tarjetas y el detalle pasa a ser la ruta hija `/pedidos/:pedidoId`.
class PedidosScreen extends StatefulWidget {
  const PedidosScreen({super.key, this.pedidoId});

  /// Pedido abierto en el panel de detalle, si la ruta lo trae.
  final String? pedidoId;

  @override
  State<PedidosScreen> createState() => _PedidosScreenState();
}

class _PedidosScreenState extends State<PedidosScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _sincronizar());
  }

  @override
  void didUpdateWidget(PedidosScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pedidoId != widget.pedidoId) _sincronizar();
  }

  Future<void> _sincronizar() async {
    if (!mounted) return;
    final provider = context.read<PedidosProvider>();
    await provider.cargar();
    if (!mounted) return;
    final id = widget.pedidoId;
    if (id != null) provider.seleccionar(id);
  }

  @override
  Widget build(BuildContext context) {
    final sesion = context.watch<SesionProvider>();
    final provider = context.watch<PedidosProvider>();
    final compacta = AdminScreen.esCompacta(context);
    final visibles = provider.pedidosVisibles;

    // En estrecho, la ruta con identificador muestra solo el detalle.
    if (compacta && widget.pedidoId != null) {
      final pedido = provider.porId(widget.pedidoId!);
      if (pedido != null) {
        return AdminScreen(
          titulo: pedido.id,
          nombreOperador: sesion.nombre,
          rolOperador: sesion.rol,
          desplazable: false,
          child: SizedBox(
            width: double.infinity,
            child: PanelDetallePedido(pedido: pedido, mostrarBotonAtras: true),
          ),
        );
      }
    }

    final tabla = SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(22, 22, 22, AppSpacing.xxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AdminPageHeader(
            migaDePan: 'Inicio / Pedidos',
            titulo: 'Pedidos',
            acciones: [
              Text(
                '${provider.pedidosActivos.length} activos · '
                '${provider.totalHoy} hoy',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              for (final filtro in FiltroPedido.values)
                AppFilterChip(
                  label: filtro.etiqueta,
                  count: provider.contarPorFiltro(filtro),
                  selected: provider.filtro == filtro,
                  tone: filtro == FiltroPedido.problema
                      ? AppBadgeTone.danger
                      : null,
                  onTap: () => provider.cambiarFiltro(filtro),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          VistaAsync(
            cargando: provider.cargando,
            error: provider.error,
            vacio: visibles.isEmpty,
            onReintentar: () => provider.cargar(forzar: true),
            tituloVacio: 'Ningún pedido coincide',
            mensajeVacio:
                'Prueba con otro filtro o borra el texto del buscador.',
            iconoVacio: Icons.receipt_long_outlined,
            accionVacio: 'Ver todos los pedidos',
            onAccionVacio: () {
              provider
                ..cambiarFiltro(FiltroPedido.todos)
                ..buscar('');
            },
            builder: (context) => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _TablaPedidos(
                  pedidos: visibles,
                  seleccionadoId: provider.seleccionado?.id,
                  compacta: compacta,
                  onSeleccionar: (pedido) {
                    if (compacta) {
                      context.go(AppRoutes.aDetallePedido(pedido.id));
                    } else {
                      provider.seleccionar(pedido.id);
                    }
                  },
                ),
                const SizedBox(height: 14),
                AppPagination(
                  mostrando: visibles.length,
                  total: provider.filtro == FiltroPedido.todos
                      ? provider.totalHoy
                      : visibles.length,
                  paginaActual: 1,
                  paginas: 3,
                  onPagina: (pagina) => _avisarPagina(context, pagina),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    return AdminScreen(
      titulo: 'Pedidos',
      nombreOperador: sesion.nombre,
      rolOperador: sesion.rol,
      hintBusqueda: 'Buscar por #pedido, cliente o negocio…',
      onBuscar: provider.buscar,
      desplazable: false,
      child: compacta
          ? tabla
          : Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: tabla),
                if (provider.seleccionado != null)
                  PanelDetallePedido(pedido: provider.seleccionado!),
              ],
            ),
    );
  }

  static void _avisarPagina(BuildContext context, int pagina) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            'Página $pagina de ${DelyMockStore.pedidosHoy} pedidos del día. '
            'El histórico completo llega al conectar Firebase.',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textOnPrimary,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      );
  }
}

class _TablaPedidos extends StatelessWidget {
  const _TablaPedidos({
    required this.pedidos,
    required this.seleccionadoId,
    required this.compacta,
    required this.onSeleccionar,
  });

  final List<Pedido> pedidos;
  final String? seleccionadoId;
  final bool compacta;
  final ValueChanged<Pedido> onSeleccionar;

  @override
  Widget build(BuildContext context) {
    return AppDataTable(
      stackedTitleIndex: 0,
      stackedTrailingIndex: 5,
      columns: const [
        AppTableColumn.fixed('Pedido', width: 82),
        AppTableColumn('Negocio', flex: 13),
        AppTableColumn('Cliente', flex: 10),
        AppTableColumn('Repartidor', flex: 10),
        AppTableColumn.fixed('Monto', width: 78),
        AppTableColumn.fixed('Estado', width: 130),
      ],
      rows: [
        for (final pedido in pedidos)
          AppTableRow(
            selected: !compacta && pedido.id == seleccionadoId,
            onTap: () => onSeleccionar(pedido),
            cells: [
              Text(
                pedido.id,
                style: AppTextStyles.amount.copyWith(
                  color: pedido.id == seleccionadoId && !compacta
                      ? AppColors.primaryDark
                      : AppColors.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              AppTableText(
                pedido.negocio,
                style: AppTextStyles.bodySmallStrong,
              ),
              AppTableText(pedido.cliente, color: AppColors.textSecondary),
              AppTableText(
                pedido.repartidor ?? 'Sin asignar',
                color: pedido.tieneRepartidor
                    ? AppColors.textSecondary
                    : AppColors.textMuted,
              ),
              Text(
                pedido.montoTexto,
                style: AppTextStyles.amount.copyWith(
                  color: pedido.monto == null
                      ? AppColors.textMuted
                      : AppColors.textPrimary,
                ),
                maxLines: 1,
              ),
              Align(
                alignment: Alignment.center,
                child: AppBadge.pedido(pedido.estado, corta: true, dense: true),
              ),
            ],
          ),
      ],
    );
  }
}
