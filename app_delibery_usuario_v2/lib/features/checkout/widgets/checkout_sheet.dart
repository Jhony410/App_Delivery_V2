import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/state/cart_controller.dart';
import '../../../router/app_routes.dart';
import '../../../theme/app_theme.dart';

/// Muestra la hoja "Confirmar pedido" como modal sobre la ruta actual
/// (usado por el botón "Agregar" del producto). Implementada como
/// DraggableScrollableSheet con 2 estados (intermedio 0.6 / expandido 0.92).
Future<void> showCheckoutSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.35),
    builder: (_) => const CheckoutSheet(),
  );
}

/// Contenedor arrastrable con 2 puntos de anclaje.
class CheckoutSheet extends StatelessWidget {
  const CheckoutSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.5,
      maxChildSize: 0.92,
      snap: true,
      snapSizes: const [0.6, 0.92],
      expand: false,
      builder: (context, scrollController) =>
          CheckoutSheetContent(scrollController: scrollController),
    );
  }
}

/// Contenido reutilizable de la hoja de checkout. Lo comparten el modal
/// (producto) y la ruta /checkout (barra flotante de carrito).
class CheckoutSheetContent extends StatefulWidget {
  const CheckoutSheetContent({super.key, required this.scrollController});

  final ScrollController scrollController;

  @override
  State<CheckoutSheetContent> createState() => _CheckoutSheetContentState();
}

class _CheckoutSheetContentState extends State<CheckoutSheetContent> {
  int _payment = 0; // 0 Efectivo, 1 Yape, 2 Plin

