import 'package:flutter/material.dart';
import '../models/order_model.dart';
import '../models/product_model.dart';

class OrderProvider extends ChangeNotifier {
  final List<OrderModel> _orders = [
    OrderModel(
      id: 'ORD-DECOR-001',
      items: [
        OrderItem(
          product: FurnitureProduct(
            id: 'p3',
            name: 'Aurelius Lounge Chair',
            price: 420.00,
            category: 'Chair',
            imagePath: 'https://images.unsplash.com/photo-1567538096630-e0c55bd6374c?w=400&q=80',
            material: 'Leather',
            style: 'Classic',
            shopName: 'Aura Home',
          ),
          quantity: 1,
        ),
      ],
      totalAmount: 420.00,
      orderDate: DateTime.now().subtract(const Duration(hours: 2)),
      status: OrderStatus.ordered,
    ),
    OrderModel(
      id: 'ORD-DECOR-002',
      items: [
        OrderItem(
          product: FurnitureProduct(
            id: 'p2',
            name: 'Solstice Floor Lamp',
            price: 185.00,
            category: 'Lighting',
            imagePath: 'https://images.unsplash.com/photo-1507473885765-e6ed057f782c?w=400&q=80',
            material: 'Brass',
            style: 'Minimalist',
            shopName: 'Lumina Store',
          ),
          quantity: 2,
        ),
      ],
      totalAmount: 370.00,
      orderDate: DateTime.now().subtract(const Duration(days: 1)),
      status: OrderStatus.processing,
    ),
    OrderModel(
      id: 'ORD-DECOR-003',
      items: [
        OrderItem(
          product: FurnitureProduct(
            id: 'p1',
            name: 'Terra Ambiance Chair',
            price: 84.00,
            category: 'Chair',
            imagePath: 'https://images.unsplash.com/photo-1598300042247-d088f8ab3a91?w=400&q=80',
            material: 'Fabric',
            style: 'Modern',
            shopName: 'Aura Home',
          ),
          quantity: 1,
        ),
      ],
      totalAmount: 84.00,
      orderDate: DateTime.now().subtract(const Duration(days: 2)),
      status: OrderStatus.shipped, // Test Chat Courier here
    ),
    OrderModel(
      id: 'ORD-DECOR-004',
      items: [
        OrderItem(
          product: FurnitureProduct(
            id: 'p4',
            name: 'Nomad Coffee Table',
            price: 290.00,
            category: 'Table',
            imagePath: 'https://images.unsplash.com/photo-1533090481720-856c6e3c1fdc?w=400&q=80',
            material: 'Oak Wood',
            style: 'Nordic',
            shopName: 'Timber Collective',
          ),
          quantity: 1,
        ),
      ],
      totalAmount: 290.00,
      orderDate: DateTime.now().subtract(const Duration(days: 5)),
      status: OrderStatus.delivered,
    ),
    OrderModel(
      id: 'ORD-DECOR-005',
      items: [
        OrderItem(
          product: FurnitureProduct(
            id: 'p5',
            name: 'Velvet Sofa Set',
            price: 1200.00,
            category: 'Sofa',
            imagePath: 'https://images.unsplash.com/photo-1555041469-a586c61ea9bc?w=400&q=80',
            material: 'Velvet',
            style: 'Luxurious',
            shopName: 'Grand Living',
          ),
          quantity: 1,
        ),
      ],
      totalAmount: 1200.00,
      orderDate: DateTime.now().subtract(const Duration(days: 10)),
      status: OrderStatus.cancelled,
    ),
    OrderModel(
      id: 'ORD-DECOR-006',
      items: [
        OrderItem(
          product: FurnitureProduct(
            id: 'p6',
            name: 'Minimalist Side Table',
            price: 120.00,
            category: 'Table',
            imagePath: 'https://images.unsplash.com/photo-1532372320572-cda25653a26d?w=400&q=80',
            material: 'Metal',
            style: 'Industrial',
            shopName: 'Timber Collective',
          ),
          quantity: 1,
        ),
      ],
      totalAmount: 120.00,
      orderDate: DateTime.now().subtract(const Duration(days: 3)),
      status: OrderStatus.returning,
    ),
  ];

  List<OrderModel> get orders => List.unmodifiable(_orders);

  void addOrder(OrderModel order) {
    _orders.insert(0, order);
    notifyListeners();
  }

  void updateOrderStatus(String orderId, OrderStatus status) {
    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index >= 0) {
      final oldOrder = _orders[index];
      _orders[index] = OrderModel(
        id: oldOrder.id,
        items: oldOrder.items,
        totalAmount: oldOrder.totalAmount,
        orderDate: oldOrder.orderDate,
        status: status,
      );
      notifyListeners();
    }
  }
}
