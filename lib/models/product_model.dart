import '../core/constants.dart';

class ReviewModel {
  final int id;
  final String customerName;
  final String? customerImage;
  final int rating;
  final String comment;
  final String? reply;

  ReviewModel({
    required this.id,
    required this.customerName,
    this.customerImage,
    required this.rating,
    required this.comment,
    this.reply,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    String name = 'Anonymous';
    String? imageUrl;
    if (json['customer'] != null) {
      if (json['customer']['user'] != null) {
        name = json['customer']['user']['full_name'] ?? 'Anonymous';
      }
      
      String? rawPath = json['customer']['profile_image'];
      if (rawPath != null && rawPath.isNotEmpty) {
        if (rawPath.startsWith('http')) {
          imageUrl = rawPath;
        } else {
          imageUrl = "${ApiConstants.baseUrl}/storage/$rawPath";
        }
      } else {
        // Fallback to dicebear using name
        imageUrl = "https://api.dicebear.com/7.x/avataaars/svg?seed=${Uri.encodeComponent(name)}";
      }
    }
    
    int rawRating = 5;
    if (json['rating'] != null) {
      if (json['rating'] is String) {
        rawRating = int.tryParse(json['rating']) ?? 5;
      } else {
        rawRating = (json['rating'] as num).toInt();
      }
    }

    return ReviewModel(
      id: json['id'] != null ? int.tryParse(json['id'].toString()) ?? 0 : 0,
      customerName: name,
      customerImage: imageUrl,
      rating: rawRating,
      comment: json['comment'] ?? '',
      reply: json['reply']?.toString(),
    );
  }
}

class ProductModel {
  final int id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final String category;
  final String style;
  final String shopName;
  final String shopLogo;
  final String shopBanner;
  final String shopDescription;
  final int sellerId;
  final int sellerUserId;
  final List<ReviewModel> reviews;

  ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    this.category = 'Sofa',
    this.style = 'Modern',
    this.shopName = 'Decor Official',
    this.shopLogo = '',
    this.shopBanner = '',
    this.shopDescription = '',
    this.sellerId = 1,
    this.sellerUserId = 1,
    this.reviews = const [],
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    // The base URL of your Laravel server
    final String baseUrl = ApiConstants.rootUrl;

    double rawPrice = 0;
    if (json['price'] != null) {
      if (json['price'] is String) {
        rawPrice = double.tryParse(json['price']) ?? 0;
      } else {
        rawPrice = (json['price'] as num).toDouble();
      }
    }
    
    // If the price is very low (e.g., < 10000), it's likely in USD and needs conversion to IDR
    double finalPrice = rawPrice < 10000 ? rawPrice * 15000 : rawPrice;
    
    // Handle Laravel images relationship
    String firstImage = '';
    if (json['images'] != null && (json['images'] as List).isNotEmpty) {
      firstImage = json['images'][0]['img_url'] ?? '';
    } else {
      firstImage = json['image_url'] ?? ''; // Fallback
    }

    // Fix relative image paths from Laravel (e.g., /storage/...)
    if (firstImage.isNotEmpty && !firstImage.startsWith('http')) {
      if (firstImage.startsWith('/')) {
        firstImage = "$baseUrl$firstImage";
      } else {
        // Many Laravel setups store paths without the 'storage/' prefix in DB
        // If it doesn't have 'storage' or 'public' prefix, add storage/
        if (!firstImage.contains('storage/')) {
          firstImage = "$baseUrl/storage/$firstImage";
        } else {
          firstImage = "$baseUrl/$firstImage";
        }
      }
    }

    // If the image URL contains localhost or 127.0.0.1 (common when using Laravel's asset() helper),
    // replace it with our ngrok baseUrl so it can be accessed from mobile.
    if (firstImage.contains('localhost:8000') || firstImage.contains('127.0.0.1:8000')) {
      firstImage = firstImage.replaceAll('http://localhost:8000', baseUrl)
                             .replaceAll('http://127.0.0.1:8000', baseUrl);
    }

    // DEBUG: Print the final image URL to terminal
    print('DEBUG IMAGE URL for ${json['name']}: $firstImage');

    // Handle Laravel seller relationship
    String shop = 'Decor Official';
    String shopLogo = '';
    String shopBanner = '';
    String shopDesc = '';
    if (json['seller'] != null) {
      shop = json['seller']['store_name'] ?? 'Decor Official';
      shopLogo = json['seller']['store_image_url'] ?? '';
      shopBanner = json['seller']['store_banner_url'] ?? '';
      shopDesc = json['seller']['store_description'] ?? '';
    }

    // Handle Laravel category relationship
    String cat = 'Uncategorized';
    if (json['category'] != null) {
      if (json['category'] is Map) {
        cat = json['category']['name'] ?? 'Uncategorized';
      } else if (json['category'] is String) {
        cat = json['category'];
      }
    }

    int sId = 1;
    int sUserId = 1;
    if (json['seller_id'] != null) {
      sId = int.tryParse(json['seller_id'].toString()) ?? 1;
    } 
    if (json['seller'] != null) {
      if (json['seller']['id'] != null) {
        sId = json['seller']['id'];
      }
      if (json['seller']['user_id'] != null) {
        sUserId = json['seller']['user_id'];
      }
    }

    return ProductModel(
      id: json['id'] != null ? int.tryParse(json['id'].toString()) ?? 0 : 0,
      name: json['name'] ?? 'Unknown Product',
      description: json['description'] ?? '',
      price: finalPrice,
      imageUrl: firstImage.isEmpty ? 'https://images.unsplash.com/photo-1555041469-a586c61ea9bc?w=400&q=80' : firstImage,
      category: cat,
      style: json['style'] ?? 'Modern',
      shopName: shop,
      shopLogo: shopLogo,
      shopBanner: shopBanner,
      shopDescription: shopDesc,
      sellerId: sId,
      sellerUserId: sUserId,
      reviews: json['reviews'] != null && json['reviews'] is List
          ? (json['reviews'] as List).map((r) => ReviewModel.fromJson(r)).toList()
          : [],
    );
  }

  // Convert to UI model for compatibility
  FurnitureProduct toFurnitureProduct() {
    return FurnitureProduct(
      id: id.toString(),
      name: name,
      description: description,
      price: price,
      category: category,
      imagePath: imageUrl,
      style: style,
      shopName: shopName,
      shopLogo: shopLogo,
      shopBanner: shopBanner,
      shopDescription: shopDescription,
      sellerId: sellerId,
      sellerUserId: sellerUserId,
      reviews: reviews,
    );
  }
}

class FurnitureProduct {
  final String id;
  final String name;
  final String description;
  final double price;
  final String category;
  final String imagePath;
  final String material;
  final String style;
  final String shopName;
  final String shopLogo;
  final String shopBanner;
  final String shopDescription;
  final int sellerId;
  final int sellerUserId;
  final List<ReviewModel> reviews;

  FurnitureProduct({
    required this.id,
    required this.name,
    this.description = '',
    required this.price,
    required this.category,
    required this.imagePath,
    this.material = 'Oak',
    this.style = 'Modern',
    this.shopName = 'Decor Official',
    this.shopLogo = '',
    this.shopBanner = '',
    this.shopDescription = '',
    this.sellerId = 1,
    this.sellerUserId = 1,
    this.reviews = const [],
  });
}
