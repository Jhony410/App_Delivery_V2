/// Tokens de espaciado y radios, derivados del diseño.
/// Mantiene consistencia en paddings, gaps y bordes redondeados.
class AppSpacing {
  AppSpacing._();

  // Espaciado base
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;

  // Padding horizontal estándar de las pantallas (20px en el diseño)
  static const double screenH = 20;
}

/// Radios de borde estándar.
class AppRadius {
  AppRadius._();

  static const double chip = 22;
  static const double input = 14;
  static const double button = 18;
  static const double card = 18;
  static const double cardLarge = 22;
  static const double sheet = 26;
  static const double pill = 20;
}
