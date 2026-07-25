import 'package:flutter/material.dart';

import '../../data/demo_data.dart';
import '../../router/app_routes.dart';
import '../../state/app_state.dart';
import '../../state/app_state_scope.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/badges.dart';
import '../../widgets/map_backdrop.dart';
import 'operation_sheets.dart';

/// **Frames 06–13 en una sola pantalla.**
///
/// El diseño muestra ocho "pantallas" del núcleo operativo, pero todas son el
/// mismo mapa: lo único que cambia es el contenido de la hoja inferior y qué
/// marcadores hay encima. Por eso aquí hay un único `Scaffold` y una única
/// ruta ([AppRoutes.operations]); la fase la decide [AppState.phase].
///
/// | Fase                        | Frame |
/// |-----------------------------|-------|
/// | `desconectado`              | 21    |
/// | `buscando`                  | 06    |
/// | `sinPedidos`                | 25    |
/// | `pedidoEntrante`            | 08    |
/// | `rutaAlRestaurante`         | 09    |
/// | `esperandoEnRestaurante`    | 10    |
/// | `rutaAlCliente`             | 11    |
/// | `confirmarEntrega`          | 12    |
/// | `pedidosMultiples`          | 13    |
///
/// El heatmap (frame 07) es una capa que se enciende sobre cualquier fase.
class OperationsScreen extends StatefulWidget {
  const OperationsScreen({super.key});

  @override
  State<OperationsScreen> createState() => _OperationsScreenState();
}

class _OperationsScreenState extends State<OperationsScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    // Frame 24: el mapa arranca con el skeleton mientras "carga".
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) AppStateScope.read(context).warmUp();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    final phase = state.phase;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.mapTop,
      drawer: const AppDrawer(currentRoute: AppRoutes.operations),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ---- Mapa ----
          MapBackdrop(
            route: _routeFor(phase),
            showHeatmap: state.showHeatmap,
            grayscale: phase == OperationPhase.desconectado,
            dim: _dimFor(phase),
            blur: phase == OperationPhase.pedidoEntrante,
          ),

          // ---- Marcadores ----
          ..._markersFor(phase),

          // ---- Cabecera flotante ----
          Positioned(
            top: MediaQuery.paddingOf(context).top + 8,
            left: 16,
            right: 16,
            child: _shouldShowHeader(phase)
                ? _RiderHeaderCard(
                    online: state.isOnline,
                    onMenu: () => _scaffoldKey.currentState?.openDrawer(),
                    onToggle: state.setOnline,
                    heatmapTitle: state.showHeatmap,
                  )
                : const SizedBox.shrink(),
          ),

          // ---- Botones flotantes del mapa ----
          if (_shouldShowFabs(phase))
            Positioned(
              top: MediaQuery.paddingOf(context).top + 90,
              right: 16,
              child: Column(
                children: [
                  MapFab(
                    icon: Icons.layers_outlined,
                    tooltip: state.showHeatmap ? 'Ocultar demanda' : 'Ver zonas de demanda',
                    iconColor: state.showHeatmap ? AppColors.warning : AppColors.primary,
                    onPressed: state.toggleHeatmap,
                  ),
                  const SizedBox(height: 12),
                  MapFab(
                    icon: Icons.my_location_rounded,
                    iconColor: AppColors.textPrimary,
                    tooltip: 'Centrar en mi ubicación',
                    onPressed: () => _snack(context, 'Centrando en tu ubicación'),
                  ),
                ],
              ),
            ),

          // ---- Atajo a Google Maps durante la navegación ----
          if (phase == OperationPhase.rutaAlRestaurante || phase == OperationPhase.rutaAlCliente)
            Positioned(
              right: 16,
              bottom: MediaQuery.sizeOf(context).height * 0.42,
              child: MapFab(
                icon: Icons.navigation_rounded,
                label: 'Maps',
                size: 54,
                tooltip: 'Abrir en ${state.mapsApp}',
                onPressed: () => _snack(context, 'Abriendo ${state.mapsApp}…'),
              ),
            ),

          // ---- Leyenda del heatmap (frame 07) ----
          if (state.showHeatmap)
            Positioned(
              left: 16,
              bottom: MediaQuery.sizeOf(context).height * 0.46,
              child: const _DemandLegend(),
            ),

          // ---- Hoja inferior: aquí vive el contenido de cada frame ----
          Align(
            alignment: Alignment.bottomCenter,
            child: AnimatedSize(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              alignment: Alignment.bottomCenter,
              child: OperationSheet(phase: phase),
            ),
          ),
        ],
      ),
    );
  }

  bool _shouldShowHeader(OperationPhase phase) => switch (phase) {
        OperationPhase.desconectado ||
        OperationPhase.buscando ||
        OperationPhase.sinPedidos =>
          true,
        _ => false,
      };

  bool _shouldShowFabs(OperationPhase phase) => switch (phase) {
        OperationPhase.buscando || OperationPhase.sinPedidos => true,
        _ => false,
      };

  MapRoute _routeFor(OperationPhase phase) => switch (phase) {
        OperationPhase.rutaAlRestaurante => MapRoute.alRestaurante,
        OperationPhase.rutaAlCliente => MapRoute.alCliente,
        OperationPhase.pedidosMultiples => MapRoute.multiple,
        _ => MapRoute.ninguna,
      };

  double _dimFor(OperationPhase phase) => switch (phase) {
        OperationPhase.pedidoEntrante => 0.14,
        OperationPhase.confirmarEntrega => 0.10,
        OperationPhase.desconectado => 0.28,
        _ => 0,
      };

  List<Widget> _markersFor(OperationPhase phase) {
    final order = AppStateScope.of(context).currentOrder;

    return switch (phase) {
      // Buscando: el repartidor pulsa esperando oferta.
      OperationPhase.buscando || OperationPhase.sinPedidos => const [
          Align(alignment: Alignment(0, -0.05), child: RiderMarker(pulsing: true)),
        ],

      // Ruta al restaurante: repartidor abajo, chincheta del negocio arriba.
      OperationPhase.rutaAlRestaurante => [
          const Align(alignment: Alignment(0, -0.05), child: RiderMarker()),
          Align(
            alignment: const Alignment(0.2, -0.62),
            child: MapPin(emoji: order.businessEmoji),
          ),
        ],

      // En el restaurante: solo la chincheta del negocio.
      OperationPhase.esperandoEnRestaurante => [
          Align(
            alignment: const Alignment(0, -0.55),
            child: MapPin(emoji: order.businessEmoji, size: 44),
          ),
        ],

      // Ruta al cliente: repartidor arriba, casa del cliente abajo.
      OperationPhase.rutaAlCliente => const [
          Align(alignment: Alignment(0, -0.5), child: RiderMarker()),
          Align(
            alignment: Alignment(-0.1, 0.32),
            child: MapPin(icon: Icons.home_rounded, color: AppColors.textPrimary),
          ),
        ],

      OperationPhase.pedidosMultiples => const [
          Align(alignment: Alignment(0, -0.05), child: RiderMarker()),
        ],

      _ => const [],
    };
  }

  void _snack(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppColors.primaryDark,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
  }
}

