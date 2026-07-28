import 'package:flutter/material.dart';

import 'app_states.dart';

/// Resuelve los tres estados de una sección: carga, error y vacío.
///
/// Toda lista o bloque que dependa del repositorio pasa por aquí, de modo que
/// ninguna pantalla puede quedarse renderizando datos nulos.
class VistaAsync extends StatelessWidget {
  const VistaAsync({
    super.key,
    required this.cargando,
    required this.error,
    required this.vacio,
    required this.builder,
    this.onReintentar,
    this.tituloVacio = 'Aún no hay nada por aquí',
    this.mensajeVacio = 'Cuando lleguen datos aparecerán en esta sección.',
    this.iconoVacio = Icons.inbox_outlined,
    this.accionVacio,
    this.onAccionVacio,
    this.skeletons = 3,
  });

  final bool cargando;
  final String? error;
  final bool vacio;
  final WidgetBuilder builder;
  final VoidCallback? onReintentar;

  final String tituloVacio;
  final String mensajeVacio;
  final IconData iconoVacio;
  final String? accionVacio;
  final VoidCallback? onAccionVacio;

  final int skeletons;

  @override
  Widget build(BuildContext context) {
    if (cargando) return AppLoadingState(count: skeletons);
    if (error != null) {
      return AppErrorState(message: error!, onRetry: onReintentar);
    }
    if (vacio) {
      return AppEmptyState(
        title: tituloVacio,
        message: mensajeVacio,
        icon: iconoVacio,
        actionLabel: accionVacio,
        onAction: onAccionVacio,
      );
    }
    return builder(context);
  }
}
