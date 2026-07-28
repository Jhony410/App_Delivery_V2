import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/providers/sesion_provider.dart';
import '../../features/clientes/presentation/screens/clientes_screen.dart';
import '../../features/configuracion/presentation/screens/configuracion_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/mapa/presentation/screens/mapa_vivo_screen.dart';
import '../../features/negocios/presentation/screens/negocios_screen.dart';
import '../../features/negocios/presentation/screens/soporte_negocio_screen.dart';
import '../../features/pagos/presentation/screens/pagos_screen.dart';
import '../../features/pedidos/presentation/screens/pedidos_screen.dart';
import '../../features/promociones/presentation/screens/promociones_screen.dart';
import '../../features/reasignacion/presentation/screens/reasignacion_screen.dart';
import '../../features/reportes/presentation/screens/reportes_screen.dart';
import '../../features/repartidores/presentation/screens/repartidor_detalle_screen.dart';
import '../../features/repartidores/presentation/screens/repartidores_screen.dart';
import '../widgets/admin_shell_scaffold.dart';
import 'app_routes.dart';
import 'no_encontrado_screen.dart';

final GlobalKey<NavigatorState> _navegadorRaiz = GlobalKey<NavigatorState>(
  debugLabel: 'raiz',
);

/// Router del panel.
///
/// Las diez pantallas de la barra lateral viven en un
/// `StatefulShellRoute.indexedStack`, de modo que la barra persiste y cada
/// pestaña conserva su estado. El detalle de pedido, la ficha de repartidor y
/// el soporte al negocio son rutas hijas (push), así que el botón atrás
/// siempre devuelve al listado. El centro de reasignación es una ruta modal
/// sobre el navegador raíz.
GoRouter crearRouter(SesionProvider sesion) {
  return GoRouter(
    navigatorKey: _navegadorRaiz,
    initialLocation: AppRoutes.dashboard,
    refreshListenable: sesion,
    debugLogDiagnostics: false,
    redirect: (context, state) {
      final enLogin = state.matchedLocation == AppRoutes.login;
      if (!sesion.autenticado) return enLogin ? null : AppRoutes.login;
      if (enLogin) return AppRoutes.dashboard;
      return null;
    },
    errorBuilder: (context, state) =>
        NoEncontradoScreen(ruta: state.uri.toString()),
    routes: [
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),

      // Frame 06 · modal compartido, se abre sobre la pantalla que lo invoca.
      GoRoute(
        path: AppRoutes.reasignar,
        parentNavigatorKey: _navegadorRaiz,
        pageBuilder: (context, state) => CustomTransitionPage<void>(
          key: state.pageKey,
          opaque: false,
          barrierDismissible: true,
          barrierColor: Colors.transparent,
          transitionDuration: const Duration(milliseconds: 180),
          transitionsBuilder: (context, animation, _, child) =>
              FadeTransition(opacity: animation, child: child),
          child: ReasignacionScreen(
            pedidoId: Uri.decodeComponent(
              state.pathParameters['pedidoId'] ?? '',
            ),
          ),
        ),
      ),

      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AdminShellScaffold(navigationShell: navigationShell),
        branches: [
          // 01 · Dashboard
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.dashboard,
                builder: (context, state) => const DashboardScreen(),
              ),
            ],
          ),

          // 02 · Pedidos, con el detalle como ruta hija
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.pedidos,
                builder: (context, state) => const PedidosScreen(),
                routes: [
                  GoRoute(
                    path: AppRoutes.detallePedidoSegmento,
                    builder: (context, state) => PedidosScreen(
                      pedidoId: Uri.decodeComponent(
                        state.pathParameters['pedidoId'] ?? '',
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          // 03 · Mapa en vivo
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.mapa,
                builder: (context, state) => const MapaVivoScreen(),
              ),
            ],
          ),

          // 04 · Repartidores, con la ficha como ruta hija
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.repartidores,
                builder: (context, state) => const RepartidoresScreen(),
                routes: [
                  GoRoute(
                    path: AppRoutes.fichaRepartidorSegmento,
                    builder: (context, state) => RepartidorDetalleScreen(
                      repartidorId: Uri.decodeComponent(
                        state.pathParameters['repartidorId'] ?? '',
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          // 05 · Negocios, con el soporte como ruta hija
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.negocios,
                builder: (context, state) => const NegociosScreen(),
                routes: [
                  GoRoute(
                    path: AppRoutes.soporteNegocioSegmento,
                    builder: (context, state) => SoporteNegocioScreen(
                      negocioId: Uri.decodeComponent(
                        state.pathParameters['negocioId'] ?? '',
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          // 06 · Clientes
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.clientes,
                builder: (context, state) => const ClientesScreen(),
              ),
            ],
          ),

          // 07 · Promociones
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.promociones,
                builder: (context, state) => const PromocionesScreen(),
              ),
            ],
          ),

          // 08 · Reportes
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.reportes,
                builder: (context, state) => const ReportesScreen(),
              ),
            ],
          ),

          // 09 · Pagos
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.pagos,
                builder: (context, state) => const PagosScreen(),
              ),
            ],
          ),

          // 10 · Configuración
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.configuracion,
                builder: (context, state) => const ConfiguracionScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
