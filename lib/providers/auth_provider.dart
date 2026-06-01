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

  Future<bool> register({
    required String username,
    required String fullName,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    _isLoading = true;
    notifyListeners();

    final user = await _authService.register(
      username: username,
      fullName: fullName,
      email: email,
      password: password,
      confirmPassword: confirmPassword,
    );
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
    String? address,
    String? city,
    String? profilePicture,
  }) async {
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(
        fullName: fullName,
        email: email,
        phone: phone,
        address: address,
        city: city,
        profilePicture: profilePicture,
      );
      await _authService.updateUser(_currentUser!);
      notifyListeners();
    }
  }

  Future<bool> uploadProfilePicture(String filePath) async {
    _isLoading = true;
    notifyListeners();

    final imageUrl = await _authService.uploadProfilePicture(filePath);
    
    if (imageUrl != null && _currentUser != null) {
      _currentUser = _currentUser!.copyWith(profilePicture: imageUrl);
      _isLoading = false;
      notifyListeners();
      return true;
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<void> refreshProfile() async {
    _isLoading = true;
    notifyListeners();

    final user = await _authService.getProfile();
    if (user != null) {
      _currentUser = user;
    }

    _isLoading = false;
    notifyListeners();
  }
}
