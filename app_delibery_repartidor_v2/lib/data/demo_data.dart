import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'models.dart';

/// Datos de demostración tomados literalmente del canvas de diseño.
///
/// Aísla el contenido de las pantallas: cuando llegue el backend real, se
/// reemplaza esta clase sin tocar la UI.
class DemoData {
  DemoData._();

  // ---- Repartidor ----
  static const String riderName = 'Rubén Mamani';
  static const String riderShortName = 'Rubén M.';
  static const String riderInitials = 'RM';
  static const String riderPhone = '+51 987 654 321';
  static const String riderSince = 'Repartidor desde ene. 2025';
  static const String riderTier = 'Chasqui Oro';
  static const double riderRating = 4.9;
  static const int riderDeliveries = 1284;
  static const int riderAcceptance = 98;

  // ---- Resumen del día (hoja del mapa, frame 06) ----
  static const double todayEarnings = 48.50;
  static const int todayOrders = 6;
  static const String todayOnline = '3h 20m';

  // ---- Pedido entrante (frames 08–12) ----
  static const DeliveryOrder incomingOrder = DeliveryOrder(
    id: '#A-2481',
    businessName: 'Pollería El Cholo',
    businessCategory: 'Comida · Parrillas',
    businessEmoji: '🍗',
    pickupAddress: 'Jr. Puno 214',
    customerName: 'María Ccapa',
    customerInitials: 'MC',
    dropoffAddress: 'Jr. Lima 320, Dpto 4 · timbre 2',
    earnings: 9.50,
    distanceKm: 2.4,
    etaMinutes: 18,
    customerTotal: 37.00,
    deliveryCode: '7239',
    gradient: [AppColors.demandMedium, AppColors.demandHigh],
    items: [
      OrderItem(quantity: 1, name: 'Pollo a la brasa (1/4)', price: 15.00),
      OrderItem(quantity: 1, name: 'Chaufa de pollo', price: 14.00),
      OrderItem(quantity: 2, name: 'Chicha morada', price: 8.00),
    ],
  );

  /// Segundos que dura la oferta antes de expirar (frame 08).
  static const int offerSeconds = 20;

  // ---- Lote multi-pedido (frame 13) ----
  static const List<DeliveryOrder> multiOrders = [
    DeliveryOrder(
      id: '#B-1102',
      businessName: 'Chifa Titicaca',
      businessCategory: 'Comida · Chifa',
      businessEmoji: '🥡',
      pickupAddress: 'Jr. Puno 214',
      customerName: 'Luis Mamani',
      customerInitials: 'LM',
      dropoffAddress: 'Jr. Lima 320',
      earnings: 8.00,
      distanceKm: 1.2,
      etaMinutes: 12,
      customerTotal: 42.00,
      deliveryCode: '4410',
      status: OrderStatus.recogido,
      items: [OrderItem(quantity: 1, name: 'Arroz chaufa especial', price: 22.00)],
    ),
    DeliveryOrder(
      id: '#B-1103',
      businessName: 'Botica Salud+',
      businessCategory: 'Farmacia',
      businessEmoji: '💊',
      pickupAddress: 'Jr. Tacna 88',
      customerName: 'Ana Quispe',
      customerInitials: 'AQ',
      dropoffAddress: 'Jr. Tacna 88',
      earnings: 6.50,
      distanceKm: 2.0,
      etaMinutes: 15,
      customerTotal: 28.50,
      deliveryCode: '8821',
      status: OrderStatus.buscando,
      items: [OrderItem(quantity: 1, name: 'Paracetamol 500mg', price: 12.00)],
    ),
    DeliveryOrder(
      id: '#B-1104',
      businessName: 'Café del Lago',
      businessCategory: 'Cafetería',
      businessEmoji: '☕',
      pickupAddress: 'Jr. Arequipa 12',
      customerName: 'Ana Quispe',
      customerInitials: 'AQ',
      dropoffAddress: 'Jr. Arequipa 12',
      earnings: 7.00,
      distanceKm: 2.6,
      etaMinutes: 19,
      customerTotal: 31.00,
      deliveryCode: '5507',
      status: OrderStatus.buscando,
      items: [OrderItem(quantity: 2, name: 'Café americano', price: 14.00)],
    ),
  ];

