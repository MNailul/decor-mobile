import 'package:flutter/material.dart';

enum ConsultationStatus { pending, scheduled, completed, cancelled }

class ConsultationModel {
  final String id;
  final String designerName;
  final String designerImage;
  final String consultationType;
  final DateTime date;
  final String time;
  final double totalPrice;
  final double paidAmount;
  final bool isFullPayment;
  final ConsultationStatus status;
  final String? projectBrief;

  ConsultationModel({
    required this.id,
    required this.designerName,
    required this.designerImage,
    required this.consultationType,
    required this.date,
    required this.time,
    required this.totalPrice,
    required this.paidAmount,
    required this.isFullPayment,
    this.status = ConsultationStatus.scheduled,
    this.projectBrief,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'designerName': designerName,
      'designerImage': designerImage,
      'consultationType': consultationType,
      'date': date.toIso8601String(),
      'time': time,
      'totalPrice': totalPrice,
      'paidAmount': paidAmount,
      'isFullPayment': isFullPayment,
      'status': status.name,
      'projectBrief': projectBrief,
    };
  }

  factory ConsultationModel.fromMap(Map<String, dynamic> map) {
    return ConsultationModel(
      id: map['id'],
      designerName: map['designerName'],
      designerImage: map['designerImage'],
      consultationType: map['consultationType'],
      date: DateTime.parse(map['date']),
      time: map['time'],
      totalPrice: map['totalPrice'],
      paidAmount: map['paidAmount'],
      isFullPayment: map['isFullPayment'],
      status: ConsultationStatus.values.firstWhere((e) => e.name == map['status']),
      projectBrief: map['projectBrief'],
    );
  }
}
