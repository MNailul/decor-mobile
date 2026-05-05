class ProductModel {
  final int id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;

  ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'],
      name: json['name'],
      description: json['description'] ?? '',
      price: (json['price'] as num).toDouble(),
      imageUrl: json['image_url'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'image_url': imageUrl,
    };
  }
}

// Keeping FurnitureProduct for backward compatibility with existing views
class FurnitureProduct {
  final String id;
  final String name;
  final double price;
  final String category;
  final String imagePath;
  final String material;
  final String style;
  final String shopName;

  FurnitureProduct({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    required this.imagePath,
    this.material = 'Oak',
    this.style = 'Modern',
    this.shopName = 'Decor Official',
  });
}
