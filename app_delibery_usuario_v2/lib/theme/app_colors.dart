import 'package:flutter/material.dart';

/// Paleta central de DelyPuno, extraída del diseño `DelyPuno.dc.html`.
/// No definir colores sueltos en las pantallas: usar siempre estas constantes.
class AppColors {
  AppColors._();

  // Marca / verdes
  static const Color primary = Color(0xFF0E7A4F); // verde primario
  static const Color primaryDark = Color(0xFF0A5C3B); // verde oscuro
  static const Color primaryMid = Color(0xFF128A59); // usado en gradientes
  static const Color greenLight = Color(0xFFE6F4EC); // fondos suaves
  static const Color greenBorder = Color(0xFFBEE6CE); // bordes suaves

  // Estado / feedback
  static const Color success = Color(0xFF22C55E);
  static const Color successDark = Color(0xFF12A150);
  static const Color danger = Color(0xFFE24C4C);
  static const Color dangerSoft = Color(0xFFD66A5A);
  static const Color dangerBg = Color(0xFFFDEEE9);
  static const Color warning = Color(0xFFB98600);
  static const Color warningBg = Color(0xFFFFF6E0);

  // Fondos y superficies
  static const Color canvas = Color(0xFFE5E7E2); // fondo global del lienzo
  static const Color screenBg = Color(0xFFFAFAFA); // fondo de pantalla
  static const Color surface = Colors.white; // tarjetas
  static const Color surfaceMuted = Color(0xFFF1F3F0); // chips / campos apagados
  static const Color surfaceMuted2 = Color(0xFFF5F7F4);

  // Texto
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF6B675F);
  static const Color textMuted = Color(0xFF8A8B85);
  static const Color textPlaceholder = Color(0xFFAEB1AA);

  // Bordes / divisores
  static const Color border = Color(0xFFE4E7E2);
  static const Color divider = Color(0xFFEEF1EE);

  // Acentos de terceros (métodos de pago, estrellas, etc.)
  static const Color yape = Color(0xFF6D4BC7);
  static const Color plin = Color(0xFF0AA5D9);
  static const Color whatsapp = Color(0xFF25D366);
  static const Color star = Color(0xFFFFB800);

  // Gradiente de cabecera (verde marca)
  static const LinearGradient headerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryMid, primaryDark],
  );

  // Gradiente para la banda de promo del Home
  static const LinearGradient promoGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [primaryDark, Color(0xFF12A05F)],
  );
}
