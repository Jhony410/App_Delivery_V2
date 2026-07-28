import '../../../../core/models/estado_repartidor.dart';

/// Estado de verificación de un documento de CHASQUI.
enum EstadoDocumento {
  aprobado('APROBADO'),
  porVencer('POR VENCER'),
  enRevision('EN REVISIÓN'),
  rechazado('RECHAZADO');

  const EstadoDocumento(this.etiqueta);

  final String etiqueta;

  String toJson() => name;

  static EstadoDocumento fromJson(Object? value) {
    final texto = value?.toString();
    return EstadoDocumento.values.firstWhere(
      (e) => e.name == texto,
      orElse: () => EstadoDocumento.enRevision,
    );
  }
}

/// Uno de los 5 documentos que exige CHASQUI.
class DocumentoRepartidor {
  const DocumentoRepartidor({
    required this.tipo,
    required this.detalle,
    required this.estado,
  });

  final String tipo;

  /// «Subido 12 ene. 2025», «Vence en 21 días», «Esperando revisión».
  final String detalle;

  final EstadoDocumento estado;

  DocumentoRepartidor copyWith({EstadoDocumento? estado, String? detalle}) =>
      DocumentoRepartidor(
        tipo: tipo,
        detalle: detalle ?? this.detalle,
        estado: estado ?? this.estado,
      );

  factory DocumentoRepartidor.fromJson(Map<String, dynamic> json) =>
      DocumentoRepartidor(
        tipo: json['tipo'] as String? ?? '',
        detalle: json['detalle'] as String? ?? '',
        estado: EstadoDocumento.fromJson(json['estado']),
      );

  Map<String, dynamic> toJson() => {
    'tipo': tipo,
    'detalle': detalle,
    'estado': estado.toJson(),
  };
}

/// Comentario que un cliente dejó al repartidor.
class ComentarioCliente {
  const ComentarioCliente({
    required this.estrellas,
    required this.texto,
    required this.autor,
    required this.cuando,
  });

  final int estrellas;
  final String texto;
  final String autor;
  final String cuando;

