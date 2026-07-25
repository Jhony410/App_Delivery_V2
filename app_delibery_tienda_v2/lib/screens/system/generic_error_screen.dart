import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../router/app_routes.dart';
import '../../theme/app_theme.dart';
import '../../widgets/system_states.dart';

/// **Pantalla 12 · Error genérico** ("Algo salió mal").
///
/// Es la red de seguridad de toda la app y se alcanza por cuatro caminos:
///
/// 1. `errorBuilder` del router → cualquier ruta inexistente
/// 2. ruta propia `/error`
/// 3. `ErrorWidget.builder` en `main.dart` → cualquier excepción de
///    construcción, en debug y en release, sustituyendo a la pantalla roja
/// 4. embebida como [GenericErrorState] dentro de Pedidos y Productos
///
/// No usa `AppStateScope`: tiene que poder pintarse aunque el estado de la app
/// sea justamente lo que falló.
class GenericErrorScreen extends StatelessWidget {
  const GenericErrorScreen({super.key, this.location, this.details});

  /// Ruta que no se pudo resolver, si el error vino del router.
  final String? location;

  /// Detalle técnico del error de construcción, si vino de
  /// `ErrorWidget.builder`. Solo se muestra en debug.
  final String? details;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: GenericErrorState(
                message: location == null
                    ? 'No pudimos cargar esta pantalla. Inténtalo de nuevo en unos segundos.'
                    : 'No encontramos la pantalla "$location". Vuelve al inicio y sigue trabajando.',
                onRetry: () {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go(AppRoutes.home);
                  }
                },
                onGoHome: () => context.go(AppRoutes.home),
              ),
            ),
            if (kDebugMode && details != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
                child: Text(
                  details!,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: AppText.body(
                    11,
                    color: AppColors.neutral,
                    height: 1.4,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
