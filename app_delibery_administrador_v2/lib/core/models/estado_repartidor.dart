/// Estados operativos de un repartidor (app CHASQUI), tal como los lista el
/// frame 04 del diseño.
///
/// Vive en `core/` porque lo consumen Repartidores, Mapa, Reasignación y
/// Dashboard.
enum EstadoRepartidor {
  conectado('CONECTADO'),
  buscando('BUSCANDO'),
  enCamino('EN CAMINO'),
  multiPedido('MULTI-PEDIDO'),
  docsPendientes('DOCS PENDIENTES'),
  desconectado('DESCONECTADO');

  const EstadoRepartidor(this.etiqueta);

  final String etiqueta;

  /// Está en línea y el sistema puede contarlo como disponible.
  bool get estaEnLinea => switch (this) {
    EstadoRepartidor.desconectado || EstadoRepartidor.docsPendientes => false,
    _ => true,
  };

  /// Puede recibir una reasignación ahora mismo.
  bool get puedeRecibirPedido => switch (this) {
    EstadoRepartidor.conectado ||
    EstadoRepartidor.buscando ||
    EstadoRepartidor.enCamino => true,
    EstadoRepartidor.multiPedido ||
    EstadoRepartidor.docsPendientes ||
    EstadoRepartidor.desconectado => false,
  };

  String toJson() => name;

  static EstadoRepartidor fromJson(Object? value) {
    final texto = value?.toString();
    return EstadoRepartidor.values.firstWhere(
      (e) => e.name == texto,
      orElse: () => EstadoRepartidor.desconectado,
    );
  }
}
