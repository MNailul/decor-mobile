import 'package:flutter/material.dart';
import '../models/order_model.dart';
import '../models/product_model.dart';
import 'cart_provider.dart'; // To get dummyCatalog

class OrderProvider extends ChangeNotifier {
  final List<OrderModel> _orders = [
    OrderModel(
      id: 'ORD-TEST-REVIEW',
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
      totalAmount: 123.40,
      orderDate: DateTime.now().subtract(const Duration(days: 3)),
      status: OrderStatus.delivered,
    ),
  ];

  OrderProvider() {
    // Initial mock order is now in the list declaration
  }

  List<OrderModel> get orders => List.unmodifiable(_orders);

  void addOrder(OrderModel order) {
    _orders.insert(0, order); // Newest first
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
