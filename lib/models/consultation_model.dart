import 'dart:convert';
import 'package:flutter/material.dart';
import '../core/constants.dart';

class ConsultationModel {
  final int id;
  final int customerId;
  final int designerId;
  final String title;
  final String description;
  final String budgetRange;
  final int status; // 0: Waiting Brief, 1: Drafting, 2: Review, 3: Revision, 4: Completed
  final String? coverImage;
  final String? consultationType;
  final String? designerName;
  final String? designerImage;
  final List<ConsultationMessageModel>? messages;
  final List<ConsultationAttachmentModel>? attachments;
  final List<ConsultationQuoteModel>? quotes;
  final DateTime? createdAt;
  final String? paymentProof; // null = not yet submitted; non-null = awaiting validation
  final double? finalAmountApi; // from backend appended 'final_amount' attribute
  final DateTime? chatExpiresAt;
  final bool isChatExpired;

  ConsultationModel({
    required this.id,
    required this.customerId,
    required this.designerId,
    required this.title,
    required this.description,
    required this.budgetRange,
    required this.status,
    this.consultationType,
    this.coverImage,
    this.designerName,
    this.designerImage,
    this.messages,
    this.attachments,
    this.quotes,
    this.createdAt,
    this.paymentProof,
    this.finalAmountApi,
    this.chatExpiresAt,
    this.isChatExpired = false,
  });

  factory ConsultationModel.fromJson(Map<String, dynamic> json) {
    return ConsultationModel(
      id: json['id'],
      customerId: json['customer_id'],
      designerId: json['designer_id'],
      title: json['title'],
      description: json['description'],
      budgetRange: json['budget_range'],
      status: json['status'],
      consultationType: json['consultation_type'],
      coverImage: json['cover_image'],
      paymentProof: json['payment_proof'],
      finalAmountApi: json['final_amount'] != null ? double.tryParse(json['final_amount'].toString()) : null,
      designerName: json['designer'] != null ? (json['designer']['studio_name'] ?? json['designer']['user']['full_name']) : null,
      designerImage: json['designer'] != null ? (json['designer']['designer_image'] != null ? 'storage/' + json['designer']['designer_image'] : null) : null,
      messages: json['messages'] != null 
          ? (json['messages'] as List).map((m) => ConsultationMessageModel.fromJson(m)).toList()
          : null,
      attachments: json['attachments'] != null
          ? (json['attachments'] as List).map((a) => ConsultationAttachmentModel.fromJson(a)).toList()
          : null,
      quotes: json['quotes'] != null
          ? (json['quotes'] as List).map((q) => ConsultationQuoteModel.fromJson(q)).toList()
          : null,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      chatExpiresAt: json['chat_expires_at'] != null ? DateTime.parse(json['chat_expires_at']) : null,
      isChatExpired: json['is_chat_expired'] ?? false,
    );
  }

  /// The initial consultation fee (from API consultation_fee attribute or fallback)
  double get consultationFee {
    return consultationType == 'request_proposal' ? 250000.0 : 50000.0;
  }

  /// The accepted quote/RAB amount for final payment.
  /// Prefers the backend-appended 'final_amount', then falls back to quotes list.
  double? get finalAmount {
    if (finalAmountApi != null && finalAmountApi! > 0) return finalAmountApi;
    if (quotes != null && quotes!.isNotEmpty) {
      try {
        final acceptedQuote = quotes!.firstWhere((q) => q.status == 'accepted');
        return acceptedQuote.amount;
      } catch (_) {}
    }
    return null;
  }

  String getStatusLabel() {
    switch (status) {
      case 0: return 'Waiting Brief';
      case 1: return 'Drafting';
      case 2: return 'Under Review';
      case 3: return 'Revision Requested';
      case 4: return 'Completed';
      case 5: return 'Pending Approval';
      case 6: return 'Rejected';
      case 7: return 'Waiting Payment';
      case 8: return 'Offer Received';
      case 9: return 'Waiting Final Payment';
      default: return 'Unknown';
    }
  }

