import 'package:go_router/go_router.dart';

import '../screens/account/documents_screen.dart';
import '../screens/account/earnings_screen.dart';
import '../screens/account/help_center_screen.dart';
import '../screens/account/history_screen.dart';
import '../screens/account/profile_screen.dart';
import '../screens/account/settings_screen.dart';
import '../screens/error/not_found_screen.dart';
import '../screens/onboarding/document_verification_screen.dart';
import '../screens/onboarding/location_permission_screen.dart';
import '../screens/onboarding/login_screen.dart';
import '../screens/onboarding/sms_verification_screen.dart';
import '../screens/onboarding/splash_screen.dart';
import '../screens/operations/operations_screen.dart';
import 'app_routes.dart';

/// Router único de CHASQUI.
///
/// Aquí está registrada **toda** pantalla navegable del proyecto, sin
/// excepción. Las 13 rutas cubren los 27 frames del diseño:
///
/// | Frames  | Cómo se resuelven                                            |
/// |---------|--------------------------------------------------------------|
/// | 01–05   | una ruta cada uno (onboarding)                               |
/// | 06–13   | [AppRoutes.operations]: un solo `Scaffold` con fases          |
/// | 14–19   | una ruta cada uno (cuenta y desempeño)                        |
/// | 20      | `AppDrawer`, no es ruta                                       |
/// | 21–26   | banderas de `AppState` que monta `SystemStateGate`            |
/// | 27      | librería de widgets en `lib/widgets/`                         |
///
/// Cualquier path desconocido cae en [NotFoundScreen] (pantalla 28), nunca en
/// la pantalla roja de Flutter.
class AppRouter {
  AppRouter._();

  /// Router de la app en ejecución.
  static final GoRouter router = create();

  /// Crea una instancia nueva con la misma configuración.
  ///
  /// Las pruebas la usan para no compartir el estado de navegación entre
  /// casos; la app siempre usa [router].
  static GoRouter create() => GoRouter(
    initialLocation: AppRoutes.splash,

    // Red de seguridad: sustituye el error rojo por la pantalla de marca.
    errorBuilder: (context, state) => NotFoundScreen(location: state.uri.toString()),

    routes: [
      // ---- Onboarding y acceso (frames 01–05) ----
      GoRoute(
        path: AppRoutes.splash,
        name: AppRoutes.nSplash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        name: AppRoutes.nLogin,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.smsVerification,
        name: AppRoutes.nSmsVerification,
        builder: (context, state) => const SmsVerificationScreen(),
      ),
      GoRoute(
        path: AppRoutes.locationPermission,
        name: AppRoutes.nLocationPermission,
        builder: (context, state) => const LocationPermissionScreen(),
      ),
      GoRoute(
        path: AppRoutes.documentVerification,
        name: AppRoutes.nDocumentVerification,
        builder: (context, state) => const DocumentVerificationScreen(),
      ),

      // ---- Núcleo operativo (frames 06–13, más 21 y 25 como fases) ----
      GoRoute(
        path: AppRoutes.operations,
        name: AppRoutes.nOperations,
        builder: (context, state) => const OperationsScreen(),
      ),

      // ---- Cuenta y desempeño (frames 14–19) ----
      GoRoute(
        path: AppRoutes.earnings,
        name: AppRoutes.nEarnings,
        builder: (context, state) => const EarningsScreen(),
      ),
      GoRoute(
        path: AppRoutes.history,
        name: AppRoutes.nHistory,
        builder: (context, state) => const HistoryScreen(),
      ),
      GoRoute(
        path: AppRoutes.profile,
        name: AppRoutes.nProfile,
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: AppRoutes.documents,
        name: AppRoutes.nDocuments,
        builder: (context, state) => const DocumentsScreen(),
      ),
      GoRoute(
        path: AppRoutes.settings,
        name: AppRoutes.nSettings,
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: AppRoutes.help,
        name: AppRoutes.nHelp,
        builder: (context, state) => const HelpCenterScreen(),
      ),

      // ---- Pantalla 28: fallback con identidad ----
      // Registrada además del `errorBuilder` para poder llegar a ella con
      // `context.go(AppRoutes.notFound)` desde pruebas o enlaces internos.
      GoRoute(
        path: AppRoutes.notFound,
        name: AppRoutes.nNotFound,
        builder: (context, state) => const NotFoundScreen(),
      ),
    ],
  );
}
