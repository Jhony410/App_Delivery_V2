import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/addresses/screens/add_address_screen.dart';
import '../features/addresses/screens/addresses_screen.dart';
import '../features/addresses/screens/adjust_map_screen.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/register_screen.dart';
import '../features/business/screens/business_screen.dart';
import '../features/category/screens/category_screen.dart';
import '../features/checkout/screens/checkout_screen.dart';
import '../features/error/screens/not_found_screen.dart';
import '../features/history/screens/history_screen.dart';
import '../features/home/screens/home_screen.dart';
import '../features/my_town/screens/my_town_screen.dart';
import '../features/onboarding/screens/onboarding_screen.dart';
import '../features/product/screens/product_screen.dart';
import '../features/profile/screens/profile_screen.dart';
import '../features/rating/screens/rating_screen.dart';
import '../features/search/screens/search_screen.dart';
import '../features/shell/screens/main_shell.dart';
import '../features/splash/screens/splash_screen.dart';
import '../features/tracking/screens/tracking_screen.dart';
import 'app_routes.dart';

/// Configuración central de navegación con go_router.
///
/// Una única fuente de verdad (ver [AppRoutes]). Un `StatefulShellRoute`
/// preserva el estado de las 4 pestañas; `errorBuilder` y `onException`
/// garantizan que nunca aparezca la pantalla roja de error de Flutter: cualquier
/// ruta inexistente o fallo de navegación cae en una pantalla amigable de
/// "no encontrado" con botón para volver al inicio.
class AppRouter {
  AppRouter._();

  static final GlobalKey<NavigatorState> _rootKey =
      GlobalKey<NavigatorState>(debugLabel: 'root');
  static final GlobalKey<NavigatorState> _homeKey =
      GlobalKey<NavigatorState>(debugLabel: 'home');
  static final GlobalKey<NavigatorState> _searchKey =
      GlobalKey<NavigatorState>(debugLabel: 'search');
  static final GlobalKey<NavigatorState> _myTownKey =
      GlobalKey<NavigatorState>(debugLabel: 'myTown');
  static final GlobalKey<NavigatorState> _historyKey =
      GlobalKey<NavigatorState>(debugLabel: 'history');
  static final GlobalKey<NavigatorState> _profileKey =
      GlobalKey<NavigatorState>(debugLabel: 'profile');

  static final GoRouter router = GoRouter(
    navigatorKey: _rootKey,
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: false,

    // Nunca mostrar la pantalla roja: cualquier ruta inexistente o fallo de
    // navegación cae en la pantalla amigable de "no encontrado".
    // (go_router permite SOLO uno de errorBuilder / onException; usamos
    // errorBuilder porque renderiza la pantalla amigable en el sitio, sin
    // necesidad de una redirección adicional.)
    errorBuilder: (context, state) =>
        NotFoundScreen(detail: 'Ruta: ${state.uri}'),

    routes: [
      // ---- Fuera del shell ----
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
        path: AppRoutes.register,
        name: AppRoutes.nRegister,
        builder: (context, state) => const RegisterScreen(),
      ),

      // ---- Shell de 4 pestañas (estado preservado con IndexedStack) ----
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            MainShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            navigatorKey: _homeKey,
            routes: [
              GoRoute(
                path: AppRoutes.home,
                name: AppRoutes.nHome,
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _searchKey,
            routes: [
              GoRoute(
                path: AppRoutes.search,
                name: AppRoutes.nSearch,
                builder: (context, state) => const SearchScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _myTownKey,
            routes: [
              GoRoute(
                path: AppRoutes.myTown,
                name: AppRoutes.nMyTown,
                builder: (context, state) => const MyTownScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _historyKey,
            routes: [
              GoRoute(
                path: AppRoutes.history,
                name: AppRoutes.nHistory,
                builder: (context, state) => const HistoryScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _profileKey,
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

      // ---- Flujos sobre el shell (pantalla completa, cubren el bottom nav) ----
      GoRoute(
        path: AppRoutes.category,
        name: AppRoutes.nCategory,
        parentNavigatorKey: _rootKey,
        builder: (context, state) => CategoryScreen(
          categoryId: state.pathParameters['categoryId']!,
        ),
      ),
      GoRoute(
        path: AppRoutes.business,
        name: AppRoutes.nBusiness,
        parentNavigatorKey: _rootKey,
        builder: (context, state) => BusinessScreen(
          businessId: state.pathParameters['businessId']!,
        ),
      ),
      GoRoute(
        path: AppRoutes.product,
        name: AppRoutes.nProduct,
        parentNavigatorKey: _rootKey,
        builder: (context, state) => ProductScreen(
          businessId: state.pathParameters['businessId']!,
          productId: state.pathParameters['productId']!,
        ),
      ),
      GoRoute(
        path: AppRoutes.checkout,
        name: AppRoutes.nCheckout,
        parentNavigatorKey: _rootKey,
        // Página transparente: la hoja se ve sobre la pantalla anterior atenuada.
        pageBuilder: (context, state) => CustomTransitionPage<void>(
          key: state.pageKey,
          opaque: false,
          barrierDismissible: true,
          barrierColor: Colors.transparent,
          transitionsBuilder: (context, animation, secondary, child) =>
              FadeTransition(opacity: animation, child: child),
          child: const CheckoutScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.tracking,
        name: AppRoutes.nTracking,
        parentNavigatorKey: _rootKey,
        builder: (context, state) =>
            TrackingScreen(orderId: state.pathParameters['orderId']!),
      ),
      GoRoute(
        path: AppRoutes.rating,
        name: AppRoutes.nRating,
        parentNavigatorKey: _rootKey,
        builder: (context, state) =>
            RatingScreen(orderId: state.pathParameters['orderId']!),
      ),
      GoRoute(
        path: AppRoutes.addresses,
        name: AppRoutes.nAddresses,
        parentNavigatorKey: _rootKey,
        builder: (context, state) => const AddressesScreen(),
      ),
      GoRoute(
        path: AppRoutes.addAddress,
        name: AppRoutes.nAddAddress,
        parentNavigatorKey: _rootKey,
        builder: (context, state) => const AddAddressScreen(),
      ),
      GoRoute(
        path: AppRoutes.adjustMap,
        name: AppRoutes.nAdjustMap,
        parentNavigatorKey: _rootKey,
        builder: (context, state) =>
            AdjustMapScreen(from: state.uri.queryParameters['from']),
      ),
      GoRoute(
        path: AppRoutes.notFound,
        name: AppRoutes.nNotFound,
        parentNavigatorKey: _rootKey,
        builder: (context, state) => const NotFoundScreen(),
      ),
    ],
  );
}
