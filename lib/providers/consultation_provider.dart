import 'package:flutter/material.dart';
import '../models/consultation_model.dart';

class ConsultationProvider with ChangeNotifier {
  final List<ConsultationModel> _consultations = [];

  List<ConsultationModel> get consultations => [..._consultations];

  void addConsultation(ConsultationModel consultation) {
    _consultations.insert(0, consultation);
    notifyListeners();
  }

  void updateConsultationStatus(String id, ConsultationStatus newStatus) {
    final index = _consultations.indexWhere((c) => c.id == id);
    if (index != -1) {
      final old = _consultations[index];
      _consultations[index] = ConsultationModel(
        id: old.id,
        designerName: old.designerName,
        designerImage: old.designerImage,
        consultationType: old.consultationType,
        date: old.date,
        time: old.time,
        totalPrice: old.totalPrice,
        paidAmount: old.paidAmount,
        isFullPayment: old.isFullPayment,
        status: newStatus,
        projectBrief: old.projectBrief,
      );
      notifyListeners();
    }
  }
}
