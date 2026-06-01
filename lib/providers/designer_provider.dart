import 'package:flutter/material.dart';
import '../models/designer_model.dart';
import '../services/api_service.dart';

class DesignerProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<DesignerModel> _designers = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<DesignerModel> get designers => _designers;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadDesigners() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final List<Map<String, dynamic>> designerData = await _apiService.fetchDesigners();
      _designers = designerData.map((json) => DesignerModel.fromJson(json)).toList();
    } catch (e) {
      _errorMessage = e.toString();
      print("Error loading designers: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<DesignerModel?> getDesignerDetail(int id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final Map<String, dynamic>? designerData = await _apiService.fetchDesignerDetail(id);
      if (designerData != null) {
        return DesignerModel.fromJson(designerData);
      }
      return null;
    } catch (e) {
      _errorMessage = e.toString();
      print("Error loading designer detail: $e");
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>?> startFreeChat(int designerId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _apiService.startFreeChat(designerId);
      return result;
    } catch (e) {
      _errorMessage = e.toString();
      print("Error starting free chat: $e");
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
