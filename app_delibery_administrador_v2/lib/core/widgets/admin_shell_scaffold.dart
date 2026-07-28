import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../features/dashboard/providers/dashboard_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import 'admin_shell.dart';

/// Armazón persistente del panel.
///
/// Envuelve el `StatefulShellRoute` con la barra lateral del diseño:
/// - a partir de [AppSizes.sidebarBreakpoint] es una columna fija de 260 px,
///   como en los 1440×900 del diseño;
/// - por debajo, la misma barra se presenta como `Drawer`, sin duplicar
///   navegación ni estado activo.
///
/// El `indexedStack` del shell conserva el estado de cada pestaña: al volver a
/// Pedidos, el filtro y el pedido abierto siguen donde estaban.
class AdminShellScaffold extends StatelessWidget {
  const AdminShellScaffold({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  void _irA(BuildContext context, int indice) {
    // `initialLocation: true` cuando se vuelve a pulsar la pestaña activa
    // devuelve la rama a su raíz, que es lo esperable al pulsar de nuevo
    // «Pedidos» estando en el detalle de un pedido.
    navigationShell.goBranch(
      indice,
      initialLocation: indice == navigationShell.currentIndex,
    );
    // En estrecho la barra vive en el Drawer y hay que cerrarlo al navegar.
    final scaffold = Scaffold.maybeOf(context);
    if (scaffold != null && scaffold.isDrawerOpen) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final dashboard = context.watch<DashboardProvider>();
    final compacta =
        MediaQuery.sizeOf(context).width < AppSizes.sidebarBreakpoint;

    Widget barraLateral(BuildContext context) => AdminSidebar(
      indiceActivo: navigationShell.currentIndex,
      pedidosActivos: dashboard.pedidosActivos,
      documentosPorVerificar: dashboard.documentosPorVerificar,
      onDestino: (indice) => _irA(context, indice),
    );

    if (compacta) {
      return Scaffold(
        backgroundColor: AppColors.background,
        drawer: Drawer(child: Builder(builder: barraLateral)),
        body: navigationShell,
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Builder(builder: barraLateral),
          Expanded(child: navigationShell),
        ],
      ),
    );
  }
}
