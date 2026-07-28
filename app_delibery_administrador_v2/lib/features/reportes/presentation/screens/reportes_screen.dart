import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/admin_screen.dart';
import '../../../../core/widgets/admin_shell.dart';
import '../../../../core/widgets/app_buttons.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_charts.dart';
import '../../../../core/widgets/app_dialogs.dart';
import '../../../../core/widgets/app_table.dart';
import '../../../../core/widgets/vista_async.dart';
import '../../../auth/providers/sesion_provider.dart';
import '../../data/models/reporte_mensual.dart';
import '../../data/repositories/reportes_repository.dart';
import '../../providers/reportes_provider.dart';

/// Frame 11 · Reportes.
class ReportesScreen extends StatefulWidget {
  const ReportesScreen({super.key});

  @override
  State<ReportesScreen> createState() => _ReportesScreenState();
}

class _ReportesScreenState extends State<ReportesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<ReportesProvider>().cargar();
    });
  }

  Future<void> _exportar(FormatoExportacion formato) async {
    final provider = context.read<ReportesProvider>();
    final archivo = await provider.exportar(formato);
    if (!mounted) return;
    mostrarAviso(
      context,
      archivo == null
          ? provider.error ?? 'No se pudo generar el archivo.'
          : 'Se generó $archivo con los datos de ${provider.periodo}.',
      exito: archivo != null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final sesion = context.watch<SesionProvider>();
    final provider = context.watch<ReportesProvider>();
    final reporte = provider.reporte;

    return AdminScreen(
      titulo: 'Reportes',
      nombreOperador: sesion.nombre,
      rolOperador: sesion.rol,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AdminPageHeader(
            titulo: 'Reportes',
            acciones: [
              _SelectorPeriodo(
                periodo: provider.periodo,
                periodos: provider.periodos,
                onCambiar: provider.cambiarPeriodo,
              ),
              AppTextActionButton(
                label: 'Exportar Excel',
                height: AppSizes.controlHeight,
                onPressed: () => _exportar(FormatoExportacion.excel),
              ),
              AppButton.primary(
                label: 'Exportar PDF',
                height: AppSizes.controlHeight,
                onPressed: () => _exportar(FormatoExportacion.pdf),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          VistaAsync(
            cargando: provider.cargando,
            error: provider.error,
            vacio: reporte == null,
            onReintentar: () => provider.cargar(forzar: true),
            tituloVacio: 'Sin datos del periodo',
            mensajeVacio: 'Elige otro mes en el selector superior.',
            iconoVacio: Icons.bar_chart_rounded,
            skeletons: 4,
            builder: (context) => _Contenido(reporte: reporte!),
          ),
        ],
      ),
    );
  }
}

class _SelectorPeriodo extends StatelessWidget {
  const _SelectorPeriodo({
    required this.periodo,
    required this.periodos,
    required this.onCambiar,
  });

  final String? periodo;
  final List<String> periodos;
  final ValueChanged<String> onCambiar;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: 'Cambiar periodo',
      onSelected: onCambiar,
      color: AppColors.surface,
      itemBuilder: (context) => [
        for (final p in periodos)
          PopupMenuItem<String>(value: p, child: Text(p)),
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
          '${periodo ?? 'Periodo'} ▾',
          style: AppTextStyles.amount,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}

class _Contenido extends StatelessWidget {
  const _Contenido({required this.reporte});

  final ReporteMensual reporte;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AdminGrid(
          anchoMinimo: 250,
          children: [
            for (final metrica in reporte.metricas)
              AppCard(
                padding: const EdgeInsets.all(AppSpacing.cardPaddingTight),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      metrica.titulo,
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
                        metrica.valor,
                        style: AppTextStyles.kpiValueLarge,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppKpiTrend(
                      text: metrica.variacion,
                      positive: metrica.positiva,
                      neutral: metrica.neutral,
                    ),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.gridGap),
        AdminTwoColumns(
          flexIzquierda: 12,
          flexDerecha: 10,
          izquierda: AppSectionCard(
            title: 'Ingresos por semana',
            child: AppBarChart(
              puntos: reporte.ingresosPorSemana,
              alto: 200,
              radioSuperior: 10,
              separacion: AppSpacing.xl,
            ),
          ),
          derecha: AppSectionCard(
            title: 'Pedidos por categoría',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final categoria in reporte.categorias)
                  AppProgressRow(
                    etiqueta: categoria.categoria,
                    porcentaje: categoria.porcentaje,
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.gridGap),
        AppSectionCard(
          title: 'Top negocios del mes',
          child: AppDataTable(
            stackedTitleIndex: 1,
            columns: const [
              AppTableColumn.fixed('#', width: 34),
              AppTableColumn('Negocio', flex: 14),
              AppTableColumn.fixed('Pedidos', width: 84),
              AppTableColumn.fixed('Ventas', width: 108),
              AppTableColumn.fixed('Comisión', width: 108),
            ],
            rows: [
              for (final fila in reporte.topNegocios)
                AppTableRow(
                  cells: [
                    Text('${fila.posicion}', style: AppTextStyles.amount),
                    AppTableText(
                      fila.negocio,
                      style: AppTextStyles.bodySmallStrong,
                    ),
                    AppTableText(
                      '${fila.pedidos}',
                      style: AppTextStyles.amount,
                    ),
                    AppTableText(
                      'S/ ${_miles(fila.ventas)}',
                      style: AppTextStyles.amount,
                    ),
                    AppTableText(
                      'S/ ${_miles(fila.comision)}',
                      style: AppTextStyles.amount,
                      color: AppColors.primary,
                    ),
                  ],
                ),
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
