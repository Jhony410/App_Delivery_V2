import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Tipografía y tema de CHASQUI.
///
/// El diseño usa **Poppins** para títulos y botones, e **Inter** para el
/// cuerpo. `google_fonts` cae de vuelta a la fuente del sistema si no hay
/// red, así que la app nunca se rompe por esto.
class AppText {
  AppText._();

  /// Poppins — títulos, cifras y etiquetas de botón.
  static TextStyle display(double size, {FontWeight weight = FontWeight.w800, Color? color, double? height, double? letterSpacing}) =>
      GoogleFonts.poppins(
        fontSize: size,
        fontWeight: weight,
        color: color ?? AppColors.textPrimary,
        height: height,
        letterSpacing: letterSpacing,
      );

  /// Inter — cuerpo, descripciones y metadatos.
  static TextStyle body(double size, {FontWeight weight = FontWeight.w400, Color? color, double? height, double? letterSpacing}) =>
      GoogleFonts.inter(
        fontSize: size,
        fontWeight: weight,
        color: color ?? AppColors.textSecondary,
        height: height,
        letterSpacing: letterSpacing,
      );

  /// Etiqueta de sección en mayúsculas ("PEDIDOS", "NAVEGACIÓN"…).
  static TextStyle sectionLabel() => body(
        12,
        weight: FontWeight.w700,
        color: AppColors.neutral,
        letterSpacing: 1,
      );

  /// Texto de las píldoras de estado (chips).
  static TextStyle chip(Color color) => body(
        10,
        weight: FontWeight.w700,
        color: color,
        letterSpacing: 0.5,
      );
}

class AppTheme {
  AppTheme._();

  /// Radios del sistema, tal como aparecen en el canvas.
  static const double rButton = 18;
  static const double rButtonSmall = 16;
  static const double rCard = 18;
  static const double rCardLarge = 20;
  static const double rField = 14;
  static const double rSheet = 26;
  static const double rPill = 22;

  /// Sombra estándar de tarjeta.
  static const List<BoxShadow> cardShadow = [
    BoxShadow(color: Color(0x0D000000), blurRadius: 12, offset: Offset(0, 3)),
  ];

  /// Sombra de elementos flotantes sobre el mapa.
  static const List<BoxShadow> floatingShadow = [
    BoxShadow(color: Color(0x33000000), blurRadius: 24, offset: Offset(0, 8), spreadRadius: -8),
  ];

  /// Sombra de la hoja inferior (crece hacia arriba).
  static const List<BoxShadow> sheetShadow = [
    BoxShadow(color: Color(0x14000000), blurRadius: 30, offset: Offset(0, -8)),
  ];

  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        surface: AppColors.surface,
        error: AppColors.danger,
      ),
      scaffoldBackgroundColor: AppColors.surface,
    );

    return base.copyWith(
      textTheme: GoogleFonts.interTextTheme(base.textTheme).apply(
        bodyColor: AppColors.textPrimary,
        displayColor: AppColors.textPrimary,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: AppText.display(22),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
        space: 1,
      ),
      splashFactory: InkRipple.splashFactory,
    );
  }
}
