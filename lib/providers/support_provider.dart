import 'package:flutter/material.dart';
import '../models/support_model.dart';
import '../services/api_service.dart';

class SupportProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<SupportModel> _supports = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<SupportModel> get supports => _supports;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadSupports() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final List<Map<String, dynamic>> supportData = await _apiService.fetchSupports();
      _supports = supportData.map((json) => SupportModel.fromJson(json)).toList();
    } catch (e) {
      _errorMessage = e.toString();
      print("Error loading supports: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> submitSupport({
    required String subject,
    required String message,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _apiService.submitSupport(
        subject: subject,
        message: message,
      );
      if (result != null) {
        // Insert new support at the beginning of the list
        _supports.insert(0, SupportModel.fromJson(result));
        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      print("Error submitting support: $e");
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
