import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../services/api_service.dart';

class CartItem {
  int? id; // Database ID from Laravel
  final FurnitureProduct product;
  int quantity;
  bool isSelected;

  CartItem({this.id, required this.product, this.quantity = 1, this.isSelected = true});
}

class CartProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final List<CartItem> _items = [];
  bool _isLoading = false;

  CartProvider() {
    fetchCart();
  }

  List<CartItem> get items => _items;
  bool get isLoading => _isLoading;
  List<CartItem> get selectedItems => _items.where((item) => item.isSelected).toList();

  Future<void> fetchCart() async {
    _isLoading = true;
    notifyListeners();

    try {
      final cartData = await _apiService.fetchCart();
      _items.clear();
      if (cartData != null && cartData['cart_items'] != null) {
        for (var item in cartData['cart_items']) {
          // Map Laravel response to our model
          if (item['product'] != null) {
            final productModel = ProductModel.fromJson(item['product']);
            _items.add(CartItem(
              id: item['id'],
              product: productModel.toFurnitureProduct(),
              quantity: item['quantity'] ?? 1,
            ));
          }
        }
      }
    } catch (e) {
      print("Fetch Cart Error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addToCart(FurnitureProduct product, {int quantity = 1}) async {
    // Optimistic UI update or just wait for API? Let's do API first for consistency
    try {
      final productId = int.tryParse(product.id);
      if (productId == null) {
        // Handle dummy products locally if needed, or just print warning
        print("Warning: Cannot add dummy product with ID ${product.id} to backend cart.");
        return;
      }
      final success = await _apiService.addToCart(productId, quantity);
      if (success) {
        await fetchCart(); // Refresh to get the database ID
      }
    } catch (e) {
      print("Add to Cart Error: $e");
    }
  }

  Future<void> buyAgain(List<FurnitureProduct> products) async {
    _isLoading = true;
    notifyListeners();
    try {
      for (var product in products) {
        final productId = int.tryParse(product.id);
        if (productId != null) {
          await _apiService.addToCart(productId, 1);
        }
      }
      await fetchCart();
    } catch (e) {
      print("Buy Again Error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> removeFromCart(String productId) async {
    final index = _items.indexWhere((item) => item.product.id == productId);
    if (index >= 0) {
      final item = _items[index];
      // Optimistic update
      _items.removeAt(index);
      notifyListeners();

      if (item.id != null) {
        final success = await _apiService.removeFromCart(item.id!);
        if (!success) {
          // Re-fetch if API fails to keep sync
          await fetchCart();
        }
      }
    }
  }

  Future<void> incrementQuantity(String productId) async {
    try {
      final id = int.tryParse(productId);
      if (id == null) return;
      final success = await _apiService.addToCart(id, 1);
      if (success) {
        await fetchCart();
      }
    } catch (e) {
      print("Increment Error: $e");
    }
  }

  Future<void> decrementQuantity(String productId) async {
    final index = _items.indexWhere((item) => item.product.id == productId);
    if (index >= 0) {
      final item = _items[index];
      if (item.quantity > 1) {
        // Optimistic update
        item.quantity--;
        notifyListeners();

        if (item.id != null) {
          final success = await _apiService.updateCartQuantity(item.id!, item.quantity);
          if (!success) {
            // Revert or re-fetch on failure
            item.quantity++;
            notifyListeners();
            await fetchCart();
          }
        }
      } else {
        await removeFromCart(productId);
      }
    }
  }

  void toggleSelection(String productId) {
    final index = _items.indexWhere((item) => item.product.id == productId);
    if (index >= 0) {
      _items[index].isSelected = !_items[index].isSelected;
      notifyListeners();
    }
  }

  void toggleSelectAll(bool selectAll) {
    for (var item in _items) {
      item.isSelected = selectAll;
    }
    notifyListeners();
  }

  double get totalAmount {
    return _items.where((item) => item.isSelected).fold(0.0, (sum, item) => sum + (item.product.price * item.quantity));
  }

  int get selectedItemCount {
    return _items.where((item) => item.isSelected).fold(0, (sum, item) => sum + item.quantity);
  }

  int get itemCount {
    return _items.fold(0, (sum, item) => sum + item.quantity);
  }

  void clearSelectedItems() {
    _items.removeWhere((item) => item.isSelected);
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}

// Dummy catalog to populate from UI
final List<FurnitureProduct> dummyCatalog = [
  FurnitureProduct(
    id: 'p1',
    name: 'Terra Ambiance Chair',
    description: 'The Terra Ambiance Chair is a masterpiece of organic brutalism, balancing architectural precision with unparalleled comfort. Hand-finished walnut meets curated Belgian linen for a timeless presence in any modern living space.',
    price: 1250000,
    category: 'Chair',
    imagePath: 'https://images.unsplash.com/photo-1598300042247-d088f8ab3a91?w=400&q=80',
    material: 'Fabric',
    style: 'Modern',
    shopName: 'Aura Home',
  ),
  FurnitureProduct(
    id: 'p2',
    name: 'Sofa Minimalist Beige',
    description: 'Experience ultimate comfort with our Minimalist Beige Sofa. Designed for modern living, this sofa features premium fabric and a sturdy frame, making it the perfect centerpiece for your minimalist home decor.',
    price: 2500000,
    category: 'Sofa',
    imagePath: 'https://images.unsplash.com/photo-1493663284031-b7e3aefcae8e?w=400&q=80',
    material: 'Fabric',
    style: 'Minimalist',
    shopName: 'Urban Loft',
  ),
  FurnitureProduct(
    id: 'p3',
    name: 'Wooden Oak Table',
    description: 'Crafted from solid oak, this table brings the warmth of nature into your dining room. Its classic design and durable finish ensure it will be a gathering place for your family for generations to come.',
    price: 3750000,
    category: 'Table',
    imagePath: 'https://images.unsplash.com/photo-1577140917170-285929fb55b7?w=400&q=80',
    material: 'Oak',
    style: 'Classic',
    shopName: 'Nordic Wood',
  ),
  FurnitureProduct(
    id: 'p4',
    name: 'Lumina Pendant Light',
    description: 'Illuminate your space with the Lumina Pendant Light. Its sleek metal design and modern aesthetic provide sophisticated lighting for kitchens, dining areas, or office spaces.',
    price: 450000,
    category: 'Lighting',
    imagePath: 'https://images.unsplash.com/photo-1565814329452-e1efa11c5b89?w=400&q=80',
    material: 'Metal',
    style: 'Modern',
    shopName: 'Glow Studio',
  ),
  FurnitureProduct(
    id: 'p5',
    name: 'Velvet Accent Chair',
    description: 'Add a touch of luxury with the Velvet Accent Chair. The plush velvet upholstery and classic silhouette offer both style and comfort, perfect for a reading nook or as a statement piece.',
    price: 1850000,
    category: 'Chair',
    imagePath: 'https://images.unsplash.com/photo-1580480055273-228ff5388ef8?w=400&q=80',
    material: 'Fabric',
    style: 'Classic',
    shopName: 'Velvet & Co',
  ),
  FurnitureProduct(
    id: 'p6',
    name: 'Cloud Lounge Sofa',
    description: 'Sink into the Cloud Lounge Sofa, designed for maximum relaxation. Its deep seats and soft fabric create a cloud-like experience, perfect for cozy movie nights and lazy afternoons.',
    price: 4200000,
    category: 'Sofa',
    imagePath: 'https://images.unsplash.com/photo-1555041469-a586c61ea9bc?w=400&q=80',
    material: 'Fabric',
    style: 'Modern',
    shopName: 'Urban Loft',
  ),
];
