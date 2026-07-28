import '../../../reportes/data/models/reporte_mensual.dart';

/// Cifras y series que alimentan el frame 01.
class ResumenOperativo {
  const ResumenOperativo({
    required this.pedidosActivos,
    required this.pedidosPreparando,
    required this.pedidosEnCamino,
    required this.ventasDia,
    required this.variacionVentas,
    required this.ventasMes,
    required this.repartidoresActivos,
    required this.repartidoresTotales,
    required this.repartidoresConPedido,
    required this.repartidoresBuscando,
    required this.negociosAbiertos,
    required this.negociosTotales,
    required this.clientesConectados,
    required this.documentosPorVerificar,
    required this.negociosConIncidencias,
    required this.ventasSemana,
    required this.ventasSemanaAcumulado,
    required this.pedidosPorHora,
    required this.horaPico,
  });

  final int pedidosActivos;
  final int pedidosPreparando;
  final int pedidosEnCamino;

  final double ventasDia;

  /// «+12% vs. ayer».
  final String variacionVentas;

  final double ventasMes;

  final int repartidoresActivos;
  final int repartidoresTotales;
  final int repartidoresConPedido;
  final int repartidoresBuscando;

  final int negociosAbiertos;
  final int negociosTotales;
  final int clientesConectados;

  /// Alimenta la tarjeta de acción ámbar y el contador de la sidebar.
  final int documentosPorVerificar;

  /// Alimenta la tarjeta de acción roja.
  final int negociosConIncidencias;

  final List<PuntoSerie> ventasSemana;
  final double ventasSemanaAcumulado;

  /// Serie de pedidos por hora entre las 8 h y las 23 h.
  final List<PuntoSerie> pedidosPorHora;

  /// «13:00 – 14:00».
  final String horaPico;

  factory ResumenOperativo.fromJson(
    Map<String, dynamic> json,
  ) => ResumenOperativo(
    pedidosActivos: (json['pedidosActivos'] as num?)?.toInt() ?? 0,
    pedidosPreparando: (json['pedidosPreparando'] as num?)?.toInt() ?? 0,
    pedidosEnCamino: (json['pedidosEnCamino'] as num?)?.toInt() ?? 0,
    ventasDia: (json['ventasDia'] as num?)?.toDouble() ?? 0,
    variacionVentas: json['variacionVentas'] as String? ?? '',
    ventasMes: (json['ventasMes'] as num?)?.toDouble() ?? 0,
    repartidoresActivos: (json['repartidoresActivos'] as num?)?.toInt() ?? 0,
    repartidoresTotales: (json['repartidoresTotales'] as num?)?.toInt() ?? 0,
    repartidoresConPedido:
        (json['repartidoresConPedido'] as num?)?.toInt() ?? 0,
    repartidoresBuscando: (json['repartidoresBuscando'] as num?)?.toInt() ?? 0,
    negociosAbiertos: (json['negociosAbiertos'] as num?)?.toInt() ?? 0,
    negociosTotales: (json['negociosTotales'] as num?)?.toInt() ?? 0,
    clientesConectados: (json['clientesConectados'] as num?)?.toInt() ?? 0,
    documentosPorVerificar:
        (json['documentosPorVerificar'] as num?)?.toInt() ?? 0,
    negociosConIncidencias:
        (json['negociosConIncidencias'] as num?)?.toInt() ?? 0,
    ventasSemana: [
      for (final p in (json['ventasSemana'] as List<dynamic>? ?? const []))
        PuntoSerie.fromJson(Map<String, dynamic>.from(p as Map)),
    ],
    ventasSemanaAcumulado:
        (json['ventasSemanaAcumulado'] as num?)?.toDouble() ?? 0,
    pedidosPorHora: [
      for (final p in (json['pedidosPorHora'] as List<dynamic>? ?? const []))
        PuntoSerie.fromJson(Map<String, dynamic>.from(p as Map)),
    ],
    horaPico: json['horaPico'] as String? ?? '',
  );

  Map<String, dynamic> toJson() => {
    'pedidosActivos': pedidosActivos,
    'pedidosPreparando': pedidosPreparando,
    'pedidosEnCamino': pedidosEnCamino,
    'ventasDia': ventasDia,
    'variacionVentas': variacionVentas,
    'ventasMes': ventasMes,
    'repartidoresActivos': repartidoresActivos,
    'repartidoresTotales': repartidoresTotales,
    'repartidoresConPedido': repartidoresConPedido,
    'repartidoresBuscando': repartidoresBuscando,
    'negociosAbiertos': negociosAbiertos,
    'negociosTotales': negociosTotales,
    'clientesConectados': clientesConectados,
    'documentosPorVerificar': documentosPorVerificar,
    'negociosConIncidencias': negociosConIncidencias,
    'ventasSemana': [for (final p in ventasSemana) p.toJson()],
    'ventasSemanaAcumulado': ventasSemanaAcumulado,
    'pedidosPorHora': [for (final p in pedidosPorHora) p.toJson()],
    'horaPico': horaPico,
  };
}
