import 'package:flutter/material.dart';

import '../../data/demo_data.dart';
import '../../data/models.dart';
import '../../router/app_routes.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../widgets/account_scaffold.dart';
import '../../widgets/badges.dart';
import '../../widgets/system_states.dart';

/// Frame 15 — Historial de entregas.
///
/// Cabecera fija y las entregas agrupadas por día. Si no hubiera ninguna,
/// muestra el estado vacío del frame 25 en su variante compacta en vez de una
/// lista en blanco.
class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const days = DemoData.history;

    return AccountScaffold(
      currentRoute: AppRoutes.history,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
              child: Row(
                children: [
                  const DrawerMenuButton(onSurface: true),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Historial',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.display(24),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: days.isEmpty
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: EmptyStateCard(
                          title: 'Aún no tienes entregas',
                          message: 'Conéctate y tu primer pedido aparecerá aquí',
                        ),
                      ),
                    )
                  : ListView(
                      padding: EdgeInsets.fromLTRB(
                        20,
                        6,
                        20,
                        30 + MediaQuery.paddingOf(context).bottom,
                      ),
                      children: [
                        for (final day in days) ...[
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 8, 0, 12),
                            child: Text(
                              day.label.toUpperCase(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppText.sectionLabel(),
                            ),
                          ),
                          for (final entry in day.entries)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _HistoryCard(entry: entry),
                            ),
                        ],
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Tarjeta de una entrega: negocio, hora, cliente, monto, estado y propina.
class _HistoryCard extends StatelessWidget {
  const _HistoryCard({required this.entry});

  final HistoryEntry entry;

  @override
  Widget build(BuildContext context) {
    final cancelled = entry.status == OrderStatus.cancelado;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppTheme.rCard),
        border: Border.all(color: AppColors.borderSoft),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: cancelled
                      ? null
                      : LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: entry.gradient,
                        ),
                  color: cancelled ? AppColors.dangerSoft : null,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(entry.emoji, style: const TextStyle(fontSize: 18)),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      entry.businessName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.display(14, weight: FontWeight.w700),
                    ),
                    Text(
                      '${entry.time} · ${entry.customerName}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.body(11),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    entry.amount == null ? '—' : 'S/ ${entry.amount!.toStringAsFixed(2)}',
                    maxLines: 1,
                    style: AppText.display(
                      15,
                      color: entry.amount == null ? AppColors.neutral : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  StatusChip(status: entry.status),
                ],
              ),
            ],
          ),

          // Propina: solo aparece cuando la hubo.
          if (entry.tip != null) ...[
            const SizedBox(height: 10),
            const Divider(height: 1),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.favorite_rounded, size: 14, color: AppColors.primaryOnSoft),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '+ S/ ${entry.tip!.toStringAsFixed(2)} de propina',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.body(12, weight: FontWeight.w600, color: AppColors.primaryOnSoft),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
