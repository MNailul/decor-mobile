import 'user_model.dart';
import 'product_model.dart';

class ChatModel {
  final int id;
  final int senderId;
  final int receiverId;
  final int? productId;
  final String message;
  final bool isRead;
  final String createdAt;
  final User? sender;
  final User? receiver;
  final ProductModel? product;

  ChatModel({
    required this.id,
    required this.senderId,
    required this.receiverId,
    this.productId,
    required this.message,
    required this.isRead,
    required this.createdAt,
    this.sender,
    this.receiver,
    this.product,
  });

  factory ChatModel.fromJson(Map<String, dynamic> json) {
    return ChatModel(
      id: json['id'],
      senderId: json['sender_id'],
      receiverId: json['receiver_id'],
      productId: json['product_id'],
      message: json['message'],
      isRead: json['is_read'] == 1 || json['is_read'] == true,
      createdAt: json['created_at'],
      sender: json['sender'] != null ? User.fromJson(json['sender']) : null,
      receiver: json['receiver'] != null ? User.fromJson(json['receiver']) : null,
      product: json['product'] != null ? ProductModel.fromJson(json['product']) : null,
    );
  }
}
