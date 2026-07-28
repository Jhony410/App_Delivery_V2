/// Estados de un negocio en el frame 07 del diseño.
///
/// Es el único módulo del panel que usa el acento rojo de la marca.
enum EstadoNegocio {
  abierto('ABIERTO'),
  cerrado('CERRADO'),
  retrasos('RETRASOS');

  const EstadoNegocio(this.etiqueta);

  final String etiqueta;

  bool get atiende => this != EstadoNegocio.cerrado;

  String toJson() => name;

  static EstadoNegocio fromJson(Object? value) {
    final texto = value?.toString();
    return EstadoNegocio.values.firstWhere(
      (e) => e.name == texto,
      orElse: () => EstadoNegocio.cerrado,
    );
  }
}

/// Estados de un cliente en el frame 09.
enum EstadoCliente {
  frecuente('FRECUENTE'),
  activo('ACTIVO'),
  bloqueado('BLOQUEADO');

  const EstadoCliente(this.etiqueta);

  final String etiqueta;

  bool get puedePedir => this != EstadoCliente.bloqueado;

  String toJson() => name;

  static EstadoCliente fromJson(Object? value) {
    final texto = value?.toString();
    return EstadoCliente.values.firstWhere(
      (e) => e.name == texto,
      orElse: () => EstadoCliente.activo,
    );
  }
}
