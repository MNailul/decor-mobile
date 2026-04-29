import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  User? _currentUser;
  bool _isLoading = false;

  User? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  bool get isLoading => _isLoading;

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    final user = await _authService.login(email, password);
    _currentUser = user;
    
    _isLoading = false;
    notifyListeners();
    return user != null;
  }

  Future<bool> register(String fullName, String email, String password, String phone) async {
    _isLoading = true;
    notifyListeners();

    final user = await _authService.register(fullName, email, password, phone);
    _currentUser = user;
    
    _isLoading = false;
    notifyListeners();
    return user != null;
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }

  Future<void> updateProfile({
    String? fullName,
    String? email,
    String? phone,
    String? profilePicture,
  }) async {
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(
        fullName: fullName,
        email: email,
        phone: phone,
        profilePicture: profilePicture,
      );
      await _authService.updateUser(_currentUser!);
      notifyListeners();
    }
  }
}
