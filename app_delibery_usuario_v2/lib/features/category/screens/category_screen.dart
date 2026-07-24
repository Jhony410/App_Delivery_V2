import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/data/demo_data.dart';
import '../../../core/state/cart_controller.dart';
import '../../../core/widgets/business_card.dart';
import '../../../core/widgets/floating_cart_bar.dart';
import '../../../core/widgets/states.dart';
import '../../../router/app_routes.dart';
import '../../../theme/app_theme.dart';

/// 09 · Listado por categoría. Filtros + lista de comercios. Cada tarjeta va a
/// /business/:businessId. Incluye estado "Error carga catálogo" con Reintentar.
class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key, required this.categoryId});

  final String categoryId;

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

enum _Status { loading, ready, error }

class _CategoryScreenState extends State<CategoryScreen> {
  _Status _status = _Status.loading;
  int _activeFilter = 2;

  final _filters = const ['Filtros', 'Más rápido', 'Mejor calificado', 'Envío gratis'];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _status = _Status.loading);
    await Future<void>.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    setState(() => _status = _Status.ready);
  }

  @override
  Widget build(BuildContext context) {
    final category = DemoData.categoryById(widget.categoryId);
    return Scaffold(
      backgroundColor: AppColors.screenBg,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Column(
            children: [
              _header(context, category),
              Expanded(child: _body()),
            ],
          ),
          const FloatingCartBar(),
        ],
      ),
    );
  }

  Widget _header(BuildContext context, Category category) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(
          20, MediaQuery.of(context).padding.top + 12, 20, 12),
      child: Column(
        children: [
          Row(
            children: [
              _circleBtn(Icons.arrow_back_ios_new, () => context.pop()),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(category.name, style: AppText.h3),
                    Text('48 comercios cerca', style: AppText.caption),
                  ],
                ),
              ),
              _circleBtn(Icons.search, () => context.go(AppRoutes.search)),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _filters.length,
              separatorBuilder: (_, _) => const SizedBox(width: 9),
              itemBuilder: (context, i) => _filterChip(i),
            ),
          ),
        ],
      ),
    );
  }

  Widget _circleBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.surfaceMuted,
          borderRadius: BorderRadius.circular(13),
        ),
        child: Icon(icon, size: 20, color: AppColors.textPrimary),
      ),
    );
  }

  Widget _filterChip(int i) {
    final active = i == _activeFilter;
    return GestureDetector(
      onTap: () => setState(() => _activeFilter = i),
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 15),
        decoration: BoxDecoration(
          color: active ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.chip),
          border: Border.all(
              color: active ? AppColors.primary : AppColors.border, width: 1.5),
        ),
        child: Row(
          children: [
            if (i == 0)
              Padding(
                padding: const EdgeInsets.only(right: 6),
                child: Icon(Icons.tune,
                    size: 15, color: active ? Colors.white : AppColors.textPrimary),
              ),
            Text(_filters[i],
                style: AppText.bodySecondary.copyWith(
                  fontWeight: FontWeight.w600,
                  color: active ? Colors.white : AppColors.textPrimary,
                )),
          ],
        ),
      ),
    );
  }

  Widget _body() {
    switch (_status) {
      case _Status.loading:
        return const Center(child: CircularProgressIndicator());
      case _Status.error:
        return RetryableError.catalog(onRetry: _load);
      case _Status.ready:
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
          itemCount: DemoData.businesses.length,
          separatorBuilder: (_, _) => const SizedBox(height: 14),
          itemBuilder: (context, i) {
            final b = DemoData.businesses[i];
            return BusinessListCard(
              business: b,
              onTap: () {
                cart.seedDemo();
                context.push(AppRoutes.businessTo(b.id));
              },
            );
          },
        );
    }
  }
}
