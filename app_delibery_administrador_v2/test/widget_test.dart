import 'package:app_delibery_administrador_v2/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('la app arranca en la pantalla de acceso', (tester) async {
    tester.view
      ..physicalSize = const Size(1440, 900)
      ..devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const DelyPunoAdminApp());
    await tester.pump();

    expect(find.text('DelyPuno'), findsOneWidget);
    expect(find.text('OPERACIONES'), findsOneWidget);
    expect(find.text('Ingresar al panel'), findsOneWidget);
  });

  testWidgets('no deja entrar con credenciales incompletas', (tester) async {
    tester.view
      ..physicalSize = const Size(1440, 900)
      ..devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const DelyPunoAdminApp());
    await tester.pump();

    // El correo viene precargado; la contraseña queda vacía.
    await tester.tap(find.text('Ingresar al panel'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.textContaining('al menos 4 caracteres'), findsOneWidget);
  });
}
