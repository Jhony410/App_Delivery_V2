import 'package:flutter/material.dart';

/// Paleta de DelyPuno Operaciones.
///
/// Los valores salen tal cual del diseño `DelyPunoAdmin.dc.html`.
/// Regla de identidad del panel: **verde = sistema**, **rojo = solo el módulo
/// de Negocios y los errores**. Ningún otro módulo usa el acento rojo.
abstract final class AppColors {
  // ── Marca ──────────────────────────────────────────────────────────────
  /// Verde sistema: sidebar activo, CTA primario, acentos.
  static const Color primary = Color(0xFF0E7A4F);

  /// Verde oscuro: texto sobre fondo verde claro, fin del degradado del logo.
  static const Color primaryDark = Color(0xFF0A5C3B);

  /// Inicio del degradado del logo (`linear-gradient(140deg,#128A59,#0A5C3B)`).
  static const Color primaryGradientStart = Color(0xFF128A59);

  /// Verde claro: fondo del ítem de navegación activo y de los chips «ok».
  static const Color primarySoft = Color(0xFFE6F4EC);

  /// Borde del chip verde claro.
  static const Color primarySoftBorder = Color(0xFFCDE9D8);

  /// Barras inactivas del gráfico de ventas.
  static const Color primaryMuted = Color(0xFFCFE9D8);

  static const LinearGradient brandGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryGradientStart, primaryDark],
  );

  // ── Estado: éxito ──────────────────────────────────────────────────────
  /// Punto vivo «conectado / en línea».
  static const Color success = Color(0xFF22C55E);

  /// Texto y cifras en verde de éxito (+12% vs. ayer).
  static const Color successText = Color(0xFF12A150);
  static const Color successSoft = Color(0xFFE8F7EE);

  // ── Estado: atención ───────────────────────────────────────────────────
  static const Color warning = Color(0xFFD98324);
  static const Color warningSoft = Color(0xFFFBEFD9);
  static const Color warningSoftBorder = Color(0xFFF0E0C0);

  /// Ámbar profundo del estado «PREPARANDO» (frame 14).
  static const Color warningDeep = Color(0xFFB98600);
  static const Color warningDeepSoft = Color(0xFFFFF6E0);

  // ── Estado: crítico · módulo Negocios · acciones destructivas ──────────
  /// Rojo del módulo Negocios y de los botones destructivos.
  static const Color danger = Color(0xFFE53935);

  /// Rojo de texto (más oscuro, para contraste sobre [dangerSoft]).
  static const Color dangerText = Color(0xFFC62828);
  static const Color dangerSoft = Color(0xFFFDECEA);
  static const Color dangerSoftBorder = Color(0xFFF6D5D1);

  /// Punto de notificaciones sin leer del app bar.
  static const Color notificationDot = Color(0xFFEA4335);

  // ── Estado: destacado ──────────────────────────────────────────────────
  static const Color highlight = Color(0xFF6D4BC7);
  static const Color highlightSoft = Color(0xFFEEE8FA);
  static const Color highlightSoftBorder = Color(0xFFDDD4F3);

  // ── Texto ──────────────────────────────────────────────────────────────
  /// Texto principal.
  static const Color textPrimary = Color(0xFF1A1A1A);

  /// Texto secundario (descripciones, celdas no destacadas).
  static const Color textSecondary = Color(0xFF6B675F);

  /// Texto terciario (etiquetas de tabla, metadatos, valores «—»).
  static const Color textMuted = Color(0xFF8A8B85);

  /// Texto de marcador de posición dentro de campos.
  static const Color textPlaceholder = Color(0xFFAEB1AA);

  static const Color textOnPrimary = Color(0xFFFFFFFF);

  /// Texto de un control deshabilitado.
  static const Color textDisabled = Color(0xFFB4B7B0);

  // ── Superficies ────────────────────────────────────────────────────────
  /// Fondo de la aplicación. Nunca blanco.
  static const Color background = Color(0xFFE4E7E2);

  /// Tarjetas, sidebar, app bar, panel de detalle.
  static const Color surface = Color(0xFFFFFFFF);

  /// Campos de búsqueda, encabezado de tabla, filas de apoyo.
  static const Color surfaceSoft = Color(0xFFF5F7F4);

  /// Fondo del chip de estado neutro («BUSCANDO»).
  static const Color surfaceNeutral = Color(0xFFF1F3F0);

  // ── Bordes y divisores ─────────────────────────────────────────────────
  /// Borde de tarjeta.
  static const Color border = Color(0xFFEEF1EE);

  /// Borde de controles y separador de la sidebar (igual al fondo de la app).
  static const Color borderStrong = Color(0xFFE4E7E2);

  /// Divisor entre filas de tabla y de lista.
  static const Color divider = Color(0xFFF3F5F1);

  static const Color scrollbar = Color(0xFFD8DCD6);

  // ── Mapa ───────────────────────────────────────────────────────────────
  static const Color mapGradientStart = Color(0xFFDCEAD8);
  static const Color mapGradientEnd = Color(0xFFB4D9C4);

  /// Marcador de repartidor en ruta.
  static const Color markerCourier = textPrimary;

  /// Marcador de negocio abierto.
  static const Color markerBusiness = primary;

  /// Marcador de cliente esperando.
  static const Color markerCustomer = warning;

  /// Marcador de pedido con problema.
  static const Color markerProblem = danger;

  // ── Skeleton de carga ──────────────────────────────────────────────────
  static const Color skeletonBase = Color(0xFFE9ECE8);
  static const Color skeletonHighlight = Color(0xFFF3F5F1);

  // ── Sombras ────────────────────────────────────────────────────────────
  /// `box-shadow:0 3px 12px rgba(0,0,0,.05)` — tarjetas.
  static const List<BoxShadow> cardShadow = [
    BoxShadow(color: Color(0x0D000000), blurRadius: 12, offset: Offset(0, 3)),
  ];

  /// `box-shadow:0 10px 24px -8px rgba(14,122,79,.6)` — CTA primario.
  static const List<BoxShadow> primaryButtonShadow = [
    BoxShadow(
      color: Color(0x990E7A4F),
      blurRadius: 24,
      spreadRadius: -8,
      offset: Offset(0, 10),
    ),
  ];

  /// `box-shadow:0 6px 16px -6px rgba(14,122,79,.55)` — logotipo.
  static const List<BoxShadow> logoShadow = [
    BoxShadow(
      color: Color(0x8C0E7A4F),
      blurRadius: 16,
      spreadRadius: -6,
      offset: Offset(0, 6),
    ),
  ];

  /// `box-shadow:0 4px 12px rgba(0,0,0,.12)` — píldoras flotantes del mapa.
  static const List<BoxShadow> floatingShadow = [
    BoxShadow(color: Color(0x1F000000), blurRadius: 12, offset: Offset(0, 4)),
  ];

  /// `box-shadow:0 3px 8px rgba(0,0,0,.35)` — marcadores del mapa.
  static const List<BoxShadow> markerShadow = [
    BoxShadow(color: Color(0x59000000), blurRadius: 8, offset: Offset(0, 3)),
  ];
}
