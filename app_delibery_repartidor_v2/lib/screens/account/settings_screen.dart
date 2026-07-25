import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../data/demo_data.dart';
import '../../router/app_routes.dart';
import '../../state/app_state.dart';
import '../../state/app_state_scope.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../widgets/account_scaffold.dart';
import '../../widgets/badges.dart';
import '../../widgets/buttons.dart';

/// Frame 18 — Configuración.
///
/// Tres grupos: pedidos, navegación y cuenta. Todos los interruptores y
/// selectores escriben en [AppState], así que lo que se elige aquí se nota en
/// el resto de la app (por ejemplo, el atajo a la app de mapas del frame 09).
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);

    return AccountScaffold(
      currentRoute: AppRoutes.settings,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 14),
              child: Row(
                children: [
                  const BackToMapButton(),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Configuración',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.display(22),
                    ),
                  ),
                  const DrawerMenuButton(onSurface: true),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.fromLTRB(20, 6, 20, 30 + MediaQuery.paddingOf(context).bottom),
                children: [
                  const _SectionLabel('Pedidos'),
                  SettingsGroup(
                    children: [
                      SettingsRow(
                        icon: Icons.notifications_none_rounded,
                        label: 'Nuevos pedidos',
                        trailing: ChasquiSwitch(
                          value: state.newOrderAlerts,
                          onChanged: state.setNewOrderAlerts,
                        ),
                      ),
                      SettingsRow(
                        icon: Icons.volume_up_outlined,
                        label: 'Sonido de alerta',
                        trailing: ChasquiSwitch(
                          value: state.soundAlerts,
                          onChanged: state.setSoundAlerts,
                        ),
                      ),
                      SettingsRow(
                        icon: Icons.vibration_rounded,
                        label: 'Vibración',
                        iconColor: state.vibration ? AppColors.primary : AppColors.neutral,
                        divider: false,
                        trailing: ChasquiSwitch(
                          value: state.vibration,
                          onChanged: state.setVibration,
                        ),
                      ),
                    ],
                  ),

                  const _SectionLabel('Navegación'),
                  SettingsGroup(
                    children: [
                      SettingsRow(
                        icon: Icons.near_me_outlined,
                        label: 'App de mapas',
                        value: state.mapsApp,
                        onTap: () => _pickOption(
                          context,
                          title: 'App de mapas',
                          options: DemoData.mapsApps,
                          selected: state.mapsApp,
                          onSelected: state.setMapsApp,
                        ),
                      ),
                      SettingsRow(
                        icon: Icons.language_rounded,
                        label: 'Idioma',
                        value: state.language,
                        divider: false,
                        onTap: () => _pickOption(
                          context,
                          title: 'Idioma',
                          options: DemoData.languages,
                          selected: state.language,
                          onSelected: state.setLanguage,
                        ),
                      ),
                    ],
                  ),

                  const _SectionLabel('Cuenta'),
                  SettingsGroup(
                    children: [
                      SettingsRow(
                        icon: Icons.shield_outlined,
                        iconColor: AppColors.textSecondary,
                        label: 'Privacidad y datos',
                        onTap: () => _showPrivacy(context),
                      ),
                      SettingsRow(
                        icon: Icons.delete_outline_rounded,
                        label: 'Eliminar cuenta',
                        iconColor: AppColors.danger,
                        labelColor: AppColors.danger,
                        showChevron: false,
                        divider: false,
                        onTap: () => _confirmDelete(context, state),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _pickOption(
    BuildContext context, {
    required String title,
    required List<String> options,
    required String selected,
    required ValueChanged<String> onSelected,
  }) {
    showAccountSheet(
      context,
      title: title,
      child: SettingsGroup(
        children: [
          for (var i = 0; i < options.length; i++)
            SettingsRow(
              icon: options[i] == selected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_unchecked_rounded,
              iconColor: options[i] == selected ? AppColors.primary : AppColors.neutral,
              label: options[i],
              showChevron: false,
              divider: i < options.length - 1,
              onTap: () {
                onSelected(options[i]);
                Navigator.of(context).pop();
              },
            ),
        ],
      ),
    );
  }

  void _showPrivacy(BuildContext context) {
    showAccountSheet(
      context,
      title: 'Privacidad y datos',
      subtitle: 'Qué guardamos mientras repartes y para qué lo usamos.',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _PrivacyPoint(
            icon: Icons.location_on_outlined,
            text: 'Tu ubicación se registra solo mientras estás conectado, para asignarte '
                'pedidos y que el cliente siga su entrega.',
          ),
          const SizedBox(height: 12),
          const _PrivacyPoint(
            icon: Icons.receipt_long_outlined,
            text: 'Guardamos el historial de entregas y pagos por requisito contable.',
          ),
          const SizedBox(height: 12),
          const _PrivacyPoint(
            icon: Icons.block_outlined,
            text: 'Nunca compartimos tu número con el cliente: las llamadas van enmascaradas.',
          ),
          const SizedBox(height: 18),
          SecondaryButton(
            label: 'Entendido',
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, AppState state) {
    final router = GoRouter.of(context);

    showAccountSheet(
      context,
      title: '¿Eliminar tu cuenta?',
      subtitle: 'Se borran tus datos y tu historial de entregas. Esta acción no se puede '
          'deshacer y tendrás que volver a subir tus documentos si regresas.',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DangerButton(
            label: 'Sí, eliminar mi cuenta',
            icon: Icons.delete_outline_rounded,
            onPressed: () {
              Navigator.of(context).pop();
              state.signOut();
              router.go(AppRoutes.login);
            },
          ),
          const SizedBox(height: 8),
          GhostButton(
            label: 'Conservar mi cuenta',
            onPressed: () => Navigator.of(context).pop(),
            color: AppColors.textSecondary,
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 22, 2, 10),
      child: Text(
        label.toUpperCase(),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppText.sectionLabel(),
      ),
    );
  }
}

class _PrivacyPoint extends StatelessWidget {
  const _PrivacyPoint({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.fill,
        borderRadius: BorderRadius.circular(AppTheme.rField),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: AppText.body(13, height: 1.5))),
        ],
      ),
    );
  }
}
