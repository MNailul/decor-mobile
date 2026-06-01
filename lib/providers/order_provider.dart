import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../models/order_model.dart';
import '../models/voucher_model.dart';
import '../services/api_service.dart';

class OrderProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<OrderModel> _orders = [];
  bool _isLoading = false;
  VoucherModel? _selectedVoucher;

  List<OrderModel> get orders => _orders;
  bool get isLoading => _isLoading;
  VoucherModel? get selectedVoucher => _selectedVoucher;

  void selectVoucher(VoucherModel? voucher) {
    _selectedVoucher = voucher;
    notifyListeners();
  }

  Future<List<VoucherModel>> getSellerVouchers(int sellerId) async {
    return await _apiService.fetchSellerVouchers(sellerId);
  }

  Future<bool> claimVoucher(int voucherId) async {
    return await _apiService.claimVoucher(voucherId);
  }

  Future<String?> applyVoucher(String code, int sellerId, double subtotal) async {
    try {
      final voucher = await _apiService.applyVoucher(code, sellerId);
      if (voucher == null) {
        return "Voucher tidak valid atau sudah kadaluarsa.";
      }

      if (subtotal < voucher.minPurchase) {
        return "Minimal belanja belum terpenuhi.";
      }

      _selectedVoucher = voucher;
      notifyListeners();
      return null; // Success
    } catch (e) {
      return "Terjadi kesalahan saat menerapkan voucher.";
    }
  }

  Future<void> loadOrders() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _orders = await _apiService.fetchOrders();
    } catch (e) {
      _errorMessage = "Gagal memuat pesanan: $e";
      print("Load Orders Error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Method baru untuk merefresh satu order saja
  Future<OrderModel?> refreshOrder(String orderId) async {
    try {
      // Cari index order lama
      final index = _orders.indexWhere((o) => o.id == orderId);
      
      // Ambil data terbaru dari API
      // Karena API kita belum punya endpoint detail order per ID yang spesifik (hanya /orders),
      // kita bisa fetch semua dan ambil yang ID-nya cocok, atau update loadOrders.
      // Namun biasanya lebih baik fetch all jika listnya tidak terlalu besar, 
      // atau jika backend ada endpoint show, kita pakai itu.
      
      // Cek di ApiService apakah ada show order
      // (Berdasarkan pengamatan, kita punya fetchOrders)
      final latestOrders = await _apiService.fetchOrders();
      _orders = latestOrders;
      
      final updatedOrder = _orders.firstWhere((o) => o.id == orderId);
      notifyListeners();
      return updatedOrder;
    } catch (e) {
      print("Refresh Order Error: $e");
      return null;
    }
  }

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<OrderModel?> placeOrder({
    required String paymentMethod,
    required String shippingCourier,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final order = await _apiService.createOrder(
        paymentMethod: paymentMethod,
        shippingCourier: shippingCourier,
        voucherId: _selectedVoucher?.id,
      );

      if (order != null) {
        _selectedVoucher = null; // Reset setelah checkout
        _orders.insert(0, order);
        _isLoading = false;
        notifyListeners();
        return order;
      }
    } on DioException catch (e) {
      if (e.response != null && e.response?.data != null) {
        _errorMessage = e.response?.data['message'] ?? e.message;
      } else {
        _errorMessage = e.message;
      }
      print("Place Order Error: $_errorMessage");
    } catch (e) {
      _errorMessage = e.toString();
      print("Place Order Error: $e");
    }

    _isLoading = false;
    notifyListeners();
    return null;
  }

  Future<bool> payOrder(String orderId, String proofPath) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final success = await _apiService.payOrder(orderId, proofPath);
      if (success) {
        final index = _orders.indexWhere((o) => o.id == orderId);
        if (index >= 0) {
          final oldOrder = _orders[index];
          _orders[index] = OrderModel(
            id: oldOrder.id,
            items: oldOrder.items,
            totalAmount: oldOrder.totalAmount,
            orderDate: oldOrder.orderDate,
            status: OrderStatus.awaiting_verification, // Now awaiting verification
            paymentMethod: oldOrder.paymentMethod,
            shippingCourier: oldOrder.shippingCourier,
          );
        }
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } on DioException catch (e) {
      if (e.response != null && e.response?.data != null) {
        _errorMessage = e.response?.data['message'] ?? e.message;
      } else {
        _errorMessage = e.message;
      }
      print("Pay Order Error: $_errorMessage");
    } catch (e) {
      _errorMessage = e.toString();
      print("Pay Order Error: $e");
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> completeOrder(String orderId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final success = await _apiService.completeOrder(orderId);
      if (success) {
        await loadOrders(); // Refresh status in list
      }
      return success;
    } on DioException catch (e) {
      if (e.response != null && e.response?.data != null) {
        _errorMessage = e.response?.data['message'] ?? e.message;
      } else {
        _errorMessage = e.message;
      }
      print("Complete Order Error: $_errorMessage");
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      print("Complete Order Error: $e");
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void updateOrderStatus(String orderId, OrderStatus status) {
    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index >= 0) {
      final oldOrder = _orders[index];
      _orders[index] = OrderModel(
        id: oldOrder.id,
        items: oldOrder.items,
        totalAmount: oldOrder.totalAmount,
        orderDate: oldOrder.orderDate,
        status: status,
        paymentMethod: oldOrder.paymentMethod,
        shippingCourier: oldOrder.shippingCourier,
      );
      notifyListeners();
    }
  }

  Future<bool> submitReview(int productId, int rating, String comment, {String? orderId}) async {
    _isLoading = true;
    notifyListeners();
    try {
      final success = await _apiService.submitReview(productId, rating, comment, orderId: orderId);
      if (success && orderId != null) {
        // Refresh orders to update hasReviewed status
        await loadOrders();
      }
      return success;
    } catch (e) {
      print("Submit review error: $e");
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
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
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final success = await _apiService.submitReturn(
        orderId: orderId,
        reason: reason,
        returnType: returnType,
        bankAccountNumber: bankAccountNumber,
        photoPath: photoPath,
        videoPath: videoPath,
      );
      if (success) {
        await loadOrders(); // Refresh status di list
      }
      return success;
    } on DioException catch (e) {
      if (e.response != null && e.response?.data != null) {
        _errorMessage = e.response?.data['message'] ?? e.message;
      } else {
        _errorMessage = e.message;
      }
      print("Submit return error: $_errorMessage");
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      print("Submit return error: $e");
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
