import 'package:flutter/material.dart';

import 'app_state.dart';

/// Inyecta [AppState] en el árbol.
///
/// Se monta una sola vez, por encima del `MaterialApp.router`, para que el
/// estado sobreviva a cualquier cambio de ruta: cambiar de pestaña o abrir la
/// alerta de pedido nuevo no reinicia nada.
class AppStateScope extends StatefulWidget {
  const AppStateScope({super.key, required this.child, this.state});

  final Widget child;

  /// Estado alternativo; solo lo usan las pruebas, que necesitan una instancia
  /// limpia por caso. En producción se crea aquí.
  final AppState? state;

  @override
  State<AppStateScope> createState() => _AppStateScopeState();

  /// Acceso con suscripción: el widget se reconstruye ante cada cambio.
  static AppState of(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<_AppStateInherited>();
    assert(scope != null, 'No hay AppStateScope por encima de este widget.');
    return scope!.state;
  }

  /// Acceso sin suscripción, para llamar métodos desde un `onPressed`.
  static AppState read(BuildContext context) {
    final scope = context.getInheritedWidgetOfExactType<_AppStateInherited>();
    assert(scope != null, 'No hay AppStateScope por encima de este widget.');
    return scope!.state;
  }
}

class _AppStateScopeState extends State<AppStateScope> {
  late final AppState _state = widget.state ?? AppState();
  late final bool _propio = widget.state == null;

  @override
  void dispose() {
    if (_propio) _state.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // AnimatedBuilder vuelve a montar el InheritedWidget en cada notificación;
    // `child` no se reconstruye, solo los widgets que dependen del estado.
    return AnimatedBuilder(
      animation: _state,
      builder: (context, child) =>
          _AppStateInherited(state: _state, child: child!),
      child: widget.child,
    );
  }
}

class _AppStateInherited extends InheritedWidget {
  const _AppStateInherited({required this.state, required super.child});

  final AppState state;

  @override
  bool updateShouldNotify(_AppStateInherited old) => true;
}
