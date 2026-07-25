import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

/// Las tres alturas de la hoja inferior del frame 27.
enum SheetHeight {
  /// Solo el asa y un resumen corto.
  peek(0.42),

  /// Contenido operativo habitual.
  medio(0.62),

  /// Formularios largos (confirmar entrega, esperar en el restaurante).
  alto(0.82);

  const SheetHeight(this.maxFraction);

  /// Fracción máxima de la altura de pantalla que puede ocupar la hoja.
  final double maxFraction;
}

/// La hoja inferior blanca sobre la que se apoya todo el núcleo operativo.
///
/// Es el mismo contenedor en las 8 fases: solo cambia el [child]. Nunca
/// desborda — si el contenido excede [height], la hoja se vuelve desplazable.
class BottomSheetShell extends StatelessWidget {
  const BottomSheetShell({
    super.key,
    required this.child,
    this.height = SheetHeight.medio,
    this.padding = const EdgeInsets.fromLTRB(22, 14, 22, 30),
    this.showHandle = true,
  });

  final Widget child;
  final SheetHeight height;
  final EdgeInsets padding;
  final bool showHandle;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: screenHeight * height.maxFraction),
      child: DecoratedBox(
        decoration: const BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.rSheet)),
          boxShadow: AppTheme.sheetShadow,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showHandle)
              Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 4),
                child: Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: AppColors.handle,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            Flexible(
              child: SingleChildScrollView(
                padding: padding.copyWith(bottom: padding.bottom + bottomInset),
                child: child,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Fila de métricas del resumen del día (frame 06): tres cajitas grises.
class StatTiles extends StatelessWidget {
  const StatTiles({super.key, required this.tiles});

  final List<StatTileData> tiles;

  @override
  Widget build(BuildContext context) {
    // `IntrinsicHeight` es imprescindible: la hoja vive dentro de un scroll,
    // así que sin él `stretch` pediría altura infinita y reventaría el layout.
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < tiles.length; i++) ...[
            if (i > 0) const SizedBox(width: 10),
            Expanded(child: _StatTile(data: tiles[i])),
          ],
        ],
      ),
    );
  }
}

class StatTileData {
  const StatTileData({required this.label, required this.value, this.valueColor});

  final String label;
  final String value;
  final Color? valueColor;
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.data});

  final StatTileData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.fill,
        borderRadius: BorderRadius.circular(AppTheme.rField),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            data.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppText.body(11),
          ),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              data.value,
              style: AppText.display(20, color: data.valueColor ?? AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}

/// Caja de dato con ícono usada en la oferta entrante (distancia / tiempo).
class IconStat extends StatelessWidget {
  const IconStat({super.key, required this.icon, required this.value, required this.label});

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
      decoration: BoxDecoration(
        color: AppColors.fill,
        borderRadius: BorderRadius.circular(AppTheme.rField),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.textSecondary),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.display(15, weight: FontWeight.w700),
                ),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.body(11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Trayecto recogida → entrega con la línea punteada vertical (frame 08).
class PickupDropoffRow extends StatelessWidget {
  const PickupDropoffRow({
    super.key,
    required this.pickupName,
    required this.pickupAddress,
    required this.dropoffName,
    required this.dropoffAddress,
  });

  final String pickupName;
  final String pickupAddress;
  final String dropoffName;
  final String dropoffAddress;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _line(
          marker: Container(
            width: 11,
            height: 11,
            decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
          ),
          name: pickupName,
          address: pickupAddress,
        ),
        Container(
          margin: const EdgeInsets.only(left: 5),
          width: 2,
          height: 16,
          color: const Color(0xFFC7D6CC),
        ),
        _line(
          marker: Container(
            width: 11,
            height: 11,
            decoration: BoxDecoration(
              color: AppColors.textPrimary,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          name: dropoffName,
          address: dropoffAddress,
        ),
      ],
    );
  }

  Widget _line({required Widget marker, required String name, required String address}) {
    return Row(
      children: [
        marker,
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppText.body(13, weight: FontWeight.w600, color: AppColors.textPrimary),
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            address,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.right,
            style: AppText.body(12),
          ),
        ),
      ],
    );
  }
}
