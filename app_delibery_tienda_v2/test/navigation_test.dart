// Pruebas de navegación de DelyPuno Negocios.
//
// Lo que garantizan: las 13 pantallas del diseño se construyen, están
// registradas en el router y ninguna ruta —existente o inventada— cae en la
// pantalla roja de Flutter.

import 'package:app_delibery_tienda_v2/main.dart';
import 'package:app_delibery_tienda_v2/router/app_router.dart';
import 'package:app_delibery_tienda_v2/router/app_routes.dart';
import 'package:app_delibery_tienda_v2/screens/home/home_screen.dart';
import 'package:app_delibery_tienda_v2/screens/onboarding/business_verification_screen.dart';
import 'package:app_delibery_tienda_v2/screens/onboarding/login_screen.dart';
import 'package:app_delibery_tienda_v2/screens/onboarding/onboarding_screen.dart';
import 'package:app_delibery_tienda_v2/screens/onboarding/splash_screen.dart';
import 'package:app_delibery_tienda_v2/screens/orders/new_order_alert_screen.dart';
import 'package:app_delibery_tienda_v2/screens/orders/orders_screen.dart';
import 'package:app_delibery_tienda_v2/screens/products/products_screen.dart';
import 'package:app_delibery_tienda_v2/screens/profile/profile_screen.dart';
import 'package:app_delibery_tienda_v2/screens/reports/reports_screen.dart';
import 'package:app_delibery_tienda_v2/screens/system/generic_error_screen.dart';
import 'package:app_delibery_tienda_v2/screens/system/offline_screen.dart';
import 'package:app_delibery_tienda_v2/state/app_state.dart';
import 'package:app_delibery_tienda_v2/widgets/store_shell.dart';
import 'package:app_delibery_tienda_v2/widgets/system_states.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Monta la app con router y estado limpios, en la ruta pedida.
///
/// Fija el viewport en 390×844, el tamaño de los frames del canvas. Con el
/// 800×600 por defecto de `flutter_test` el contenido de abajo (el enlace
/// "Regístralo", la cuarta tarjeta de Reportes) queda fuera de pantalla y no
/// se puede tocar.
Future<AppState> montar(
  WidgetTester tester, {
  String en = AppRoutes.splash,
  AppState? estado,
}) async {
  tester.view.physicalSize = const Size(390 * 3, 844 * 3);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final state = estado ?? AppState();
  await tester.pumpWidget(
    DelyNegociosApp(
      router: AppRouter.create(initialLocation: en),
      state: state,
    ),
  );
  await tester.pump();
  return state;
}

/// Avanza unos cuantos frames.
///
/// Sustituye a `pumpAndSettle` en las pantallas con animación en bucle —
/// splash (anillos), alerta (campana) y skeleton (shimmer)—, que por diseño no
/// se quedan quietas nunca y harían expirar el `pumpAndSettle`.
Future<void> avanzar(
  WidgetTester tester, {
  Duration paso = const Duration(milliseconds: 120),
  int frames = 6,
}) async {
  for (var i = 0; i < frames; i++) {
    await tester.pump(paso);
  }
}

/// Simula el botón/gesto atrás del sistema operativo.
///
/// Es el mismo mensaje de plataforma que envía Android, así que prueba el
/// camino real y no el `IconButton` de la barra superior.
Future<void> pulsarAtrasDelSistema(WidgetTester tester) {
  return tester.binding.defaultBinaryMessenger.handlePlatformMessage(
    'flutter/navigation',
    const JSONMethodCodec().encodeMethodCall(const MethodCall('popRoute')),
    (_) {},
  );
}

/// La pantalla roja de Flutter se pinta con `ErrorWidget`. Que no aparezca
/// nunca es el requisito central de esta integración.
void sinPantallaRoja() {
  expect(
    find.byType(ErrorWidget),
    findsNothing,
    reason: 'apareció la pantalla roja de Flutter',
  );
}

