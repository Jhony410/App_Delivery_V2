import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/map_backdrop.dart';
import '../../../router/app_routes.dart';
import '../../../theme/app_theme.dart';

/// 17 · Ajustar ubicación en el mapa. Mueve el mapa y confirma el pin.
/// Confirmar -> vuelve a /addresses o /add-address según de dónde vino (`from`).
class AdjustMapScreen extends StatelessWidget {
  const AdjustMapScreen({super.key, this.from});

  /// Origen de la navegación: `addAddress` vuelve a la pantalla de agregar;
  /// cualquier otro valor (o nulo) vuelve a la lista de direcciones.
  final String? from;

  void _confirm(BuildContext context) {
    if (from == AppRoutes.nAddAddress) {
      // Venía de "Ajustar el punto" en medio de la edición.
      context.pop();
    } else {
      // Venía de la lista o del guardado final.
      context.go(AppRoutes.addresses);
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Ubicación confirmada')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: MapBackdrop(showCenterPin: true)),
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 20,
            child: GestureDetector(
              onTap: () => context.pop(),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: AppTheme.cardShadow,
                ),
                child: const Icon(Icons.arrow_back_ios_new,
                    size: 20, color: AppColors.textPrimary),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(
                  22, 22, 22, 24 + MediaQuery.of(context).padding.bottom),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.vertical(top: Radius.circular(AppRadius.sheet)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Mueve el mapa para que el pin quede justo en tu puerta',
                      style: AppText.bodySecondary, textAlign: TextAlign.center),
                  const SizedBox(height: 8),
                  Text('📍 Cerca de Jr. 2 de Mayo con Jr. Ayacucho',
                      style: AppText.cardTitle, textAlign: TextAlign.center),
                  const SizedBox(height: 18),
                  ElevatedButton(
                    onPressed: () => _confirm(context),
                    child: const Text('Confirmar ubicación'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
