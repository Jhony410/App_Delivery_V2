import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Estados por los que pasa un pedido en el panel del comerciante.
///
/// Son los cinco del canvas (frame 05 y la librería de componentes del frame
/// 14) y coinciden con los de las apps de usuario y de repartidor.
enum OrderStatus {
  /// Recién llegado: dispara la alerta emergente y espera Aceptar/Rechazar.
  nuevo,

  /// Aceptado por el local, cocinándose. Acción: "Marcar como listo".
  preparando,

  /// Listo en mostrador, buscando chasqui. Sin acción del comerciante.
  esperandoRepartidor,

  /// El repartidor lo recogió. Sin acción del comerciante.
  enCamino,

  /// Cerrado. Solo histórico.
  entregado,
}

extension OrderStatusView on OrderStatus {
  /// Texto de la píldora, tal como está escrito en el canvas.
  String get label => switch (this) {
    OrderStatus.nuevo => '● NUEVO PEDIDO',
    OrderStatus.preparando => 'PREPARANDO',
    OrderStatus.esperandoRepartidor => 'ESPERANDO REPARTIDOR',
    OrderStatus.enCamino => 'REPARTIDOR EN CAMINO',
    OrderStatus.entregado => 'ENTREGADO',
  };

  Color get color => switch (this) {
    OrderStatus.nuevo => AppColors.primary,
    OrderStatus.preparando => AppColors.warning,
    OrderStatus.esperandoRepartidor => AppColors.textSecondary,
    OrderStatus.enCamino => AppColors.transit,
    OrderStatus.entregado => AppColors.success,
  };

  Color get softColor => switch (this) {
    OrderStatus.nuevo => AppColors.primarySoft,
    OrderStatus.preparando => AppColors.warningSoft,
    OrderStatus.esperandoRepartidor => AppColors.fillStrong,
    OrderStatus.enCamino => AppColors.transitSoft,
    OrderStatus.entregado => AppColors.successSoft,
  };
}

/// Un pedido tal como lo ve el local.
@immutable
class Order {
  const Order({
    required this.code,
    required this.customer,
    required this.address,
    required this.total,
    required this.items,
    required this.status,
    this.statusNote,
    this.emoji = '🍗',
    this.receivedAt,
  });

  /// Código visible: `#A-2485`.
  final String code;
  final String customer;
  final String address;
  final double total;

  /// Líneas del pedido: "1× Pollo entero", "2× Chicha morada"…
  final List<String> items;
  final OrderStatus status;

  /// Texto auxiliar bajo el nombre ("Listo · buscando chasqui").
  final String? statusNote;
  final String emoji;
  final DateTime? receivedAt;

  /// Resumen corto para la tarjeta: "3 productos".
  String get itemsSummary => items.length == 1
      ? items.single
      : '${items.first} · ${items.length - 1} más';

  int get itemCount => items.length;

  Order copyWith({OrderStatus? status, String? statusNote}) => Order(
    code: code,
    customer: customer,
    address: address,
    total: total,
    items: items,
    status: status ?? this.status,
    statusNote: statusNote ?? this.statusNote,
    emoji: emoji,
    receivedAt: receivedAt,
  );
}

/// Un producto del catálogo del local (frame 07).
@immutable
class Product {
  const Product({
    required this.id,
    required this.name,
    required this.price,
    required this.available,
    this.emoji = '🍽️',
    this.thumb = ProductThumb.warm,
  });

  final String id;
  final String name;
  final double price;

  /// `true` → "Disponible"; `false` → "Agotado" (tarjeta atenuada).
  final bool available;
  final String emoji;
  final ProductThumb thumb;

  Product copyWith({bool? available}) => Product(
    id: id,
    name: name,
    price: price,
    available: available ?? this.available,
    emoji: emoji,
    thumb: thumb,
  );
}

/// Degradado de la miniatura del producto en el canvas.
enum ProductThumb { warm, orange }

/// Datos del local: se llenan en Verificación del negocio y se muestran en
/// Inicio y Perfil.
@immutable
class BusinessProfile {
  const BusinessProfile({
    required this.name,
    required this.category,
    required this.address,
    required this.taxId,
    required this.schedule,
    required this.whatsapp,
  });

  final String name;
  final String category;
  final String address;

  /// RUC o DNI.
  final String taxId;

  /// "10:00 – 22:00".
  final String schedule;
  final String whatsapp;

  BusinessProfile copyWith({
    String? name,
    String? category,
    String? address,
    String? taxId,
    String? schedule,
    String? whatsapp,
  }) => BusinessProfile(
    name: name ?? this.name,
    category: category ?? this.category,
    address: address ?? this.address,
    taxId: taxId ?? this.taxId,
    schedule: schedule ?? this.schedule,
    whatsapp: whatsapp ?? this.whatsapp,
  );
}

/// Rango del filtro de Reportes (frame 08).
enum ReportRange {
  hoy('Hoy'),
  semana('Semana'),
  mes('Mes');

  const ReportRange(this.label);
  final String label;
}

/// Cifras que pinta la pantalla de Reportes para un [ReportRange].
@immutable
class ReportSummary {
  const ReportSummary({
    required this.sales,
    required this.orderCount,
    required this.profit,
    required this.topProduct,
    required this.topProductUnits,
    required this.topProductEmoji,
  });

  final double sales;
  final int orderCount;
  final double profit;
  final String topProduct;
  final int topProductUnits;
  final String topProductEmoji;
}