  factory ComentarioCliente.fromJson(Map<String, dynamic> json) =>
      ComentarioCliente(
        estrellas: (json['estrellas'] as num?)?.toInt() ?? 5,
        texto: json['texto'] as String? ?? '',
        autor: json['autor'] as String? ?? '',
        cuando: json['cuando'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {
    'estrellas': estrellas,
    'texto': texto,
    'autor': autor,
    'cuando': cuando,
  };
}

/// Porcentaje de conexión por zona (mini heatmap del frame 05).
class ZonaConexion {
  const ZonaConexion({required this.zona, required this.porcentaje});

  final String zona;
  final int porcentaje;

  factory ZonaConexion.fromJson(Map<String, dynamic> json) => ZonaConexion(
    zona: json['zona'] as String? ?? '',
    porcentaje: (json['porcentaje'] as num?)?.toInt() ?? 0,
  );

  Map<String, dynamic> toJson() => {'zona': zona, 'porcentaje': porcentaje};
}

/// Cifras de desempeño de la semana.
class DesempenoRepartidor {
  const DesempenoRepartidor({
    required this.gananciaSemana,
    required this.pedidos,
    required this.aceptacion,
    required this.entregaPromedioMin,
  });

  final double gananciaSemana;
  final int pedidos;
  final int aceptacion;
  final int entregaPromedioMin;

  factory DesempenoRepartidor.fromJson(Map<String, dynamic> json) =>
      DesempenoRepartidor(
        gananciaSemana: (json['gananciaSemana'] as num?)?.toDouble() ?? 0,
        pedidos: (json['pedidos'] as num?)?.toInt() ?? 0,
        aceptacion: (json['aceptacion'] as num?)?.toInt() ?? 0,
        entregaPromedioMin: (json['entregaPromedioMin'] as num?)?.toInt() ?? 0,
      );

  Map<String, dynamic> toJson() => {
    'gananciaSemana': gananciaSemana,
    'pedidos': pedidos,
    'aceptacion': aceptacion,
    'entregaPromedioMin': entregaPromedioMin,
  };
}

/// Repartidor de CHASQUI.
class Repartidor {
  const Repartidor({
    required this.id,
    required this.nombre,
    required this.estado,
    required this.calificacion,
    this.vehiculo,
    this.placa,
    this.zonaActual,
    this.pedidosActivos = 0,
    this.gananciaHoy,
    this.tiempoConectado,
    this.dni,
    this.celular,
    this.desde,
    this.entregasTotales = 0,
    this.nivel,
    this.notaEstado,
    this.documentos = const [],
    this.desempeno,
    this.comentarios = const [],
    this.zonas = const [],
    this.suspendido = false,
    this.bloqueado = false,
  });

  final String id;
  final String nombre;
  final EstadoRepartidor estado;
  final double calificacion;

  final String? vehiculo;
  final String? placa;

  /// `null` cuando está desconectado y el diseño pinta «—».
  final String? zonaActual;

  final int pedidosActivos;
  final double? gananciaHoy;
  final String? tiempoConectado;

  final String? dni;
  final String? celular;
  final String? desde;
  final int entregasTotales;

  /// «Chasqui Oro», el nivel de fidelidad que muestra la ficha.
  final String? nivel;

  /// Aviso bajo el nombre en el listado («SOAT por vencer»).
  final String? notaEstado;

  final List<DocumentoRepartidor> documentos;
  final DesempenoRepartidor? desempeno;
  final List<ComentarioCliente> comentarios;
  final List<ZonaConexion> zonas;

  final bool suspendido;
  final bool bloqueado;

  /// «Moto ABC-123» o solo el vehículo si no hay placa.
  String get vehiculoTexto {
    if (vehiculo == null) return '—';
    if (placa == null) return vehiculo!;
    return '$vehiculo · $placa';
  }

  int get documentosAprobados =>
      documentos.where((d) => d.estado == EstadoDocumento.aprobado).length;

  bool get tieneDocumentosPendientes =>
      documentos.any((d) => d.estado == EstadoDocumento.enRevision);

  Repartidor copyWith({
    EstadoRepartidor? estado,
    int? pedidosActivos,
    List<DocumentoRepartidor>? documentos,
    bool? suspendido,
    bool? bloqueado,
  }) => Repartidor(
    id: id,
    nombre: nombre,
    estado: estado ?? this.estado,
    calificacion: calificacion,
    vehiculo: vehiculo,
    placa: placa,
    zonaActual: zonaActual,
    pedidosActivos: pedidosActivos ?? this.pedidosActivos,
    gananciaHoy: gananciaHoy,
    tiempoConectado: tiempoConectado,
    dni: dni,
    celular: celular,
    desde: desde,
    entregasTotales: entregasTotales,
    nivel: nivel,
    notaEstado: notaEstado,
    documentos: documentos ?? this.documentos,
    desempeno: desempeno,
    comentarios: comentarios,
    zonas: zonas,
    suspendido: suspendido ?? this.suspendido,
    bloqueado: bloqueado ?? this.bloqueado,
  );

  factory Repartidor.fromJson(Map<String, dynamic> json) => Repartidor(
    id: json['id'] as String? ?? '',
    nombre: json['nombre'] as String? ?? '',
    estado: EstadoRepartidor.fromJson(json['estado']),
    calificacion: (json['calificacion'] as num?)?.toDouble() ?? 0,
    vehiculo: json['vehiculo'] as String?,
    placa: json['placa'] as String?,
    zonaActual: json['zonaActual'] as String?,
    pedidosActivos: (json['pedidosActivos'] as num?)?.toInt() ?? 0,
    gananciaHoy: (json['gananciaHoy'] as num?)?.toDouble(),
    tiempoConectado: json['tiempoConectado'] as String?,
    dni: json['dni'] as String?,
    celular: json['celular'] as String?,
    desde: json['desde'] as String?,
    entregasTotales: (json['entregasTotales'] as num?)?.toInt() ?? 0,
    nivel: json['nivel'] as String?,
    notaEstado: json['notaEstado'] as String?,
    documentos: [
      for (final doc in (json['documentos'] as List<dynamic>? ?? const []))
        DocumentoRepartidor.fromJson(Map<String, dynamic>.from(doc as Map)),
    ],
    desempeno: json['desempeno'] == null
        ? null
        : DesempenoRepartidor.fromJson(
            Map<String, dynamic>.from(json['desempeno'] as Map),
          ),
    comentarios: [
      for (final c in (json['comentarios'] as List<dynamic>? ?? const []))
        ComentarioCliente.fromJson(Map<String, dynamic>.from(c as Map)),
    ],
    zonas: [
      for (final z in (json['zonas'] as List<dynamic>? ?? const []))
        ZonaConexion.fromJson(Map<String, dynamic>.from(z as Map)),
    ],
    suspendido: json['suspendido'] as bool? ?? false,
    bloqueado: json['bloqueado'] as bool? ?? false,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'nombre': nombre,
    'estado': estado.toJson(),
    'calificacion': calificacion,
    'vehiculo': vehiculo,
    'placa': placa,
    'zonaActual': zonaActual,
    'pedidosActivos': pedidosActivos,
    'gananciaHoy': gananciaHoy,
    'tiempoConectado': tiempoConectado,
    'dni': dni,
    'celular': celular,
    'desde': desde,
    'entregasTotales': entregasTotales,
    'nivel': nivel,
    'notaEstado': notaEstado,
    'documentos': [for (final doc in documentos) doc.toJson()],
    'desempeno': desempeno?.toJson(),
    'comentarios': [for (final c in comentarios) c.toJson()],
    'zonas': [for (final z in zonas) z.toJson()],
    'suspendido': suspendido,
    'bloqueado': bloqueado,
  };
}

/// Filtros de la barra de chips del frame 04.
enum FiltroRepartidor {
  todos('Todos'),
  conectado('Conectado'),
  enCamino('En camino'),
  desconectado('Desconectado'),
  docsPendientes('Docs pendientes');

  const FiltroRepartidor(this.etiqueta);

  final String etiqueta;

  bool aceptar(Repartidor repartidor) => switch (this) {
    FiltroRepartidor.todos => true,
    FiltroRepartidor.conectado =>
      repartidor.estado == EstadoRepartidor.conectado ||
          repartidor.estado == EstadoRepartidor.buscando,
    FiltroRepartidor.enCamino =>
      repartidor.estado == EstadoRepartidor.enCamino ||
          repartidor.estado == EstadoRepartidor.multiPedido,
    FiltroRepartidor.desconectado =>
      repartidor.estado == EstadoRepartidor.desconectado,
    FiltroRepartidor.docsPendientes =>
      repartidor.estado == EstadoRepartidor.docsPendientes,
  };
}
