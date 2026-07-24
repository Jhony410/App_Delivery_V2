import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../widgets/checkout_sheet.dart';

/// 12 · Confirmar pedido como RUTA (/checkout). Destino de la barra flotante
/// de carrito. Presenta la misma hoja arrastrable (2 estados) sobre un fondo
/// atenuado; tocar fuera cierra y vuelve atrás. Confirmar -> /tracking/:orderId.
class CheckoutScreen extends StatelessWidget {
  const CheckoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withValues(alpha: 0.35),
      body: Stack(
        children: [
          // Fondo atenuado: al tocar, cierra.
          Positioned.fill(
            child: GestureDetector(
              onTap: () => context.pop(),
              child: const ColoredBox(color: Colors.transparent),
            ),
          ),
          DraggableScrollableSheet(
            initialChildSize: 0.9,
            minChildSize: 0.6,
            maxChildSize: 0.92,
            snap: true,
            snapSizes: const [0.6, 0.92],
            expand: false,
            builder: (context, scrollController) => CheckoutSheetContent(
              scrollController: scrollController,
            ),
          ),
        ],
      ),
    );
  }
}
