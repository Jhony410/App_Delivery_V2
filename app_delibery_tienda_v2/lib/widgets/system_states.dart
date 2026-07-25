import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'buttons.dart';

/// Estados del sistema del canvas (frames 10, 12 y 13), como widgets.
///
/// Son piezas **reutilizables**, no pestañas: se montan dentro de la pantalla
/// que falló, así que el bottom nav sigue visible y el comerciante nunca queda
/// atrapado. Ver [OfflineState], [SectionEmptyState] y [GenericErrorState] para
/// el detalle de dónde se usa cada uno.

/// Maqueta común: ícono en placa redondeada, título, texto y acciones.
class _SystemStateLayout extends StatelessWidget {
  const _SystemStateLayout({
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    required this.title,
    required this.message,
    this.actions = const [],
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final String title;
  final String message;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  color: iconBackground,
                  borderRadius: BorderRadius.circular(34),
                ),
                child: Icon(icon, size: 56, color: iconColor),
              ),
            ),
            const SizedBox(height: 28),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppText.display(24, weight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppText.body(17, weight: FontWeight.w500, height: 1.55),
            ),
            if (actions.isNotEmpty) ...[const SizedBox(height: 30), ...actions],
          ],
        ),
      ),
    );
  }
}

/// **Frame 10 · Sin conexión.**
///
/// Se usa en:
/// - `HomeScreen` (Inicio) cuando `AppState.enLinea` es `false`
/// - `OrdersScreen` (Pedidos) con `LoadStatus.sinConexion`
/// - `ProductsScreen` (Productos) con `LoadStatus.sinConexion`
/// - `OfflineScreen`, la versión a pantalla completa en `/sin-conexion`
class OfflineState extends StatelessWidget {
  const OfflineState({super.key, required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return _SystemStateLayout(
      icon: Icons.wifi_off_rounded,
      iconColor: AppColors.danger,
      iconBackground: AppColors.dangerSoft,
      title: 'Sin conexión',
      message:
          'Revisa tu internet. No podrás recibir pedidos nuevos hasta reconectar.',
      actions: [PrimaryButton(label: 'Reintentar', onPressed: onRetry)],
    );
  }
}

/// **Frame 12 · Estado vacío.**
///
/// Se usa en:
/// - `OrdersScreen` (Pedidos) cuando la lista está vacía y no hubo error
/// - `ProductsScreen` (Productos) cuando el catálogo está vacío
///
/// Nunca ocupa la pantalla entera: siempre queda bajo el bottom nav, para que
/// el comerciante pueda cambiar de pestaña sin gestos raros.
class SectionEmptyState extends StatelessWidget {
  const SectionEmptyState({
    super.key,
    this.title = 'Aún no hay pedidos',
    this.message =
        'Cuando un cliente pida, aparecerá aquí y sonará la alerta. Mantén tu negocio abierto.',
    this.icon = Icons.shopping_bag_outlined,
  });

  final String title;
  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 130,
              height: 130,
              decoration: const BoxDecoration(
                color: AppColors.primarySoft,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 62, color: AppColors.primary),
            ),
            const SizedBox(height: 22),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppText.display(22, weight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppText.body(17, weight: FontWeight.w500, height: 1.55),
            ),
          ],
        ),
      ),
    );
  }
}

/// **Frame 13 · Error genérico.**
///
/// Se usa en:
/// - `OrdersScreen` (Pedidos) con `LoadStatus.error`
/// - `GenericErrorScreen`, la versión a pantalla completa, que a su vez es el
///   destino del `errorBuilder` del router y del `ErrorWidget.builder` de la
///   app. Por eso ningún fallo termina en la pantalla roja de Flutter.
class GenericErrorState extends StatelessWidget {
  const GenericErrorState({
    super.key,
    required this.onRetry,
    this.onGoHome,
    this.message =
        'No pudimos cargar tus pedidos. Inténtalo de nuevo en unos segundos.',
  });

  final VoidCallback onRetry;

  /// "Volver al inicio". Si es `null` el enlace no se dibuja (por ejemplo
  /// cuando el error ya ocurrió *dentro* de Inicio).
  final VoidCallback? onGoHome;
  final String message;

  @override
  Widget build(BuildContext context) {
    return _SystemStateLayout(
      icon: Icons.warning_amber_rounded,
      iconColor: AppColors.danger,
      iconBackground: AppColors.dangerSoft,
      title: 'Algo salió mal',
      message: message,
      actions: [
        PrimaryButton(label: 'Reintentar', onPressed: onRetry),
        if (onGoHome != null) ...[
          const SizedBox(height: 14),
          Center(
            child: TextButton(
              onPressed: onGoHome,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.textSecondary,
                textStyle: AppText.body(16, weight: FontWeight.w600),
              ),
              child: const Text('Volver al inicio'),
            ),
          ),
        ],
      ],
    );
  }
}
