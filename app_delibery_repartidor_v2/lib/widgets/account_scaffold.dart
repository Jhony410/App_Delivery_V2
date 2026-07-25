import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../router/app_routes.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import 'app_drawer.dart';

/// Envoltura común de las pantallas de cuenta (frames 14–19).
///
/// Garantiza dos cosas en todas ellas:
/// 1. el `Drawer` del frame 20 siempre está disponible, así ninguna pantalla
///    queda aislada;
/// 2. el cuerpo va dentro de un `Scaffold` con fondo del sistema.
class AccountScaffold extends StatelessWidget {
  const AccountScaffold({
    super.key,
    required this.currentRoute,
    required this.body,
    this.backgroundColor = AppColors.surface,
  });

  final String currentRoute;
  final Widget body;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      drawer: AppDrawer(currentRoute: currentRoute),
      body: body,
    );
  }
}

/// Botón cuadrado de 40×40 que abre el drawer. Sustituye al botón de volver en
/// las pantallas que en el diseño no lo tienen (frames 14, 15, 16 y 19).
class DrawerMenuButton extends StatelessWidget {
  const DrawerMenuButton({super.key, this.onSurface = false});

  /// `true` para la variante sobre fondo claro (frames 15 y 17).
  final bool onSurface;

  @override
  Widget build(BuildContext context) {
    final foreground = onSurface ? AppColors.textPrimary : Colors.white;
    return Material(
      color: onSurface ? AppColors.card : Colors.white.withValues(alpha: 0.15),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: Scaffold.of(context).openDrawer,
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: onSurface ? Border.all(color: AppColors.borderSoft) : null,
          ),
          child: Icon(Icons.menu_rounded, size: 21, color: foreground),
        ),
      ),
    );
  }
}

/// Botón de volver de los frames 17 y 18.
///
/// El drawer navega con `context.go`, así que la pila queda en una sola
/// entrada: volver siempre significa "al mapa", nunca una ruta vacía.
class BackToMapButton extends StatelessWidget {
  const BackToMapButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go(AppRoutes.operations);
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderSoft),
          ),
          child: const Icon(Icons.chevron_left_rounded, size: 24, color: AppColors.textPrimary),
        ),
      ),
    );
  }
}

/// Fila de una lista agrupada (frames 16, 18 y 19): ícono, texto y chevron.
class SettingsRow extends StatelessWidget {
  const SettingsRow({
    super.key,
    required this.icon,
    required this.label,
    this.iconColor = AppColors.primary,
    this.labelColor = AppColors.textPrimary,
    this.value,
    this.trailing,
    this.onTap,
    this.showChevron = true,
    this.divider = true,
  });

  final IconData icon;
  final String label;
  final Color iconColor;
  final Color labelColor;

  /// Valor a la derecha ("Google Maps", "Español"…).
  final String? value;

  /// Widget a la derecha; tiene prioridad sobre [value] y el chevron.
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool showChevron;
  final bool divider;

  @override
  Widget build(BuildContext context) {
    final row = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      child: Row(
        children: [
          Icon(icon, size: 21, color: iconColor),
          const SizedBox(width: 13),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppText.body(14, weight: FontWeight.w600, color: labelColor),
            ),
          ),
          if (trailing != null)
            trailing!
          else ...[
            if (value != null)
              Flexible(
                child: Text(
                  value!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.body(13, weight: FontWeight.w600),
                ),
              ),
            if (showChevron) ...[
              const SizedBox(width: 6),
              const Icon(Icons.chevron_right_rounded, size: 20, color: AppColors.neutral),
            ],
          ],
        ],
      ),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (onTap == null)
          row
        else
          Material(
            color: Colors.transparent,
            child: InkWell(onTap: onTap, child: row),
          ),
        if (divider) const Divider(height: 1, indent: 16, endIndent: 16),
      ],
    );
  }
}

/// Tarjeta blanca que agrupa varias [SettingsRow]. Frames 17, 18 y 19.
class SettingsGroup extends StatelessWidget {
  const SettingsGroup({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppTheme.rCard),
        border: Border.all(color: AppColors.borderSoft),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: children),
    );
  }
}

/// Hoja modal estándar de las pantallas de cuenta.
///
/// Toda fila que en el diseño no lleva a otro frame termina aquí en lugar de
/// no hacer nada: así ninguna acción queda muerta.
Future<void> showAccountSheet(
  BuildContext context, {
  required String title,
  String? subtitle,
  required Widget child,
}) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppColors.card,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.rSheet)),
    ),
    builder: (context) => SafeArea(
      top: false,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.8),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 12, 22, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: AppColors.handle,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(title, style: AppText.display(19)),
              if (subtitle != null) ...[
                const SizedBox(height: 6),
                Text(subtitle, style: AppText.body(13, height: 1.5)),
              ],
              const SizedBox(height: 18),
              child,
            ],
          ),
        ),
      ),
    ),
  );
}