  /// Etiqueta de estado de cada tarjeta del lote (frame 13).
  static const List<String> multiOrderBadges = ['RECOGER', 'EN COLA', 'EN COLA'];

  // ---- Ganancias (frame 14) ----
  /// Los tres periodos del selector. El índice 0 ("Semana") es exactamente el
  /// frame 14 del diseño; los otros dos completan el selector.
  static const List<EarningsPeriod> earningsPeriods = [
    EarningsPeriod(
      tab: 'Semana',
      headline: 'Ganancia esta semana',
      total: 412.50,
      delta: '+18% vs. semana pasada',
      chartTitle: 'Por día',
      bars: [
        EarningsBar(label: 'L', value: 62),
        EarningsBar(label: 'M', value: 88),
        EarningsBar(label: 'M', value: 74),
        EarningsBar(label: 'J', value: 110),
        EarningsBar(label: 'V', value: 130, highlighted: true),
        EarningsBar(label: 'S', value: 100),
        EarningsBar(label: 'D', value: 56),
      ],
      orders: 47,
      hours: '21h 40m',
      tips: 58.00,
      perOrder: 8.77,
    ),
    EarningsPeriod(
      tab: 'Día',
      headline: 'Ganancia de hoy',
      total: 48.50,
      delta: '+9% vs. ayer',
      chartTitle: 'Por hora',
      bars: [
        EarningsBar(label: '10', value: 6),
        EarningsBar(label: '11', value: 9),
        EarningsBar(label: '12', value: 14, highlighted: true),
        EarningsBar(label: '13', value: 11),
        EarningsBar(label: '14', value: 8.50),
      ],
      orders: 6,
      hours: '3h 20m',
      tips: 6.00,
      perOrder: 8.08,
    ),
    EarningsPeriod(
      tab: 'Mes',
      headline: 'Ganancia de julio',
      total: 1620.00,
      delta: '+12% vs. junio',
      chartTitle: 'Por semana',
      bars: [
        EarningsBar(label: 'S1', value: 372),
        EarningsBar(label: 'S2', value: 398),
        EarningsBar(label: 'S3', value: 437, highlighted: true),
        EarningsBar(label: 'S4', value: 413),
      ],
      orders: 186,
      hours: '84h 15m',
      tips: 214.00,
      perOrder: 8.71,
    ),
  ];

  // ---- Historial (frame 15) ----
  static const List<HistoryDay> history = [
    HistoryDay(
      label: 'Hoy · viernes 24',
      entries: [
        HistoryEntry(
          businessName: 'Pollería El Cholo',
          emoji: '🍗',
          time: '14:20',
          customerName: 'María Ccapa',
          amount: 9.50,
          status: OrderStatus.entregado,
          gradient: [AppColors.demandMedium, AppColors.demandHigh],
          tip: 2.00,
        ),
        HistoryEntry(
          businessName: 'Botica Salud+',
          emoji: '💊',
          time: '13:05',
          customerName: 'Luis Mamani',
          amount: 6.50,
          status: OrderStatus.entregado,
          gradient: [Color(0xFFCDBFEF), Color(0xFF8B6FD4)],
        ),
        HistoryEntry(
          businessName: 'Chifa Titicaca',
          emoji: '🥡',
          time: '12:10',
          customerName: 'sin repartidor',
          amount: null,
          status: OrderStatus.cancelado,
          gradient: [AppColors.dangerSoft, AppColors.dangerSoft],
        ),
      ],
    ),
    HistoryDay(
      label: 'Jueves 23',
      entries: [
        HistoryEntry(
          businessName: 'Café del Lago',
          emoji: '☕',
          time: '18:40',
          customerName: 'Ana Quispe',
          amount: 7.00,
          status: OrderStatus.entregado,
          gradient: [Color(0xFFF5B7AE), Color(0xFFD65A44)],
        ),
      ],
    ),
  ];

