/// Fuente única de verdad para las rutas de DelyPuno Negocios.
///
/// Nunca escribir un path a mano en una pantalla: usar estas constantes. Así no
/// existen rutas huérfanas ni typos que terminen en la pantalla de error.
///
/// **Sobre el conteo:** el diseño pide 13 pantallas. Diez son rutas propias;
/// las tres restantes (Sin conexión, Estado vacío, Error genérico) son estados
/// reutilizables que se montan *dentro* de Inicio, Pedidos y Productos. Aun
/// así, Sin conexión y Error genérico tienen ruta propia registrada para poder
/// alcanzarlas de forma directa (enlaces internos, pruebas y `errorBuilder`).
class AppRoutes {
  AppRoutes._();

  // ---- Stack previo al login (sin bottom nav) ----
  /// 01 · Splash. Ruta inicial de la app.
  static const String splash = '/';

  /// 02 · Onboarding.
  static const String onboarding = '/onboarding';

  /// 03 · Login ("Ingresa a tu local").
  static const String login = '/login';

  /// 04 · Verificación del negocio ("Datos de tu negocio").
  static const String businessVerification = '/verificacion-negocio';

  // ---- Shell con bottom navigation persistente ----
  /// 05 · Inicio (dashboard).
  static const String home = '/inicio';

  /// 06 · Pedidos.
  static const String orders = '/pedidos';

  /// 07 · Productos.
  static const String products = '/productos';

  /// 08 · Reportes.
  static const String reports = '/reportes';

  /// 09 · Perfil.
  static const String profile = '/perfil';

  // ---- Estados del sistema ----
  /// 10 · Alerta de pedido nuevo. Ruta transparente sobre el shell: la
  /// pantalla de abajo sigue montada y no pierde su estado.
  static const String newOrderAlert = '/alerta-pedido';

  /// 11 · Sin conexión a pantalla completa. Su uso habitual es embebido en
  /// Inicio/Pedidos/Productos; la ruta existe para enlaces directos.
  static const String offline = '/sin-conexion';

  /// 12 · Error genérico. Destino del `errorBuilder` del router y del
  /// `ErrorWidget.builder` de la app: sustituye a la pantalla roja de Flutter.
  static const String error = '/error';

  // ---- Nombres únicos (para goNamed / pushNamed) ----
  static const String nSplash = 'splash';
  static const String nOnboarding = 'onboarding';
  static const String nLogin = 'login';
  static const String nBusinessVerification = 'businessVerification';
  static const String nHome = 'home';
  static const String nOrders = 'orders';
  static const String nProducts = 'products';
  static const String nReports = 'reports';
  static const String nProfile = 'profile';
  static const String nNewOrderAlert = 'newOrderAlert';
  static const String nOffline = 'offline';
  static const String nError = 'error';

  /// Las cinco pestañas del bottom nav, en orden.
  static const List<String> tabs = [home, orders, products, reports, profile];

  /// Todas las rutas registradas, en orden de aparición en el diseño.
  /// Las pruebas la recorren para garantizar que ninguna queda sin registrar.
  static const List<String> all = [
    splash,
    onboarding,
    login,
    businessVerification,
    home,
    orders,
    products,
    reports,
    profile,
    newOrderAlert,
    offline,
    error,
  ];
}
