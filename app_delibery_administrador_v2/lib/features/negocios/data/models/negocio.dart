import '../../../../core/models/estado_negocio.dart';

/// Producto del catálogo de un negocio, editable desde Soporte.
class Producto {
  const Producto({
    required this.id,
    required this.nombre,
    required this.precio,
    required this.disponible,
    this.emoji = '🍽️',
  });

  final String id;
  final String nombre;
  final double precio;
  final bool disponible;
  final String emoji;

  String get precioTexto => 'S/ ${precio.toStringAsFixed(2)}';

  String get disponibilidadTexto => disponible ? 'Disponible' : 'Agotado';

  Producto copyWith({String? nombre, double? precio, bool? disponible}) =>
      Producto(
        id: id,
        nombre: nombre ?? this.nombre,
        precio: precio ?? this.precio,
        disponible: disponible ?? this.disponible,
        emoji: emoji,
      );

  factory Producto.fromJson(Map<String, dynamic> json) => Producto(
    id: json['id'] as String? ?? '',
    nombre: json['nombre'] as String? ?? '',
    precio: (json['precio'] as num?)?.toDouble() ?? 0,
    disponible: json['disponible'] as bool? ?? true,
    emoji: json['emoji'] as String? ?? '🍽️',
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'nombre': nombre,
    'precio': precio,
    'disponible': disponible,
    'emoji': emoji,
  };
}

/// Estado de resolución de una incidencia.
enum EstadoIncidencia {
  sinResolver('sin resolver'),
  enRevision('en revisión'),
  resuelta('resuelto');

  const EstadoIncidencia(this.etiqueta);

  final String etiqueta;

  String toJson() => name;

  static EstadoIncidencia fromJson(Object? value) {
    final texto = value?.toString();
    return EstadoIncidencia.values.firstWhere(
      (e) => e.name == texto,
      orElse: () => EstadoIncidencia.sinResolver,
    );
  }
}

/// Incidencia registrada sobre un pedido o un negocio.
class Incidencia {
  const Incidencia({
    required this.id,
    required this.titulo,
    required this.detalle,
    required this.estado,
    this.pedidoId,
    this.negocioId,
    this.severidad = SeveridadIncidencia.critica,
  });

  final String id;
  final String titulo;

  /// «Hoy 13:12 · sin resolver», «Chifa Titicaca · hace 12 min».
  final String detalle;

  final EstadoIncidencia estado;
  final String? pedidoId;
  final String? negocioId;
  final SeveridadIncidencia severidad;

  factory Incidencia.fromJson(Map<String, dynamic> json) => Incidencia(
    id: json['id'] as String? ?? '',
    titulo: json['titulo'] as String? ?? '',
    detalle: json['detalle'] as String? ?? '',
    estado: EstadoIncidencia.fromJson(json['estado']),
    pedidoId: json['pedidoId'] as String?,
    negocioId: json['negocioId'] as String?,
    severidad: SeveridadIncidencia.fromJson(json['severidad']),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'titulo': titulo,
    'detalle': detalle,
    'estado': estado.toJson(),
    'pedidoId': pedidoId,
    'negocioId': negocioId,
    'severidad': severidad.toJson(),
  };
}

/// Severidad de una incidencia; decide el color del icono en el diseño.
enum SeveridadIncidencia {
  /// Rojo: retraso grave, cobro duplicado.
  critica,

  /// Ámbar: sin repartidor, demora incipiente.
  atencion,

  /// Morado: reclamo de cliente.
  reclamo;

  String toJson() => name;

  static SeveridadIncidencia fromJson(Object? value) {
    final texto = value?.toString();
    return SeveridadIncidencia.values.firstWhere(
      (e) => e.name == texto,
      orElse: () => SeveridadIncidencia.critica,
    );
  }
}

