import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/admin_screen.dart';
import '../../../../core/widgets/admin_shell.dart';
import '../../../../core/widgets/app_badge.dart';
import '../../../../core/widgets/app_buttons.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_dialogs.dart';
import '../../../../core/widgets/app_table.dart';
import '../../../../core/widgets/vista_async.dart';
import '../../../auth/providers/sesion_provider.dart';
import '../../data/models/liquidacion.dart';
import '../../providers/pagos_provider.dart';

/// Frame 12 · Pagos y liquidaciones.
class PagosScreen extends StatefulWidget {
  const PagosScreen({super.key});

  @override
  State<PagosScreen> createState() => _PagosScreenState();
}

class _PagosScreenState extends State<PagosScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<PagosProvider>().cargar();
    });
  }

  Future<void> _procesar() async {
    final provider = context.read<PagosProvider>();
    final confirmado = await mostrarConfirmacion(
      context,
      titulo: '¿Procesar la liquidación de ${provider.semana ?? 'la semana'}?',
      mensaje:
          'Se marcarán como pagadas todas las liquidaciones pendientes de '
          'negocios y repartidores.',
      etiquetaConfirmar: 'Procesar',
      destructiva: false,
      icono: Icons.account_balance_wallet_outlined,
    );
    if (confirmado == null || !mounted) return;

    final procesadas = await provider.procesarLiquidacion();
    if (!mounted) return;
    mostrarAviso(
      context,
      provider.hayError
          ? provider.error ?? 'No se pudo procesar la liquidación.'
          : procesadas == 0
          ? 'No quedaban liquidaciones pendientes.'
          : '$procesadas liquidaciones marcadas como pagadas.',
      exito: !provider.hayError,
    );
  }

  @override
  Widget build(BuildContext context) {
    final sesion = context.watch<SesionProvider>();
    final provider = context.watch<PagosProvider>();
    final resumen = provider.resumen;

    return AdminScreen(
      titulo: 'Pagos y liquidaciones',
      nombreOperador: sesion.nombre,
      rolOperador: sesion.rol,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AdminPageHeader(
            titulo: 'Pagos y liquidaciones',
            acciones: [
              _SelectorSemana(
                semana: provider.semana,
                semanas: provider.semanas,
                onCambiar: provider.cambiarSemana,
              ),
              AppButton.primary(
                label: 'Procesar liquidación',
                height: AppSizes.controlHeight,
                onPressed: provider.hayPendientes ? _procesar : null,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          VistaAsync(
            cargando: provider.cargando,
            error: provider.error,
            vacio: resumen == null,
            onReintentar: () => provider.cargar(forzar: true),
            tituloVacio: 'Sin liquidaciones',
            mensajeVacio: 'No hay pagos registrados para esta semana.',
            iconoVacio: Icons.credit_card,
            skeletons: 4,
            builder: (context) => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AdminGrid(
                  anchoMinimo: 250,
                  children: [
                    _KpiPago(
                      titulo: 'Por pagar a negocios',
                      valor: 'S/ ${_miles(resumen!.porPagarNegocios)}',
                    ),
                    _KpiPago(
                      titulo: 'Por pagar a repartidores',
                      valor: 'S/ ${_miles(resumen.porPagarRepartidores)}',
                    ),
                    _KpiPago(
                      titulo: 'Comisión DelyPuno',
                      valor: 'S/ ${_miles(resumen.comisionDelyPuno)}',
                      color: AppColors.primary,
                    ),
                    _KpiPago(
                      titulo: 'Pagos pendientes',
                      valor: '${resumen.pagosPendientes}',
                      color: AppColors.warning,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.gridGap),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [
                    for (final tab in TipoBeneficiario.values)
                      AppFilterChip(
                        label: tab.etiqueta,
                        selected: provider.tab == tab,
                        onTap: () => provider.cambiarTab(tab),
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                if (provider.liquidaciones.isEmpty)
                  AppCard(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.xxxl,
                    ),
                    child: Text(
                      'No hay liquidaciones en «${provider.tab.etiqueta}» '
                      'para esta semana.',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  )
                else
                  _TablaLiquidaciones(
                    liquidaciones: provider.liquidaciones,
                    mostrarPeriodo: provider.tab == TipoBeneficiario.historico,
                  ),
              ],
            ),
          ),
        ],
      ),
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

class _SelectorSemana extends StatelessWidget {
  const _SelectorSemana({
    required this.semana,
    required this.semanas,
    required this.onCambiar,
  });

  final String? semana;
  final List<String> semanas;
  final ValueChanged<String> onCambiar;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: 'Cambiar semana',
      onSelected: onCambiar,
      color: AppColors.surface,
      itemBuilder: (context) => [
        for (final s in semanas)
          PopupMenuItem<String>(value: s, child: Text(s)),
      ],
      child: Container(
        height: AppSizes.controlHeight,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.control,
          border: Border.all(color: AppColors.borderStrong),
        ),
        child: Text(
          '${semana ?? 'Semana'} ▾',
          style: AppTextStyles.amount,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}

class _KpiPago extends StatelessWidget {
  const _KpiPago({
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
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              valor,
              style: AppTextStyles.pageTitle.copyWith(color: color),
            ),
          ),
        ],
      ),
    );
  }
}

class _TablaLiquidaciones extends StatelessWidget {
  const _TablaLiquidaciones({
    required this.liquidaciones,
    required this.mostrarPeriodo,
  });

  final List<Liquidacion> liquidaciones;
  final bool mostrarPeriodo;

  AppBadgeTone _tono(EstadoLiquidacion estado) => switch (estado) {
    EstadoLiquidacion.pagado => AppBadgeTone.success,
    EstadoLiquidacion.pendiente => AppBadgeTone.amber,
    EstadoLiquidacion.observado => AppBadgeTone.danger,
  };

  @override
  Widget build(BuildContext context) {
    return AppDataTable(
      stackedTitleIndex: 0,
      stackedTrailingIndex: mostrarPeriodo ? 6 : 5,
      columns: [
        const AppTableColumn('Beneficiario', flex: 14),
        const AppTableColumn.fixed('Pedidos', width: 76),
        const AppTableColumn.fixed('Bruto', width: 96),
        const AppTableColumn.fixed('Comisión', width: 104),
        const AppTableColumn.fixed('Neto', width: 96),
        if (mostrarPeriodo) const AppTableColumn.fixed('Periodo', width: 116),
        const AppTableColumn.fixed('Estado', width: 108),
      ],
      rows: [
        for (final liquidacion in liquidaciones)
          AppTableRow(
            accentColor: liquidacion.estado == EstadoLiquidacion.observado
                ? AppColors.dangerSoftBorder
                : null,
            cells: [
              AppTableText(
                liquidacion.beneficiario,
                style: AppTextStyles.bodySmallStrong,
              ),
              AppTableText(
                '${liquidacion.pedidos}',
                color: AppColors.textSecondary,
              ),
              AppTableText(liquidacion.brutoTexto, style: AppTextStyles.amount),
              AppTableText(
                liquidacion.comisionTexto,
                style: AppTextStyles.amount,
                color: AppColors.dangerText,
              ),
              AppTableText(
                liquidacion.netoTexto,
                style: AppTextStyles.amount,
                color: AppColors.primary,
              ),
              if (mostrarPeriodo)
                AppTableText(
                  liquidacion.periodo ?? '—',
                  color: AppColors.textSecondary,
                ),
              AppBadge(
                label: liquidacion.estado.etiqueta,
                tone: _tono(liquidacion.estado),
                dense: true,
              ),
            ],
          ),
      ],
    );
  }
}
