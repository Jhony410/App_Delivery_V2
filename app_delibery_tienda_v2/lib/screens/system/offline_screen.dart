import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../router/app_routes.dart';
import '../../state/app_state_scope.dart';
import '../../theme/app_theme.dart';
import '../../widgets/system_states.dart';

/// **Pantalla 11 · Sin conexión**, versión a pantalla completa (`/sin-conexion`).
///
/// El uso habitual de este estado es *embebido*: [OfflineState] se monta dentro
/// de Inicio, Pedidos y Productos, con el bottom nav siempre visible. Esta ruta
/// existe para los casos en que el fallo ocurre antes de tener shell (por
/// ejemplo durante el arranque) y para poder enlazarla directamente.
class OfflineScreen extends StatelessWidget {
  const OfflineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: OfflineState(
          onRetry: () async {
            await state.reintentar();
            if (!context.mounted) return;
            // Al recuperar la red se sale del callejón: atrás si hay algo
            // debajo, Inicio si no.
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(AppRoutes.home);
            }
          },
        ),
      ),
    );
  }
}
