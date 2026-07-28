/// Los 11 estados de pedido del frame 14 del diseño.
///
/// El diseño los marca como «idénticos en las 4 apps», por eso viven en `core/`
/// y no dentro de una feature: los consumen Pedidos, Mapa, Negocios, Soporte,
/// Repartidores y Dashboard. Es el primer candidato a mudarse a
/// `packages/dely_core` sin cambios.
enum EstadoPedido {
  pendiente('PENDIENTE'),
  buscandoRepartidor('BUSCANDO REPARTIDOR'),
  aceptado('ACEPTADO'),
  preparando('PREPARANDO'),
  listo('LISTO'),
  recogido('RECOGIDO'),
  enCamino('EN CAMINO'),
  entregado('ENTREGADO'),
  cancelado('CANCELADO'),
  problema('PROBLEMA'),
  multiPedido('MULTI-PEDIDO');

  const EstadoPedido(this.etiqueta);

  /// Texto tal como aparece en la insignia del diseño.
  final String etiqueta;

  /// Rótulo corto para tablas estrechas («BUSCANDO» en vez de
  /// «BUSCANDO REPARTIDOR»).
  String get etiquetaCorta =>
      this == EstadoPedido.buscandoRepartidor ? 'BUSCANDO' : etiqueta;

  /// Un pedido en curso ocupa a un repartidor y aparece en el mapa.
  bool get estaActivo => switch (this) {
    EstadoPedido.entregado || EstadoPedido.cancelado => false,
    _ => true,
  };

  /// Solo estos estados admiten reasignar el repartidor.
  bool get admiteReasignacion => switch (this) {
    EstadoPedido.buscandoRepartidor ||
    EstadoPedido.aceptado ||
    EstadoPedido.preparando ||
    EstadoPedido.listo ||
    EstadoPedido.recogido ||
    EstadoPedido.enCamino ||
    EstadoPedido.problema ||
    EstadoPedido.multiPedido => true,
    EstadoPedido.pendiente ||
    EstadoPedido.entregado ||
    EstadoPedido.cancelado => false,
  };

  String toJson() => name;

  static EstadoPedido fromJson(Object? value) {
    final texto = value?.toString();
    return EstadoPedido.values.firstWhere(
      (e) => e.name == texto,
      orElse: () => EstadoPedido.pendiente,
    );
  }
}
