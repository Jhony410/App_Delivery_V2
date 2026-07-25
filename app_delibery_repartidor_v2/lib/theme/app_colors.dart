import 'package:flutter/material.dart';

/// Paleta de CHASQUI, extraída del canvas de diseño `CHASQUI.dc.html`.
///
/// Fuente única de verdad para el color: ninguna pantalla debe escribir un
/// `Color(0x...)` a mano. Si un tono no está aquí, es que no pertenece al
/// sistema de diseño.
class AppColors {
  AppColors._();

  // ---- Marca / acción principal ----
  /// Aceptar, avanzar, confirmar. El verde del chasqui.
  static const Color primary = Color(0xFF0E7A4F);
  static const Color primaryDark = Color(0xFF0A5C3B);
  static const Color primaryLight = Color(0xFF128A59);

  /// Fondo suave de la marca (píldoras, íconos sobre superficie clara).
  static const Color primarySoft = Color(0xFFE6F4EC);
  static const Color primaryOnSoft = Color(0xFF12A150);

  /// Degradado de cabecera usado en login, perfil, ganancias y drawer.
  static const LinearGradient brandGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryLight, primaryDark],
  );

  // ---- Neutrales ----
  /// Neutral / rechazar.
  static const Color neutral = Color(0xFF8A8B85);
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF6B675F);
  static const Color textHint = Color(0xFFAEB1AA);
  static const Color textOnBrandSoft = Color(0xFFCFEAD9);
  static const Color textOnBrandStrong = Color(0xFFBFE9CF);

  // ---- Superficies ----
  static const Color canvas = Color(0xFFE4E7E2);
  static const Color surface = Color(0xFFFAFAFA);
  static const Color card = Color(0xFFFFFFFF);
  static const Color fill = Color(0xFFF5F7F4);
  static const Color fillStrong = Color(0xFFF0F1EE);
  static const Color border = Color(0xFFE4E7E2);
  static const Color borderSoft = Color(0xFFEEF1EE);
  static const Color divider = Color(0xFFF0F1EE);
  static const Color handle = Color(0xFFE1E4DE);
  static const Color trackOff = Color(0xFFD8DCD6);

  // ---- Semánticos ----
  /// Conectado / en línea.
  static const Color online = Color(0xFF22C55E);

  /// Cancelar / error. Uso exclusivo: nunca para acciones normales.
  static const Color danger = Color(0xFFEA4335);
  static const Color dangerSoft = Color(0xFFFDEEE9);
  static const Color dangerBorder = Color(0xFFFBD5CE);

  /// Advertencia / en revisión / por vencer.
  static const Color warning = Color(0xFFD98324);
  static const Color warningSoft = Color(0xFFFBEFD9);
  static const Color warningBorder = Color(0xFFFBE3C4);
  static const Color warningText = Color(0xFF8A6A2E);

  static const Color star = Color(0xFFFFB800);
  static const Color whatsapp = Color(0xFF25D366);

  // ---- Mapa ----
  static const Color mapTop = Color(0xFFDCEAD8);
  static const Color mapBottom = Color(0xFFB4D9C4);
  static const Color mapWater = Color(0xFF9FCBDD);
  static const Color mapBlock = Color(0xFFBFE0C6);
  static const Color mapOffline = Color(0xFFEDEEEB);

  // ---- Heatmap de demanda (baja → muy alta) ----
  static const Color demandLow = Color(0xFF6EA8DC);
  static const Color demandMedium = Color(0xFFF2C98F);
  static const Color demandHigh = Color(0xFFD98324);
  static const Color demandVeryHigh = Color(0xFFC0503F);

  // ---- Multi-pedido: 1 · 2 · 3 ----
  static const Color order1 = primary;
  static const Color order2 = Color(0xFFD98324);
  static const Color order3 = Color(0xFF6D4BC7);
  static const Color order3Soft = Color(0xFFEEE8FA);

  /// Color de acento por índice de pedido en un lote multi-pedido.
  static Color orderAccent(int index) {
    switch (index % 3) {
      case 0:
        return order1;
      case 1:
        return order2;
      default:
        return order3;
    }
  }

  /// Fondo suave que acompaña a [orderAccent].
  static Color orderAccentSoft(int index) {
    switch (index % 3) {
      case 0:
        return primarySoft;
      case 1:
        return warningSoft;
      default:
        return order3Soft;
    }
  }

  // ---- Barras del gráfico de ganancias ----
  static const Color chartBar = Color(0xFFCFE9D8);

  // ---- Skeleton (shimmer) ----
  static const Color skeletonBase = Color(0xFFE9ECE8);
  static const Color skeletonHighlight = Color(0xFFF3F5F1);
}
