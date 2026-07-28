import '../../../../core/models/estado_negocio.dart';

/// Cliente registrado en la app de usuario.
class Cliente {
  const Cliente({
    required this.id,
    required this.nombre,
    required this.celular,
    required this.pedidos,
    required this.gastoTotal,
    required this.ultimoPedido,
    required this.estado,
    this.direccion,
    this.ticketPromedio,
    this.registradoEn,
  });

  final String id;
  final String nombre;
  final String celular;
  final int pedidos;
  final double gastoTotal;

  /// «Hoy 14:18», «12 jul.».
  final String ultimoPedido;

  final EstadoCliente estado;
  final String? direccion;
  final double? ticketPromedio;
  final String? registradoEn;

  String get gastoTexto => 'S/ ${gastoTotal.toStringAsFixed(0)}';

  Cliente copyWith({EstadoCliente? estado}) => Cliente(
    id: id,
    nombre: nombre,
    celular: celular,
    pedidos: pedidos,
    gastoTotal: gastoTotal,
    ultimoPedido: ultimoPedido,
    estado: estado ?? this.estado,
    direccion: direccion,
    ticketPromedio: ticketPromedio,
    registradoEn: registradoEn,
  );

  factory Cliente.fromJson(Map<String, dynamic> json) => Cliente(
    id: json['id'] as String? ?? '',
    nombre: json['nombre'] as String? ?? '',
    celular: json['celular'] as String? ?? '',
    pedidos: (json['pedidos'] as num?)?.toInt() ?? 0,
    gastoTotal: (json['gastoTotal'] as num?)?.toDouble() ?? 0,
    ultimoPedido: json['ultimoPedido'] as String? ?? '',
    estado: EstadoCliente.fromJson(json['estado']),
    direccion: json['direccion'] as String?,
    ticketPromedio: (json['ticketPromedio'] as num?)?.toDouble(),
    registradoEn: json['registradoEn'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'nombre': nombre,
    'celular': celular,
    'pedidos': pedidos,
    'gastoTotal': gastoTotal,
    'ultimoPedido': ultimoPedido,
    'estado': estado.toJson(),
    'direccion': direccion,
    'ticketPromedio': ticketPromedio,
    'registradoEn': registradoEn,
  };
}