  Future<void> _confirm(BuildContext context) async {
    const orderId = '4821';
    // Capturamos el router ANTES del pop: tras cerrar la hoja el `context`
    // local queda desmontado y no puede usarse para navegar.
    final router = GoRouter.of(context);
    Navigator.of(context).pop(); // cierra la hoja
    cart.clear();
    router.push(AppRoutes.trackingTo(orderId)); // seguimiento del nuevo pedido
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.screenBg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.sheet)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 44,
            height: 5,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
            child: AnimatedBuilder(
              animation: cart,
              builder: (context, _) => Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Confirmar pedido', style: AppText.h2),
                    Text('${cart.count} productos en tu pedido',
                        style: AppText.bodySecondary),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: AnimatedBuilder(
              animation: cart,
              builder: (context, _) {
                if (cart.isEmpty) {
                  return Center(
                    child: Text('Tu carrito está vacío', style: AppText.bodySecondary),
                  );
                }
                return ListView(
                  controller: widget.scrollController,
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  children: [
                    _itemsCard(),
                    const SizedBox(height: 16),
                    _sectionLabel('Dirección de entrega'),
                    _addressCard(context),
                    const SizedBox(height: 16),
                    _sectionLabel('Método de pago'),
                    _paymentRow(),
                    const SizedBox(height: 16),
                    _sectionLabel('Cupón de descuento'),
                    _couponRow(),
                    const SizedBox(height: 16),
                    _sectionLabel('Resumen'),
                    _summaryCard(),
                  ],
                );
              },
            ),
          ),
          _confirmBar(context),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(text.toUpperCase(),
            style: AppText.small.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.textMuted,
              letterSpacing: 0.6,
            )),
      );

  Widget _itemsCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.card),
        boxShadow: AppTheme.cardShadow,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Column(
        children: [
          for (final item in cart.items)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                          colors: [Color(0xFFF6D9A8), Color(0xFFEDA845)]),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.name,
                            style: AppText.cardTitle
                                .copyWith(fontWeight: FontWeight.w600)),
                        Text('S/ ${item.unitPrice.toStringAsFixed(2)}',
                            style: AppText.price),
                      ],
                    ),
                  ),
                  _stepper(item.id, item.quantity),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _stepper(String id, int qty) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(11),
      ),
      child: Row(
        children: [
          _stepBtn('−', Colors.white, AppColors.textPrimary,
              () => cart.decrement(id)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text('$qty', style: AppText.label),
          ),
          _stepBtn('+', AppColors.primary, Colors.white, () => cart.increment(id)),
        ],
      ),
    );
  }

  Widget _stepBtn(String label, Color bg, Color fg, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        alignment: Alignment.center,
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
        child: Text(label,
            style: AppText.cardTitle.copyWith(color: fg, fontSize: 16)),
      ),
    );
  }

  Widget _addressCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.card),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.greenLight,
              borderRadius: BorderRadius.circular(11),
            ),
            child: const Icon(Icons.location_on_outlined,
                color: AppColors.primary, size: 19),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Casa · Jr. Lima 320', style: AppText.cardTitle),
                Text('Ref: frente a la plaza', style: AppText.caption),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              final router = GoRouter.of(context);
              Navigator.of(context).pop();
              router.push(AppRoutes.addresses);
            },
            child: Text('Cambiar', style: AppText.link),
          ),
        ],
      ),
    );
  }

  Widget _paymentRow() {
    final methods = [
      (_PayMethod('Efectivo', Icons.payments_outlined, AppColors.primary)),
      (_PayMethod('Yape', null, AppColors.yape)),
      (_PayMethod('Plin', null, AppColors.plin)),
    ];
    return Row(
      children: [
        for (var i = 0; i < methods.length; i++) ...[
          if (i > 0) const SizedBox(width: 10),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _payment = i),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _payment == i ? AppColors.greenLight : Colors.white,
                  border: Border.all(
                      color: _payment == i ? AppColors.primary : AppColors.border,
                      width: 1.5),
                  borderRadius: BorderRadius.circular(AppRadius.input),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 34,
                      height: 24,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: methods[i].color,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: methods[i].icon != null
                          ? Icon(methods[i].icon, color: Colors.white, size: 16)
                          : Text(methods[i].label[0],
                              style: AppText.badge.copyWith(color: Colors.white)),
                    ),
                    const SizedBox(height: 8),
                    Text(methods[i].label,
                        style: AppText.caption.copyWith(
                            fontWeight: FontWeight.w700,
                            color: _payment == i
                                ? AppColors.primaryDark
                                : AppColors.textPrimary)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _couponRow() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 46,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            alignment: Alignment.centerLeft,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: AppColors.border, width: 1.5),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Text('Ingresa tu código',
                style: AppText.caption.copyWith(color: AppColors.textPlaceholder)),
          ),
        ),
        const SizedBox(width: 10),
        Container(
          height: 46,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color(0xFFE9ECE8),
            borderRadius: BorderRadius.circular(13),
          ),
          child: Text('Aplicar',
              style: AppText.buttonSm.copyWith(color: const Color(0xFFB4B7B0))),
        ),
      ],
    );
  }

  Widget _summaryCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.card),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        children: [
          _summaryRow('Subtotal', 'S/ ${cart.subtotal.toStringAsFixed(2)}'),
          const SizedBox(height: 8),
          _summaryRow('Envío', 'S/ ${cart.deliveryFee.toStringAsFixed(2)}'),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(height: 1),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total', style: AppText.title),
              Text('S/ ${cart.total.toStringAsFixed(2)}',
                  style: AppText.title.copyWith(color: AppColors.primaryDark)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppText.bodySecondary),
        Text(value,
            style: AppText.body.copyWith(fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _confirmBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          20, 12, 20, 20 + MediaQuery.of(context).padding.bottom),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      child: AnimatedBuilder(
        animation: cart,
        builder: (context, _) => ElevatedButton(
          onPressed: cart.isEmpty ? null : () => _confirm(context),
          child: Text('Confirmar pedido · S/ ${cart.total.toStringAsFixed(2)}'),
        ),
      ),
    );
  }
}

class _PayMethod {
  const _PayMethod(this.label, this.icon, this.color);
  final String label;
  final IconData? icon;
  final Color color;
}
