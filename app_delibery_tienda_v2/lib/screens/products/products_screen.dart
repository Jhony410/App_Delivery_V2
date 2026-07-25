import 'package:flutter/material.dart';

import '../../state/app_state.dart';
import '../../state/app_state_scope.dart';
import '../../theme/app_theme.dart';
import '../../widgets/product_card.dart';
import '../../widgets/skeleton.dart';
import '../../widgets/system_states.dart';

/// **Pantalla 08 · Productos.** Tercera pestaña del bottom nav.
///
/// Catálogo del local con disponibilidad conmutable y botón Editar por
/// producto, más el FAB de "agregar".
///
/// Estados del sistema que monta, todos por debajo del bottom nav:
/// - **Sin conexión** (frame 10) con `LoadStatus.sinConexion`
/// - **Estado vacío** (frame 12) cuando el catálogo está vacío
/// - **Carga · skeleton** (frame 11) con `LoadStatus.cargando`
class ProductsScreen extends StatelessWidget {
  const ProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text('Mis productos'),
      ),
      floatingActionButton: state.productsStatus == LoadStatus.listo
          ? _FabAgregar(
              onPressed: () => _pendiente(context, 'Agregar producto'),
            )
          : null,
      body: SafeArea(top: false, child: _cuerpo(context, state)),
    );
  }

  Widget _cuerpo(BuildContext context, AppState state) {
    switch (state.productsStatus) {
      case LoadStatus.cargando:
        return const OrdersSkeleton(itemCount: 3);

      case LoadStatus.sinConexion:
        return OfflineState(onRetry: state.reintentar);

      case LoadStatus.error:
        return GenericErrorState(
          onRetry: state.reintentar,
          message: 'No pudimos cargar tu catálogo. Inténtalo de nuevo.',
        );

      case LoadStatus.listo:
        if (state.products.isEmpty) {
          return const SectionEmptyState(
            title: 'Aún no hay productos',
            message:
                'Agrega lo que vendes con el botón +. Sin productos, tu local no aparece para los clientes.',
            icon: Icons.grid_view_rounded,
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(20, 6, 20, 100),
          itemCount: state.products.length,
          separatorBuilder: (_, _) => const SizedBox(height: 14),
          itemBuilder: (context, i) {
            final product = state.products[i];
            return ProductCard(
              product: product,
              onToggle: (_) => state.alternarDisponibilidad(product.id),
              onEdit: () => _pendiente(context, 'Editar ${product.name}'),
            );
          },
        );
    }
  }

  /// El canvas no define el formulario de alta/edición; hasta que exista se
  /// avisa en vez de navegar a una pantalla en blanco.
  void _pendiente(BuildContext context, String accion) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            '$accion · disponible en la siguiente entrega',
            style: AppText.body(
              15,
              weight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          backgroundColor: AppColors.textPrimary,
          behavior: SnackBarBehavior.floating,
        ),
      );
  }
}

/// FAB cuadrado rojo del canvas (radio 20, no circular).
class _FabAgregar extends StatelessWidget {
  const _FabAgregar({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.rFab),
        boxShadow: AppTheme.fabShadow,
      ),
      child: SizedBox(
        width: 64,
        height: 64,
        child: FloatingActionButton(
          onPressed: onPressed,
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.rFab),
          ),
          tooltip: 'Agregar producto',
          child: const Icon(Icons.add_rounded, size: 30),
        ),
      ),
    );
  }
}
