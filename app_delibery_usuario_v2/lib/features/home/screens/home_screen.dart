import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/data/demo_data.dart';
import '../../../core/state/cart_controller.dart';
import '../../../core/widgets/andean_pattern.dart';
import '../../../core/widgets/business_card.dart';
import '../../../core/widgets/common.dart';
import '../../../core/widgets/floating_cart_bar.dart';
import '../../../core/widgets/states.dart';
import '../../../router/app_routes.dart';
import '../../../theme/app_theme.dart';

/// 05 · Home (pestaña). Cabecera con dirección + Mi Pueblo, buscador, promo,
/// categorías y carruseles de comercios. Barra flotante de carrito superpuesta.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

enum _LoadStatus { loading, ready, error }

class _HomeScreenState extends State<HomeScreen> {
  _LoadStatus _status = _LoadStatus.loading;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _status = _LoadStatus.loading);
    await Future<void>.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    // Aquí iría la carga real (Firebase). Si fallara -> _LoadStatus.error.
    setState(() => _status = _LoadStatus.ready);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.screenBg,
      body: Stack(
        fit: StackFit.expand,
        children: [
          _buildBody(),
          const FloatingCartBar(),
        ],
      ),
    );
  }

  Widget _buildBody() {
    switch (_status) {
      case _LoadStatus.loading:
        return const Center(child: CircularProgressIndicator());
      case _LoadStatus.error:
        // Estado "Error carga catálogo": Reintentar recarga la misma pantalla.
        return RetryableError.catalog(onRetry: _load);
      case _LoadStatus.ready:
        return _buildContent();
    }
  }

  Widget _buildContent() {
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          _header(context),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
            child: _promoBanner(context),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionHeader(title: 'Categorías'),
                const SizedBox(height: 14),
                _categoriesGrid(context),
              ],
            ),
          ),
          const SizedBox(height: 22),
          _carousel(
            context,
            title: 'Cerca de ti',
            businesses: DemoData.businesses.take(3).toList(),
          ),
          const SizedBox(height: 22),
          _carousel(
            context,
            title: 'Más pedidos',
            businesses: DemoData.businesses.skip(3).toList(),
          ),
          const SizedBox(height: 120),
        ],
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.headerGradient,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(26)),
      ),
      child: Stack(
        children: [
          const AndeanPattern(),
          Padding(
            padding: EdgeInsets.fromLTRB(
                20, MediaQuery.of(context).padding.top + 12, 20, 22),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => context.go(AppRoutes.myTown),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Entregar en',
                                style: AppText.small
                                    .copyWith(color: const Color(0xFFCFEAD9))),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                const Icon(Icons.location_on_outlined,
                                    color: Colors.white, size: 16),
                                const SizedBox(width: 6),
                                Text('Jr. Lima 320',
                                    style: AppText.cardTitle
                                        .copyWith(color: Colors.white)),
                                const Icon(Icons.keyboard_arrow_down,
                                    color: Colors.white, size: 18),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => context.push(AppRoutes.history),
                      child: Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.notifications_none,
                            color: Colors.white, size: 20),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () => context.go(AppRoutes.search),
                  child: Container(
                    height: 50,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppRadius.card),
                      boxShadow: AppTheme.cardShadow,
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.search,
                            color: AppColors.textSecondary, size: 20),
                        const SizedBox(width: 10),
                        Text('Busca comida, farmacia, tiendas…',
                            style: AppText.body
                                .copyWith(color: AppColors.textPlaceholder)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _promoBanner(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(AppRoutes.categoryTo('comida')),
      child: Container(
        height: 150,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          gradient: AppColors.promoGradient,
          borderRadius: BorderRadius.circular(AppRadius.cardLarge),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Positioned(
              right: -10,
              bottom: -20,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 9, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFD54A),
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                        ),
                        child: Text('PROMO DEL DÍA',
                            style: AppText.badge
                                .copyWith(color: AppColors.primaryDark)),
                      ),
                      const SizedBox(height: 10),
                      Text('Envío gratis en tu\nprimer pedido',
                          style: AppText.h2.copyWith(
                              color: Colors.white, fontSize: 22, height: 1.2)),
                      const SizedBox(height: 6),
                      Text('Usa el código PUNO40',
                          style: AppText.caption
                              .copyWith(color: const Color(0xFFCFEAD9))),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _categoriesGrid(BuildContext context) {
    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 0.78,
      children: [
        for (final c in DemoData.categories)
          GestureDetector(
            onTap: () => context.push(AppRoutes.categoryTo(c.id)),
            child: Column(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppColors.greenLight,
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                  child: Icon(c.icon, color: AppColors.primary, size: 28),
                ),
                const SizedBox(height: 8),
                Text(c.name, style: AppText.caption.copyWith(
                    fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              ],
            ),
          ),
      ],
    );
  }

  Widget _carousel(BuildContext context,
      {required String title, required List<Business> businesses}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SectionHeader(
            title: title,
            actionLabel: 'Ver todo',
            onAction: () => context.push(AppRoutes.categoryTo('comida')),
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 200,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: businesses.length,
            separatorBuilder: (_, _) => const SizedBox(width: 14),
            itemBuilder: (context, i) {
              final b = businesses[i];
              return BusinessMiniCard(
                business: b,
                onTap: () {
                  cart.seedDemo();
                  context.push(AppRoutes.businessTo(b.id));
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
