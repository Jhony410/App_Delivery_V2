import 'package:flutter/widgets.dart';

/// Escala de espaciado del diseño `DelyPunoAdmin.dc.html`.
abstract final class AppSpacing {
  static const double xxs = 3;
  static const double xs = 6;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 26;
  static const double xxxl = 32;

  /// Separación entre tarjetas de una misma cuadrícula (`gap:16px`).
  static const double gridGap = 16;

  /// Relleno horizontal del contenido principal (`padding:24px 26px`).
  static const double pageHorizontal = 26;
  static const double pageVertical = 24;

  /// Relleno interno estándar de una tarjeta (`padding:18px`/`20px`).
  static const double cardPadding = 20;
  static const double cardPaddingTight = 18;
}

/// Radios de esquina del diseño.
abstract final class AppRadius {
  static const double xs = 8;
  static const double sm = 9;
  static const double md = 12;
  static const double lg = 14;
  static const double xl = 16;
  static const double xxl = 18;

  /// Radio de píldora (`border-radius:20px` sobre elementos bajos).
  static const double pill = 20;

  static const BorderRadius chip = BorderRadius.all(Radius.circular(pill));
  static const BorderRadius card = BorderRadius.all(Radius.circular(xl));
  static const BorderRadius control = BorderRadius.all(Radius.circular(md));
  static const BorderRadius panel = BorderRadius.all(Radius.circular(lg));
}

/// Dimensiones fijas tomadas del diseño (1440×900).
abstract final class AppSizes {
  /// Ancho de la barra lateral de navegación.
  static const double sidebarWidth = 260;

  /// Alto de la barra superior.
  static const double topBarHeight = 70;

  /// Ancho del panel de detalle de pedido (frame 02).
  static const double detailPanelWidth = 430;

  /// Ancho del panel lateral del mapa (frame 03).
  static const double mapPanelWidth = 330;

  /// Alto de los controles (botones, campos, chips altos).
  static const double controlHeight = 42;
  static const double controlHeightSmall = 40;

  /// Punto de corte a partir del cual la barra lateral es fija.
  ///
  /// Por debajo, el mismo shell la presenta como `Drawer` y las tablas se
  /// apilan en tarjetas.
  static const double sidebarBreakpoint = 900;

  /// Punto de corte para pasar de cuadrículas de 4 columnas a 2 y de 2 a 1.
  static const double wideBreakpoint = 1180;
  static const double compactBreakpoint = 640;

  static const double avatarSm = 34;
  static const double avatarMd = 40;
  static const double avatarLg = 44;
  static const double avatarXl = 52;
}