/// Tarjeta superior del frame 06: avatar, nombre, estado e interruptor.
/// También abre el drawer (frame 20).
class _RiderHeaderCard extends StatelessWidget {
  const _RiderHeaderCard({
    required this.online,
    required this.onMenu,
    required this.onToggle,
    required this.heatmapTitle,
  });

  final bool online;
  final VoidCallback onMenu;
  final ValueChanged<bool> onToggle;

  /// Con el heatmap encendido, la tarjeta muestra el copy del frame 07.
  final bool heatmapTitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppTheme.rCardLarge),
        boxShadow: AppTheme.floatingShadow,
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: onMenu,
            icon: const Icon(Icons.menu_rounded, color: AppColors.textPrimary),
            tooltip: 'Abrir menú',
            visualDensity: VisualDensity.compact,
          ),
          RiderAvatar(
            initials: DemoData.riderInitials,
            online: online,
            muted: !online,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  heatmapTitle ? 'Zonas con más demanda' : DemoData.riderShortName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.display(15, weight: FontWeight.w700),
                ),
                if (heatmapTitle)
                  Text(
                    'Muévete al centro para ganar más',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.body(12),
                  )
                else
                  Row(
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: online ? AppColors.online : AppColors.neutral,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Flexible(
                        child: Text(
                          online ? 'Conectado' : 'Desconectado',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppText.body(
                            12,
                            weight: FontWeight.w600,
                            color: online ? AppColors.primaryOnSoft : AppColors.neutral,
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ChasquiSwitch(value: online, onChanged: onToggle),
          const SizedBox(width: 6),
        ],
      ),
    );
  }
}

/// Leyenda flotante del heatmap. Frame 07.
class _DemandLegend extends StatelessWidget {
  const _DemandLegend();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppTheme.rCard),
        boxShadow: AppTheme.floatingShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Demanda ahora', style: AppText.display(12, weight: FontWeight.w700)),
          const SizedBox(height: 10),
          for (final level in DemoData.demandLegend)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: level.color,
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  const SizedBox(width: 9),
                  Text(
                    level.label,
                    style: AppText.body(11, weight: FontWeight.w600, color: AppColors.textPrimary),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