void main() {
  group('Las 13 pantallas se construyen y están enrutadas', () {
    testWidgets('01 Splash', (tester) async {
      await montar(tester);
      expect(find.byType(SplashScreen), findsOneWidget);
      sinPantallaRoja();
      // Deja correr el temporizador para no dejar timers vivos.
      await tester.pump(const Duration(seconds: 2));
      await avanzar(tester);
    });

    testWidgets('01 Splash · el degradado cubre la pantalla entera', (
      tester,
    ) async {
      await montar(tester);
      await avanzar(tester);

      // Regresión: con un `DecoratedBox` suelto, el fondo medía solo el ancho
      // del texto más largo y dejaba media pantalla en blanco.
      final fondo = tester.getSize(find.byKey(const Key('splash-background')));
      final pantalla = tester.view.physicalSize / tester.view.devicePixelRatio;
      expect(fondo.width, pantalla.width);
      expect(fondo.height, pantalla.height);

      await tester.pump(const Duration(seconds: 2));
      await avanzar(tester);
    });

    testWidgets('02 Onboarding', (tester) async {
      await montar(tester, en: AppRoutes.onboarding);
      expect(find.byType(OnboardingScreen), findsOneWidget);
      expect(find.text('Siguiente'), findsOneWidget);
      sinPantallaRoja();
    });

    testWidgets('03 Login', (tester) async {
      await montar(tester, en: AppRoutes.login);
      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.text('Ingresa a tu local'), findsOneWidget);
      sinPantallaRoja();
    });

    testWidgets('04 Verificación del negocio', (tester) async {
      await montar(tester, en: AppRoutes.businessVerification);
      expect(find.byType(BusinessVerificationScreen), findsOneWidget);
      expect(find.text('Datos de tu negocio'), findsOneWidget);
      expect(find.text('Otro'), findsOneWidget);
      sinPantallaRoja();
    });

    testWidgets('04 · "Otro" agrega un rubro propio y lo deja marcado', (
      tester,
    ) async {
      await montar(tester, en: AppRoutes.businessVerification);

      await tester.tap(find.text('Otro'));
      await tester.pumpAndSettle();
      expect(find.text('¿Cuál es tu rubro?'), findsOneWidget);

      await tester.enterText(find.byType(TextField).last, 'Ferretería');
      await tester.tap(find.text('Agregar'));
      await tester.pumpAndSettle();

      expect(find.text('🏪 Ferretería'), findsOneWidget);
      // El chip "Otro" sigue disponible para agregar más.
      expect(find.text('Otro'), findsOneWidget);
      sinPantallaRoja();
    });

    testWidgets('05 Inicio', (tester) async {
      await montar(tester, en: AppRoutes.home);
      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.text('Ver pedidos nuevos'), findsOneWidget);
      sinPantallaRoja();
    });

    testWidgets('06 Pedidos', (tester) async {
      await montar(tester, en: AppRoutes.orders);
      expect(find.byType(OrdersScreen), findsOneWidget);
      expect(find.text('Aceptar'), findsOneWidget);
      expect(find.text('Marcar como listo'), findsOneWidget);
      sinPantallaRoja();
    });

    testWidgets('07 Alerta de pedido nuevo', (tester) async {
      await montar(tester, en: AppRoutes.newOrderAlert);
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(NewOrderAlertScreen), findsOneWidget);
      expect(find.text('¡NUEVO PEDIDO!'), findsOneWidget);
      expect(find.text('Aceptar pedido'), findsOneWidget);
      sinPantallaRoja();
    });

    testWidgets('08 Productos', (tester) async {
      await montar(tester, en: AppRoutes.products);
      expect(find.byType(ProductsScreen), findsOneWidget);
      expect(find.text('Disponible'), findsNWidgets(2));
      expect(find.text('Agotado'), findsOneWidget);
      sinPantallaRoja();
    });

    testWidgets('09 Reportes', (tester) async {
      await montar(tester, en: AppRoutes.reports);
      expect(find.byType(ReportsScreen), findsOneWidget);
      expect(find.text('Ventas del día'), findsOneWidget);
      expect(find.text('Ganancia total'), findsOneWidget);
      sinPantallaRoja();
    });

    testWidgets('10 Perfil', (tester) async {
      await montar(tester, en: AppRoutes.profile);
      expect(find.byType(ProfileScreen), findsOneWidget);
      expect(find.text('Cerrar negocio'), findsOneWidget);
      expect(find.text('WhatsApp del negocio'), findsOneWidget);
      sinPantallaRoja();
    });

    testWidgets('11 Sin conexión', (tester) async {
      await montar(tester, en: AppRoutes.offline);
      expect(find.byType(OfflineScreen), findsOneWidget);
      expect(find.byType(OfflineState), findsOneWidget);
      expect(find.text('Reintentar'), findsOneWidget);
      sinPantallaRoja();
    });

    testWidgets('12 Estado vacío dentro de Pedidos', (tester) async {
      final state = AppState(seedOrders: false);
      await montar(tester, en: AppRoutes.orders, estado: state);
      expect(find.byType(SectionEmptyState), findsOneWidget);
      expect(find.text('Aún no hay pedidos'), findsOneWidget);
      // Sigue siendo un estado bajo el bottom nav, no una pantalla suelta.
      expect(find.byType(StoreShell), findsOneWidget);
      sinPantallaRoja();
    });

    testWidgets('13 Error genérico', (tester) async {
      await montar(tester, en: AppRoutes.error);
      expect(find.byType(GenericErrorScreen), findsOneWidget);
      expect(find.text('Algo salió mal'), findsOneWidget);
      expect(find.text('Volver al inicio'), findsOneWidget);
      sinPantallaRoja();
    });
  });

  group('Reglas de navegación', () {
    testWidgets('toda ruta declarada en AppRoutes.all resuelve', (
      tester,
    ) async {
      for (final ruta in AppRoutes.all) {
        await montar(tester, en: ruta);
        await avanzar(tester);
        sinPantallaRoja();
        expect(
          find.byType(GenericErrorScreen),
          ruta == AppRoutes.error ? findsOneWidget : findsNothing,
          reason: '$ruta no está registrada en el router',
        );
        // Agota el temporizador del splash antes de cambiar de ruta.
        await tester.pump(const Duration(seconds: 2));
        await avanzar(tester);
      }
    });

    testWidgets('una ruta inexistente cae en Error genérico, no en rojo', (
      tester,
    ) async {
      await montar(tester, en: '/esta-ruta-no-existe');
      expect(find.byType(GenericErrorScreen), findsOneWidget);
      expect(find.text('Algo salió mal'), findsOneWidget);
      sinPantallaRoja();
    });

    testWidgets('el bottom nav persiste en las cinco pestañas', (tester) async {
      await montar(tester, en: AppRoutes.home);

      for (final (etiqueta, pantalla) in <(String, Type)>[
        ('Pedidos', OrdersScreen),
        ('Productos', ProductsScreen),
        ('Reportes', ReportsScreen),
        ('Perfil', ProfileScreen),
        ('Inicio', HomeScreen),
      ]) {
        await tester.tap(find.text(etiqueta).last);
        await tester.pumpAndSettle();
        expect(find.byType(pantalla), findsOneWidget);
        // El shell es el mismo widget en las cinco: la barra no se remonta.
        expect(find.byType(StoreShell), findsOneWidget);
        sinPantallaRoja();
      }
    });

    testWidgets('Inicio lleva a Pedidos con "Ver pedidos nuevos"', (
      tester,
    ) async {
      await montar(tester, en: AppRoutes.home);
      await tester.tap(find.text('Ver pedidos nuevos'));
      await tester.pumpAndSettle();
      expect(find.byType(OrdersScreen), findsOneWidget);
      sinPantallaRoja();
    });

    testWidgets('Login enlaza con Verificación del negocio', (tester) async {
      await montar(tester, en: AppRoutes.login);
      await tester.tap(find.text('Regístralo'));
      await tester.pumpAndSettle();
      expect(find.byType(BusinessVerificationScreen), findsOneWidget);

      // El botón atrás del sistema devuelve al Login; antes cerraba la app
      // porque se llegaba con `go` en vez de `push`.
      await pulsarAtrasDelSistema(tester);
      await tester.pumpAndSettle();
      expect(find.byType(LoginScreen), findsOneWidget);
      sinPantallaRoja();
    });

    testWidgets('la flecha de Verificación también vuelve al Login', (
      tester,
    ) async {
      await montar(tester, en: AppRoutes.login);
      await tester.tap(find.text('Regístralo'));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.arrow_back_rounded));
      await tester.pumpAndSettle();
      expect(find.byType(LoginScreen), findsOneWidget);
      sinPantallaRoja();
    });

    testWidgets('Splash manda a Onboarding sin sesión', (tester) async {
      await montar(tester);
      await tester.pump(const Duration(seconds: 2));
      await avanzar(tester);
      expect(find.byType(OnboardingScreen), findsOneWidget);
      sinPantallaRoja();
    });

    testWidgets('Splash manda a Inicio con sesión iniciada', (tester) async {
      final state = AppState()..iniciarSesion();
      await montar(tester, estado: state);
      await tester.pump(const Duration(seconds: 2));
      await avanzar(tester);
      expect(find.byType(HomeScreen), findsOneWidget);
      sinPantallaRoja();
    });
  });

  group('Alerta de pedido nuevo', () {
    testWidgets('un pedido nuevo abre la alerta sobre la pantalla activa', (
      tester,
    ) async {
      final state = await montar(tester, en: AppRoutes.orders);

      state.simularPedidoNuevo();
      await avanzar(tester);

      expect(find.byType(NewOrderAlertScreen), findsOneWidget);
      // La pantalla de abajo sigue montada: la ruta es transparente.
      expect(find.byType(OrdersScreen), findsOneWidget);
      sinPantallaRoja();
    });

    testWidgets('cerrarla devuelve la pantalla de abajo intacta', (
      tester,
    ) async {
      final state = await montar(tester, en: AppRoutes.orders);

      state.simularPedidoNuevo();
      await avanzar(tester);
      expect(find.byType(NewOrderAlertScreen), findsOneWidget);

      await tester.tap(find.byIcon(Icons.close_rounded));
      await avanzar(tester);

      expect(find.byType(NewOrderAlertScreen), findsNothing);
      expect(find.byType(OrdersScreen), findsOneWidget);
      expect(find.byType(StoreShell), findsOneWidget);
      sinPantallaRoja();
    });
  });

  group('Estados del sistema dentro de las pestañas', () {
    testWidgets('sin conexión se monta dentro de Pedidos', (tester) async {
      final state = AppState()..alternarConexion();
      await montar(tester, en: AppRoutes.orders, estado: state);

      expect(find.byType(OfflineState), findsOneWidget);
      expect(find.byType(StoreShell), findsOneWidget);
      sinPantallaRoja();
    });

    testWidgets('el error de Pedidos se monta bajo el bottom nav', (
      tester,
    ) async {
      final state = AppState()..forzarErrorPedidos();
      await montar(tester, en: AppRoutes.orders, estado: state);

      expect(find.byType(GenericErrorState), findsOneWidget);
      expect(find.byType(StoreShell), findsOneWidget);
      sinPantallaRoja();
    });
  });
}
