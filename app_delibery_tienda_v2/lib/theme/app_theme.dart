import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

export 'app_colors.dart';

/// Tipografía de DelyPuno Negocios.
///
/// El canvas usa **Poppins** para títulos, cifras y botones, e **Inter** para
/// cuerpo y metadatos. `google_fonts` cae de vuelta a la fuente del sistema si
/// no hay red, así que la app nunca se rompe por esto.
///
/// Piso de 16 px en textos de lectura: el comerciante usa el celular con una
/// mano, muchas veces con guantes o con las manos ocupadas.
class AppText {
  AppText._();

  /// Poppins — títulos, cifras y etiquetas de botón.
  static TextStyle display(
    double size, {
    FontWeight weight = FontWeight.w800,
    Color? color,
    double? height,
    double? letterSpacing,
  }) => GoogleFonts.poppins(
    fontSize: size,
    fontWeight: weight,
    color: color ?? AppColors.textPrimary,
    height: height,
    letterSpacing: letterSpacing,
  );

  /// Inter — cuerpo, descripciones y metadatos.
  static TextStyle body(
    double size, {
    FontWeight weight = FontWeight.w400,
    Color? color,
    double? height,
    double? letterSpacing,
  }) => GoogleFonts.inter(
    fontSize: size,
    fontWeight: weight,
    color: color ?? AppColors.textSecondary,
    height: height,
    letterSpacing: letterSpacing,
  );

  /// Etiqueta de sección en mayúsculas ("HOY", "ÚLTIMO PEDIDO"…).
  static TextStyle sectionLabel() => body(
    15,
    weight: FontWeight.w700,
    color: AppColors.neutral,
    letterSpacing: 0.5,
  );

  /// Texto de las píldoras de estado (chips).
  static TextStyle chip(Color color) =>
      body(12, weight: FontWeight.w700, color: color, letterSpacing: 0.4);

  /// Etiqueta de campo de formulario.
  static TextStyle fieldLabel() =>
      body(15, weight: FontWeight.w700, color: AppColors.textPrimary);
}

/// Radios, sombras y medidas del sistema, tal como aparecen en el canvas.
class AppTheme {
  AppTheme._();

  // ---- Radios ----
  static const double rButton = 16;
  static const double rButtonLarge = 18;
  static const double rCard = 20;
  static const double rField = 16;
  static const double rThumb = 16;
  static const double rPill = 20;
  static const double rFab = 20;
  static const double rLogo = 22;

  // ---- Medidas ----
  /// Altura mínima de un botón táctil: el canvas exige 56 px o más.
  static const double hButton = 56;
  static const double hButtonPrimary = 60;
  static const double hField = 58;
  static const double hBottomNav = 84;

  // ---- Sombras ----
  /// Sombra estándar de tarjeta.
  static const List<BoxShadow> cardShadow = [
    BoxShadow(color: Color(0x0D000000), blurRadius: 12, offset: Offset(0, 3)),
  ];

  /// Sombra de una tarjeta destacada (pedido nuevo).
  static const List<BoxShadow> alertShadow = [
    BoxShadow(
      color: Color(0x59E53935),
      blurRadius: 22,
      offset: Offset(0, 8),
      spreadRadius: -10,
    ),
  ];

  /// Sombra bajo un botón primario rojo.
  static const List<BoxShadow> buttonShadow = [
    BoxShadow(
      color: Color(0x73E53935),
      blurRadius: 20,
      offset: Offset(0, 8),
      spreadRadius: -8,
    ),
  ];

  /// Sombra del FAB de "agregar producto".
  static const List<BoxShadow> fabShadow = [
    BoxShadow(
      color: Color(0x99E53935),
      blurRadius: 26,
      offset: Offset(0, 12),
      spreadRadius: -6,
    ),
  ];

  /// Sombra de la barra inferior (crece hacia arriba).
  static const List<BoxShadow> bottomNavShadow = [
    BoxShadow(color: Color(0x0D000000), blurRadius: 24, offset: Offset(0, -4)),
  ];

  /// Borde de una tarjeta normal.
  static Border get cardBorder => Border.all(color: AppColors.borderSoft);

  /// Decoración reutilizable de tarjeta blanca.
  static BoxDecoration get cardDecoration => BoxDecoration(
    color: AppColors.card,
    border: cardBorder,
    borderRadius: BorderRadius.circular(rCard),
    boxShadow: cardShadow,
  );

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
        titleTextStyle: AppText.display(22, weight: FontWeight.w700),
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
