import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data/models.dart';
import '../screens/home/home_screen.dart';
import '../screens/onboarding/business_verification_screen.dart';
import '../screens/onboarding/login_screen.dart';
import '../screens/onboarding/onboarding_screen.dart';
import '../screens/onboarding/splash_screen.dart';
import '../screens/orders/new_order_alert_screen.dart';
import '../screens/orders/orders_screen.dart';
import '../screens/products/products_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/reports/reports_screen.dart';
import '../screens/system/generic_error_screen.dart';
import '../screens/system/offline_screen.dart';
import '../widgets/store_shell.dart';
import 'app_routes.dart';

/// Router único de DelyPuno Negocios.
///
/// ```text
///  MAPA DE NAVEGACIÓN — ninguna pantalla queda huérfana
///  ═══════════════════════════════════════════════════════════════════════
///
///  STACK PREVIO AL LOGIN  (sin bottom nav, raíz del Navigator)
///
///   [01 Splash]  /                        ruta inicial de la app
///        │  sesión iniciada ─────────────────────────────► [05 Inicio]
///        │  onboarding ya visto ─────────────► [03 Login]
///        └─ primera vez ──► [02 Onboarding] ─► [03 Login]
///                                                 │
///                    "Ingresar" ──────────────────┼──────► [05 Inicio]
///                    "Regístralo" ────────────────┘
///                                 ▼
///                    [04 Verificación del negocio]
///                                 │ "Continuar" (registra el local)
///                                 └──────────────────────► [05 Inicio]
///
///  ═══════════════════════════════════════════════════════════════════════
///  SHELL CON BOTTOM NAV PERSISTENTE  (StatefulShellRoute.indexedStack)
///  Las cinco ramas conservan su estado al cambiar de pestaña.
///
///   ┌────────────┬────────────┬───────────────┬─────────────┬───────────┐
///   │[05 Inicio] │[06 Pedidos]│[07 Productos] │[08 Reportes]│[09 Perfil]│
///   │  /inicio   │  /pedidos  │  /productos   │  /reportes  │  /perfil  │
///   └────────────┴────────────┴───────────────┴─────────────┴───────────┘
///          │            ▲
///          └─ "Ver pedidos nuevos" ─┘   (Inicio salta a la pestaña Pedidos)
///
///   Perfil ─ "Cerrar sesión" ─────────────────────────────► [03 Login]
///
///  ═══════════════════════════════════════════════════════════════════════
///  ESTADOS DEL SISTEMA
///
///   [10 Alerta de pedido nuevo]  /alerta-pedido
///        ▲ la abre `NewOrderAlertGate` al escuchar `AppState.nuevosPedidos`
///        │ ruta transparente sobre el shell: Inicio/Pedidos siguen montados
///        └─ Aceptar / Rechazar / atrás ─► vuelve a la pantalla de abajo intacta
///
///   [11 Sin conexión]  → widget `OfflineState`  dentro de Inicio, Pedidos y
///                        Productos, y ruta propia /sin-conexion
///   [12 Estado vacío]  → widget `SectionEmptyState` dentro de Pedidos y
///                        Productos (no tiene ruta: nunca ocupa la pantalla
///                        entera, siempre vive bajo el bottom nav)
///   [13 Error genérico]→ widget `GenericErrorState` dentro de Pedidos,
///                        ruta propia /error, `errorBuilder` del router y
///                        `ErrorWidget.builder` de la app
///
///  Cualquier path desconocido cae en [GenericErrorScreen], nunca en la
///  pantalla roja de depuración de Flutter.
/// ```
class AppRouter {
  AppRouter._();

  /// Navigator raíz. El stack previo al login y la alerta de pedido nuevo
  /// viven aquí, por encima del shell, para quedar fuera del bottom nav.
  static final GlobalKey<NavigatorState> rootNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'root');

  /// Router de la app en ejecución.
  static final GoRouter router = create();

  /// Crea una instancia nueva con la misma configuración.
  ///
  /// Las pruebas la usan para no compartir el estado de navegación entre
  /// casos; la app siempre usa [router].
  static GoRouter create({
    String initialLocation = AppRoutes.splash,
  }) => GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: initialLocation,

    // Red de seguridad nº 1: cualquier ruta inexistente muestra la pantalla
    // 13 del diseño en vez del error rojo de Flutter.
    errorBuilder: (context, state) =>
        GenericErrorScreen(location: state.uri.toString()),

    routes: [
      // ================= Stack previo al login (sin bottom nav) =============
      GoRoute(
        path: AppRoutes.splash,
        name: AppRoutes.nSplash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        name: AppRoutes.nOnboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        name: AppRoutes.nLogin,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.businessVerification,
        name: AppRoutes.nBusinessVerification,
        builder: (context, state) => const BusinessVerificationScreen(),
      ),

      // ================= Shell con bottom nav persistente ===================
      // Las cinco pestañas son ramas de un IndexedStack: cambiar de pestaña
      // no desmonta la anterior, así que Pedidos conserva su scroll y
      // Reportes su filtro.
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            StoreShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.home,
                name: AppRoutes.nHome,
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.orders,
                name: AppRoutes.nOrders,
                builder: (context, state) => const OrdersScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.products,
                name: AppRoutes.nProducts,
                builder: (context, state) => const ProductsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.reports,
                name: AppRoutes.nReports,
                builder: (context, state) => const ReportsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.profile,
                name: AppRoutes.nProfile,
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),

      // ================= Estados del sistema ================================

      // Alerta de pedido nuevo (frame 06). Va en el Navigator raíz y con
      // `opaque: false`, de modo que la pantalla de abajo sigue montada:
      // cerrarla no pierde scroll, filtros ni pestaña activa.
      GoRoute(
        path: AppRoutes.newOrderAlert,
        name: AppRoutes.nNewOrderAlert,
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) => CustomTransitionPage<void>(
          key: state.pageKey,
          opaque: false,
          barrierDismissible: false,
          barrierColor: Colors.transparent,
          transitionDuration: const Duration(milliseconds: 220),
          reverseTransitionDuration: const Duration(milliseconds: 180),
          transitionsBuilder: (context, animation, secondary, child) =>
              FadeTransition(
                opacity: animation,
                child: ScaleTransition(
                  scale: Tween<double>(begin: 1.04, end: 1).animate(
                    CurvedAnimation(parent: animation, curve: Curves.easeOut),
                  ),
                  child: child,
                ),
              ),
          child: NewOrderAlertScreen(order: state.extra as Order?),
        ),
      ),

      // Sin conexión a pantalla completa (frame 10).
      GoRoute(
        path: AppRoutes.offline,
        name: AppRoutes.nOffline,
        builder: (context, state) => const OfflineScreen(),
      ),

      // Error genérico (frame 13). Registrada además del `errorBuilder` para
      // poder llegar con `context.goNamed(AppRoutes.nError)` desde código.
      GoRoute(
        path: AppRoutes.error,
        name: AppRoutes.nError,
        builder: (context, state) => const GenericErrorScreen(),
      ),
    ],
  );
}
