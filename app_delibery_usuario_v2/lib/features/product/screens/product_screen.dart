import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/data/demo_data.dart';
import '../../../core/state/cart_controller.dart';
import '../../../theme/app_theme.dart';
import '../../checkout/widgets/checkout_sheet.dart';

/// 11 · Detalle de producto. Variantes, cantidad y notas. El botón "Agregar"
/// añade al carrito y abre la hoja Confirmar Pedido como MODAL (no ruta nueva).
class ProductScreen extends StatefulWidget {
  const ProductScreen({
    super.key,
    required this.businessId,
    required this.productId,
  });

  final String businessId;
  final String productId;

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  int _qty = 1;
  int _sauce = 0;

  @override
  Widget build(BuildContext context) {
    final product = DemoData.productById(widget.productId);
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: _heroImage(context, product)),
                SliverToBoxAdapter(child: _details(product)),
              ],
            ),
          ),
          _bottomBar(context, product),
        ],
      ),
    );
  }

  Widget _heroImage(BuildContext context, Product product) {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: product.gradient,
        ),
      ),
      padding: EdgeInsets.fromLTRB(
          20, MediaQuery.of(context).padding.top + 12, 20, 0),
      child: Align(
        alignment: Alignment.topLeft,
        child: GestureDetector(
          onTap: () => context.pop(),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.9),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.arrow_back_ios_new,
                size: 18, color: AppColors.textPrimary),
          ),
        ),
      ),
    );
  }

  Widget _details(Product product) {
    return Transform.translate(
      offset: const Offset(0, -22),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.sheet)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: Text(product.name, style: AppText.h2)),
                Text('S/ ${product.price.toStringAsFixed(2)}',
                    style: AppText.h3.copyWith(color: AppColors.primaryDark)),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'Cuarto de pollo jugoso, con papas fritas doradas, ensalada fresca '
              'y las cremas de la casa.',
              style: AppText.bodySecondary.copyWith(height: 1.55),
            ),
            const SizedBox(height: 22),
            Row(
              children: [
                Text('Elige el tamaño', style: AppText.title.copyWith(fontSize: 15)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                  child: Text('Obligatorio',
                      style: AppText.small.copyWith(
                          color: Colors.white, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _sizeOption(product),
            const SizedBox(height: 22),
            Text('Cremas extra', style: AppText.title.copyWith(fontSize: 15)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 9,
              children: [
                _sauceChip('Ají', 0),
                _sauceChip('Mayonesa', 1),
                _sauceChip('Mostaza', 2),
              ],
            ),
            const SizedBox(height: 22),
            Text('Notas para el restaurante',
                style: AppText.title.copyWith(fontSize: 15)),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              constraints: const BoxConstraints(minHeight: 58),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surfaceMuted2,
                borderRadius: BorderRadius.circular(AppRadius.input),
              ),
              child: TextField(
                maxLines: 2,
                style: AppText.bodySecondary,
                decoration: InputDecoration.collapsed(
                  hintText: 'Ej: sin ensalada, extra crujiente…',
                  hintStyle: AppText.bodySecondary
                      .copyWith(color: AppColors.textPlaceholder),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _sizeOption(Product product) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.greenLight,
        border: Border.all(color: AppColors.primary, width: 1.5),
        borderRadius: BorderRadius.circular(AppRadius.input),
      ),
      child: Row(
        children: [
          Text('Tamaño estándar', style: AppText.body),
          const Spacer(),
          Text('Incluido', style: AppText.bodySecondary),
          const SizedBox(width: 12),
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primary, width: 6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sauceChip(String label, int index) {
    final active = index == _sauce;
    return GestureDetector(
      onTap: () => setState(() => _sauce = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 9),
        decoration: BoxDecoration(
          color: active ? AppColors.greenLight : Colors.white,
          border: Border.all(
              color: active ? AppColors.primary : AppColors.border, width: 1.5),
          borderRadius: BorderRadius.circular(AppRadius.chip),
        ),
        child: Text(label,
            style: AppText.bodySecondary.copyWith(
              fontWeight: FontWeight.w600,
              color: active ? AppColors.primaryDark : AppColors.textPrimary,
            )),
      ),
    );
  }

  Widget _bottomBar(BuildContext context, Product product) {
    final total = product.price * _qty;
    return Container(
      padding: EdgeInsets.fromLTRB(
          20, 14, 20, 14 + MediaQuery.of(context).padding.bottom),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      child: Row(
        children: [
          Container(
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: 6),
            decoration: BoxDecoration(
              color: AppColors.surfaceMuted,
              borderRadius: BorderRadius.circular(AppRadius.card),
            ),
            child: Row(
              children: [
                _qtyBtn('−', Colors.white, AppColors.textPrimary,
                    () => setState(() => _qty = _qty > 1 ? _qty - 1 : 1)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Text('$_qty', style: AppText.title),
                ),
                _qtyBtn('+', AppColors.primary, Colors.white,
                    () => setState(() => _qty++)),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  cart.add(CartItem(
                    id: product.id,
                    name: product.name,
                    unitPrice: product.price,
                    quantity: _qty,
                  ));
                  showCheckoutSheet(context);
                },
                child: Text('Agregar · S/ ${total.toStringAsFixed(2)}'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _qtyBtn(String label, Color bg, Color fg, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        alignment: Alignment.center,
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(11)),
        child: Text(label, style: AppText.h3.copyWith(color: fg)),
      ),
    );
  }
}
