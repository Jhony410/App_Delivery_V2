import 'package:flutter/material.dart';

/// Datos de demostración en memoria. Sustituyen a un backend mientras se
/// conecta Firebase; permiten que todas las pantallas naveguen con contenido
/// coherente (categorías, comercios, productos, pedidos).

class Category {
  const Category({required this.id, required this.name, required this.icon});
  final String id;
  final String name;
  final IconData icon;
}

class Business {
  const Business({
    required this.id,
    required this.name,
    required this.tags,
    required this.rating,
    required this.eta,
    required this.freeShipping,
    required this.gradient,
    this.reviews = 0,
    this.address = 'Jr. Puno 445 · Puno',
  });

  final String id;
  final String name;
  final String tags;
  final double rating;
  final String eta;
  final bool freeShipping;
  final List<Color> gradient;
  final int reviews;
  final String address;
}

class Product {
  const Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.gradient,
  });

  final String id;
  final String name;
  final String description;
  final double price;
  final List<Color> gradient;
}

class OrderSummary {
  const OrderSummary({
    required this.id,
    required this.businessName,
    required this.subtitle,
    required this.detail,
    required this.delivered,
    required this.gradient,
  });

  final String id;
  final String businessName;
  final String subtitle;
  final String detail;
  final bool delivered;
  final List<Color> gradient;
}

class DemoData {
  DemoData._();

  static const categories = <Category>[
    Category(id: 'comida', name: 'Comida', icon: Icons.ramen_dining),
    Category(id: 'farmacia', name: 'Farmacia', icon: Icons.medical_services),
    Category(id: 'mercado', name: 'Mercado', icon: Icons.shopping_basket),
    Category(id: 'licoreria', name: 'Licorería', icon: Icons.local_bar),
  ];

  static const businesses = <Business>[
    Business(
      id: 'chifa-titicaca',
      name: 'Chifa Titicaca',
      tags: 'Comida · Chifa',
      rating: 4.8,
      eta: '25-35 min',
      freeShipping: true,
      reviews: 640,
      gradient: [Color(0xFFCFE9D8), Color(0xFF7FC79C)],
    ),
    Business(
      id: 'botica-salud',
      name: 'Botica Salud+',
      tags: 'Farmacia · 24 h',
      rating: 4.9,
      eta: '15-20 min',
      freeShipping: false,
      reviews: 320,
      gradient: [Color(0xFFCDBFEF), Color(0xFF8B6FD4)],
    ),
    Business(
      id: 'mercado-central',
      name: 'Mercado Central',
      tags: 'Mercado · Abarrotes',
      rating: 4.6,
      eta: '30-40 min',
      freeShipping: false,
      reviews: 210,
      gradient: [Color(0xFFF6D8A8), Color(0xFFE0A24A)],
    ),
    Business(
      id: 'polleria-el-cholo',
      name: 'Pollería El Cholo',
      tags: 'Pollo a la brasa · Parrillas',
      rating: 4.7,
      eta: '20-30 min',
      freeShipping: true,
      reviews: 812,
      address: 'Jr. Puno 445 · a 2 cuadras de la Plaza de Armas',
      gradient: [Color(0xFFF2C98F), Color(0xFFD98324)],
    ),
    Business(
      id: 'anticuchos-rosa',
      name: 'Anticuchos Doña Rosa',
      tags: 'Comida criolla · Anticuchos',
      rating: 4.9,
      eta: '20-30 min',
      freeShipping: false,
      reviews: 430,
      gradient: [Color(0xFFC9B8F0), Color(0xFF8B6FD4)],
    ),
    Business(
      id: 'cafe-del-lago',
      name: 'Café del Lago',
      tags: 'Cafetería · Postres',
      rating: 4.6,
      eta: '25-35 min',
      freeShipping: true,
      reviews: 150,
      gradient: [Color(0xFFF5B7AE), Color(0xFFD65A44)],
    ),
  ];

  static const products = <Product>[
    Product(
      id: 'p1',
      name: '1/4 de Pollo a la brasa',
      description: 'Papas, ensalada y cremas',
      price: 18.90,
      gradient: [Color(0xFFF6D9A8), Color(0xFFEDA845)],
    ),
    Product(
      id: 'p2',
      name: 'Pollo entero + gaseosa',
      description: 'Para compartir · papas fam.',
      price: 52.00,
      gradient: [Color(0xFFF5C1A0), Color(0xFFD9622F)],
    ),
    Product(
      id: 'p3',
      name: 'Anticuchos (2 palos)',
      description: 'Corazón marinado + papa',
      price: 15.00,
      gradient: [Color(0xFFE3C49B), Color(0xFFA9743A)],
    ),
    Product(
      id: 'p4',
      name: 'Mollejitas doradas',
      description: 'Con papas al hilo',
      price: 12.00,
      gradient: [Color(0xFFEDD3A0), Color(0xFFC99A3E)],
    ),
  ];

  static const orders = <OrderSummary>[
    OrderSummary(
      id: '4821',
      businessName: 'Pollería El Cholo',
      subtitle: 'Pedido #4821 · Hoy 9:40',
      detail: 'Llega aprox. 9:58 · 2 productos',
      delivered: false,
      gradient: [Color(0xFFF2C98F), Color(0xFFD98324)],
    ),
    OrderSummary(
      id: '4790',
      businessName: 'Botica Salud+',
      subtitle: 'Pedido #4790 · Ayer 18:20',
      detail: 'Paracetamol, Vitamina C · S/ 24.50',
      delivered: true,
      gradient: [Color(0xFFBEE6CE), Color(0xFF5FB98A)],
    ),
    OrderSummary(
      id: '4712',
      businessName: 'Licorería Nocturna',
      subtitle: 'Pedido #4712 · 20 jul',
      detail: 'Cerveza x6, Piqueo · S/ 58.00',
      delivered: true,
      gradient: [Color(0xFFC9B8F0), Color(0xFF8B6FD4)],
    ),
  ];

  static Business businessById(String id) => businesses.firstWhere(
        (b) => b.id == id,
        orElse: () => businesses.first,
      );

  static Product productById(String id) => products.firstWhere(
        (p) => p.id == id,
        orElse: () => products.first,
      );

  static Category categoryById(String id) => categories.firstWhere(
        (c) => c.id == id,
        orElse: () => categories.first,
      );
}
