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
    this.material = 'Oak', // Default value
    this.style = 'Modern', // Default value
    this.shopName = 'Decor Official', // Default value
  });
}
