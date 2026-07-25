/// Fuente única de verdad para las rutas de CHASQUI.
///
/// Nunca escribir un path a mano en una pantalla: usar estas constantes. Así
/// no existen rutas huérfanas ni typos que terminen en la pantalla de "no
/// encontrado".
///
/// **Sobre el conteo:** el diseño tiene 27 frames, pero solo 13 son rutas.
/// Los frames 06–13 (núcleo operativo) comparten [operations]; el 20 es un
/// `Drawer`; los frames 21–26 son estados que dispara `AppState`; y el 27 es
/// la librería de widgets en `lib/widgets/`.
class AppRoutes {
  AppRoutes._();

  // ---- Onboarding y acceso (frames 01–05) ----
  static const String splash = '/';
  static const String login = '/login';
  static const String smsVerification = '/verificacion-sms';
  static const String locationPermission = '/permisos-ubicacion';
  static const String documentVerification = '/verificacion-documentos';

  /// Núcleo operativo (frames 06–13): una sola pantalla con overlays y hojas
  /// inferiores según la fase de `AppState`.
  static const String operations = '/mapa';

  // ---- Cuenta y desempeño (frames 14–19) ----
  static const String earnings = '/ganancias';
  static const String history = '/historial';
  static const String profile = '/perfil';
  static const String documents = '/documentos';
  static const String settings = '/configuracion';
  static const String help = '/ayuda';

  /// Pantalla 28: red de seguridad con identidad CHASQUI para cualquier ruta
  /// desconocida. Sustituye a la pantalla roja de Flutter.
  static const String notFound = '/no-encontrado';

  // ---- Nombres (para goNamed / pushNamed) ----
  static const String nSplash = 'splash';
  static const String nLogin = 'login';
  static const String nSmsVerification = 'smsVerification';
  static const String nLocationPermission = 'locationPermission';
  static const String nDocumentVerification = 'documentVerification';
  static const String nOperations = 'operations';
  static const String nEarnings = 'earnings';
  static const String nHistory = 'history';
  static const String nProfile = 'profile';
  static const String nDocuments = 'documents';
  static const String nSettings = 'settings';
  static const String nHelp = 'help';
  static const String nNotFound = 'notFound';

  /// Todas las rutas navegables, en orden de aparición en el diseño.
  /// Se usa en las pruebas para garantizar que ninguna quede sin registrar.
  static const List<String> all = [
    splash,
    login,
    smsVerification,
    locationPermission,
    documentVerification,
    operations,
    earnings,
    history,
    profile,
    documents,
    settings,
    help,
    notFound,
  ];
}