/// Negocio afiliado a DelyPuno.
class Negocio {
  const Negocio({
    required this.id,
    required this.nombre,
    required this.categoria,
    required this.direccion,
    required this.estado,
    required this.horario,
    required this.comision,
    this.emoji = '🛍️',
    this.ventasHoy,
    this.pedidosPendientes = 0,
    this.calificacion,
    this.incidenciasAbiertas = 0,
    this.comisionPreferente = false,
    this.productos = const [],
    this.incidencias = const [],
  });

  final String id;
  final String nombre;
  final String categoria;
  final String direccion;
  final EstadoNegocio estado;

  /// «12:00–23:00».
  final String horario;

  /// Porcentaje sobre el total del pedido.
  final int comision;

  final String emoji;

  /// `null` cuando el negocio está cerrado y el diseño muestra «—».
  final double? ventasHoy;

  final int pedidosPendientes;
  final double? calificacion;
  final int incidenciasAbiertas;

  /// El diseño marca la comisión reducida de bodegas con una estrella.
  final bool comisionPreferente;

  final List<Producto> productos;
  final List<Incidencia> incidencias;

  bool get tieneIncidencias => incidenciasAbiertas > 0;

  String get ventasTexto =>
      ventasHoy == null ? '—' : 'S/ ${ventasHoy!.toStringAsFixed(0)}';

  String get comisionTexto =>
      comisionPreferente ? '$comision% ★' : '$comision%';

  Negocio copyWith({
    EstadoNegocio? estado,
    int? comision,
    String? horario,
    List<Producto>? productos,
    List<Incidencia>? incidencias,
    int? incidenciasAbiertas,
  }) => Negocio(
    id: id,
    nombre: nombre,
    categoria: categoria,
    direccion: direccion,
    estado: estado ?? this.estado,
    horario: horario ?? this.horario,
    comision: comision ?? this.comision,
    emoji: emoji,
    ventasHoy: ventasHoy,
    pedidosPendientes: pedidosPendientes,
    calificacion: calificacion,
    incidenciasAbiertas: incidenciasAbiertas ?? this.incidenciasAbiertas,
    comisionPreferente: comisionPreferente,
    productos: productos ?? this.productos,
    incidencias: incidencias ?? this.incidencias,
  );

  factory Negocio.fromJson(Map<String, dynamic> json) => Negocio(
    id: json['id'] as String? ?? '',
    nombre: json['nombre'] as String? ?? '',
    categoria: json['categoria'] as String? ?? '',
    direccion: json['direccion'] as String? ?? '',
    estado: EstadoNegocio.fromJson(json['estado']),
    horario: json['horario'] as String? ?? '',
    comision: (json['comision'] as num?)?.toInt() ?? 0,
    emoji: json['emoji'] as String? ?? '🛍️',
    ventasHoy: (json['ventasHoy'] as num?)?.toDouble(),
    pedidosPendientes: (json['pedidosPendientes'] as num?)?.toInt() ?? 0,
    calificacion: (json['calificacion'] as num?)?.toDouble(),
    incidenciasAbiertas: (json['incidenciasAbiertas'] as num?)?.toInt() ?? 0,
    comisionPreferente: json['comisionPreferente'] as bool? ?? false,
    productos: [
      for (final p in (json['productos'] as List<dynamic>? ?? const []))
        Producto.fromJson(Map<String, dynamic>.from(p as Map)),
    ],
    incidencias: [
      for (final i in (json['incidencias'] as List<dynamic>? ?? const []))
        Incidencia.fromJson(Map<String, dynamic>.from(i as Map)),
    ],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'nombre': nombre,
    'categoria': categoria,
    'direccion': direccion,
    'estado': estado.toJson(),
    'horario': horario,
    'comision': comision,
    'emoji': emoji,
    'ventasHoy': ventasHoy,
    'pedidosPendientes': pedidosPendientes,
    'calificacion': calificacion,
    'incidenciasAbiertas': incidenciasAbiertas,
    'comisionPreferente': comisionPreferente,
    'productos': [for (final p in productos) p.toJson()],
    'incidencias': [for (final i in incidencias) i.toJson()],
  };
}
