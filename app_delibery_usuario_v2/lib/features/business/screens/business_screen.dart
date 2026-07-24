import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/data/demo_data.dart';
import '../../../core/state/cart_controller.dart';
import '../../../core/widgets/business_card.dart';
import '../../../core/widgets/floating_cart_bar.dart';
import '../../../core/widgets/states.dart';
import '../../../router/app_routes.dart';
import '../../../theme/app_theme.dart';

/// 10 · Detalle de negocio. Estilo perfil, grilla 2 col de productos y barra
/// flotante de carrito. Producto -> /product/:businessId/:productId.
/// Incluye estado "No disponible" con Reintentar.
class BusinessScreen extends StatefulWidget {
  const BusinessScreen({super.key, required this.businessId});

  final String businessId;

  @override
  State<BusinessScreen> createState() => _BusinessScreenState();
}

enum _Status { loading, ready, unavailable }

class _BusinessScreenState extends State<BusinessScreen> {
  _Status _status = _Status.loading;
  int _activeChip = 0;

  final _chips = const ['Populares', 'Combos', 'Parrillas', 'Bebidas'];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _status = _Status.loading);
    await Future<void>.delayed(const Duration(milliseconds: 350));
    if (!mounted) return;
    final exists = DemoData.businesses.any((b) => b.id == widget.businessId);
    setState(() => _status = exists ? _Status.ready : _Status.unavailable);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.screenBg,
      body: _body(),
    );
  }

  Widget _body() {
    if (_status == _Status.loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_status == _Status.unavailable) {
      return SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                onPressed: () => context.pop(),
                icon: const Icon(Icons.arrow_back_ios_new, size: 20),
              ),
            ),
            Expanded(child: RetryableError.unavailable(onRetry: _load)),
          ],
        ),
      );
    }

    final business = DemoData.businessById(widget.businessId);
    return Stack(
      fit: StackFit.expand,
      children: [
        _content(business),
        const FloatingCartBar(),
      ],
    );
  }

  Widget _content(Business business) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _headerImage(context, business)),
        SliverToBoxAdapter(child: _infoBlock(business)),
        SliverToBoxAdapter(
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(20, 6, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Populares', style: AppText.title),
                const SizedBox(height: 14),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  childAspectRatio: 0.72,
                  children: [
                    for (final p in DemoData.products)
                      ProductGridCard(
                        product: p,
                        onTap: () => context.push(
                            AppRoutes.productTo(business.id, p.id)),
                        onAdd: () {
                          cart.add(CartItem(
                              id: p.id, name: p.name, unitPrice: p.price));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              duration: const Duration(milliseconds: 900),
                              content: Text('${p.name} agregado'),
                            ),
                          );
                        },
                      ),
                  ],
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _headerImage(BuildContext context, Business business) {
    return Container(
      height: 172 + MediaQuery.of(context).padding.top,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: business.gradient,
        ),
      ),
      padding: EdgeInsets.fromLTRB(
          20, MediaQuery.of(context).padding.top + 12, 20, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _roundBtn(Icons.arrow_back_ios_new, () => context.pop()),
          Row(
            children: [
              _roundBtn(Icons.ios_share, () {}),
              const SizedBox(width: 10),
              _roundBtn(Icons.favorite_border, () {}),
            ],
          ),
        ],
      ),
    );
  }

  Widget _roundBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.9),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 19, color: AppColors.textPrimary),
      ),
    );
  }

  Widget _infoBlock(Business business) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Transform.translate(
            offset: const Offset(0, -46),
            child: Container(
              width: 92,
              height: 92,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: business.gradient),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 4),
                boxShadow: AppTheme.cardShadow,
              ),
              child: const Icon(Icons.ramen_dining, color: Colors.white, size: 40),
            ),
          ),
          Transform.translate(
            offset: const Offset(0, -34),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(business.name, style: AppText.h1),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.star, size: 16, color: AppColors.star),
                    const SizedBox(width: 4),
                    Text('${business.rating}',
                        style: AppText.label.copyWith(fontSize: 14)),
                    const SizedBox(width: 4),
                    Text('(${business.reviews} reseñas)', style: AppText.bodySecondary),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.location_on_outlined,
                        size: 16, color: AppColors.primary),
                    const SizedBox(width: 6),
                    Expanded(
                        child: Text(business.address, style: AppText.bodySecondary)),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                  decoration: BoxDecoration(
                    color: AppColors.greenLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                            color: AppColors.success, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 8),
                      Text('Abierto ahora · entrega en ${business.eta}',
                          style: AppText.caption.copyWith(
                              color: AppColors.primaryDark,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 38,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _chips.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 9),
                    itemBuilder: (context, i) {
                      final active = i == _activeChip;
                      return GestureDetector(
                        onTap: () => setState(() => _activeChip = i),
                        child: Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          decoration: BoxDecoration(
                            color: active ? AppColors.primary : AppColors.surfaceMuted,
                            borderRadius: BorderRadius.circular(AppRadius.chip),
                          ),
                          child: Text(_chips[i],
                              style: AppText.bodySecondary.copyWith(
                                fontWeight: FontWeight.w600,
                                color: active ? Colors.white : AppColors.textPrimary,
                              )),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
