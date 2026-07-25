import 'package:flutter/material.dart';

import '../../data/demo_data.dart';
import '../../data/models.dart';
import '../../router/app_routes.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../widgets/account_scaffold.dart';
import '../../widgets/andean_pattern.dart';
import '../../widgets/buttons.dart';

/// Frame 14 — Ganancias.
///
/// Cabecera verde con la cifra del periodo, selector día/semana/mes, gráfico
/// de barras, cuatro métricas y el botón de retiro.
class EarningsScreen extends StatefulWidget {
  const EarningsScreen({super.key});

  @override
  State<EarningsScreen> createState() => _EarningsScreenState();
}

class _EarningsScreenState extends State<EarningsScreen> {
  /// 0 = Semana (el estado que dibuja el diseño), 1 = Día, 2 = Mes.
  int _periodIndex = 0;

  EarningsPeriod get _period => DemoData.earningsPeriods[_periodIndex];

  @override
  Widget build(BuildContext context) {
    final period = _period;

    return AccountScaffold(
      currentRoute: AppRoutes.earnings,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            BrandHeader(
              padding: const EdgeInsets.fromLTRB(22, 14, 22, 26),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      const DrawerMenuButton(),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Ganancias',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppText.display(18, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    period.headline,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.body(13, weight: FontWeight.w600, color: AppColors.textOnBrandSoft),
                  ),
                  const SizedBox(height: 2),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'S/ ${period.total.toStringAsFixed(2)}',
                      style: AppText.display(40, color: Colors.white, letterSpacing: -0.5),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.trending_up_rounded, size: 15, color: AppColors.textOnBrandStrong),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          period.delta,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppText.body(12, weight: FontWeight.w600, color: AppColors.textOnBrandStrong),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  _PeriodSelector(
                    periods: DemoData.earningsPeriods,
                    selected: _periodIndex,
                    onChanged: (index) => setState(() => _periodIndex = index),
                  ),
                ],
              ),
            ),

            // ---- Gráfico ----
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(period.chartTitle, style: AppText.display(16, weight: FontWeight.w700)),
                  const SizedBox(height: 16),
                  _EarningsChart(bars: period.bars),
                ],
              ),
            ),

            // ---- Métricas ----
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(child: _MetricTile(label: 'Pedidos', value: '${period.orders}')),
                      const SizedBox(width: 12),
                      Expanded(child: _MetricTile(label: 'Horas conectado', value: period.hours)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _MetricTile(
                          label: 'Propinas',
                          value: 'S/ ${period.tips.toStringAsFixed(2)}',
                          valueColor: AppColors.primaryOnSoft,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _MetricTile(
                          label: 'S/ por pedido',
                          value: 'S/ ${period.perOrder.toStringAsFixed(2)}',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ---- Retiro ----
            Padding(
              padding: EdgeInsets.fromLTRB(20, 22, 20, 30 + MediaQuery.paddingOf(context).bottom),
              child: OutlinedBrandButton(
                label: 'Retirar a mi cuenta',
                icon: Icons.credit_card_outlined,
                onPressed: () => _showWithdrawSheet(context, period.total),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showWithdrawSheet(BuildContext context, double available) {
    // Se captura antes de abrir la hoja: al cerrarla, su `context` ya no sirve
    // para buscar el ScaffoldMessenger.
    final messenger = ScaffoldMessenger.of(context);

    showAccountSheet(
      context,
      title: 'Retirar a mi cuenta',
      subtitle: 'El depósito llega a tu cuenta BCP en un máximo de 24 horas hábiles.',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.fill,
              borderRadius: BorderRadius.circular(AppTheme.rCard),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Disponible',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.body(13),
                  ),
                ),
                Text(
                  'S/ ${available.toStringAsFixed(2)}',
                  style: AppText.display(20, color: AppColors.primary),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          PrimaryButton(
            label: 'Confirmar retiro',
            onPressed: () {
              Navigator.of(context).pop();
              messenger
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  const SnackBar(
                    content: Text('Retiro solicitado. Te avisaremos al depositar.'),
                    backgroundColor: AppColors.primaryDark,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
            },
          ),
        ],
      ),
    );
  }
}

/// Selector "Semana · Día · Mes" sobre la cabecera verde.
class _PeriodSelector extends StatelessWidget {
  const _PeriodSelector({
    required this.periods,
    required this.selected,
    required this.onChanged,
  });

  final List<EarningsPeriod> periods;
  final int selected;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppTheme.rField),
      ),
      child: Row(
        children: [
          for (var i = 0; i < periods.length; i++)
            Expanded(
              child: GestureDetector(
                onTap: () => onChanged(i),
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  padding: const EdgeInsets.symmetric(vertical: 9),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: i == selected ? AppColors.card : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    periods[i].tab,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.display(
                      13,
                      weight: i == selected ? FontWeight.w700 : FontWeight.w600,
                      color: i == selected ? AppColors.textSecondary : Colors.white,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Barras del periodo. La barra destacada va en verde de marca.
///
/// La altura de cada barra es una fracción del espacio que sobra tras colocar
/// la etiqueta, no un valor fijo en píxeles: así el gráfico no puede desbordar
/// por más que cambie el tamaño de fuente del sistema.
class _EarningsChart extends StatelessWidget {
  const _EarningsChart({required this.bars});

  final List<EarningsBar> bars;

  @override
  Widget build(BuildContext context) {
    if (bars.isEmpty) return const SizedBox.shrink();

    final peak = bars.map((b) => b.value).reduce((a, b) => a > b ? a : b);

    return SizedBox(
      height: 150,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (var i = 0; i < bars.length; i++) ...[
            if (i > 0) const SizedBox(width: 9),
            Expanded(
              child: Column(
                children: [
                  Expanded(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: AnimatedFractionallySizedBox(
                        duration: const Duration(milliseconds: 260),
                        curve: Curves.easeOut,
                        alignment: Alignment.bottomCenter,
                        widthFactor: 1,
                        heightFactor: peak == 0 ? 0 : bars[i].value / peak,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: bars[i].highlighted ? AppColors.primary : AppColors.chartBar,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    bars[i].label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.body(
                      11,
                      weight: bars[i].highlighted ? FontWeight.w700 : FontWeight.w600,
                      color: bars[i].highlighted ? AppColors.primary : AppColors.neutral,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Recuadro gris con una métrica del periodo.
class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.label,
    required this.value,
    this.valueColor = AppColors.textPrimary,
  });

  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.fill,
        borderRadius: BorderRadius.circular(AppTheme.rButtonSmall),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppText.body(12)),
          const SizedBox(height: 3),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(value, style: AppText.display(24, color: valueColor)),
          ),
        ],
      ),
    );
  }
}
