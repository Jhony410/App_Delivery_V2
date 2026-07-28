/// Tipo de promoción del creador del frame 10.
enum TipoPromocion {
  descuento('Descuento %'),
  dosPorUno('2×1'),
  envio('Envío');

  const TipoPromocion(this.etiqueta);

  final String etiqueta;

  String toJson() => name;

  static TipoPromocion fromJson(Object? value) {
    final texto = value?.toString();
    return TipoPromocion.values.firstWhere(
      (e) => e.name == texto,
      orElse: () => TipoPromocion.descuento,
    );
  }
}

/// Estado de una promoción publicada.
enum EstadoPromocion {
  activa('ACTIVA'),
  terminaHoy('TERMINA HOY'),
  borrador('BORRADOR'),
  finalizada('FINALIZADA');

  const EstadoPromocion(this.etiqueta);

  final String etiqueta;

  String toJson() => name;

  static EstadoPromocion fromJson(Object? value) {
    final texto = value?.toString();
    return EstadoPromocion.values.firstWhere(
      (e) => e.name == texto,
      orElse: () => EstadoPromocion.borrador,
    );
  }
}

/// Promoción de la app del cliente.
class Promocion {
  const Promocion({
    required this.id,
    required this.titulo,
    required this.tipo,
    required this.valor,
    required this.desde,
    required this.hasta,
    required this.estado,
    this.negocios = const [],
    this.usos = 0,
    this.alcanceTexto,
  });

  final String id;
  final String titulo;
  final TipoPromocion tipo;

  /// «25%», «2×1», «Gratis».
  final String valor;

  final String desde;
  final String hasta;
  final EstadoPromocion estado;

  /// Nombres de los negocios incluidos. Vacío significa «todos los negocios».
  final List<String> negocios;

  final int usos;

  /// Texto ya compuesto para el listado («Todos los negocios · 1,204 usos»).
  final String? alcanceTexto;

  String get alcance =>
      alcanceTexto ??
      (negocios.isEmpty
          ? 'Todos los negocios · $usos usos'
          : '${negocios.length} negocios · $usos usos');

  factory Promocion.fromJson(Map<String, dynamic> json) => Promocion(
    id: json['id'] as String? ?? '',
    titulo: json['titulo'] as String? ?? '',
    tipo: TipoPromocion.fromJson(json['tipo']),
    valor: json['valor'] as String? ?? '',
    desde: json['desde'] as String? ?? '',
    hasta: json['hasta'] as String? ?? '',
    estado: EstadoPromocion.fromJson(json['estado']),
    negocios: [
      for (final n in (json['negocios'] as List<dynamic>? ?? const []))
        n.toString(),
    ],
    usos: (json['usos'] as num?)?.toInt() ?? 0,
    alcanceTexto: json['alcanceTexto'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'titulo': titulo,
    'tipo': tipo.toJson(),
    'valor': valor,
    'desde': desde,
    'hasta': hasta,
    'estado': estado.toJson(),
    'negocios': negocios,
    'usos': usos,
    'alcanceTexto': alcanceTexto,
  };
}
