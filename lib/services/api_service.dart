import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/product_model.dart';
import '../models/order_model.dart';
import '../models/chat_model.dart';
import '../models/user_model.dart';
import '../models/voucher_model.dart';
import '../core/constants.dart';

class ApiService {
  final Dio _dio = Dio();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // Use centralized base URL
  final String baseUrl = ApiConstants.baseUrl;

  ApiService() {
    _dio.options.baseUrl = baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);

    // Interceptor to add Bearer Token
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.read(key: 'auth_token');
          options.headers['Accept'] = 'application/json';
          options.headers['ngrok-skip-browser-warning'] = 'true';
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
      final response = await _dio.get('/api/products');

      if (response.statusCode == 200) {
        // Accessing 'data' field from Laravel's successResponse
        List<dynamic> data = response.data['data'];
        return data.map((json) => ProductModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load products');
      }
    } on DioException catch (e) {
      print('Fetch Products Error: ${e.message}');
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> fetchProductDetail(int productId) async {
    try {
      final response = await _dio.get('/api/products/$productId');
      if (response.statusCode == 200) {
        return response.data['data'];
      }
      return null;
    } catch (e) {
      print('Fetch Product Detail Error: $e');
      return null;
    }
  }

  // --- ORDERS ---

  Future<List<OrderModel>> fetchOrders() async {
    try {
      final response = await _dio.get('/api/orders');
      if (response.statusCode == 200) {
        List<dynamic> data = response.data['data'];
        return data.map((json) => OrderModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print("Error fetching orders: $e");
      return [];
    }
  }

  Future<OrderModel?> createOrder({
    required String paymentMethod,
    required String shippingCourier,
    int? voucherId,
  }) async {
    try {
      final response = await _dio.post(
        '/api/checkout',
        data: {
          'payment_method': paymentMethod,
          'shipping_courier': shippingCourier,
          if (voucherId != null) 'voucher_id': voucherId,
        },
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return OrderModel.fromJson(response.data['data']);
      }
      return null;
    } catch (e) {
      print("Error creating order: $e");
      rethrow;
    }
  }

  // --- VOUCHERS ---

  Future<List<VoucherModel>> fetchSellerVouchers(int sellerId) async {
    try {
      final response = await _dio.get('/api/vouchers/seller/$sellerId');
      if (response.statusCode == 200) {
        List<dynamic> data = response.data['data'];
        return data.map((json) => VoucherModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print("Error fetching seller vouchers: $e");
      return [];
    }
  }

  Future<bool> claimVoucher(int voucherId) async {
    try {
      final response = await _dio.post('/api/vouchers/claim/$voucherId');
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print("Error claiming voucher: $e");
      return false;
    }
  }

  Future<VoucherModel?> applyVoucher(String code, int sellerId) async {
    try {
      final response = await _dio.post('/api/vouchers/apply', data: {
        'code': code,
        'seller_id': sellerId,
      });
      if (response.statusCode == 200) {
        return VoucherModel.fromJson(response.data['data']);
      }
      return null;
    } catch (e) {
      print("Error applying voucher: $e");
      return null;
    }
  }

  Future<bool> payOrder(String orderId, String proofImagePath) async {
    try {
      // Use RegExp to handle both / and \ (Windows)
      String fileName = proofImagePath.split(RegExp(r'[/\\]')).last;
      
      FormData formData = FormData.fromMap({
        "payment_proof": await MultipartFile.fromFile(
          proofImagePath, 
          filename: fileName,
        ),
      });

      final response = await _dio.post(
        '/api/orders/$orderId/pay',
        data: formData,
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } on DioException catch (e) {
      print("Error paying order: ${e.response?.data ?? e.message}");
      rethrow; // Rethrow to allow provider to capture error message
    } catch (e) {
      print("Error paying order: $e");
      return false;
    }
  }

  Future<bool> completeOrder(String orderId) async {
    try {
      final response = await _dio.post('/api/orders/$orderId/received');
      return response.statusCode == 200 || response.statusCode == 201;
    } on DioException catch (e) {
      print("Error completing order: ${e.response?.data ?? e.message}");
      rethrow;
    } catch (e) {
      print("Error completing order: $e");
      return false;
    }
  }

  Future<bool> submitReturn({
    required String orderId,
    required String reason,
    required String returnType,
    String? bankAccountNumber,
    String? photoPath,
    String? videoPath,
  }) async {
    try {
      FormData formData = FormData.fromMap({
        'reason': reason,
        'return_type': returnType,
        if (bankAccountNumber != null) 'bank_account_number': bankAccountNumber,
      });

      if (photoPath != null) {
        String photoName = photoPath.split(RegExp(r'[/\\]')).last;
        formData.files.add(MapEntry(
          'photo_proof',
          await MultipartFile.fromFile(photoPath, filename: photoName),
        ));
      }

      if (videoPath != null) {
        String videoName = videoPath.split(RegExp(r'[/\\]')).last;
        formData.files.add(MapEntry(
          'video_proof',
          await MultipartFile.fromFile(videoPath, filename: videoName),
        ));
      }

      final response = await _dio.post('/api/orders/$orderId/return', data: formData);
      return response.statusCode == 200 || response.statusCode == 201;
    } on DioException catch (e) {
      print("Error submitting return: ${e.response?.data ?? e.message}");
      rethrow;
    } catch (e) {
      print("Error submitting return: $e");
      return false;
    }
  }

  // --- CART ---

  Future<Map<String, dynamic>?> fetchCart() async {
    try {
      final response = await _dio.get('/api/cart');
      if (response.statusCode == 200) {
        return response.data['data'] is Map<String, dynamic> 
            ? response.data['data'] 
            : null;
      }
      return null;
    } catch (e) {
      print("Error fetching cart: $e");
      return null;
    }
  }

  Future<bool> addToCart(int productId, int quantity) async {
    try {
      final response = await _dio.post('/api/cart/add', data: {
        'product_id': productId,
        'quantity': quantity,
      });
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print("Error adding to cart: $e");
      return false;
    }
  }

  Future<bool> updateCartQuantity(int cartId, int quantity) async {
    try {
      final response = await _dio.put('/api/cart/$cartId', data: {
        'quantity': quantity,
      });
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      print("Error updating cart: $e");
      return false;
    }
  }

  Future<bool> removeFromCart(int cartId) async {
    try {
      final response = await _dio.delete('/api/cart/$cartId');
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      print("Error removing from cart: $e");
      return false;
    }
  }

  // --- REVIEWS ---

  Future<bool> submitReview(int productId, int rating, String comment, {String? orderId}) async {
    try {
      final response = await _dio.post(
        '/api/products/$productId/reviews',
        data: {
          'rating': rating,
          'comment': comment,
          if (orderId != null) 'order_id': orderId,
        },
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print("Error submitting review: $e");
      return false;
    }
  }
  // --- ADDRESSES ---

  Future<List<Map<String, dynamic>>> fetchAddresses() async {
    try {
      final response = await _dio.get('/api/address-list');
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data['data']);
      }
      return [];
    } catch (e) {
      print("Error fetching addresses: $e");
      return [];
    }
  }

  Future<Map<String, dynamic>?> createAddress(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('/api/addresses', data: data);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data['data'];
      }
      return null;
    } catch (e) {
      print("Error creating address: $e");
      return null;
    }
  }

  Future<Map<String, dynamic>?> updateAddress(String id, Map<String, dynamic> data) async {
    try {
      final response = await _dio.put('/api/addresses/$id', data: data);
      if (response.statusCode == 200) {
        return response.data['data'];
      }
      return null;
    } catch (e) {
      print("Error updating address: $e");
      return null;
    }
  }

  Future<bool> deleteAddress(String id) async {
    try {
      final response = await _dio.delete('/api/addresses/$id');
      return response.statusCode == 200;
    } catch (e) {
      print("Error deleting address: $e");
      return false;
    }
  }

  // --- SELLERS ---

  Future<Map<String, dynamic>?> fetchSellerStore(int sellerId) async {
    try {
      final response = await _dio.get('/api/sellers/$sellerId');
      if (response.statusCode == 200) {
        return response.data['data'];
      }
      return null;
    } catch (e) {
      print("Error fetching seller store: $e");
      return null;
    }
  }

  // --- CHATS ---

  Future<List<User>> fetchConversations() async {
    try {
      final response = await _dio.get('/api/chats/conversations');
      if (response.statusCode == 200) {
        List<dynamic> data = response.data['data'];
        return data.map((json) => User.fromJson(json)).toList();
      }
      throw Exception('Failed to load conversations');
    } catch (e) {
      print('Fetch Conversations Error: $e');
      rethrow;
    }
  }

  Future<List<ChatModel>> fetchMessages(int receiverId) async {
    try {
      final response = await _dio.get('/api/chats/$receiverId');
      if (response.statusCode == 200) {
        List<dynamic> data = response.data['data'];
        return data.map((json) => ChatModel.fromJson(json)).toList();
      }
      throw Exception('Failed to load messages');
    } catch (e) {
      print('Fetch Messages Error: $e');
      rethrow;
    }
  }

  Future<ChatModel> sendMessage(int receiverId, String message, {int? productId}) async {
    try {
      final response = await _dio.post('/api/chats/send', data: {
        'receiver_id': receiverId,
        'message': message,
        'product_id': productId,
      });
      if (response.statusCode == 200 || response.statusCode == 201) {
        return ChatModel.fromJson(response.data['data']);
      }
      throw Exception('Failed to send message');
    } catch (e) {
      print('Send Message Error: $e');
      rethrow;
    }
  }

  // --- DESIGNERS ---

  Future<List<Map<String, dynamic>>> fetchDesigners() async {
    try {
      final response = await _dio.get('/api/designers');
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data['data']);
      }
      return [];
    } catch (e) {
      print("Error fetching designers: $e");
      return [];
    }
  }

  Future<Map<String, dynamic>?> fetchDesignerDetail(int id) async {
    try {
      final response = await _dio.get('/api/designers/$id');
      if (response.statusCode == 200) {
        return response.data['data'];
      }
      return null;
    } catch (e) {
      print("Error fetching designer detail: $e");
      return null;
    }
  }
  // --- CONSULTATIONS ---

  Future<List<Map<String, dynamic>>> fetchConsultations() async {
    try {
      final response = await _dio.get('/api/consultations');
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data['data']);
      }
      return [];
    } catch (e) {
      print("Error fetching consultations: $e");
      return [];
    }
  }

  Future<Map<String, dynamic>?> startFreeChat(int designerId) async {
    try {
      final response = await _dio.post('/api/consultations/$designerId/free-chat');
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data['data'];
      }
      return null;
    } catch (e) {
      print("Error starting free chat: $e");
      return null;
    }
  }

  Future<Map<String, dynamic>?> bookConsultation({
    required int designerId,
    required String title,
    required String description,
    required String budgetRange,
    String? consultationType,
  }) async {
    try {
      final response = await _dio.post('/api/consultations', data: {
        'designer_id': designerId,
        'title': title,
        'description': description,
        'budget_range': budgetRange,
        if (consultationType != null) 'consultation_type': consultationType,
      });
      if (response.statusCode == 201) {
        return response.data['data'];
      }
      return null;
    } catch (e) {
      print("Error booking consultation: $e");
      return null;
    }
  }

  Future<Map<String, dynamic>?> fetchConsultationDetail(int id) async {
    try {
      final response = await _dio.get('/api/consultations/$id');
      if (response.statusCode == 200) {
        return response.data['data'];
      }
      return null;
    } catch (e) {
      print("Error fetching consultation detail: $e");
      return null;
    }
  }

  Future<bool> sendConsultationMessage(int consultationId, String message) async {
    try {
      final response = await _dio.post('/api/consultations/$consultationId/messages', data: {
        'message': message,
      });
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print("Error sending consultation message: $e");
      return false;
    }
  }

  Future<bool> uploadConsultationAttachment(int consultationId, String filePath, String fileType) async {
    try {
      String fileName = filePath.split('/').last;
      FormData formData = FormData.fromMap({
        "file": await MultipartFile.fromFile(filePath, filename: fileName),
        "file_type": fileType,
      });

      final response = await _dio.post(
        '/api/consultations/$consultationId/attachments',
        data: formData,
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print("Error uploading consultation attachment: $e");
      return false;
    }
  }

  Future<bool> payConsultation(int consultationId, String proofImagePath) async {
    try {
      final String fileName = proofImagePath.split(RegExp(r'[/\\]')).last;
      final FormData formData = FormData.fromMap({
        'payment_proof': await MultipartFile.fromFile(proofImagePath, filename: fileName),
      });
      final response = await _dio.post(
        '/api/consultations/$consultationId/pay',
        data: formData,
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } on DioException catch (e) {
      print("Error paying consultation: ${e.response?.data ?? e.message}");
      rethrow;
    } catch (e) {
      print("Error paying consultation: $e");
      return false;
    }
  }

  Future<bool> submitBrief(int consultationId, String description) async {
    try {
      final response = await _dio.post('/api/consultations/$consultationId/submit-brief', data: {
        'description': description,
      });
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print("Error submitting brief: $e");
      return false;
    }
  }

  Future<bool> respondToQuote(int quoteId, String status, {String? revisionNotes}) async {
    try {
      final response = await _dio.post('/api/quotes/$quoteId/respond', data: {
        'status': status,
        if (revisionNotes != null) 'revision_notes': revisionNotes,
      });
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      try {
        print("Error response body: ${(e as dynamic).response?.data}");
      } catch (_) {}
      print("Error responding to quote: $e");
      return false;
    }
  }

  Future<bool> submitConsultationReview(int consultationId, int rating, String comment, String projectDuration) async {
    try {
      final response = await _dio.post('/api/consultations/$consultationId/review', data: {
        'rating': rating,
        'comment': comment,
        'project_duration': projectDuration,
      });
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print("Error submitting consultation review: $e");
      return false;
    }
  }

  Future<Map<String, dynamic>> generateRoomDesign({
    required String imagePath,
    required String roomType,
    required String style,
  }) async {
    try {
      final formData = FormData.fromMap({
        'room_image': await MultipartFile.fromFile(
          imagePath,
          filename: imagePath.split('/').last,
        ),
        'room_type': roomType,
        'style': style,
      });

      final response = await _dio.post(
        '/api/generate-room',
        data: formData,
      );

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        return {
          'success': false,
          'message': 'Failed to generate room design: ${response.statusMessage}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  // --- SUPPORTS / HELP CENTER ---

  Future<List<Map<String, dynamic>>> fetchSupports() async {
    try {
      final response = await _dio.get('/api/supports');
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data['data']);
      }
      return [];
    } catch (e) {
      print("Error fetching supports: $e");
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> submitSupport({
    required String subject,
    required String message,
  }) async {
    try {
      final response = await _dio.post('/api/supports', data: {
        'subject': subject,
        'message': message,
      });
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data['data'];
      }
      return null;
    } catch (e) {
      print("Error submitting support: $e");
      rethrow;
    }
  }
}

