import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:app_delibery_repartidor_v2/main.dart';
import 'package:app_delibery_repartidor_v2/screens/account/documents_screen.dart';
import 'package:app_delibery_repartidor_v2/screens/account/earnings_screen.dart';
import 'package:app_delibery_repartidor_v2/screens/account/help_center_screen.dart';
import 'package:app_delibery_repartidor_v2/screens/account/history_screen.dart';
import 'package:app_delibery_repartidor_v2/screens/account/profile_screen.dart';
import 'package:app_delibery_repartidor_v2/screens/account/settings_screen.dart';
import 'package:app_delibery_repartidor_v2/router/app_router.dart';
import 'package:app_delibery_repartidor_v2/router/app_routes.dart';
import 'package:app_delibery_repartidor_v2/screens/error/not_found_screen.dart';
import 'package:app_delibery_repartidor_v2/screens/onboarding/login_screen.dart';
import 'package:app_delibery_repartidor_v2/screens/onboarding/splash_screen.dart';
import 'package:app_delibery_repartidor_v2/screens/operations/operations_screen.dart';
import 'package:app_delibery_repartidor_v2/state/app_state_scope.dart';
import 'package:app_delibery_repartidor_v2/widgets/skeleton.dart';

/// Verificación del PASO 4: ninguna ruta puede terminar en pantalla de error.
void main() {
  setUpAll(() {
    // Sin red en las pruebas: que caiga a la fuente del sistema en vez de
    // intentar descargar Poppins/Inter.
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  /// Deja la ventana con el tamaño del diseño (390×844 @3x).
  void useDesignViewport(WidgetTester tester) {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);
  }

  testWidgets('la app arranca en el splash, sin pantalla roja', (tester) async {
    useDesignViewport(tester);

    await tester.pumpWidget(ChasquiApp(router: AppRouter.create()));
    await tester.pump();

    expect(find.byType(SplashScreen), findsOneWidget);
    expect(tester.takeException(), isNull);

    // El splash navega solo al login a los 2.2 s. Tras disparar el temporizador
    // hacen falta más frames: go_router resuelve la ruta de forma asíncrona.
    await tester.pump(const Duration(milliseconds: 2400));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(SplashScreen), findsNothing);
    expect(find.byType(LoginScreen), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('las 13 rutas registradas resuelven sin caer en el fallback', (tester) async {
    useDesignViewport(tester);

    final router = AppRouter.create();
    await tester.pumpWidget(ChasquiApp(router: router));
    await tester.pump();

    for (final route in AppRoutes.all) {
      router.go(route);
      await tester.pump();
      // Margen para el skeleton del mapa (1.1 s) y las animaciones de entrada.
      await tester.pump(const Duration(milliseconds: 1400));

      expect(tester.takeException(), isNull, reason: 'La ruta $route lanzó una excepción');

      if (route != AppRoutes.notFound) {
        expect(
          find.byType(NotFoundScreen),
          findsNothing,
          reason: 'La ruta $route cayó en la pantalla de "no encontrado"',
        );
      }
    }
  });

  testWidgets('una ruta desconocida muestra el fallback de marca, no el error rojo', (tester) async {
    useDesignViewport(tester);

    final router = AppRouter.create();
    await tester.pumpWidget(ChasquiApp(router: router));
    await tester.pump();

    router.go('/ruta-que-no-existe');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byType(NotFoundScreen), findsOneWidget);
    expect(find.text('Este camino no existe'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('el núcleo operativo recorre los frames 21 → 06 → 08 → 09 → 10 → 11 → 12',
      (tester) async {
    useDesignViewport(tester);

    final router = AppRouter.create();
    await tester.pumpWidget(ChasquiApp(router: router));
    await tester.pump();

    router.go(AppRoutes.operations);
    await tester.pump();
    // El mapa arranca con el skeleton del frame 24 durante 1.1 s.
    await tester.pump(const Duration(milliseconds: 1400));

    // Frame 21 — desconectado.
    expect(find.text('Conectarme'), findsOneWidget);
    await tester.tap(find.text('Conectarme'));
    await tester.pump(const Duration(milliseconds: 400));

    // Frame 06 — buscando, con los disparadores de oferta.
    expect(find.text('Simular pedido'), findsOneWidget);
    await tester.tap(find.text('Simular pedido'));
    await tester.pump(const Duration(milliseconds: 400));

    // Frame 08 — oferta entrante.
    expect(find.text('ACEPTAR PEDIDO'), findsOneWidget);
    await tester.tap(find.text('ACEPTAR PEDIDO'));
    await tester.pump(const Duration(milliseconds: 400));

    // Frame 09 → 10 → 11 → 12.
    expect(find.text('Llegué al restaurante'), findsOneWidget);
    await tester.tap(find.text('Llegué al restaurante'));
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Confirmar recojo'), findsOneWidget);
    await tester.tap(find.text('Confirmar recojo'));
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Llegué con el cliente'), findsOneWidget);
    await tester.tap(find.text('Llegué con el cliente'));
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('¡Ya llegaste!'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('el lote multi-pedido (frame 13) es alcanzable desde el mapa', (tester) async {
    useDesignViewport(tester);

    final router = AppRouter.create();
    await tester.pumpWidget(ChasquiApp(router: router));
    await tester.pump();

    router.go(AppRoutes.operations);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1400));

    await tester.tap(find.text('Conectarme'));
    await tester.pump(const Duration(milliseconds: 400));

    await tester.tap(find.text('Lote de 3'));
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Empezar con Pedido 1'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('los estados del sistema (frames 22, 23, 24 y 26) se montan sobre el mapa',
      (tester) async {
    useDesignViewport(tester);

    final router = AppRouter.create();
    await tester.pumpWidget(ChasquiApp(router: router));
    await tester.pump();

    router.go(AppRoutes.operations);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1400));

    final state = AppStateScope.read(tester.element(find.byType(OperationsScreen)));

    // Frame 22 — sin internet.
    state.setInternet(false);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Sin conexión a internet'), findsOneWidget);
    expect(tester.takeException(), isNull);

    // Frame 26 — error genérico.
    state.setInternet(true);
    state.raiseError();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Algo salió mal'), findsOneWidget);
    expect(tester.takeException(), isNull);

    // Frame 23 — GPS desactivado (solo cuenta si está conectado).
    state.clearError();
    state.setOnline(true);
    state.setGps(false);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Activa tu GPS'), findsOneWidget);
    expect(tester.takeException(), isNull);

    // Frame 24 — skeleton de carga.
    state.setGps(true);
    state.setLoading(true);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(OperationsSkeleton), findsOneWidget);
    expect(tester.takeException(), isNull);

    // Al bajar todas las banderas, el mapa vuelve sin dejar rastro.
    state.setLoading(false);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(OperationsSkeleton), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('el drawer lleva a las seis pantallas de cuenta', (tester) async {
    useDesignViewport(tester);

    final router = AppRouter.create();
    await tester.pumpWidget(ChasquiApp(router: router));
    await tester.pump();

    router.go(AppRoutes.operations);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1400));

    final destinations = <String, Type>{
      'Ganancias': EarningsScreen,
      'Historial': HistoryScreen,
      'Perfil': ProfileScreen,
      'Documentos': DocumentsScreen,
      'Configuración': SettingsScreen,
      'Centro de ayuda': HelpCenterScreen,
    };

    for (final entry in destinations.entries) {
      // El drawer se abre desde el botón de menú de la pantalla actual.
      // Hacen falta dos pump: el primero arranca el ticker, el segundo deja
      // la animación de apertura terminada para poder tocar el ítem.
      await tester.tap(find.byIcon(Icons.menu_rounded).first);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      await tester.tap(find.text(entry.key).last);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pump(const Duration(milliseconds: 600));

      expect(
        find.byType(entry.value),
        findsOneWidget,
        reason: 'El ítem "${entry.key}" del drawer no llegó a ${entry.value}',
      );
      expect(tester.takeException(), isNull, reason: '${entry.value} lanzó una excepción');
    }
  });

  testWidgets('desde el fallback se vuelve al mapa', (tester) async {
    useDesignViewport(tester);

    final router = AppRouter.create();
    await tester.pumpWidget(ChasquiApp(router: router));
    await tester.pump();

    router.go('/otra-ruta-rota');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    await tester.tap(find.text('Volver al mapa'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1400));

    expect(find.byType(OperationsScreen), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
