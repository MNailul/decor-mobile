import 'package:flutter/material.dart';
import '../models/product_model.dart';

class CartItem {
  final FurnitureProduct product;
  int quantity;
  bool isSelected;

  CartItem({required this.product, this.quantity = 1, this.isSelected = true});
}

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];

  CartProvider() {
    // Initialize with an empty cart as requested
  }

  List<CartItem> get items => _items;
  List<CartItem> get selectedItems => _items.where((item) => item.isSelected).toList();

  void addToCart(FurnitureProduct product, {int quantity = 1}) {
    final existingIndex = _items.indexWhere((item) => item.product.id == product.id);
    if (existingIndex >= 0) {
      _items[existingIndex].quantity += quantity;
    } else {
      _items.add(CartItem(product: product, quantity: quantity));
    }
    notifyListeners();
  }

  void removeFromCart(String productId) {
    _items.removeWhere((item) => item.product.id == productId);
    notifyListeners();
  }

  void incrementQuantity(String productId) {
    final index = _items.indexWhere((item) => item.product.id == productId);
    if (index >= 0) {
      _items[index].quantity++;
      notifyListeners();
    }
  }

  void decrementQuantity(String productId) {
    final index = _items.indexWhere((item) => item.product.id == productId);
    if (index >= 0) {
      if (_items[index].quantity > 1) {
        _items[index].quantity--;
      } else {
        _items.removeAt(index);
      }
      notifyListeners();
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
    price: 84.00,
    category: 'Chair',
    imagePath: 'https://images.unsplash.com/photo-1598300042247-d088f8ab3a91?w=400&q=80',
    material: 'Fabric',
    style: 'Modern',
    shopName: 'Aura Home',
  ),
  FurnitureProduct(
    id: 'p2',
    name: 'Sofa Minimalist Beige',
    price: 150.00,
    category: 'Sofa',
    imagePath: 'https://images.unsplash.com/photo-1493663284031-b7e3aefcae8e?w=400&q=80',
    material: 'Fabric',
    style: 'Minimalist',
    shopName: 'Urban Loft',
  ),
  FurnitureProduct(
    id: 'p3',
    name: 'Wooden Oak Table',
    price: 220.00,
    category: 'Table',
    imagePath: 'https://images.unsplash.com/photo-1577140917170-285929fb55b7?w=400&q=80',
    material: 'Oak',
    style: 'Classic',
    shopName: 'Nordic Wood',
  ),
  FurnitureProduct(
    id: 'p4',
    name: 'Lumina Pendant Light',
    price: 45.00,
    category: 'Lighting',
    imagePath: 'https://images.unsplash.com/photo-1565814329452-e1efa11c5b89?w=400&q=80',
    material: 'Metal',
    style: 'Modern',
    shopName: 'Glow Studio',
  ),
  FurnitureProduct(
    id: 'p5',
    name: 'Velvet Accent Chair',
    price: 110.00,
    category: 'Chair',
    imagePath: 'https://images.unsplash.com/photo-1580480055273-228ff5388ef8?w=400&q=80',
    material: 'Fabric',
    style: 'Classic',
    shopName: 'Velvet & Co',
  ),
  FurnitureProduct(
    id: 'p6',
    name: 'Cloud Lounge Sofa',
    price: 340.00,
    category: 'Sofa',
    imagePath: 'https://images.unsplash.com/photo-1555041469-a586c61ea9bc?w=400&q=80',
    material: 'Fabric',
    style: 'Modern',
    shopName: 'Urban Loft',
  ),
];
