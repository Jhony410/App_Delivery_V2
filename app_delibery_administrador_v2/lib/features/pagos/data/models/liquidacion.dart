/// Estado de pago de una liquidación.
enum EstadoLiquidacion {
  pagado('PAGADO'),
  pendiente('PENDIENTE'),
  observado('OBSERVADO');

  const EstadoLiquidacion(this.etiqueta);

  final String etiqueta;

  String toJson() => name;

  static EstadoLiquidacion fromJson(Object? value) {
    final texto = value?.toString();
    return EstadoLiquidacion.values.firstWhere(
      (e) => e.name == texto,
      orElse: () => EstadoLiquidacion.pendiente,
    );
  }
}

/// Beneficiario de una liquidación: los tres tabs del frame 12.
enum TipoBeneficiario {
  negocios('Negocios'),
  repartidores('Repartidores'),
  historico('Histórico');

  const TipoBeneficiario(this.etiqueta);

  final String etiqueta;
}

/// Fila de la tabla de liquidaciones.
class Liquidacion {
  const Liquidacion({
    required this.id,
    required this.beneficiario,
    required this.tipo,
    required this.pedidos,
    required this.bruto,
    required this.comision,
    required this.estado,
    this.periodo,
  });

  final String id;
  final String beneficiario;
  final TipoBeneficiario tipo;
  final int pedidos;
  final double bruto;

  /// Descuento aplicado. Se muestra en negativo, como en el diseño.
  final double comision;

  final EstadoLiquidacion estado;

  /// «Semana 27 jul», solo en el histórico.
  final String? periodo;

  double get neto => bruto - comision;

  String get brutoTexto => 'S/ ${_miles(bruto)}';
  String get comisionTexto => '−S/ ${_miles(comision)}';
  String get netoTexto => 'S/ ${_miles(neto)}';

  static String _miles(double valor) {
    final entero = valor.round().toString();
    final buffer = StringBuffer();
    for (var i = 0; i < entero.length; i++) {
      if (i > 0 && (entero.length - i) % 3 == 0) buffer.write(',');
      buffer.write(entero[i]);
    }
    return buffer.toString();
  }

  Liquidacion copyWith({EstadoLiquidacion? estado}) => Liquidacion(
    id: id,
    beneficiario: beneficiario,
    tipo: tipo,
    pedidos: pedidos,
    bruto: bruto,
    comision: comision,
    estado: estado ?? this.estado,
    periodo: periodo,
  );

  factory Liquidacion.fromJson(Map<String, dynamic> json) => Liquidacion(
    id: json['id'] as String? ?? '',
    beneficiario: json['beneficiario'] as String? ?? '',
    tipo: TipoBeneficiario.values.firstWhere(
      (t) => t.name == json['tipo'],
      orElse: () => TipoBeneficiario.negocios,
    ),
    pedidos: (json['pedidos'] as num?)?.toInt() ?? 0,
    bruto: (json['bruto'] as num?)?.toDouble() ?? 0,
    comision: (json['comision'] as num?)?.toDouble() ?? 0,
    estado: EstadoLiquidacion.fromJson(json['estado']),
    periodo: json['periodo'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'beneficiario': beneficiario,
    'tipo': tipo.name,
    'pedidos': pedidos,
    'bruto': bruto,
    'comision': comision,
    'estado': estado.toJson(),
    'periodo': periodo,
  };
}

/// Totales de la semana que encabezan el frame 12.
class ResumenPagos {
  const ResumenPagos({
    required this.porPagarNegocios,
    required this.porPagarRepartidores,
    required this.comisionDelyPuno,
    required this.pagosPendientes,
    required this.semana,
  });

  final double porPagarNegocios;
  final double porPagarRepartidores;
  final double comisionDelyPuno;
  final int pagosPendientes;

  /// «Semana 27 jul».
  final String semana;

  factory ResumenPagos.fromJson(Map<String, dynamic> json) => ResumenPagos(
    porPagarNegocios: (json['porPagarNegocios'] as num?)?.toDouble() ?? 0,
    porPagarRepartidores:
        (json['porPagarRepartidores'] as num?)?.toDouble() ?? 0,
    comisionDelyPuno: (json['comisionDelyPuno'] as num?)?.toDouble() ?? 0,
    pagosPendientes: (json['pagosPendientes'] as num?)?.toInt() ?? 0,
    semana: json['semana'] as String? ?? '',
  );

  Map<String, dynamic> toJson() => {
    'porPagarNegocios': porPagarNegocios,
    'porPagarRepartidores': porPagarRepartidores,
    'comisionDelyPuno': comisionDelyPuno,
    'pagosPendientes': pagosPendientes,
    'semana': semana,
  };
}
