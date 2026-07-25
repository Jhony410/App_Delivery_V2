import 'package:flutter/material.dart';

import 'app_state.dart';

/// Inyecta [AppState] en el árbol sin dependencias externas.
///
/// `AppStateScope.of(context)` se suscribe a los cambios (rebuild automático);
/// `AppStateScope.read(context)` solo lee, para usar dentro de callbacks.
class AppStateScope extends StatefulWidget {
  const AppStateScope({super.key, required this.child});

  final Widget child;

  static AppState of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<_AppStateInherited>();
    assert(scope != null, 'AppStateScope no encontrado en el árbol de widgets.');
    return scope!.state;
  }

  static AppState read(BuildContext context) {
    final scope = context.getInheritedWidgetOfExactType<_AppStateInherited>();
    assert(scope != null, 'AppStateScope no encontrado en el árbol de widgets.');
    return scope!.state;
  }

  @override
  State<AppStateScope> createState() => _AppStateScopeState();
}

class _AppStateScopeState extends State<AppStateScope> {
  late final AppState _state;

  @override
  void initState() {
    super.initState();
    _state = AppState();
  }

  @override
  void dispose() {
    _state.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _state,
      builder: (context, _) => _AppStateInherited(
        state: _state,
        version: _state.hashCode,
        child: widget.child,
      ),
    );
  }
}

class _AppStateInherited extends InheritedWidget {
  const _AppStateInherited({
    required this.state,
    required this.version,
    required super.child,
  });

  final AppState state;
  final int version;

  @override
  bool updateShouldNotify(_AppStateInherited oldWidget) => true;
}
