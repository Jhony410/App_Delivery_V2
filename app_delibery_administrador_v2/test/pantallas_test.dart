import 'package:app_delibery_administrador_v2/app.dart';
import 'package:app_delibery_administrador_v2/core/widgets/admin_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Recorre las 13 pantallas del diseño en el tamaño de escritorio del diseño
/// (1440×900) y en los dos tamaños de móvil del PASO 7 (360×640 y 430×932),
/// comprobando que ninguna lanza una excepción ni desborda.
void main() {
  const tamanos = <String, Size>{
    'escritorio 1440×900': Size(1440, 900),
    'móvil chico 360×640': Size(360, 640),
    'móvil grande 430×932': Size(430, 932),
  };

  for (final entrada in tamanos.entries) {
    testWidgets('recorre las 13 pantallas · ${entrada.key}', (tester) async {
      _fijarTamano(tester, entrada.value);

      await tester.pumpWidget(const DelyPunoAdminApp());
      await _reposar(tester);

      await _iniciarSesion(tester);
      expect(tester.takeException(), isNull, reason: 'acceso al panel');

      final compacta = entrada.value.width < 900;

      for (final destino in DestinoAdmin.todos) {
        await _abrirDestino(tester, destino.etiqueta, compacta: compacta);
        expect(
          tester.takeException(),
          isNull,
          reason: 'pantalla ${destino.etiqueta} en ${entrada.key}',
        );
      }

      // Rutas hijas: detalle de pedido, ficha de repartidor y soporte.
      await _abrirDestino(tester, 'Pedidos', compacta: compacta);
      await _tocarPrimero(tester, find.text('#A-2485'));
      expect(tester.takeException(), isNull, reason: 'detalle de pedido');

      await _abrirDestino(tester, 'Repartidores', compacta: compacta);
      await _tocarPrimero(tester, find.text('Rubén Mamani'));
      expect(tester.takeException(), isNull, reason: 'ficha de repartidor');

      await _abrirDestino(tester, 'Negocios', compacta: compacta);
      await _tocarPrimero(tester, find.text('Chifa Titicaca'));
      expect(tester.takeException(), isNull, reason: 'soporte al negocio');
    });
  }

  testWidgets('el centro de reasignación se abre y se cierra sobre Pedidos', (
    tester,
  ) async {
    _fijarTamano(tester, const Size(1440, 900));

    await tester.pumpWidget(const DelyPunoAdminApp());
    await _reposar(tester);
    await _iniciarSesion(tester);

    await _abrirDestino(tester, 'Pedidos', compacta: false);
    expect(find.text('Reasignar'), findsWidgets, reason: 'panel de detalle');

    await _tocarPrimero(tester, find.text('Reasignar'));
    expect(tester.takeException(), isNull, reason: 'apertura del modal');
    expect(find.text('Reasignar repartidor'), findsOneWidget);
    // Sin motivo elegido, ningún candidato se puede asignar todavía.
    expect(find.text('Elige un motivo para poder asignar'), findsOneWidget);

    await _tocarPrimero(tester, find.byIcon(Icons.close));
    expect(tester.takeException(), isNull, reason: 'cierre del modal');
    expect(find.text('Reasignar repartidor'), findsNothing);
  });
}

/// Fija el tamaño lógico de la ventana.
///
/// Hay que forzar `devicePixelRatio` a 1: el entorno de pruebas usa 3 por
/// defecto, así que sin esto un «1440×900» se convertiría en 480×300 lógicos
/// y no estaríamos midiendo el tamaño que dice la prueba.
void _fijarTamano(WidgetTester tester, Size tamano) {
  tester.view
    ..physicalSize = tamano
    ..devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
}

/// Avanza varios fotogramas sin usar `pumpAndSettle`: el panel tiene
/// animaciones que se repiten a propósito (punto «en vivo», anillo del
/// marcador, skeleton de carga) y nunca quedarían en reposo.
Future<void> _reposar(WidgetTester tester, [int fotogramas = 6]) async {
  for (var i = 0; i < fotogramas; i++) {
    await tester.pump(const Duration(milliseconds: 200));
  }
}

Future<void> _iniciarSesion(WidgetTester tester) async {
  final contrasena = find.byType(TextField).at(1);
  await tester.enterText(contrasena, 'delypuno2026');
  await tester.pump();
  await tester.tap(find.text('Ingresar al panel'));
  await _reposar(tester);
}

Future<void> _abrirDestino(
  WidgetTester tester,
  String etiqueta, {
  required bool compacta,
}) async {
  if (compacta) {
    final menu = find.byIcon(Icons.menu);
    if (menu.evaluate().isNotEmpty) {
      await tester.tap(menu.first);
      await _reposar(tester);
    }
  }
  // El `indexedStack` mantiene vivas las ramas inactivas, así que el rótulo
  // hay que buscarlo dentro de la barra lateral y no en toda la app.
  final destino = find.descendant(
    of: find.byType(AdminSidebar),
    matching: find.text(etiqueta),
  );
  if (destino.evaluate().isEmpty) return;
  await tester.tap(destino.first, warnIfMissed: false);
  await _reposar(tester);
}

Future<void> _tocarPrimero(WidgetTester tester, Finder finder) async {
  if (finder.evaluate().isEmpty) return;
  await tester.tap(finder.first, warnIfMissed: false);
  await _reposar(tester);
}
