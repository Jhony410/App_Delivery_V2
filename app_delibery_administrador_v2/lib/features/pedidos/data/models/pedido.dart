import '../../../../core/models/estado_pedido.dart';

/// Una línea del detalle de un pedido.
class ItemPedido {
  const ItemPedido({
    required this.cantidad,
    required this.nombre,
    required this.precio,
  });

  final int cantidad;
  final String nombre;
  final double precio;

  factory ItemPedido.fromJson(Map<String, dynamic> json) => ItemPedido(
    cantidad: (json['cantidad'] as num?)?.toInt() ?? 1,
    nombre: json['nombre'] as String? ?? '',
    precio: (json['precio'] as num?)?.toDouble() ?? 0,
  );

  Map<String, dynamic> toJson() => {
    'cantidad': cantidad,
    'nombre': nombre,
    'precio': precio,
  };
}

/// Un hito del historial del pedido («Repartidor asignado · 14:21 · sistema»).
class EventoPedido {
  const EventoPedido({
    required this.titulo,
    required this.hora,
    required this.origen,
    this.enCurso = false,
  });

  final String titulo;
  final String hora;

  /// Quién lo provocó: «automático», «sistema», «Julia Torres»…
  final String origen;

  /// El último hito se pinta como «en curso».
  final bool enCurso;

  factory EventoPedido.fromJson(Map<String, dynamic> json) => EventoPedido(
    titulo: json['titulo'] as String? ?? '',
    hora: json['hora'] as String? ?? '',
    origen: json['origen'] as String? ?? '',
    enCurso: json['enCurso'] as bool? ?? false,
  );

  Map<String, dynamic> toJson() => {
    'titulo': titulo,
    'hora': hora,
    'origen': origen,
    'enCurso': enCurso,
  };
}

/// Pedido de DelyPuno visto desde la torre de control.
class Pedido {
  const Pedido({
    required this.id,
    required this.negocio,
    required this.negocioDireccion,
    required this.cliente,
    required this.clienteDireccion,
    required this.estado,
    required this.hora,
    this.repartidorId,
    this.repartidor,
    this.repartidorCalificacion,
    this.repartidorDistanciaKm,
    this.monto,
    this.items = const [],
    this.historial = const [],
    this.tiempoMinutos,
    this.distanciaKm,
    this.etaMinutos,
    this.zona,
    this.emojiNegocio = '🛍️',
    this.notaProblema,
  });

  final String id;
  final String negocio;
  final String negocioDireccion;
  final String cliente;
  final String clienteDireccion;
  final EstadoPedido estado;

  /// Hora de creación, formateada como en el diseño («14:18»).
  final String hora;

  final String? repartidorId;
  final String? repartidor;
  final double? repartidorCalificacion;
  final double? repartidorDistanciaKm;

  /// `null` cuando el pedido se canceló y el diseño muestra «—».
  final double? monto;

  final List<ItemPedido> items;
  final List<EventoPedido> historial;

  final int? tiempoMinutos;
  final double? distanciaKm;
  final int? etaMinutos;
  final String? zona;
  final String emojiNegocio;

  /// Descripción de la incidencia cuando el estado es `problema`.
  final String? notaProblema;

  bool get tieneRepartidor => repartidor != null && repartidor!.isNotEmpty;

  /// Texto del monto tal como lo pinta el diseño.
  String get montoTexto =>
      monto == null ? '—' : 'S/ ${monto!.toStringAsFixed(0)}';

