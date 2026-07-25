import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../data/demo_data.dart';
import '../../data/models.dart';
import '../../router/app_routes.dart';
import '../../state/app_state_scope.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../widgets/account_scaffold.dart';
import '../../widgets/andean_pattern.dart';
import '../../widgets/badges.dart';
import '../../widgets/buttons.dart';

/// Frame 16 — Perfil.
///
/// Cabecera verde con foto y calificación, tarjeta de desempeño montada sobre
/// el degradado, y la lista de datos de la cuenta.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AccountScaffold(
      currentRoute: AppRoutes.profile,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // La cabecera lleva 60px extra abajo porque la tarjeta de
            // desempeño se sube 38px sobre ella (igual que en el diseño).
            BrandHeader(
              borderRadius: BorderRadius.zero,
              padding: const EdgeInsets.fromLTRB(22, 14, 22, 60),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Row(children: [DrawerMenuButton()]),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x4D000000),
                              blurRadius: 18,
                              offset: Offset(0, 6),
                              spreadRadius: -4,
                            ),
                          ],
                        ),
                        child: Text(
                          DemoData.riderInitials,
                          style: AppText.display(26, color: AppColors.primary),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              DemoData.riderName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppText.display(21, color: Colors.white),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              DemoData.riderSince,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppText.body(12, color: AppColors.textOnBrandSoft),
                            ),
                            const SizedBox(height: 8),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: RatingPill(
                                label: '${DemoData.riderRating} · ${DemoData.riderTier}',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ---- Tarjeta de desempeño (superpuesta) + lista de la cuenta ----
            // Van juntas en un solo Transform: así se suben 38px sobre el
            // degradado sin dejar un hueco al final del scroll.
            Transform.translate(
              offset: const Offset(0, -38),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 10),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(AppTheme.rCardLarge),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x26000000),
                            blurRadius: 24,
                            offset: Offset(0, 8),
                            spreadRadius: -8,
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: _Stat(
                              value: _thousands(DemoData.riderDeliveries),
                              label: 'Entregas',
                              color: AppColors.primary,
                            ),
                          ),
                          const _StatDivider(),
                          Expanded(
                            child: _Stat(value: '${DemoData.riderAcceptance}%', label: 'Aceptación'),
                          ),
                          const _StatDivider(),
                          Expanded(
                            child: _Stat(value: '${DemoData.riderRating}', label: 'Calificación'),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ---- Lista de la cuenta ----
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      20,
                      22,
                      20,
                      // +38 devuelve el espacio que consumió el Transform.
                      68 + MediaQuery.paddingOf(context).bottom,
                    ),
                    child: SettingsGroup(
                      children: [
                        for (final detail in DemoData.profileDetails)
                          SettingsRow(
                            icon: detail.icon,
                            label: detail.title,
                            onTap: () => _showDetail(context, detail),
                          ),
                        SettingsRow(
                          icon: Icons.logout_rounded,
                          label: 'Cerrar sesión',
                          iconColor: AppColors.danger,
                          labelColor: AppColors.danger,
                          showChevron: false,
                          divider: false,
                          onTap: () => _confirmSignOut(context),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// "1284" → "1,284", como en el diseño.
  static String _thousands(int value) {
    final digits = value.toString();
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(',');
      buffer.write(digits[i]);
    }
    return buffer.toString();
  }

  void _showDetail(BuildContext context, ProfileDetail detail) {
    showAccountSheet(
      context,
      title: detail.title,
      child: SettingsGroup(
        children: [
          for (var i = 0; i < detail.fields.length; i++)
            SettingsRow(
              icon: detail.icon,
              label: detail.fields[i].$1,
              value: detail.fields[i].$2,
              showChevron: false,
              divider: i < detail.fields.length - 1,
            ),
        ],
      ),
    );
  }

  void _confirmSignOut(BuildContext context) {
    final state = AppStateScope.read(context);
    final router = GoRouter.of(context);

    showAccountSheet(
      context,
      title: '¿Cerrar sesión?',
      subtitle: 'Dejarás de recibir pedidos hasta que vuelvas a entrar.',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DangerButton(
            label: 'Sí, cerrar sesión',
            icon: Icons.logout_rounded,
            onPressed: () {
              Navigator.of(context).pop();
              state.signOut();
              router.go(AppRoutes.login);
            },
          ),
          const SizedBox(height: 8),
          GhostButton(
            label: 'Seguir conectado',
            onPressed: () => Navigator.of(context).pop(),
            color: AppColors.textSecondary,
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label, this.color = AppColors.textPrimary});

  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(value, style: AppText.display(22, color: color)),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppText.body(11),
        ),
      ],
    );
  }
}

class _StatDivider extends StatelessWidget {
  const _StatDivider();

  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 34, color: AppColors.borderSoft);
  }
}
