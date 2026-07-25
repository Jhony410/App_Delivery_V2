import 'models.dart';

/// Contenido de ejemplo, copiado literalmente del canvas `DelyNegocios.dc.html`.
///
/// Vive aparte del estado para que, cuando exista el backend, solo haya que
/// cambiar la fuente en `AppState` sin tocar ninguna pantalla.
class DemoData {
  DemoData._();

  static const BusinessProfile business = BusinessProfile(
    name: 'Pollería El Cholo',
    category: 'Comida · Parrillas',
    address: 'Jr. Puno 214, Puno',
    taxId: '20605XXXXXX',
    schedule: '10:00 – 22:00',
    whatsapp: '+51 987 654 321',
  );

  /// Rubros ofrecidos en Verificación del negocio (frame 03).
  static const List<String> categories = [
    '🍗 Comida',
    '💊 Farmacia',
    '🛒 Bodega',
  ];

  /// Los cinco pedidos del frame 05, uno por estado.
  static List<Order> get orders => [
    Order(
      code: '#A-2485',
      customer: 'Luis Mamani',
      address: 'Jr. Tacna 88',
      total: 42,
      items: ['1× Pollo entero', '1× Chaufa', '2× Chicha morada'],
      status: OrderStatus.nuevo,
      receivedAt: DateTime.now().subtract(const Duration(seconds: 30)),
    ),
    const Order(
      code: '#A-2481',
      customer: 'María Ccapa',
      address: 'Jr. Lima 402',
      total: 37,
      items: ['1× Pollo a la brasa', '1× Papas', '1× Inca Kola'],
      status: OrderStatus.preparando,
    ),
    const Order(
      code: '#A-2479',
      customer: 'Ana Quispe',
      address: 'Av. El Sol 120',
      total: 18,
      items: ['1× Broaster'],
      status: OrderStatus.esperandoRepartidor,
      statusNote: 'Listo · buscando chasqui',
      emoji: '🍟',
    ),
    const Order(
      code: '#A-2476',
      customer: 'Rosa Huamán',
      address: 'Jr. Deustua 310',
      total: 25,
      items: ['1× Pollo a la brasa (1/2)'],
      status: OrderStatus.enCamino,
      statusNote: 'Rubén M. lo lleva',
    ),
    const Order(
      code: '#A-2470',
      customer: 'Carlos Apaza',
      address: 'Jr. Arequipa 55',
      total: 30,
      items: ['2× Chaufa de pollo'],
      status: OrderStatus.entregado,
      statusNote: 'Entregado 13:40',
      emoji: '🍚',
    ),
  ];

  /// Catálogo del frame 07.
  static List<Product> get products => const [
    Product(
      id: 'p1',
      name: 'Pollo a la brasa (1/4)',
      price: 15,
      available: true,
      emoji: '🍗',
    ),
    Product(
      id: 'p2',
      name: 'Chaufa de pollo',
      price: 14,
      available: true,
      emoji: '🍚',
      thumb: ProductThumb.orange,
    ),
    Product(
      id: 'p3',
      name: 'Chicha morada 1L',
      price: 8,
      available: false,
      emoji: '🥤',
    ),
  ];

  /// Cifras de Reportes por rango (frame 08).
  static const Map<ReportRange, ReportSummary> reports = {
    ReportRange.hoy: ReportSummary(
      sales: 340,
      orderCount: 28,
      profit: 210,
      topProduct: 'Pollo a la brasa',
      topProductUnits: 14,
      topProductEmoji: '🍗',
    ),
    ReportRange.semana: ReportSummary(
      sales: 2180,
      orderCount: 176,
      profit: 1340,
      topProduct: 'Pollo a la brasa',
      topProductUnits: 92,
      topProductEmoji: '🍗',
    ),
    ReportRange.mes: ReportSummary(
      sales: 9420,
      orderCount: 742,
      profit: 5810,
      topProduct: 'Chaufa de pollo',
      topProductUnits: 318,
      topProductEmoji: '🍚',
    ),
  };

  /// Pedidos que "entran" cuando se simula la llegada de uno nuevo. La alerta
  /// emergente (frame 06) se dispara con el primero de esta lista.
  static List<Order> get incoming => [
    Order(
      code: '#A-2490',
      customer: 'Elena Ticona',
      address: 'Jr. Puno 980',
      total: 56,
      items: ['1× Pollo entero', '2× Papas', '1× Ensalada'],
      status: OrderStatus.nuevo,
      receivedAt: DateTime.now(),
    ),
    Order(
      code: '#A-2491',
      customer: 'Julio Condori',
      address: 'Av. Floral 233',
      total: 23,
      items: ['1× Broaster', '1× Chicha morada'],
      status: OrderStatus.nuevo,
      emoji: '🍟',
      receivedAt: DateTime.now(),
    ),
  ];
}
