import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data/demo_data.dart';
import '../router/app_routes.dart';
import '../state/app_state_scope.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import 'andean_pattern.dart';
import 'badges.dart';

/// Frame 20 — navegación secundaria.
///
/// Es un `Drawer`, no una ruta: se abre desde el mapa y desde cada pantalla de
/// cuenta. Es el punto de entrada real a Ganancias, Historial, Perfil,
/// Documentos, Configuración y Centro de ayuda.
class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key, required this.currentRoute});

  /// Ruta activa, para resaltar el ítem correspondiente.
  final String currentRoute;

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);

    return Drawer(
      backgroundColor: AppColors.card,
      width: 312,
      shape: const RoundedRectangleBorder(),
      child: Column(
        children: [
          BrandHeader(
            padding: const EdgeInsets.fromLTRB(22, 28, 22, 22),
            borderRadius: BorderRadius.zero,
            child: Row(
              children: [
                RiderAvatar(
                  initials: DemoData.riderInitials,
                  size: 56,
                  online: state.isOnline,
                  ringColor: AppColors.primaryDark,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        DemoData.riderName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppText.display(17, weight: FontWeight.w700, color: Colors.white),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(Icons.star_rounded, size: 12, color: AppColors.star),
                          const SizedBox(width: 5),
                          Flexible(
                            child: Text(
                              '${DemoData.riderRating} · ${state.isOnline ? 'Conectado' : 'Desconectado'}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppText.body(
                                12,
                                weight: FontWeight.w600,
                                color: AppColors.textOnBrandStrong,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(12),
              children: [
                _DrawerItem(
                  icon: Icons.map_outlined,
                  label: 'Mapa',
                  route: AppRoutes.operations,
                  currentRoute: currentRoute,
                ),
                _DrawerItem(
                  icon: Icons.trending_up_rounded,
                  label: 'Ganancias',
                  route: AppRoutes.earnings,
                  currentRoute: currentRoute,
                ),
                _DrawerItem(
                  icon: Icons.history_rounded,
                  label: 'Historial',
                  route: AppRoutes.history,
                  currentRoute: currentRoute,
                ),
                _DrawerItem(
                  icon: Icons.person_outline_rounded,
                  label: 'Perfil',
                  route: AppRoutes.profile,
                  currentRoute: currentRoute,
                ),
                _DrawerItem(
                  icon: Icons.folder_outlined,
                  label: 'Documentos',
                  route: AppRoutes.documents,
                  currentRoute: currentRoute,
                ),
                _DrawerItem(
                  icon: Icons.settings_outlined,
                  label: 'Configuración',
                  route: AppRoutes.settings,
                  currentRoute: currentRoute,
                ),
                _DrawerItem(
                  icon: Icons.help_outline_rounded,
                  label: 'Centro de ayuda',
                  route: AppRoutes.help,
                  currentRoute: currentRoute,
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () {
                    Navigator.of(context).pop();
                    state.signOut();
                    context.go(AppRoutes.login);
                  },
                  borderRadius: BorderRadius.circular(10),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        const Icon(Icons.logout_rounded, size: 22, color: AppColors.danger),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Cerrar sesión',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppText.display(15, weight: FontWeight.w700, color: AppColors.danger),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text('CHASQUI · Repartidor v1.0', style: AppText.body(11, color: AppColors.neutral)),
              ],
            ),
          ),
          SizedBox(height: MediaQuery.paddingOf(context).bottom),
        ],
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.route,
    required this.currentRoute,
  });

  final IconData icon;
  final String label;
  final String route;
  final String currentRoute;

  @override
  Widget build(BuildContext context) {
    final active = currentRoute == route;

    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Material(
        color: active ? AppColors.primarySoft : Colors.transparent,
        borderRadius: BorderRadius.circular(AppTheme.rField),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppTheme.rField),
          onTap: () {
            Navigator.of(context).pop();
            if (!active) context.go(route);
          },
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Icon(icon, size: 22, color: active ? AppColors.primary : AppColors.textSecondary),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: active
                        ? AppText.display(15, weight: FontWeight.w700, color: AppColors.primary)
                        : AppText.body(15, weight: FontWeight.w600, color: AppColors.textPrimary),
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
