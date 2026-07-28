import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Tipografía de DelyPuno Operaciones: **Poppins** para títulos, **Inter**
/// para el cuerpo y la interfaz, tal como declara el diseño.
///
/// `google_fonts` resuelve las familias en tiempo de ejecución. Si la descarga
/// falla (sin red, primer arranque offline) [_poppins] y [_inter] devuelven un
/// `TextStyle` con `fontFamilyFallback` sobre las fuentes del sistema, de modo
/// que la app nunca deja de renderizar por una fuente ausente.
abstract final class AppTextStyles {
  static const List<String> _sansFallback = <String>[
    'Segoe UI',
    'Roboto',
    'Helvetica Neue',
    'Arial',
  ];

  static TextStyle _poppins({
    required double size,
    required FontWeight weight,
    Color color = AppColors.textPrimary,
    double? letterSpacing,
    double? height,
  }) {
    final base = TextStyle(
      fontSize: size,
      fontWeight: weight,
      color: color,
      letterSpacing: letterSpacing,
      height: height,
      fontFamilyFallback: _sansFallback,
    );
    try {
      return GoogleFonts.poppins(textStyle: base);
    } on Exception {
      return base;
    }
  }

  static TextStyle _inter({
    required double size,
    required FontWeight weight,
    Color color = AppColors.textPrimary,
    double? letterSpacing,
    double? height,
  }) {
    final base = TextStyle(
      fontSize: size,
      fontWeight: weight,
      color: color,
      letterSpacing: letterSpacing,
      height: height,
      fontFamilyFallback: _sansFallback,
    );
    try {
      return GoogleFonts.inter(textStyle: base);
    } on Exception {
      return base;
    }
  }

  // ── Poppins · títulos y cifras ─────────────────────────────────────────

  /// `font:800 32px Poppins` — marca en la pantalla de acceso.
  static TextStyle get brandTitle =>
      _poppins(size: 32, weight: FontWeight.w800, letterSpacing: -0.6);

  /// `font:800 30px Poppins` — cifra grande de una tarjeta KPI.
  static TextStyle get kpiValue =>
      _poppins(size: 30, weight: FontWeight.w800, height: 1);

  /// `font:800 28px Poppins` — cifra KPI del módulo de reportes.
  static TextStyle get kpiValueLarge =>
      _poppins(size: 28, weight: FontWeight.w800, height: 1);

  /// `font:800 26px Poppins` — título de pantalla con miga de pan.
  static TextStyle get pageTitle =>
      _poppins(size: 26, weight: FontWeight.w800, letterSpacing: -0.4);

  /// `font:800 24px Poppins` — cifra de una tarjeta de acción.
  static TextStyle get actionValue =>
      _poppins(size: 24, weight: FontWeight.w800, height: 1);

  /// `font:800 22px Poppins` — título del panel de detalle.
  static TextStyle get panelTitle =>
      _poppins(size: 22, weight: FontWeight.w800);

  /// `font:800 20px Poppins` — título de pantalla sin miga de pan.
  static TextStyle get screenTitle =>
      _poppins(size: 20, weight: FontWeight.w800);

  /// `font:700 18px Poppins` — título de una sección dentro de una tarjeta.
  static TextStyle get sectionTitle =>
      _poppins(size: 18, weight: FontWeight.w700);

  /// `font:700 17px Poppins` — título de tarjeta compacta.
  static TextStyle get cardTitleSmall =>
      _poppins(size: 17, weight: FontWeight.w700);

  /// `font:700 16px Poppins` — título de tarjeta.
  static TextStyle get cardTitle => _poppins(size: 16, weight: FontWeight.w700);

  /// `font:700 14px Poppins` — ítem de navegación activo y etiqueta de botón.
  static TextStyle get navActive => _poppins(size: 14, weight: FontWeight.w700);

  /// `font:700 13px Poppins` — montos en tabla y etiqueta de botón compacto.
  static TextStyle get amount => _poppins(size: 13, weight: FontWeight.w700);

  /// `font:700 12px Poppins` — numeración de frame / iniciales de avatar.
  static TextStyle get amountSmall =>
      _poppins(size: 12, weight: FontWeight.w700);

  // ── Inter · interfaz ───────────────────────────────────────────────────

  /// `font:600 15px Inter`.
  static TextStyle get bodyLargeStrong =>
      _inter(size: 15, weight: FontWeight.w600);

  /// `font:500 14px Inter` — ítem de navegación inactivo, celda de tabla.
  static TextStyle get body => _inter(size: 14, weight: FontWeight.w500);

  /// `font:600 14px Inter` — texto de interfaz destacado.
  static TextStyle get bodyStrong => _inter(size: 14, weight: FontWeight.w600);

  /// `font:400 14px Inter` — marcador de posición de un campo.
  static TextStyle get bodyRegular => _inter(size: 14, weight: FontWeight.w400);

  /// `font:500 13px Inter`.
  static TextStyle get bodySmall => _inter(size: 13, weight: FontWeight.w500);

  /// `font:600 13px Inter` — nombre en una fila de tabla.
  static TextStyle get bodySmallStrong =>
      _inter(size: 13, weight: FontWeight.w600);

  /// `font:500 12px Inter` — miga de pan, metadatos.
  static TextStyle get label => _inter(size: 12, weight: FontWeight.w500);

  /// `font:600 12px Inter` — etiqueta de filtro, leyenda.
  static TextStyle get labelStrong => _inter(size: 12, weight: FontWeight.w600);

  /// `font:700 12px Inter` — filtro activo.
  static TextStyle get labelBold => _inter(size: 12, weight: FontWeight.w700);

  /// `font:400 12px Inter` — descripción auxiliar.
  static TextStyle get caption => _inter(size: 12, weight: FontWeight.w400);

  /// `font:400 11px Inter` — nota al pie de un ítem de lista.
  static TextStyle get captionSmall =>
      _inter(size: 11, weight: FontWeight.w400);

  /// `font:500 11px Inter` — rótulo de eje de gráfico.
  static TextStyle get captionMedium =>
      _inter(size: 11, weight: FontWeight.w500);

  /// `font:600 11px Inter` — subtítulo de la marca en la sidebar.
  static TextStyle get captionStrong =>
      _inter(size: 11, weight: FontWeight.w600, letterSpacing: 1);

  /// `font:700 11px Inter` — contador dentro de un ítem de navegación.
  static TextStyle get counter => _inter(size: 11, weight: FontWeight.w700);

  /// `font:700 11px Inter` + `letter-spacing:.5px` + mayúsculas — encabezado
  /// de columna de tabla.
  static TextStyle get tableHeader =>
      _inter(size: 11, weight: FontWeight.w700, letterSpacing: 0.5);

  /// `font:700 10px Inter` — insignia de estado.
  static TextStyle get badge => _inter(size: 10, weight: FontWeight.w700);
}
