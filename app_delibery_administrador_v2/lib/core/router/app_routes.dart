/// Rutas del panel. Ninguna pantalla navega con cadenas literales: todas
/// pasan por estas constantes o por [AppRoutes.aXxx].
abstract final class AppRoutes {
  // ── Fuera del shell ────────────────────────────────────────────────────
  static const String login = '/login';

  /// Ruta modal del centro de reasignación (frame 06). Se abre sobre la
  /// pantalla que la invoca y devuelve el control a ella al cerrarse.
  static const String reasignar = '/reasignar/:pedidoId';

  // ── Ramas del shell (barra lateral) ────────────────────────────────────
  static const String dashboard = '/dashboard';
  static const String pedidos = '/pedidos';
  static const String mapa = '/mapa';
  static const String repartidores = '/repartidores';
  static const String negocios = '/negocios';
  static const String clientes = '/clientes';
  static const String promociones = '/promociones';
  static const String reportes = '/reportes';
  static const String pagos = '/pagos';
  static const String configuracion = '/configuracion';

  // ── Rutas hijas (push, con botón atrás) ────────────────────────────────
  /// Segmento relativo del detalle de pedido dentro de `/pedidos`.
  static const String detallePedidoSegmento = ':pedidoId';

  /// Segmento relativo de la ficha de repartidor dentro de `/repartidores`.
  static const String fichaRepartidorSegmento = ':repartidorId';

  /// Segmento relativo del soporte dentro de `/negocios`.
  static const String soporteNegocioSegmento = ':negocioId/soporte';

  // ── Constructores de rutas con parámetros ──────────────────────────────
  static String aDetallePedido(String pedidoId) =>
      '$pedidos/${Uri.encodeComponent(pedidoId)}';

  static String aFichaRepartidor(String repartidorId) =>
      '$repartidores/${Uri.encodeComponent(repartidorId)}';

  static String aSoporteNegocio(String negocioId) =>
      '$negocios/${Uri.encodeComponent(negocioId)}/soporte';

  static String aReasignar(String pedidoId) =>
      '/reasignar/${Uri.encodeComponent(pedidoId)}';

  /// Índice de la rama del shell al que pertenece cada ruta raíz, en el
  /// mismo orden que la barra lateral del diseño.
  static const List<String> ramas = [
    dashboard,
    pedidos,
    mapa,
    repartidores,
    negocios,
    clientes,
    promociones,
    reportes,
    pagos,
    configuracion,
  ];
}
