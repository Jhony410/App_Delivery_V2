import 'package:flutter/material.dart';

/// Paleta de DelyPuno Negocios, extraída del canvas `DelyNegocios.dc.html`.
///
/// Fuente única de verdad para el color: ninguna pantalla debe escribir un
/// `Color(0x...)` a mano. Si un tono no está aquí, es que no pertenece al
/// sistema de diseño.
///
/// Regla del canvas: el rojo de marca [primary] es **acción** (aceptar,
/// continuar, reintentar). El rojo apagado [danger] es **error real** y jamás
/// se usa para una acción normal.
class AppColors {
  AppColors._();

  // ---- Marca / acción principal ----
  /// Rojo de marca. Aceptar, continuar, confirmar.
  static const Color primary = Color(0xFFE53935);
  static const Color primaryDark = Color(0xFFC62828);
  static const Color primaryLight = Color(0xFFEF5350);

  /// Fondo suave de la marca (píldoras, íconos sobre superficie clara).
  static const Color primarySoft = Color(0xFFFDECEA);

  /// Degradado de cabecera: splash, login, inicio, perfil y alerta de pedido.
  static const LinearGradient brandGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryLight, primaryDark],
  );

  // ---- Texto ----
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF6B675F);
  static const Color textHint = Color(0xFFAEB1AA);
  static const Color neutral = Color(0xFF8A8B85);

  /// Texto sobre el degradado de marca.
  static const Color textOnBrandSoft = Color(0xFFFFD9D6);
  static const Color textOnBrandStrong = Color(0xFFFFE0DE);

  // ---- Superficies ----
  static const Color canvas = Color(0xFFE4E7E2);
  static const Color surface = Color(0xFFFAFAFA);
  static const Color card = Color(0xFFFFFFFF);
  static const Color fill = Color(0xFFF5F5F5);
  static const Color fillStrong = Color(0xFFF1F3F0);
  static const Color border = Color(0xFFE4E7E2);
  static const Color borderSoft = Color(0xFFEEF1EE);
  static const Color divider = Color(0xFFF0F1EE);
  static const Color trackOff = Color(0xFFD8DCD6);
  static const Color disabledText = Color(0xFFB4B7B0);

  // ---- Estados del pedido (idénticos en las 3 apps del sistema) ----
  /// Preparando.
  static const Color warning = Color(0xFFB98600);
  static const Color warningSoft = Color(0xFFFFF6E0);
  static const Color warningBorder = Color(0xFFF0E4C0);

  /// Repartidor en camino.
  static const Color transit = Color(0xFF0A5C3B);
  static const Color transitSoft = Color(0xFFE6F4EC);

  /// Entregado / disponible / ganancia.
  static const Color success = Color(0xFF12A150);
  static const Color successSoft = Color(0xFFE8F7EE);

  // ---- Semánticos ----
  /// Error real (sin conexión, algo salió mal). Nunca para acciones.
  static const Color danger = Color(0xFFC0503F);
  static const Color dangerSoft = Color(0xFFFDEEE9);

  /// Punto "Abierto ahora" sobre el degradado.
  static const Color openDot = Color(0xFF7CFFB0);

  static const Color whatsapp = Color(0xFF25D366);

  // ---- Miniaturas de producto (degradados del canvas) ----
  static const LinearGradient thumbWarm = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFE0A6), Color(0xFFF0A63C)],
  );
  static const LinearGradient thumbOrange = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFCDA6), Color(0xFFE07B3C)],
  );

  /// Miniatura de un producto agotado (gris plano, sin degradado).
  static const Color thumbMuted = Color(0xFFE7E9E5);

  // ---- Skeleton (shimmer del frame 11) ----
  static const Color skeletonBase = Color(0xFFECECEC);
  static const Color skeletonHighlight = Color(0xFFF6F6F6);
}
