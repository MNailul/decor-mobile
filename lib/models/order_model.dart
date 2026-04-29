import 'product_model.dart';

class OrderItem {
  final FurnitureProduct product;
  final int quantity;

  OrderItem({required this.product, required this.quantity});
}

enum OrderStatus { ordered, processing, shipped, delivered, cancelled }

class OrderModel {
  final String id;
  final List<OrderItem> items;
  final double totalAmount;
  final DateTime orderDate;
  final OrderStatus status;

  OrderModel({
    required this.id,
    required this.items,
    required this.totalAmount,
    required this.orderDate,
    this.status = OrderStatus.ordered,
  });
}