  // ---- Documentos en el alta (frame 05) ----
  static const List<RiderDocument> onboardingDocuments = [
    RiderDocument(name: 'DNI', icon: Icons.badge_outlined, status: DocumentStatus.verificado, expiry: 'no aplica'),
    RiderDocument(name: 'Brevete (licencia)', icon: Icons.credit_card_outlined, status: DocumentStatus.verificado, expiry: '12 mar. 2027'),
    RiderDocument(name: 'SOAT', icon: Icons.verified_user_outlined, status: DocumentStatus.verificado, expiry: '14 ago. 2026'),
    RiderDocument(name: 'Tarjeta de propiedad', icon: Icons.two_wheeler_outlined, status: DocumentStatus.enRevision, expiry: 'no aplica'),
    RiderDocument(name: 'Foto de perfil', icon: Icons.person_outline, status: DocumentStatus.pendiente, expiry: '—'),
  ];

  /// Documentos aprobados (frame 17): "3 / 5" del alta ya resuelto.
  static const List<RiderDocument> riderDocuments = [
    RiderDocument(name: 'DNI', icon: Icons.badge_outlined, status: DocumentStatus.verificado, expiry: 'Vence: no aplica'),
    RiderDocument(name: 'Brevete', icon: Icons.credit_card_outlined, status: DocumentStatus.verificado, expiry: 'Vence: 12 mar. 2027'),
    RiderDocument(name: 'SOAT', icon: Icons.verified_user_outlined, status: DocumentStatus.porVencer, expiry: 'Vence en 21 días · 14 ago.'),
    RiderDocument(name: 'Tarjeta de propiedad', icon: Icons.two_wheeler_outlined, status: DocumentStatus.verificado, expiry: 'Vence: no aplica'),
  ];

  // ---- Perfil (frame 16) ----
  /// Filas de la lista del perfil. Cada una abre una hoja con su detalle, así
  /// ninguna termina en un callejón sin salida.
  static const List<ProfileDetail> profileDetails = [
    ProfileDetail(
      title: 'Datos personales',
      icon: Icons.person_outline_rounded,
      fields: [
        ('Nombre', riderName),
        ('Celular', riderPhone),
        ('DNI', '4****812'),
        ('Ciudad', 'Puno'),
      ],
    ),
    ProfileDetail(
      title: 'Mi vehículo · placa',
      icon: Icons.two_wheeler_outlined,
      fields: [
        ('Tipo', 'Motocicleta'),
        ('Marca', 'Honda XR 150'),
        ('Placa', 'M2P-418'),
        ('Color', 'Rojo'),
      ],
    ),
    ProfileDetail(
      title: 'Método de pago',
      icon: Icons.credit_card_outlined,
      fields: [
        ('Banco', 'BCP'),
        ('Cuenta', '·······4192'),
        ('Titular', riderName),
        ('Frecuencia', 'Semanal · lunes'),
      ],
    ),
  ];

  // ---- Centro de ayuda (frame 19) ----
  static const List<FaqEntry> faqs = [
    FaqEntry(
      question: 'El cliente no responde',
      answer: 'Llama dos veces desde la app y espera 5 minutos en el punto de entrega. '
          'Si sigue sin responder, toca "Reportar un problema" y soporte decide qué '
          'hacer con el pedido sin afectar tu aceptación.',
      icon: Icons.near_me_outlined,
    ),
    FaqEntry(
      question: '¿Cuándo cobro mis ganancias?',
      answer: 'Los depósitos salen cada lunes por lo acumulado hasta el domingo. '
          'También puedes retirar antes desde Ganancias › "Retirar a mi cuenta".',
      icon: Icons.credit_card_outlined,
    ),
    FaqEntry(
      question: 'Problemas con mi cuenta',
      answer: 'Si no puedes conectarte, revisa que tus documentos estén vigentes en '
          'Documentos. Si el problema persiste, escríbenos por WhatsApp con tu DNI '
          'a la mano.',
      icon: Icons.lock_outline_rounded,
    ),
  ];

  /// Opciones del frame 18.
  static const List<String> mapsApps = ['Google Maps', 'Waze', 'Mapas de Apple'];
  static const List<String> languages = ['Español', 'Quechua', 'Aimara', 'English'];

  // ---- Heatmap (frame 07) ----
  static const List<DemandLevel> demandLegend = [
    DemandLevel.muyAlta,
    DemandLevel.alta,
    DemandLevel.media,
    DemandLevel.baja,
  ];
}
