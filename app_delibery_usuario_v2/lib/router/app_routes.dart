/// Fuente única de verdad para las rutas de DelyPuno.
///
/// Nunca escribir strings de ruta a mano en las pantallas: usar estas
/// constantes (`path`) y ayudantes (`...To(...)`) para construir rutas con
/// parámetros. Así se evitan errores de tipeo y rutas huérfanas.
class AppRoutes {
  AppRoutes._();

  // ---- Fuera del shell (pantallas completas) ----
  static const String splash = '/splash';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';

  // ---- Pestañas del shell inferior ----
  static const String home = '/home';
  static const String search = '/search';
  static const String history = '/history';
  static const String profile = '/profile';

  // ---- Flujos sobre el shell ----
  static const String category = '/category/:categoryId';
  static const String business = '/business/:businessId';
  static const String product = '/product/:businessId/:productId';
  static const String checkout = '/checkout';
  static const String tracking = '/tracking/:orderId';
  static const String rating = '/rating/:orderId';
  static const String addresses = '/addresses';
  static const String addAddress = '/add-address';
  static const String adjustMap = '/adjust-map';
  static const String myTown = '/my-town';

  // Pantalla amigable de "no encontrado".
  static const String notFound = '/not-found';

  // ---- Nombres de ruta (para pushNamed / goNamed si se prefiere) ----
  static const String nSplash = 'splash';
  static const String nOnboarding = 'onboarding';
  static const String nLogin = 'login';
  static const String nRegister = 'register';
  static const String nHome = 'home';
  static const String nSearch = 'search';
  static const String nHistory = 'history';
  static const String nProfile = 'profile';
  static const String nCategory = 'category';
  static const String nBusiness = 'business';
  static const String nProduct = 'product';
  static const String nCheckout = 'checkout';
  static const String nTracking = 'tracking';
  static const String nRating = 'rating';
  static const String nAddresses = 'addresses';
  static const String nAddAddress = 'addAddress';
  static const String nAdjustMap = 'adjustMap';
  static const String nMyTown = 'myTown';
  static const String nNotFound = 'notFound';

  // ---- Constructores de rutas con parámetros ----
  static String categoryTo(String categoryId) => '/category/$categoryId';
  static String businessTo(String businessId) => '/business/$businessId';
  static String productTo(String businessId, String productId) =>
      '/product/$businessId/$productId';
  static String trackingTo(String orderId) => '/tracking/$orderId';
  static String ratingTo(String orderId) => '/rating/$orderId';

  /// `adjust-map` recuerda su origen para saber a dónde volver al confirmar.
  /// [from] puede ser `addresses` o `add-address`.
  static String adjustMapFrom(String from) => '$adjustMap?from=$from';
}
