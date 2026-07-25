import 'package:flutter/material.dart';

import '../../data/models.dart';
import '../../state/app_state_scope.dart';
import '../../theme/app_theme.dart';

/// **Pantalla 09 · Reportes.** Cuarta pestaña del bottom nav.
///
/// Cuatro tarjetas con cifras grandes y el filtro Hoy / Semana / Mes. Sin
/// gráficos: el canvas es explícito en que el comerciante quiere el número, no
/// la curva.
class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    final resumen = state.reportSummary;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text('Reportes'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(58),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
              child: _FiltroRango(
                seleccionado: state.reportRange,
                onChanged: state.cambiarRangoReporte,
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: GridView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          // Alto fijo en vez de proporción: la tarjeta más apretada (nombre
          // del producto más vendido y su etiqueta, ambos en dos líneas) mide
          // lo mismo en cualquier ancho de pantalla.
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 14,
            crossAxisSpacing: 14,
            mainAxisExtent: 230,
          ),
          children: [
            _TarjetaCifra(
              icono: Icons.attach_money_rounded,
              iconoColor: AppColors.primary,
              iconoFondo: AppColors.primarySoft,
              valor: 'S/ ${resumen.sales.toStringAsFixed(0)}',
              valorColor: AppColors.primary,
              etiqueta: state.reportRange == ReportRange.hoy
                  ? 'Ventas del día'
                  : 'Ventas · ${state.reportRange.label.toLowerCase()}',
            ),
            _TarjetaCifra(
              icono: Icons.receipt_long_outlined,
              iconoColor: AppColors.success,
              iconoFondo: AppColors.successSoft,
              valor: '${resumen.orderCount}',
              etiqueta: 'Pedidos realizados',
            ),
            _TarjetaCifra(
              emoji: resumen.topProductEmoji,
              iconoFondo: AppColors.warningSoft,
              valor: resumen.topProduct,
              valorSize: 20,
              etiqueta: 'Más vendido · ${resumen.topProductUnits} uds',
            ),
            _TarjetaCifra(
              icono: Icons.trending_up_rounded,
              iconoColor: AppColors.transit,
              iconoFondo: AppColors.transitSoft,
              valor: 'S/ ${resumen.profit.toStringAsFixed(0)}',
              valorColor: AppColors.success,
              etiqueta: 'Ganancia total',
            ),
          ],
        ),
      ),
    );
  }
}

/// Selector segmentado Hoy / Semana / Mes.
class _FiltroRango extends StatelessWidget {
  const _FiltroRango({required this.seleccionado, required this.onChanged});

  final ReportRange seleccionado;
  final ValueChanged<ReportRange> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.fillStrong,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final rango in ReportRange.values)
            GestureDetector(
              onTap: () => onChanged(rango),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: rango == seleccionado
                      ? AppColors.primary
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  rango.label,
                  style: AppText.display(
                    15,
                    weight: rango == seleccionado
                        ? FontWeight.w700
                        : FontWeight.w600,
                    color: rango == seleccionado
                        ? Colors.white
                        : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _TarjetaCifra extends StatelessWidget {
  const _TarjetaCifra({
    this.icono,
    this.emoji,
    this.iconoColor,
    required this.iconoFondo,
    required this.valor,
    this.valorColor,
    this.valorSize = 28,
    required this.etiqueta,
  });

  final IconData? icono;

  /// Alternativa al ícono: el emoji del producto más vendido.
  final String? emoji;
  final Color? iconoColor;
  final Color iconoFondo;
  final String valor;
  final Color? valorColor;
  final double valorSize;
  final String etiqueta;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppTheme.cardDecoration,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconoFondo,
              borderRadius: BorderRadius.circular(14),
            ),
            alignment: Alignment.center,
            child: emoji != null
                ? Text(emoji!, style: const TextStyle(fontSize: 24))
                : Icon(icono, size: 26, color: iconoColor),
          ),
          // Separación fija en vez de `Spacer`: con el hueco elástico las
          // cuatro tarjetas se veían medio vacías y la cifra quedaba pegada
          // al borde inferior.
          const SizedBox(height: 14),
          Text(
            valor,
            style: AppText.display(valorSize, color: valorColor),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          // Flexible como red de seguridad: si el usuario sube la escala de
          // texto del sistema, la etiqueta se recorta en vez de desbordar.
          Flexible(
            child: Text(
              etiqueta,
              style: AppText.body(15, weight: FontWeight.w500),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
