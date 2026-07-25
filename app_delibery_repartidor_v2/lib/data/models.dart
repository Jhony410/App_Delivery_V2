import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Los 11 estados de pedido del frame 27 del diseño.
enum OrderStatus {
  buscando('BUSCANDO', AppColors.textSecondary, AppColors.fillStrong),
  aceptado('ACEPTADO', AppColors.primary, AppColors.primarySoft),
  enElRestaurante('EN EL RESTAURANTE', AppColors.primary, AppColors.primarySoft),
  esperando('ESPERANDO', AppColors.warning, AppColors.warningSoft),
  enCocina('EN COCINA', AppColors.warning, AppColors.warningSoft),
  recogido('RECOGIDO', AppColors.primary, AppColors.primarySoft),
  enCamino('EN CAMINO', Colors.white, AppColors.primary),
  cercaDelCliente('CERCA DEL CLIENTE', AppColors.primaryOnSoft, AppColors.primarySoft),
  entregado('ENTREGADO', Colors.white, AppColors.primaryOnSoft),
  multiPedido('MULTI-PEDIDO', AppColors.order3, AppColors.order3Soft),
  cancelado('CANCELADO', AppColors.danger, AppColors.dangerSoft);

  const OrderStatus(this.label, this.foreground, this.background);

  final String label;
  final Color foreground;
  final Color background;
}

/// Nivel de demanda del heatmap (frame 07).
enum DemandLevel {
  baja('Baja', AppColors.demandLow),
  media('Media', AppColors.demandMedium),
  alta('Alta', AppColors.demandHigh),
  muyAlta('Muy alta', AppColors.demandVeryHigh);

  const DemandLevel(this.label, this.color);

  final String label;
  final Color color;
}

/// Un ítem del pedido, tal como lo ve el repartidor en el restaurante.
class OrderItem {
  const OrderItem({required this.quantity, required this.name, required this.price});

  final int quantity;
  final String name;
  final double price;
}

/// Un pedido asignado al repartidor.
class DeliveryOrder {
  const DeliveryOrder({
    required this.id,
    required this.businessName,
    required this.businessCategory,
    required this.businessEmoji,
    required this.pickupAddress,
    required this.customerName,
    required this.customerInitials,
    required this.dropoffAddress,
    required this.earnings,
    required this.distanceKm,
    required this.etaMinutes,
    required this.items,
    required this.customerTotal,
    required this.deliveryCode,
    this.status = OrderStatus.buscando,
    this.gradient = const [AppColors.demandMedium, AppColors.demandHigh],
  });

  final String id;
  final String businessName;
  final String businessCategory;
  final String businessEmoji;
  final String pickupAddress;
  final String customerName;
  final String customerInitials;
  final String dropoffAddress;
  final double earnings;
  final double distanceKm;
  final int etaMinutes;
  final List<OrderItem> items;
  final double customerTotal;
  final String deliveryCode;
  final OrderStatus status;
  final List<Color> gradient;

  DeliveryOrder copyWith({OrderStatus? status}) => DeliveryOrder(
        id: id,
        businessName: businessName,
        businessCategory: businessCategory,
        businessEmoji: businessEmoji,
        pickupAddress: pickupAddress,
        customerName: customerName,
        customerInitials: customerInitials,
        dropoffAddress: dropoffAddress,
        earnings: earnings,
        distanceKm: distanceKm,
        etaMinutes: etaMinutes,
        items: items,
        customerTotal: customerTotal,
        deliveryCode: deliveryCode,
        status: status ?? this.status,
        gradient: gradient,
      );
}

/// Una entrada del historial (frame 15).
class HistoryEntry {
  const HistoryEntry({
    required this.businessName,
    required this.emoji,
    required this.time,
    required this.customerName,
    required this.amount,
    required this.status,
    required this.gradient,
    this.tip,
  });

  final String businessName;
  final String emoji;
  final String time;
  final String customerName;
  final double? amount;
  final OrderStatus status;
  final List<Color> gradient;
  final double? tip;
}

/// Grupo de entradas del historial bajo un encabezado de fecha.
class HistoryDay {
  const HistoryDay({required this.label, required this.entries});

  final String label;
  final List<HistoryEntry> entries;
}

/// Estado de verificación de un documento (frames 05 y 17).
enum DocumentStatus {
  verificado('Verificado', 'VIGENTE', AppColors.primaryOnSoft, AppColors.primarySoft),
  enRevision('En revisión', 'REVISANDO', AppColors.warning, AppColors.warningSoft),
  porVencer('Por vencer', 'POR VENCER', AppColors.warning, AppColors.warningSoft),
  pendiente('Pendiente de subir', 'SUBIR', AppColors.textSecondary, AppColors.fillStrong);

  const DocumentStatus(this.label, this.badge, this.color, this.background);

  final String label;
  final String badge;
  final Color color;
  final Color background;
}

/// Un documento del repartidor.
class RiderDocument {
  const RiderDocument({
    required this.name,
    required this.icon,
    required this.status,
    required this.expiry,
  });

  final String name;
  final IconData icon;
  final DocumentStatus status;
  final String expiry;
}

/// Una barra del gráfico de ganancias (frame 14).
class EarningsBar {
  const EarningsBar({required this.label, required this.value, this.highlighted = false});

  final String label;
  final double value;
  final bool highlighted;
}

/// Un periodo del selector "Semana · Día · Mes" del frame 14.
///
/// El diseño solo dibuja la pestaña "Semana"; las otras dos existen en el
/// selector, así que aquí llevan sus propias cifras para que ningún tab quede
/// muerto al tocarlo.
class EarningsPeriod {
  const EarningsPeriod({
    required this.tab,
    required this.headline,
    required this.total,
    required this.delta,
    required this.chartTitle,
    required this.bars,
    required this.orders,
    required this.hours,
    required this.tips,
    required this.perOrder,
  });

  /// Etiqueta del selector: "Semana", "Día", "Mes".
  final String tab;

  /// Texto sobre la cifra grande ("Ganancia esta semana").
  final String headline;
  final double total;
  final String delta;

  /// Título del gráfico ("Por día", "Por hora"…).
  final String chartTitle;
  final List<EarningsBar> bars;
  final int orders;
  final String hours;
  final double tips;
  final double perOrder;
}

/// Una pregunta del centro de ayuda (frame 19).
class FaqEntry {
  const FaqEntry({required this.question, required this.answer, required this.icon});

  final String question;
  final String answer;
  final IconData icon;
}

/// Una fila de la lista de perfil (frame 16): abre una hoja con el detalle.
class ProfileDetail {
  const ProfileDetail({
    required this.title,
    required this.icon,
    required this.fields,
  });

  final String title;
  final IconData icon;

  /// Pares etiqueta → valor mostrados en la hoja de detalle.
  final List<(String, String)> fields;
}
