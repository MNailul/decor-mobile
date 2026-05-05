 import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/product_model.dart';

class ApiService {
  final Dio _dio = Dio();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  
  // Placeholder baseUrl for local testing
  final String baseUrl = "http://192.168.1.100:8000/api";

  ApiService() {
    _dio.options.baseUrl = baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 5);
    _dio.options.receiveTimeout = const Duration(seconds: 3);

    // Interceptor to add Bearer Token
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.read(key: 'auth_token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) {
          print('Dio Error: ${e.message}');
          if (e.response != null) {
            print('Status Code: ${e.response?.statusCode}');
            print('Data: ${e.response?.data}');
          }
          return handler.next(e);
        },
      ),
    );
  }

  Future<List<ProductModel>> fetchProducts() async {
    try {
      final response = await _dio.get('/products');
      
      if (response.statusCode == 200) {
        List<dynamic> data = response.data;
        return data.map((json) => ProductModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load products');
      }
    } on DioException catch (e) {
      print('Fetch Products Error: ${e.message}');
      rethrow;
    } catch (e) {
      print('Unexpected Error: $e');
      rethrow;
    }
  }
}
