import 'product_model.dart';

class OrderItemModel {
  final ProductModel? product;
  final int quantity;
  final double price;

  OrderItemModel({this.product, required this.quantity, required this.price});

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      product: json['product'] != null ? ProductModel.fromJson(json['product']) : null,
      quantity: json['quantity'],
      price: double.parse(json['price'].toString()),
    );
  }
}

enum OrderStatus { pending, awaiting_verification, processing, shipped, delivered, cancelled, returning }

class OrderModel {
  final String id;
  final List<OrderItemModel> items;
  final double totalAmount;
  final DateTime orderDate;
  final OrderStatus status;
  final String paymentMethod;
  final String shippingCourier;
    final String? returnStatus; // Status return (pending, approved, rejected)
    final String? returnReason; // Alasan return
    final bool hasReviewed;
    final String shippingAddress;
    final String shippingRecipient;
    final String shippingPhone;
    final String shippingCity;
    final double discountAmount;
    final int? voucherId;

    OrderModel({
      required this.id,
      required this.items,
      required this.totalAmount,
      required this.orderDate,
      this.status = OrderStatus.processing,
      this.paymentMethod = 'Bank Transfer',
      this.shippingCourier = 'Standard',
      this.returnStatus,
      this.returnReason,
      this.hasReviewed = false,
      this.shippingAddress = '',
      this.shippingRecipient = '',
      this.shippingPhone = '',
      this.shippingCity = '',
      this.discountAmount = 0.0,
      this.voucherId,
    });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    // Parse product return data if exists
    String? retStatus;
    String? retReason;
    if (json['product_return'] != null) {
      retStatus = json['product_return']['status'];
      retReason = json['product_return']['reason'];
    }

    // Map Laravel status string to enum
    OrderStatus status = OrderStatus.processing;
    String rawStatus = (json['status'] ?? 'pending').toString().toLowerCase();
    
    // Prioritaskan status returning jika ada data return
    if (retStatus != null || rawStatus == 'returning' || rawStatus == 'retur') {
      status = OrderStatus.returning;
    } else if (rawStatus == 'pending') {
      status = OrderStatus.pending;
    } else if (rawStatus == 'waiting_verification' || rawStatus == 'awaiting_verification') {
      status = OrderStatus.awaiting_verification;
    } else if (rawStatus == 'paid' || rawStatus == 'processing') {
      status = OrderStatus.processing;
    } else if (rawStatus == 'shipped' || rawStatus == 'dikirim') {
      status = OrderStatus.shipped;
    } else if (rawStatus == 'completed' || rawStatus == 'selesai' || rawStatus == 'delivered') {
      status = OrderStatus.delivered;
    } else if (rawStatus == 'cancelled' || rawStatus == 'dibatalkan') {
      status = OrderStatus.cancelled;
    }

    return OrderModel(
      id: json['id'].toString(),
      items: (json['order_items'] as List)
          .map((i) => OrderItemModel.fromJson(i))
          .toList(),
      totalAmount: double.parse(json['total_price'].toString()),
      orderDate: DateTime.parse(json['created_at']),
      status: status,
      paymentMethod: json['payment_method'] ?? 'Bank Transfer',
      shippingCourier: json['shipping_courier'] ?? 'Standard',
      returnStatus: retStatus,
      returnReason: retReason,
      hasReviewed: json['has_reviewed'] == 1 || json['has_reviewed'] == true,
      shippingAddress: json['shipping_address'] ?? '',
      shippingRecipient: json['shipping_recipient'] ?? '',
      shippingPhone: json['shipping_phone'] ?? '',
      shippingCity: json['shipping_city'] ?? '',
      discountAmount: json['discount_amount'] != null ? double.parse(json['discount_amount'].toString()) : 0.0,
      voucherId: json['voucher_id'],
    );
  }
}
