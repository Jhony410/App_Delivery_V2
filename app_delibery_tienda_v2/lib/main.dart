import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'firebase_options.dart';
import 'router/app_router.dart';
import 'screens/system/generic_error_screen.dart';
import 'state/app_state.dart';
import 'state/app_state_scope.dart';
import 'theme/app_theme.dart';
import 'widgets/new_order_alert_gate.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  instalarPantallaDeErrorDeMarca();

  // Firebase no debe poder tumbar la app: si la configuración del proyecto no
  // está lista en este dispositivo, el panel arranca igual con datos locales.
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (error, stack) {
    debugPrint('Firebase no se inicializó: $error');
    debugPrintStack(stackTrace: stack);
  }

  runApp(const DelyNegociosApp());
}

/// Sustituye la pantalla roja de depuración de Flutter por la pantalla 12 del
/// diseño ("Algo salió mal").
///
/// `ErrorWidget.builder` cubre lo que el `errorBuilder` del router no puede:
/// una excepción lanzada **dentro** del `build` de cualquier widget. Se instala
/// para los dos modos:
/// - en **debug**, donde Flutter mostraría el recuadro rojo con el stack
/// - en **release**, donde mostraría un rectángulo gris vacío
///
/// El detalle técnico se sigue enviando a la consola, y en debug se pinta al
/// pie de la pantalla para no perder información al depurar.
void instalarPantallaDeErrorDeMarca() {
  ErrorWidget.builder = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    return GenericErrorScreen(details: details.exceptionAsString());
  };
}

class DelyNegociosApp extends StatelessWidget {
  const DelyNegociosApp({super.key, this.router, this.state});

  /// Router alternativo; solo lo usan las pruebas, que necesitan una instancia
  /// limpia por caso. En producción siempre es [AppRouter.router].
  final GoRouter? router;

  /// Estado alternativo; igual que [router], solo para pruebas.
  final AppState? state;

  @override
  Widget build(BuildContext context) {
    return AppStateScope(
      state: state,
      child: MaterialApp.router(
        title: 'DelyPuno · Negocios',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        routerConfig: router ?? AppRouter.router,

        // El gate envuelve el Navigator entero: la alerta de pedido nuevo
        // (frame 06) puede saltar sobre cualquier pantalla del shell.
        builder: (context, child) =>
            NewOrderAlertGate(child: child ?? const SizedBox.shrink()),
      ),
    );
  }
}
