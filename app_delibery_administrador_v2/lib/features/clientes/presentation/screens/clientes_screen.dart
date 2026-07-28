import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/models/estado_negocio.dart';
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
import '../../data/models/cliente.dart';
import '../../providers/clientes_provider.dart';
import '../widgets/hoja_ficha_cliente.dart';

/// Frame 09 · Clientes.
class ClientesScreen extends StatefulWidget {
  const ClientesScreen({super.key});

  @override
  State<ClientesScreen> createState() => _ClientesScreenState();
}

class _ClientesScreenState extends State<ClientesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<ClientesProvider>().cargar();
    });
  }

  @override
  Widget build(BuildContext context) {
    final sesion = context.watch<SesionProvider>();
    final provider = context.watch<ClientesProvider>();
    final visibles = provider.clientesVisibles;

    return AdminScreen(
      titulo: 'Clientes',
      nombreOperador: sesion.nombre,
      rolOperador: sesion.rol,
      hintBusqueda: 'Buscar cliente por nombre o celular…',
      onBuscar: provider.buscar,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const AdminPageHeader(
            migaDePan: 'Inicio / Clientes',
            titulo: 'Clientes',
          ),
          const SizedBox(height: AppSpacing.xl),
          VistaAsync(
            cargando: provider.cargando,
            error: provider.error,
            vacio: visibles.isEmpty,
            onReintentar: () => provider.cargar(forzar: true),
            tituloVacio: 'Ningún cliente coincide',
            mensajeVacio: 'Prueba con otro nombre o número de celular.',
            iconoVacio: Icons.person_search_outlined,
            accionVacio: 'Ver todos',
            onAccionVacio: () => provider.buscar(''),
            skeletons: 3,
            builder: (context) => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AdminGrid(
                  anchoMinimo: 220,
                  children: [
                    _MiniKpiCliente(
                      titulo: 'Registrados',
                      valor: _miles(provider.registrados),
                    ),
                    _MiniKpiCliente(
                      titulo: 'Activos este mes',
                      valor: _miles(provider.activosDelMes),
                      color: AppColors.primary,
                    ),
                    _MiniKpiCliente(
                      titulo: 'Ticket promedio',
                      valor: 'S/ ${provider.ticketPromedio}',
                    ),
                    _MiniKpiCliente(
                      titulo: 'Bloqueados',
                      valor: '${provider.bloqueados}',
                      color: AppColors.dangerText,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.gridGap),
                _TablaClientes(clientes: visibles),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _miles(int valor) {
    final entero = valor.toString();
    final buffer = StringBuffer();
    for (var i = 0; i < entero.length; i++) {
      if (i > 0 && (entero.length - i) % 3 == 0) buffer.write(',');
      buffer.write(entero[i]);
    }
    return buffer.toString();
  }
}

class _MiniKpiCliente extends StatelessWidget {
  const _MiniKpiCliente({
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

class _TablaClientes extends StatelessWidget {
  const _TablaClientes({required this.clientes});

  final List<Cliente> clientes;

  AppBadgeTone _tono(EstadoCliente estado) => switch (estado) {
    EstadoCliente.frecuente => AppBadgeTone.highlight,
    EstadoCliente.activo => AppBadgeTone.ok,
    EstadoCliente.bloqueado => AppBadgeTone.danger,
  };

  void _abrirFicha(BuildContext context, Cliente cliente) {
    final provider = context.read<ClientesProvider>();
    mostrarHoja<void>(
      context,
      builder: (_) => ChangeNotifierProvider<ClientesProvider>.value(
        value: provider,
        child: HojaFichaCliente(clienteId: cliente.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppDataTable(
      stackedTitleIndex: 0,
      stackedTrailingIndex: 5,
      columns: const [
        AppTableColumn('Cliente', flex: 14),
        AppTableColumn.fixed('Celular', width: 116),
        AppTableColumn.fixed('Pedidos', width: 72),
        AppTableColumn.fixed('Gasto total', width: 104),
        AppTableColumn.fixed('Último pedido', width: 116),
        AppTableColumn.fixed('Estado', width: 108),
        AppTableColumn.fixed('', width: 72, alignment: Alignment.centerRight),
      ],
      rows: [
        for (final cliente in clientes)
          AppTableRow(
            onTap: () => _abrirFicha(context, cliente),
            accentColor: cliente.estado == EstadoCliente.bloqueado
                ? AppColors.dangerSoftBorder
                : null,
            cells: [
              Row(
                children: [
                  AppAvatar(nombre: cliente.nombre),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: AppTableText(
                      cliente.nombre,
                      style: AppTextStyles.bodySmallStrong,
                    ),
                  ),
                ],
              ),
              AppTableText(cliente.celular, color: AppColors.textSecondary),
              AppTableText('${cliente.pedidos}', style: AppTextStyles.amount),
              AppTableText(cliente.gastoTexto, style: AppTextStyles.amount),
              AppTableText(
                cliente.ultimoPedido,
                color: AppColors.textSecondary,
              ),
              AppBadge(
                label: cliente.estado.etiqueta,
                tone: _tono(cliente.estado),
                dense: true,
              ),
              AppTextActionButton(
                label: 'Ver',
                height: 34,
                onPressed: () => _abrirFicha(context, cliente),
              ),
            ],
          ),
      ],
    );
  }
}
