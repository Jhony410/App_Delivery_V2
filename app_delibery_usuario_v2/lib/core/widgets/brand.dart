import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

/// Logo de DelyPuno: cuadro redondeado con gradiente verde y un ícono de
/// reparto (evoca al chasqui / mensajero andino).
class DelyLogo extends StatelessWidget {
  const DelyLogo({super.key, this.size = 64, this.radius = 20, this.iconScale = 0.62});

  final double size;
  final double radius;
  final double iconScale;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryMid, AppColors.primaryDark],
        ),
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.45),
            blurRadius: 22,
            offset: const Offset(0, 8),
            spreadRadius: -6,
          ),
        ],
      ),
      child: Icon(
        Icons.delivery_dining,
        color: Colors.white,
        size: size * iconScale,
      ),
    );
  }
}

/// Variante del logo sobre fondo blanco (usada en cabeceras verdes).
class DelyLogoOnWhite extends StatelessWidget {
  const DelyLogoOnWhite({super.key, this.size = 78, this.radius = 24});

  final double size;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 30,
            offset: const Offset(0, 12),
            spreadRadius: -8,
          ),
        ],
      ),
      child: Icon(
        Icons.delivery_dining,
        color: AppColors.primary,
        size: size * 0.58,
      ),
    );
  }
}
