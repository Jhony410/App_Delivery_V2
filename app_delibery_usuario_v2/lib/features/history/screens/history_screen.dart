import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/data/demo_data.dart';
import '../../../core/widgets/common.dart';
import '../../../core/widgets/states.dart';
import '../../../router/app_routes.dart';
import '../../../theme/app_theme.dart';

/// 07 · Historial (pestaña). Pedidos activos / completados. Un pedido activo va
/// a /tracking/:orderId; uno entregado ofrece calificar (/rating/:orderId) o
/// volver a pedir.
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final active = DemoData.orders.where((o) => !o.delivered).toList();
    final completed = DemoData.orders.where((o) => o.delivered).toList();
    final list = _tab == 0 ? active : completed;

    return Scaffold(
      backgroundColor: AppColors.screenBg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
              child: Text('Mis pedidos', style: AppText.h2),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: _segmented(),
            ),
            Expanded(
              child: list.isEmpty
                  ? const EmptyState(
                      icon: Icons.receipt_long,
                      title: 'Sin pedidos',
                      message: 'Cuando hagas un pedido aparecerá aquí.',
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                      itemCount: list.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 14),
                      itemBuilder: (context, i) => _orderCard(context, list[i]),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _segmented() {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF1EE),
        borderRadius: BorderRadius.circular(AppRadius.input),
      ),
      child: Row(
        children: [
          _segTab('Activos', 0),
          _segTab('Completados', 1),
        ],
      ),
    );
  }

  Widget _segTab(String label, int index) {
    final active = index == _tab;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _tab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: active ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(11),
            boxShadow: active ? AppTheme.cardShadow : null,
          ),
          child: Text(label,
              style: AppText.buttonSm.copyWith(
                color: active ? AppColors.textPrimary : AppColors.textSecondary,
              )),
        ),
      ),
    );
  }

  Widget _orderCard(BuildContext context, OrderSummary o) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(
            color: o.delivered ? AppColors.divider : AppColors.greenBorder,
            width: o.delivered ? 1 : 1.5),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: o.gradient),
                  borderRadius: BorderRadius.circular(13),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(o.businessName, style: AppText.cardTitle),
                    Text(o.subtitle, style: AppText.small),
                  ],
                ),
              ),
              o.delivered ? StatusBadge.delivered() : StatusBadge.enRoute(),
            ],
          ),
          const SizedBox(height: 12),
          if (!o.delivered)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.surfaceMuted2,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.pedal_bike,
                      size: 16, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Text(o.detail, style: AppText.caption),
                ],
              ),
            )
          else
            Text(o.detail, style: AppText.caption),
          const SizedBox(height: 12),
          if (!o.delivered)
            ElevatedButton(
              onPressed: () => context.push(AppRoutes.trackingTo(o.id)),
              style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(44)),
              child: const Text('Seguir pedido'),
            )
          else
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => context.push(AppRoutes.ratingTo(o.id)),
                    style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(44)),
                    icon: const Icon(Icons.star_border, size: 16),
                    label: const Text('Calificar'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Pedido añadido de nuevo')),
                    ),
                    style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(44)),
                    icon: const Icon(Icons.refresh, size: 16),
                    label: const Text('Volver a pedir'),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
