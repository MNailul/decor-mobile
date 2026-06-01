import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../models/product_model.dart';
import '../../providers/cart_provider.dart';
import '../../providers/wishlist_provider.dart';
import '../../widgets/custom_footer.dart';
import '../../widgets/bounce_tap.dart';
import '../../widgets/animated_wishlist_button.dart';
import '../shop/shop_profile_page.dart';
import '../../core/utils/currency_formatter.dart';
import '../../providers/product_provider.dart';


class ProductDetailPage extends StatefulWidget {
  final FurnitureProduct product;
  final String? heroTag;

  const ProductDetailPage({super.key, required this.product, this.heroTag});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  int _quantity = 1;
  final ScrollController _scrollController1 = ScrollController();
  final ScrollController _scrollController2 = ScrollController();
  Timer? _timer;
  late FurnitureProduct _currentProduct;
  bool _isProductLoading = false;
  bool _isDescriptionExpanded = false;

  @override
  void initState() {
    super.initState();
    _currentProduct = widget.product;
    _startAutoScroll();
    _loadFreshProductData();
  }

  Future<void> _loadFreshProductData() async {
    setState(() => _isProductLoading = true);
    try {
      final productProvider = context.read<ProductProvider>();
      final productId = int.tryParse(_currentProduct.id);
      if (productId == null) return; // Skip for dummy products with 'p1' style IDs
      
      final freshData = await productProvider.getProductDetail(productId);
      if (freshData != null && mounted) {
        setState(() {
          _currentProduct = freshData.toFurnitureProduct();
        });
      }
    } catch (e) {
      debugPrint('Error refreshing product data: $e');
    } finally {
      if (mounted) setState(() => _isProductLoading = false);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _scrollController1.dispose();
    _scrollController2.dispose();
    super.dispose();
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      _autoScrollController(_scrollController1);
      _autoScrollController(_scrollController2);
    });
  }

  void _autoScrollController(ScrollController controller) {
    if (controller.hasClients) {
      double maxScroll = controller.position.maxScrollExtent;
      double currentScroll = controller.position.pixels;
      double delta = 160.0 + 16.0; // card width + padding

      if (currentScroll >= maxScroll) {
        controller.animateTo(
          0,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );
      } else {
        controller.animateTo(
          currentScroll + delta,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  void _incrementQuantity() {
    setState(() {
      _quantity++;
    });
  }

  void _decrementQuantity() {
    if (_quantity > 1) {
      setState(() {
        _quantity--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final availableProducts = dummyCatalog.where((p) => p.id != _currentProduct.id).toList();
    final halfLength = (availableProducts.length / 2).ceil();
    final row1Products = availableProducts.take(halfLength).toList();
    final row2Products = availableProducts.skip(halfLength).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6),
      // Sticky bottom bar
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFFAF9F6),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              offset: const Offset(0, -4),
              blurRadius: 10,
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              // Quantity Selector
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.white,
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove, size: 18),
                      onPressed: _decrementQuantity,
                      color: Colors.black87,
                    ),
                    Text(
                      '$_quantity',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add, size: 18),
                      onPressed: _incrementQuantity,
                      color: Colors.black87,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // Add to Cart Button
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    final cart = context.read<CartProvider>();
                    cart.addToCart(_currentProduct, quantity: _quantity);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            const Icon(Icons.check_circle_outline, color: Colors.white, size: 28),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Successfully Added!', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white)),
                                  const SizedBox(height: 2),
                                  Text('${_currentProduct.name} x$_quantity', style: const TextStyle(fontSize: 12, color: Colors.white70)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        backgroundColor: AppColors.primaryColor,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        margin: const EdgeInsets.only(bottom: 24, left: 24, right: 24),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        elevation: 8,
                        duration: const Duration(seconds: 3),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'ADD TO CART',
                    style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2, fontSize: 13),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: const Color(0xFFFAF9F6),
            elevation: 0,
            pinned: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black87),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.search, color: Colors.black87),
                onPressed: () {},
              ),
            ],
            expandedHeight: 400,
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: widget.heroTag ?? _currentProduct.id,
                child: Image.network(
                  _currentProduct.imagePath,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(24.0),
              decoration: const BoxDecoration(
                color: Color(0xFFFAF9F6),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Thumbnails
                  Row(
                    children: [
                      _buildThumbnail('https://images.unsplash.com/photo-1505843490538-5133c6c7d0e1?w=200&q=80', true),
                      const SizedBox(width: 12),
                      _buildThumbnail('https://images.unsplash.com/photo-1598300042247-d088f8ab3a91?w=200&q=80', false),
                      const SizedBox(width: 12),
                      _buildThumbnail('https://images.unsplash.com/photo-1567538096630-e0c55bd6374c?w=200&q=80', false),
                    ],
                  ),
                  const SizedBox(height: 32),
                  // Price
                  Text(
                    _currentProduct.price.toIDR(),
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  BounceTap(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ShopProfilePage(
                            shopName: _currentProduct.shopName,
                            sellerId: _currentProduct.sellerId,
                          ),
                        ),
                      );
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                              image: NetworkImage(
                                _currentProduct.shopLogo.isNotEmpty 
                                  ? _currentProduct.shopLogo 
                                  : 'https://ui-avatars.com/api/?name=${Uri.encodeComponent(_currentProduct.shopName)}&background=B5733A&color=fff'
                              ),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _currentProduct.shopName,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Title and Favorite
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          _currentProduct.name,
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      Consumer<WishlistProvider>(
                        builder: (context, wishlist, child) {
                          final isLiked = wishlist.isWishlisted(_currentProduct.id);
                          return AnimatedWishlistButton(
                            size: 28,
                            initialIsLiked: isLiked,
                            onChanged: (liked) {
                              wishlist.toggleWishlist(_currentProduct);
                            },
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Description
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _currentProduct.description.isNotEmpty 
                          ? _currentProduct.description 
                          : 'No description available for this masterpiece.',
                        maxLines: _isDescriptionExpanded ? null : 3,
                        overflow: _isDescriptionExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.black54,
                          height: 1.6,
                        ),
                      ),
                      if (_currentProduct.description.length > 100)
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _isDescriptionExpanded = !_isDescriptionExpanded;
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              _isDescriptionExpanded ? 'SEE LESS' : 'SEE MORE',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryColor,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Reviews
                  Builder(
                    builder: (context) {
                      double avgRating = 0;
                      if (_currentProduct.reviews.isNotEmpty) {
                        avgRating = _currentProduct.reviews.map((r) => r.rating).reduce((a, b) => a + b) / _currentProduct.reviews.length;
                      }
                      
                      return Row(
                        children: [
                          ...List.generate(5, (index) {
                            if (index < avgRating.floor()) {
                              return const Icon(Icons.star, color: AppColors.primaryColor, size: 16);
                            } else if (index < avgRating) {
                              return const Icon(Icons.star_half, color: AppColors.primaryColor, size: 16);
                            } else {
                              return const Icon(Icons.star_border, color: AppColors.primaryColor, size: 16);
                            }
                          }),
                          const SizedBox(width: 8),
                          Text(
                            '${avgRating > 0 ? avgRating.toStringAsFixed(1) : '0'} (${_currentProduct.reviews.length} REVIEWS)',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.black54,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      );
                    }
                  ),
                  const SizedBox(height: 40),
                  // Curator Notes
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.secondaryColor.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'CURATOR NOTES',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.black54,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: _buildNoteItem('CATEGORY', _currentProduct.category),
                            ),
                            Expanded(
                              child: _buildNoteItem('MATERIAL', _currentProduct.material),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _buildNoteItem('STYLE', _currentProduct.style),
                            ),
                            Expanded(
                              child: _buildNoteItem('SHIPPING', 'Premium White Glove'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: _buildNoteItem('SHOP', _currentProduct.shopName),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ShopProfilePage(
                                      shopName: _currentProduct.shopName,
                                      sellerId: _currentProduct.sellerId,
                                    ),
                                  ),
                                );
                              },
                              child: const Text(
                                'VISIT STORE',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryColor,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 48),
                  // Detailed Reviews Section
                  const Text(
                    'LATEST REVIEWS',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (_currentProduct.reviews.isEmpty)
                    const Text('Belum ada ulasan untuk produk ini.', style: TextStyle(color: Colors.black54, fontSize: 13))
                  else
                    ..._currentProduct.reviews.map((r) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _buildReviewItem(r.customerName, r.comment, r.rating, r.customerImage, reply: r.reply),
                    )),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        _showAllReviewsBottomSheet(context);
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.primaryColor),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('SEE ALL REVIEWS', style: TextStyle(color: AppColors.primaryColor, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1)),
                    ),
                  ),
                  const SizedBox(height: 48),
                  // Recommended Products Section
                  const Text(
                    'RECOMMENDED FOR YOU',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Column(
                    children: [
                      SizedBox(
                        height: 232,
                        child: ListView.builder(
                          controller: _scrollController1,
                          scrollDirection: Axis.horizontal,
                          clipBehavior: Clip.none,
                          itemCount: row1Products.length,
                          itemBuilder: (context, index) {
                            return _buildRecommendedCard(row1Products[index]);
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 232,
                        child: ListView.builder(
                          controller: _scrollController2,
                          scrollDirection: Axis.horizontal,
                          clipBehavior: Clip.none,
                          itemCount: row2Products.length,
                          itemBuilder: (context, index) {
                            return _buildRecommendedCard(row2Products[index]);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              color: const Color(0xFFFAF9F6),
              child: const CustomFooter(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThumbnail(String imageUrl, bool isSelected) {
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? AppColors.primaryColor : Colors.transparent,
          width: 2,
        ),
        image: DecorationImage(
          image: NetworkImage(imageUrl),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildNoteItem(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 10,
            color: Colors.black45,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
            height: 1.3,
          ),
        ),
      ],
    );
  }

  Widget _buildReviewItem(String name, String comment, int rating, String? imageUrl, {String? reply}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: imageUrl != null && imageUrl.isNotEmpty
                    ? Image.network(
                        imageUrl,
                        width: 40,
                        height: 40,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 40,
                          height: 40,
                          color: Colors.grey.shade200,
                          child: const Icon(Icons.person, color: Colors.grey, size: 20),
                        ),
                      )
                    : Container(
                        width: 40,
                        height: 40,
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.person, color: Colors.grey, size: 20),
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: List.generate(5, (index) {
                        return Icon(
                          index < rating ? Icons.star : Icons.star_border,
                          color: AppColors.primaryColor,
                          size: 14,
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            comment,
            style: const TextStyle(fontSize: 13, color: Colors.black54, height: 1.6),
          ),
          if (reply != null && reply.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade100),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.reply, size: 14, color: AppColors.primaryColor),
                      const SizedBox(width: 8),
                      const Text(
                        'Seller Response',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryColor,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    reply,
                    style: const TextStyle(fontSize: 12, color: Colors.black54, height: 1.5),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showAllReviewsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: const BoxDecoration(
          color: Color(0xFFFAF9F6),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'ALL REVIEWS',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1.5),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: _currentProduct.reviews.length,
                itemBuilder: (context, index) {
                  final r = _currentProduct.reviews[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _buildReviewItem(r.customerName, r.comment, r.rating, r.customerImage, reply: r.reply),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendedCard(FurnitureProduct product) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 16),
      child: BounceTap(
        onTap: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => ProductDetailPage(product: product)),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 160,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                  image: NetworkImage(product.imagePath),
                  fit: BoxFit.cover,
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Consumer<WishlistProvider>(
                        builder: (context, wishlist, child) {
                          final isLiked = wishlist.isWishlisted(product.id);
                          return AnimatedWishlistButton(
                            size: 14,
                            initialIsLiked: isLiked,
                            onChanged: (liked) {
                              wishlist.toggleWishlist(product);
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(product.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.black87), maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),
            Text(product.price.toIDR(), style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}
