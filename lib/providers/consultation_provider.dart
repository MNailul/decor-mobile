import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/consultation_model.dart';

class ConsultationProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  List<ConsultationModel> _consultations = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<ConsultationModel> get consultations => _consultations;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadConsultations() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = await _apiService.fetchConsultations();
      _consultations = data.map((json) => ConsultationModel.fromJson(json)).toList();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> bookConsultation({
    required int designerId,
    required String title,
    required String description,
    required String budgetRange,
    String? consultationType,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _apiService.bookConsultation(
        designerId: designerId,
        title: title,
        description: description,
        budgetRange: budgetRange,
        consultationType: consultationType,
      );
      if (result != null) {
        await loadConsultations();
        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<ConsultationModel?> getConsultationDetail(int id) async {
    try {
      final data = await _apiService.fetchConsultationDetail(id);
      if (data != null) {
        return ConsultationModel.fromJson(data);
      }
      return null;
    } catch (e) {
      print("Error detail: $e");
      return null;
    }
  }

  Future<bool> sendMessage(int id, String message) async {
    return await _apiService.sendConsultationMessage(id, message);
  }

  Future<bool> uploadAttachment(int id, String filePath, String fileType) async {
    return await _apiService.uploadConsultationAttachment(id, filePath, fileType);
  }

  Future<bool> payConsultation(int id, String proofImagePath) async {
    final success = await _apiService.payConsultation(id, proofImagePath);
    if (success) {
      await loadConsultations();
    }
    return success;
  }

  Future<bool> submitBrief(int id, String description) async {
    final success = await _apiService.submitBrief(id, description);
    if (success) {
      await loadConsultations();
    }
    return success;
  }

  Future<bool> respondToQuote(int quoteId, String status, {String? revisionNotes}) async {
    final success = await _apiService.respondToQuote(quoteId, status, revisionNotes: revisionNotes);
    if (success) {
      await loadConsultations();
    }
    return success;
  }

  Future<bool> submitConsultationReview(int consultationId, int rating, String comment, String projectDuration) async {
    final success = await _apiService.submitConsultationReview(consultationId, rating, comment, projectDuration);
    if (success) {
      await loadConsultations();
    }
    return success;
  }
}
