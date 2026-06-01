import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user_model.dart';
import '../core/constants.dart';

class AuthService {
  final Dio _dio = Dio();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  
  // Use centralized base URL
  final String baseUrl = ApiConstants.baseUrl;

  AuthService() {
    _dio.options.baseUrl = baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 15);
    _dio.options.receiveTimeout = const Duration(seconds: 15);
    _dio.options.headers['Accept'] = 'application/json';
    _dio.options.headers['ngrok-skip-browser-warning'] = 'true';
  }

  Future<User?> login(String email, String password) async {
    try {
      final response = await _dio.post('/api/login', data: {
        'email': email,
        'password': password,
      });

      if (response.statusCode == 200) {
        final data = response.data['data'];
        final token = data['token'];
        final userData = data['user'];

        // Save token
        await _storage.write(key: 'auth_token', value: token);
        
        return User.fromJson(userData);
      }
    } catch (e) {
      print('Login Error: $e');
    }
    return null;
  }

  Future<User?> register({
    required String username,
    required String fullName,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    try {
      final response = await _dio.post(
        '/api/register', 
        data: {
          'username': username,
          'full_name': fullName,
          'email': email,
          'password': password,
          'password_confirmation': confirmPassword,
        },
        options: Options(headers: {'Accept': 'application/json'}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data['data'];
        final token = data['token'];
        final userData = data['user'];

        // Save token
        await _storage.write(key: 'auth_token', value: token);
        
        return User.fromJson(userData);
      }
    } catch (e) {
      print('Register Error: $e');
    }
    return null;
  }

  Future<void> logout() async {
    try {
      final token = await _storage.read(key: 'auth_token');
      await _dio.post('/api/logout', options: Options(headers: {
        'Authorization': 'Bearer $token',
      }));
    } catch (e) {
      print('Logout Error: $e');
    } finally {
      await _storage.delete(key: 'auth_token');
    }
  }

  // Placeholder for future profile updates
  Future<bool> updateUser(User updatedUser) async {
    try {
      final token = await _storage.read(key: 'auth_token');
      final response = await _dio.post(
        '/api/profile/update',
        data: {
          'full_name': updatedUser.fullName,
          'phone': updatedUser.phone,
          'address': updatedUser.address,
          'city': updatedUser.city,
        },
        options: Options(headers: {
          'Authorization': 'Bearer $token',
        }),
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Update User Error: $e');
      return false;
    }
  }

  Future<String?> uploadProfilePicture(String filePath) async {
    try {
      final token = await _storage.read(key: 'auth_token');
      
      String fileName = filePath.split('/').last;
      FormData formData = FormData.fromMap({
        "profile_image": await MultipartFile.fromFile(filePath, filename: fileName),
      });

      final response = await _dio.post(
        '/api/profile/update',
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        return response.data['data']['profile_image'];
      }
    } catch (e) {
      print('Upload Profile Picture Error: $e');
    }
    return null;
  }

  Future<User?> getProfile() async {
    try {
      final token = await _storage.read(key: 'auth_token');
      final response = await _dio.get(
        '/api/profile',
        options: Options(headers: {
          'Authorization': 'Bearer $token',
        }),
      );

      if (response.statusCode == 200) {
        return User.fromJson(response.data['data']);
      }
    } catch (e) {
      print('Get Profile Error: $e');
    }
    return null;
  }
}
