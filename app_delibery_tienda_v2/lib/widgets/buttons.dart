import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Botón primario rojo: "Aceptar", "Continuar", "Reintentar".
///
/// Altura mínima 56 px y tipografía Poppins 19, como exige el canvas: el
/// comerciante toca con una mano y sin mirar.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.height = AppTheme.hButtonPrimary,
    this.fontSize = 19,
  });

  final String label;

  /// `null` deja el botón deshabilitado, con el gris del canvas.
  final VoidCallback? onPressed;
  final double height;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final habilitado = onPressed != null;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.rButton),
        boxShadow: habilitado ? AppTheme.buttonShadow : const [],
      ),
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: FilledButton(
          onPressed: onPressed,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            disabledBackgroundColor: AppColors.fillStrong,
            foregroundColor: Colors.white,
            disabledForegroundColor: AppColors.disabledText,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.rButton),
              side: habilitado
                  ? BorderSide.none
                  : const BorderSide(color: AppColors.border),
            ),
            textStyle: AppText.display(fontSize, weight: FontWeight.w700),
          ),
          child: Text(label),
        ),
      ),
    );
  }
}

/// Botón secundario con contorno negro: "Rechazar", "Cerrar negocio".
class SecondaryButton extends StatelessWidget {
  const SecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.height = AppTheme.hButton,
    this.fontSize = 18,
  });

  final String label;
  final VoidCallback? onPressed;
  final double height;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: AppColors.card,
          foregroundColor: AppColors.textPrimary,
          side: const BorderSide(color: AppColors.textPrimary, width: 1.5),
          // El relleno por defecto (16 px por lado) parte "Rechazar" en dos
          // líneas cuando el botón comparte fila con "Aceptar" en 390 px.
          padding: const EdgeInsets.symmetric(horizontal: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.rButton),
          ),
          textStyle: AppText.display(fontSize, weight: FontWeight.w700),
        ),
        child: Text(label),
      ),
    );
  }
}

/// Botón blanco sobre el degradado rojo (alerta de pedido nuevo).
class OnBrandButton extends StatelessWidget {
  const OnBrandButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.filled = true,
  });

  final String label;
  final VoidCallback onPressed;

  /// `true` → blanco sólido con texto rojo. `false` → contorno blanco.
  final bool filled;

  @override
  Widget build(BuildContext context) {
    if (filled) {
      return SizedBox(
        height: 64,
        width: double.infinity,
        child: FilledButton(
          onPressed: onPressed,
          style: FilledButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: AppColors.primary,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.rButtonLarge),
            ),
            textStyle: AppText.display(21),
          ),
          child: Text(label),
        ),
      );
    }

    return SizedBox(
      height: AppTheme.hButton,
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          side: const BorderSide(color: Colors.white, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.rButton),
          ),
          textStyle: AppText.display(18, weight: FontWeight.w700),
        ),
        child: Text(label),
      ),
    );
  }
}

/// Botón pequeño "Editar" de la tarjeta de producto.
class SmallOutlineButton extends StatelessWidget {
  const SmallOutlineButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        backgroundColor: AppColors.card,
        foregroundColor: AppColors.textPrimary,
        side: const BorderSide(color: AppColors.border, width: 1.5),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        minimumSize: const Size(0, 38),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: AppText.display(14, weight: FontWeight.w700),
      ),
      child: Text(label),
    );
  }
}
