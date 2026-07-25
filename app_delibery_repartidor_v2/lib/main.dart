import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'firebase_options.dart';
import 'router/app_router.dart';
import 'state/app_state_scope.dart';
import 'theme/app_theme.dart';
import 'widgets/system_state_gate.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase no debe poder tumbar la app: si la configuración del proyecto no
  // está lista en este dispositivo, CHASQUI arranca igual con datos locales.
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  } catch (error, stack) {
    debugPrint('Firebase no se inicializó: $error');
    debugPrintStack(stackTrace: stack);
  }

  runApp(const ChasquiApp());
}

class ChasquiApp extends StatelessWidget {
  const ChasquiApp({super.key, this.router});

  /// Router alternativo; solo lo usan las pruebas, que necesitan una instancia
  /// limpia por caso. En producción siempre es [AppRouter.router].
  final GoRouter? router;

  @override
  Widget build(BuildContext context) {
    return AppStateScope(
      child: MaterialApp.router(
        title: 'CHASQUI · Repartidor',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        routerConfig: router ?? AppRouter.router,

        // El portero envuelve el Navigator entero: los estados del sistema
        // (frames 22, 23, 24 y 26) se montan sobre cualquier pantalla.
        builder: (context, child) => SystemStateGate(child: child ?? const SizedBox.shrink()),
      ),
    );
  }
}
