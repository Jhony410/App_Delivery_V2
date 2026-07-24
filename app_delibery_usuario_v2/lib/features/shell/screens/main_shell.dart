import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../theme/app_theme.dart';

/// Scaffold contenedor del `StatefulShellRoute`. Muestra la barra de
/// navegación inferior con 4 pestañas (Home, Búsqueda, Historial, Perfil) y
/// preserva el estado de cada una gracias al IndexedStack del shell.
class MainShell extends StatelessWidget {
  const MainShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  static const _tabs = <_TabSpec>[
    _TabSpec(icon: Icons.home_outlined, active: Icons.home_rounded, label: 'Inicio'),
    _TabSpec(icon: Icons.search, active: Icons.search, label: 'Búsqueda'),
    _TabSpec(
        icon: Icons.landscape_outlined,
        active: Icons.landscape,
        label: 'Mi Pueblo'),
    _TabSpec(
        icon: Icons.receipt_long_outlined,
        active: Icons.receipt_long,
        label: 'Pedidos'),
    _TabSpec(
        icon: Icons.person_outline, active: Icons.person, label: 'Perfil'),
  ];

  void _goBranch(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: const Border(top: BorderSide(color: AppColors.divider)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 24,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 66,
            child: Row(
              children: [
                for (var i = 0; i < _tabs.length; i++)
                  Expanded(
                    child: _NavItem(
                      spec: _tabs[i],
                      selected: navigationShell.currentIndex == i,
                      onTap: () => _goBranch(i),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({required this.spec, required this.selected, required this.onTap});

  final _TabSpec spec;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.primary : AppColors.textMuted;
    return InkResponse(
      onTap: onTap,
      radius: 40,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(selected ? spec.active : spec.icon, color: color, size: 24),
          const SizedBox(height: 5),
          Text(
            spec.label,
            style: AppText.navLabel.copyWith(
              color: color,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _TabSpec {
  const _TabSpec({required this.icon, required this.active, required this.label});
  final IconData icon;
  final IconData active;
  final String label;
}
