import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../state/app_state_scope.dart';
import '../theme/app_theme.dart';

/// Contenedor de las cinco pestañas: Inicio, Pedidos, Productos, Reportes y
/// Perfil.
///
/// Es el `builder` del `StatefulShellRoute.indexedStack` del router, así que la
/// barra inferior es **persistente**: existe una sola vez y las cinco ramas
/// conservan su estado (scroll, filtro de reportes, formulario a medio llenar)
/// al saltar entre ellas.
class StoreShell extends StatelessWidget {
  const StoreShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final pedidosNuevos = AppStateScope.of(context).pedidosNuevos.length;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: navigationShell,
      bottomNavigationBar: _StoreBottomNav(
        currentIndex: navigationShell.currentIndex,
        pendingOrders: pedidosNuevos,
        // `initialLocation: true` devuelve la rama a su raíz cuando ya estás en
        // ella: segundo toque en la pestaña activa = volver arriba.
        onTap: (i) => navigationShell.goBranch(
          i,
          initialLocation: i == navigationShell.currentIndex,
        ),
      ),
    );
  }
}

class _StoreBottomNav extends StatelessWidget {
  const _StoreBottomNav({
    required this.currentIndex,
    required this.onTap,
    required this.pendingOrders,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  /// Pedidos por aceptar: pintan el globo rojo sobre la pestaña Pedidos.
  final int pendingOrders;

  static const _items = <({IconData icon, String label})>[
    (icon: Icons.home_outlined, label: 'Inicio'),
    (icon: Icons.receipt_long_outlined, label: 'Pedidos'),
    (icon: Icons.grid_view_rounded, label: 'Productos'),
    (icon: Icons.bar_chart_rounded, label: 'Reportes'),
    (icon: Icons.person_outline_rounded, label: 'Perfil'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.card,
        border: Border(top: BorderSide(color: AppColors.borderSoft)),
        boxShadow: AppTheme.bottomNavShadow,
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: AppTheme.hBottomNav,
          child: Row(
            children: [
              for (var i = 0; i < _items.length; i++)
                Expanded(
                  child: _NavItem(
                    icon: _items[i].icon,
                    label: _items[i].label,
                    active: i == currentIndex,
                    badge: i == 1 ? pendingOrders : 0,
                    onTap: () => onTap(i),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.active,
    required this.badge,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool active;
  final int badge;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.primary : AppColors.neutral;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(top: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(icon, size: 26, color: color),
                if (badge > 0)
                  Positioned(
                    top: -5,
                    right: -8,
                    child: Container(
                      constraints: const BoxConstraints(minWidth: 18),
                      height: 18,
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(9),
                        border: Border.all(color: AppColors.card, width: 2),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '$badge',
                        style: AppText.display(
                          11,
                          color: Colors.white,
                          height: 1,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 5),
            Text(
              label,
              style: AppText.body(
                12,
                weight: active ? FontWeight.w700 : FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
