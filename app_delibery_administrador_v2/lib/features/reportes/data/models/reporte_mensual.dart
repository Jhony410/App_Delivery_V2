/// Punto de una serie de barras (ingresos por semana, ventas por día).
class PuntoSerie {
  const PuntoSerie({
    required this.etiqueta,
    required this.valor,
    this.destacado = false,
  });

  final String etiqueta;
  final double valor;

  /// El diseño pinta en verde sólido el punto máximo o el día en curso.
  final bool destacado;

  factory PuntoSerie.fromJson(Map<String, dynamic> json) => PuntoSerie(
    etiqueta: json['etiqueta'] as String? ?? '',
    valor: (json['valor'] as num?)?.toDouble() ?? 0,
    destacado: json['destacado'] as bool? ?? false,
  );

  Map<String, dynamic> toJson() => {
    'etiqueta': etiqueta,
    'valor': valor,
    'destacado': destacado,
  };
}

/// Porción del reparto de pedidos por categoría.
class ParticipacionCategoria {
  const ParticipacionCategoria({
    required this.categoria,
    required this.porcentaje,
  });

  final String categoria;
  final int porcentaje;

  factory ParticipacionCategoria.fromJson(Map<String, dynamic> json) =>
      ParticipacionCategoria(
        categoria: json['categoria'] as String? ?? '',
        porcentaje: (json['porcentaje'] as num?)?.toInt() ?? 0,
      );

  Map<String, dynamic> toJson() => {
    'categoria': categoria,
    'porcentaje': porcentaje,
  };
}

/// Fila del ranking «Top negocios del mes».
class FilaTopNegocio {
  const FilaTopNegocio({
    required this.posicion,
    required this.negocio,
    required this.pedidos,
    required this.ventas,
    required this.comision,
  });

  final int posicion;
  final String negocio;
  final int pedidos;
  final double ventas;
  final double comision;

  factory FilaTopNegocio.fromJson(Map<String, dynamic> json) => FilaTopNegocio(
    posicion: (json['posicion'] as num?)?.toInt() ?? 0,
    negocio: json['negocio'] as String? ?? '',
    pedidos: (json['pedidos'] as num?)?.toInt() ?? 0,
    ventas: (json['ventas'] as num?)?.toDouble() ?? 0,
    comision: (json['comision'] as num?)?.toDouble() ?? 0,
  );

  Map<String, dynamic> toJson() => {
    'posicion': posicion,
    'negocio': negocio,
    'pedidos': pedidos,
    'ventas': ventas,
    'comision': comision,
  };
}

/// Métrica del encabezado del módulo de reportes.
class MetricaReporte {
  const MetricaReporte({
    required this.titulo,
    required this.valor,
    required this.variacion,
    this.positiva = true,
    this.neutral = false,
  });

  final String titulo;
  final String valor;

  /// «+18% vs. junio».
  final String variacion;

  final bool positiva;

  /// Métricas donde el signo no implica bondad (tiempo medio de entrega).
  final bool neutral;

  factory MetricaReporte.fromJson(Map<String, dynamic> json) => MetricaReporte(
    titulo: json['titulo'] as String? ?? '',
    valor: json['valor'] as String? ?? '',
    variacion: json['variacion'] as String? ?? '',
    positiva: json['positiva'] as bool? ?? true,
    neutral: json['neutral'] as bool? ?? false,
  );

  Map<String, dynamic> toJson() => {
    'titulo': titulo,
    'valor': valor,
    'variacion': variacion,
    'positiva': positiva,
    'neutral': neutral,
  };
}

/// Reporte analítico de un mes.
class ReporteMensual {
  const ReporteMensual({
    required this.periodo,
    required this.metricas,
    required this.ingresosPorSemana,
    required this.categorias,
    required this.topNegocios,
  });

  /// «Julio 2026».
  final String periodo;

  final List<MetricaReporte> metricas;
  final List<PuntoSerie> ingresosPorSemana;
  final List<ParticipacionCategoria> categorias;
  final List<FilaTopNegocio> topNegocios;

  factory ReporteMensual.fromJson(Map<String, dynamic> json) => ReporteMensual(
    periodo: json['periodo'] as String? ?? '',
    metricas: [
      for (final m in (json['metricas'] as List<dynamic>? ?? const []))
        MetricaReporte.fromJson(Map<String, dynamic>.from(m as Map)),
    ],
    ingresosPorSemana: [
      for (final p in (json['ingresosPorSemana'] as List<dynamic>? ?? const []))
        PuntoSerie.fromJson(Map<String, dynamic>.from(p as Map)),
    ],
    categorias: [
      for (final c in (json['categorias'] as List<dynamic>? ?? const []))
        ParticipacionCategoria.fromJson(Map<String, dynamic>.from(c as Map)),
    ],
    topNegocios: [
      for (final t in (json['topNegocios'] as List<dynamic>? ?? const []))
        FilaTopNegocio.fromJson(Map<String, dynamic>.from(t as Map)),
    ],
  );

  Map<String, dynamic> toJson() => {
    'periodo': periodo,
    'metricas': [for (final m in metricas) m.toJson()],
    'ingresosPorSemana': [for (final p in ingresosPorSemana) p.toJson()],
    'categorias': [for (final c in categorias) c.toJson()],
    'topNegocios': [for (final t in topNegocios) t.toJson()],
  };
}
