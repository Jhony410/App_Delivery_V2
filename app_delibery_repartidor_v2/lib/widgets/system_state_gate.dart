import 'package:flutter/material.dart';

import '../state/app_state.dart';
import '../state/app_state_scope.dart';
import 'skeleton.dart';
import 'system_states.dart';

/// Portero de los estados del sistema.
///
/// Envuelve el `builder` del router, así que **toda** pantalla de CHASQUI
/// queda cubierta. Cuando [AppState] levanta una bandera —sin internet, GPS
/// apagado, carga o error— este widget monta el frame correspondiente encima,
/// con una transición suave. Por eso los frames 22, 23, 24 y 26 no necesitan
/// ruta propia: se muestran sobre lo que el repartidor ya tenía delante.
///
/// El orden de prioridad importa: un error de red debe ganarle al skeleton.
class SystemStateGate extends StatelessWidget {
  const SystemStateGate({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);

    return Stack(
      children: [
        child,
        // El `Positioned.fill` va aquí y no dentro de las capas: el
        // AnimatedSwitcher envuelve a su hijo en un FadeTransition, así que un
        // Positioned interior no tendría al Stack como padre directo.
        Positioned.fill(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            child: _overlayFor(context, state),
          ),
        ),
      ],
    );
  }

  Widget _overlayFor(BuildContext context, AppState state) {
    // 1. Error genérico (frame 26) — lo más grave, tapa todo.
    if (state.hasError) {
      return _Layer(
        key: const ValueKey('error'),
        child: SystemStateView.genericError(
          message: state.errorMessage,
          onRetry: state.retry,
          onHome: () {
            state.clearError();
            state.backToMap();
          },
        ),
      );
    }

    // 2. Sin internet (frame 22) — bloquea la operación.
    if (!state.hasInternet) {
      return _Layer(
        key: const ValueKey('offline'),
        child: SystemStateView.noInternet(onRetry: state.retry),
      );
    }

    // 3. GPS desactivado (frame 23) — solo importa si ya aceptó trabajar.
    if (!state.gpsEnabled && state.isOnline) {
      return _Layer(
        key: const ValueKey('gps'),
        child: SystemStateView.gpsOff(onEnable: state.grantLocation),
      );
    }

    // 4. Carga (frame 24) — el skeleton del mapa.
    if (state.isLoading) {
      return const _Layer(
        key: ValueKey('loading'),
        child: OperationsSkeleton(),
      );
    }

    return const SizedBox.shrink(key: ValueKey('none'));
  }
}

/// Capa opaca a pantalla completa que tapa la pantalla de debajo.
class _Layer extends StatelessWidget {
  const _Layer({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Material(color: Colors.transparent, child: child),
    );
  }
}
