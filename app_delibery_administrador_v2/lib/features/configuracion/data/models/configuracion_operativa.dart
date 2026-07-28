/// Rol de un miembro del equipo de operaciones.
enum RolEquipo {
  adminTotal('ADMIN TOTAL', 'Todo el panel · pagos · roles'),
  operaciones('OPERACIONES', 'Pedidos · mapa · repartidores'),
  soporte('SOPORTE', 'Negocios · clientes · chat');

  const RolEquipo(this.etiqueta, this.permisos);

  final String etiqueta;
  final String permisos;

  String toJson() => name;

  static RolEquipo fromJson(Object? value) {
    final texto = value?.toString();
    return RolEquipo.values.firstWhere(
      (r) => r.name == texto,
      orElse: () => RolEquipo.soporte,
    );
  }
}

/// Miembro del equipo con acceso al panel.
class MiembroEquipo {
  const MiembroEquipo({
    required this.id,
    required this.nombre,
    required this.correo,
    required this.rol,
  });

  final String id;
  final String nombre;
  final String correo;
  final RolEquipo rol;

  MiembroEquipo copyWith({RolEquipo? rol}) => MiembroEquipo(
    id: id,
    nombre: nombre,
    correo: correo,
    rol: rol ?? this.rol,
  );

  factory MiembroEquipo.fromJson(Map<String, dynamic> json) => MiembroEquipo(
    id: json['id'] as String? ?? '',
    nombre: json['nombre'] as String? ?? '',
    correo: json['correo'] as String? ?? '',
    rol: RolEquipo.fromJson(json['rol']),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'nombre': nombre,
    'correo': correo,
    'rol': rol.toJson(),
  };
}

/// Una tarifa o comisión editable del frame 13.
class ParametroTarifa {
  const ParametroTarifa({
    required this.clave,
    required this.titulo,
    required this.descripcion,
    required this.valor,
    required this.unidad,
  });

  final String clave;
  final String titulo;
  final String descripcion;
  final double valor;

  /// «S/» para importes, «%» para comisiones.
  final String unidad;

  /// «S/ 5.00», «+ S/ 1.50», «18%».
  String get valorTexto => unidad == '%'
      ? '${valor.toStringAsFixed(0)}%'
      : 'S/ ${valor.toStringAsFixed(2)}';

  ParametroTarifa copyWith({double? valor}) => ParametroTarifa(
    clave: clave,
    titulo: titulo,
    descripcion: descripcion,
    valor: valor ?? this.valor,
    unidad: unidad,
  );

  factory ParametroTarifa.fromJson(Map<String, dynamic> json) =>
      ParametroTarifa(
        clave: json['clave'] as String? ?? '',
        titulo: json['titulo'] as String? ?? '',
        descripcion: json['descripcion'] as String? ?? '',
        valor: (json['valor'] as num?)?.toDouble() ?? 0,
        unidad: json['unidad'] as String? ?? 'S/',
      );

  Map<String, dynamic> toJson() => {
    'clave': clave,
    'titulo': titulo,
    'descripcion': descripcion,
    'valor': valor,
    'unidad': unidad,
  };
}

/// Interruptor de operación general.
class AjusteOperativo {
  const AjusteOperativo({
    required this.clave,
    required this.titulo,
    required this.descripcion,
    required this.activo,
  });

  final String clave;
  final String titulo;
  final String descripcion;
  final bool activo;

  AjusteOperativo copyWith({bool? activo}) => AjusteOperativo(
    clave: clave,
    titulo: titulo,
    descripcion: descripcion,
    activo: activo ?? this.activo,
  );

  factory AjusteOperativo.fromJson(Map<String, dynamic> json) =>
      AjusteOperativo(
        clave: json['clave'] as String? ?? '',
        titulo: json['titulo'] as String? ?? '',
        descripcion: json['descripcion'] as String? ?? '',
        activo: json['activo'] as bool? ?? false,
      );

  Map<String, dynamic> toJson() => {
    'clave': clave,
    'titulo': titulo,
    'descripcion': descripcion,
    'activo': activo,
  };
}

/// Configuración completa del panel: costos de envío, comisiones, equipo y
/// operación general.
class ConfiguracionOperativa {
  const ConfiguracionOperativa({
    required this.costosEnvio,
    required this.comisiones,
    required this.equipo,
    required this.ajustes,
  });

  final List<ParametroTarifa> costosEnvio;
  final List<ParametroTarifa> comisiones;
  final List<MiembroEquipo> equipo;
  final List<AjusteOperativo> ajustes;

  ConfiguracionOperativa copyWith({
    List<ParametroTarifa>? costosEnvio,
    List<ParametroTarifa>? comisiones,
    List<MiembroEquipo>? equipo,
    List<AjusteOperativo>? ajustes,
  }) => ConfiguracionOperativa(
    costosEnvio: costosEnvio ?? this.costosEnvio,
    comisiones: comisiones ?? this.comisiones,
    equipo: equipo ?? this.equipo,
    ajustes: ajustes ?? this.ajustes,
  );

  factory ConfiguracionOperativa.fromJson(Map<String, dynamic> json) =>
      ConfiguracionOperativa(
        costosEnvio: [
          for (final p in (json['costosEnvio'] as List<dynamic>? ?? const []))
            ParametroTarifa.fromJson(Map<String, dynamic>.from(p as Map)),
        ],
        comisiones: [
          for (final p in (json['comisiones'] as List<dynamic>? ?? const []))
            ParametroTarifa.fromJson(Map<String, dynamic>.from(p as Map)),
        ],
        equipo: [
          for (final m in (json['equipo'] as List<dynamic>? ?? const []))
            MiembroEquipo.fromJson(Map<String, dynamic>.from(m as Map)),
        ],
        ajustes: [
          for (final a in (json['ajustes'] as List<dynamic>? ?? const []))
            AjusteOperativo.fromJson(Map<String, dynamic>.from(a as Map)),
        ],
      );

  Map<String, dynamic> toJson() => {
    'costosEnvio': [for (final p in costosEnvio) p.toJson()],
    'comisiones': [for (final p in comisiones) p.toJson()],
    'equipo': [for (final m in equipo) m.toJson()],
    'ajustes': [for (final a in ajustes) a.toJson()],
  };
}
