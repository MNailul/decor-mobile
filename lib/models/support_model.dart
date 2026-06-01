class SupportModel {
  final int id;
  final int userId;
  final String subject;
  final String message;
  final String status;
  final String? adminReply;
  final String createdAt;
  final String updatedAt;

  SupportModel({
    required this.id,
    required this.userId,
    required this.subject,
    required this.message,
    required this.status,
    this.adminReply,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SupportModel.fromJson(Map<String, dynamic> json) {
    return SupportModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      userId: json['user_id'] is int ? json['user_id'] : int.parse(json['user_id'].toString()),
      subject: json['subject'] ?? '',
      message: json['message'] ?? '',
      status: json['status'] ?? 'pending',
      adminReply: json['admin_reply'],
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }
}