  Pedido copyWith({
    String? repartidorId,
    String? repartidor,
    double? repartidorCalificacion,
    double? repartidorDistanciaKm,
    EstadoPedido? estado,
    List<EventoPedido>? historial,
  }) => Pedido(
    id: id,
    negocio: negocio,
    negocioDireccion: negocioDireccion,
    cliente: cliente,
    clienteDireccion: clienteDireccion,
    estado: estado ?? this.estado,
    hora: hora,
    repartidorId: repartidorId ?? this.repartidorId,
    repartidor: repartidor ?? this.repartidor,
    repartidorCalificacion:
        repartidorCalificacion ?? this.repartidorCalificacion,
    repartidorDistanciaKm: repartidorDistanciaKm ?? this.repartidorDistanciaKm,
    monto: monto,
    items: items,
    historial: historial ?? this.historial,
    tiempoMinutos: tiempoMinutos,
    distanciaKm: distanciaKm,
    etaMinutos: etaMinutos,
    zona: zona,
    emojiNegocio: emojiNegocio,
    notaProblema: notaProblema,
  );

  factory Pedido.fromJson(Map<String, dynamic> json) => Pedido(
    id: json['id'] as String? ?? '',
    negocio: json['negocio'] as String? ?? '',
    negocioDireccion: json['negocioDireccion'] as String? ?? '',
    cliente: json['cliente'] as String? ?? '',
    clienteDireccion: json['clienteDireccion'] as String? ?? '',
    estado: EstadoPedido.fromJson(json['estado']),
    hora: json['hora'] as String? ?? '',
    repartidorId: json['repartidorId'] as String?,
    repartidor: json['repartidor'] as String?,
    repartidorCalificacion: (json['repartidorCalificacion'] as num?)
        ?.toDouble(),
    repartidorDistanciaKm: (json['repartidorDistanciaKm'] as num?)?.toDouble(),
    monto: (json['monto'] as num?)?.toDouble(),
    items: [
      for (final item in (json['items'] as List<dynamic>? ?? const []))
        ItemPedido.fromJson(Map<String, dynamic>.from(item as Map)),
    ],
    historial: [
      for (final evento in (json['historial'] as List<dynamic>? ?? const []))
        EventoPedido.fromJson(Map<String, dynamic>.from(evento as Map)),
    ],
    tiempoMinutos: (json['tiempoMinutos'] as num?)?.toInt(),
    distanciaKm: (json['distanciaKm'] as num?)?.toDouble(),
    etaMinutos: (json['etaMinutos'] as num?)?.toInt(),
    zona: json['zona'] as String?,
    emojiNegocio: json['emojiNegocio'] as String? ?? '🛍️',
    notaProblema: json['notaProblema'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'negocio': negocio,
    'negocioDireccion': negocioDireccion,
    'cliente': cliente,
    'clienteDireccion': clienteDireccion,
    'estado': estado.toJson(),
    'hora': hora,
    'repartidorId': repartidorId,
    'repartidor': repartidor,
    'repartidorCalificacion': repartidorCalificacion,
    'repartidorDistanciaKm': repartidorDistanciaKm,
    'monto': monto,
    'items': [for (final item in items) item.toJson()],
    'historial': [for (final evento in historial) evento.toJson()],
    'tiempoMinutos': tiempoMinutos,
    'distanciaKm': distanciaKm,
    'etaMinutos': etaMinutos,
    'zona': zona,
    'emojiNegocio': emojiNegocio,
    'notaProblema': notaProblema,
  };
}

/// Filtros de la barra de chips del frame 02.
enum FiltroPedido {
  todos('Todos'),
  buscandoRepartidor('Buscando repartidor'),
  preparando('Preparando'),
  enCamino('En camino'),
  entregado('Entregado'),
  problema('Problema');

  const FiltroPedido(this.etiqueta);

  final String etiqueta;

  bool aceptar(Pedido pedido) => switch (this) {
    FiltroPedido.todos => true,
    FiltroPedido.buscandoRepartidor =>
      pedido.estado == EstadoPedido.buscandoRepartidor,
    FiltroPedido.preparando => pedido.estado == EstadoPedido.preparando,
    FiltroPedido.enCamino => pedido.estado == EstadoPedido.enCamino,
    FiltroPedido.entregado => pedido.estado == EstadoPedido.entregado,
    FiltroPedido.problema => pedido.estado == EstadoPedido.problema,
  };
}
