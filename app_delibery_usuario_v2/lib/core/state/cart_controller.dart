import 'package:flutter/foundation.dart';

/// Un ítem del carrito (demo, sin backend todavía).
class CartItem {
  const CartItem({
    required this.id,
    required this.name,
    required this.unitPrice,
    this.quantity = 1,
  });

  final String id;
  final String name;
  final double unitPrice;
  final int quantity;

  double get lineTotal => unitPrice * quantity;

  CartItem copyWith({int? quantity}) => CartItem(
        id: id,
        name: name,
        unitPrice: unitPrice,
        quantity: quantity ?? this.quantity,
      );
}

/// Carrito global reactivo. La barra flotante y el checkout escuchan sus
/// cambios. Se expone como singleton [cart] para no depender de un paquete de
/// gestión de estado externo.
class CartController extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);

  int get count => _items.fold(0, (sum, i) => sum + i.quantity);

  double get subtotal => _items.fold(0, (sum, i) => sum + i.lineTotal);

  double get deliveryFee => _items.isEmpty ? 0 : 3.50;

  double get total => subtotal + deliveryFee;

  bool get isEmpty => _items.isEmpty;

  void add(CartItem item) {
    final idx = _items.indexWhere((i) => i.id == item.id);
    if (idx >= 0) {
      _items[idx] = _items[idx].copyWith(
        quantity: _items[idx].quantity + item.quantity,
      );
    } else {
      _items.add(item);
    }
    notifyListeners();
  }

  void increment(String id) {
    final idx = _items.indexWhere((i) => i.id == id);
    if (idx >= 0) {
      _items[idx] = _items[idx].copyWith(quantity: _items[idx].quantity + 1);
      notifyListeners();
    }
  }

  void decrement(String id) {
    final idx = _items.indexWhere((i) => i.id == id);
    if (idx >= 0) {
      final q = _items[idx].quantity - 1;
      if (q <= 0) {
        _items.removeAt(idx);
      } else {
        _items[idx] = _items[idx].copyWith(quantity: q);
      }
      notifyListeners();
    }
  }

  void removeItem(String id) {
    _items.removeWhere((i) => i.id == id);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }

  /// Precarga un carrito de demostración para que la barra flotante y el
  /// checkout tengan contenido al navegar por el catálogo.
  void seedDemo() {
    if (_items.isNotEmpty) return;
    _items.addAll(const [
      CartItem(id: 'p1', name: '1/4 de Pollo a la brasa', unitPrice: 18.90),
      CartItem(id: 'p3', name: 'Anticuchos (2 palos)', unitPrice: 15.00),
    ]);
    notifyListeners();
  }
}

/// Instancia global del carrito.
final CartController cart = CartController();