  Color getStatusColor() {
    switch (status) {
      case 0: return Colors.orange;
      case 1: return Colors.blue;
      case 2: return Colors.purple;
      case 3: return Colors.red;
      case 4: return Colors.green;
      case 5: return Colors.grey;
      case 6: return Colors.red;
      case 7: return Colors.amber;
      case 8: return Colors.purpleAccent;
      case 9: return Colors.orangeAccent;
      default: return Colors.grey;
    }
  }

  String? get fullDesignerImage {
    if (designerImage == null) return null;
    if (designerImage!.startsWith('http')) return designerImage;
    return '${ApiConstants.baseUrl}/$designerImage';
  }

  String? get fullCoverImage {
    if (coverImage == null) return null;
    if (coverImage!.startsWith('http')) return coverImage;
    return '${ApiConstants.baseUrl}/storage/$coverImage';
  }

  String get displayPrice {
    // Prefer the backend-appended final_amount (always accurate)
    if (finalAmountApi != null && finalAmountApi! > 0) {
      return finalAmountApi!.toStringAsFixed(0);
    }
    // Fall back to accepted quote from the loaded quotes list
    if (quotes != null && quotes!.isNotEmpty) {
      try {
        final acceptedQuote = quotes!.firstWhere((q) => q.status == 'accepted');
        return acceptedQuote.amount.toStringAsFixed(0);
      } catch (e) {
        // No accepted quote found
      }
    }
    return budgetRange;
  }
}

class ConsultationMessageModel {
  final int id;
  final int senderId;
  final String message;
  final String? senderName;
  final DateTime createdAt;

  ConsultationMessageModel({
    required this.id,
    required this.senderId,
    required this.message,
    this.senderName,
    required this.createdAt,
  });

  factory ConsultationMessageModel.fromJson(Map<String, dynamic> json) {
    return ConsultationMessageModel(
      id: json['id'],
      senderId: json['sender_id'],
      message: json['message'],
      senderName: json['sender'] != null ? json['sender']['full_name'] : null,
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

class ConsultationAttachmentModel {
  final int id;
  final String fileUrl;
  final String fileType;
  final int? uploadedBy;
  final DateTime createdAt;

  ConsultationAttachmentModel({
    required this.id,
    required this.fileUrl,
    required this.fileType,
    this.uploadedBy,
    required this.createdAt,
  });

  factory ConsultationAttachmentModel.fromJson(Map<String, dynamic> json) {
    return ConsultationAttachmentModel(
      id: json['id'],
      fileUrl: json['file_url'],
      fileType: json['file_type'],
      uploadedBy: json['uploaded_by'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  String get fullUrl {
    if (fileUrl.startsWith('http')) return fileUrl;
    return '${ApiConstants.baseUrl}/storage/$fileUrl';
  }
}

class ConsultationQuoteModel {
  final int id;
  final double amount;
  final String? notes;
  final String status; // pending, accepted, rejected, revision
  final dynamic items;
  final String? revisionNotes;
  final DateTime createdAt;

  ConsultationQuoteModel({
    required this.id,
    required this.amount,
    this.notes,
    required this.status,
    this.items,
    this.revisionNotes,
    required this.createdAt,
  });

  factory ConsultationQuoteModel.fromJson(Map<String, dynamic> json) {
    dynamic parsedItems;
    if (json['items'] != null) {
      if (json['items'] is String) {
        try {
          parsedItems = jsonDecode(json['items']);
        } catch (e) {
          print("Error parsing items JSON: $e");
        }
      } else {
        parsedItems = json['items'];
      }
    }

    return ConsultationQuoteModel(
      id: json['id'],
      amount: double.parse(json['amount'].toString()),
      notes: json['notes'],
      status: json['status'],
      items: parsedItems,
      revisionNotes: json['revision_notes'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
