import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

/// Estado vacío reutilizable (búsqueda sin resultados, listas vacías...).
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: const BoxDecoration(
                color: AppColors.greenLight,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 42, color: AppColors.primary),
            ),
            const SizedBox(height: 16),
            Text(title, style: AppText.title, textAlign: TextAlign.center),
            const SizedBox(height: 6),
            Text(
              message,
              style: AppText.bodySecondary,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Estado de error con botón "Reintentar". El botón NO navega: vuelve a
/// intentar la misma acción (recarga el estado normal de la pantalla).
class RetryableError extends StatelessWidget {
  const RetryableError({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    required this.onRetry,
    this.retryLabel = 'Reintentar',
  });

  final IconData icon;
  final String title;
  final String message;
  final VoidCallback onRetry;
  final String retryLabel;

  /// Sin conexión a internet.
  factory RetryableError.offline({required VoidCallback onRetry}) =>
      RetryableError(
        icon: Icons.wifi_off_rounded,
        title: 'Sin conexión',
        message: 'Revisa tu internet e inténtalo de nuevo.',
        onRetry: onRetry,
      );

  /// No se pudo cargar el catálogo.
  factory RetryableError.catalog({required VoidCallback onRetry}) =>
      RetryableError(
        icon: Icons.restaurant_menu_rounded,
        title: 'No pudimos cargar el catálogo',
        message: 'Ocurrió un problema al obtener los comercios.',
        onRetry: onRetry,
      );

  /// Comercio / producto no disponible.
  factory RetryableError.unavailable({required VoidCallback onRetry}) =>
      RetryableError(
        icon: Icons.block_rounded,
        title: 'No disponible por ahora',
        message: 'Este contenido no está disponible en este momento.',
        onRetry: onRetry,
      );

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: AppColors.dangerBg,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 42, color: AppColors.dangerSoft),
            ),
            const SizedBox(height: 18),
            Text(title, style: AppText.h3, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(
              message,
              style: AppText.bodySecondary,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 22),
            SizedBox(
              width: 200,
              child: ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: Text(retryLabel),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
