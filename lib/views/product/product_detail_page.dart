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

class ProductDetailPage extends StatefulWidget {
  final FurnitureProduct product;

  const ProductDetailPage({super.key, required this.product});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  int _quantity = 1;
  final ScrollController _scrollController1 = ScrollController();
  final ScrollController _scrollController2 = ScrollController();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
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
    final availableProducts = dummyCatalog.where((p) => p.id != widget.product.id).toList();
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
                    cart.addToCart(widget.product, quantity: _quantity);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${widget.product.name} added to Cart'),
                        backgroundColor: AppColors.primaryColor,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
                tag: widget.product.id,
                child: Image.network(
                  widget.product.imagePath,
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
                    '\$${widget.product.price.toStringAsFixed(2)}',
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
                          builder: (context) => ShopProfilePage(shopName: widget.product.shopName),
                        ),
                      );
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.store, size: 16, color: Colors.black54),
                        const SizedBox(width: 6),
                        Text(
                          widget.product.shopName,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black54,
                            letterSpacing: 0.5,
                            decoration: TextDecoration.underline,
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
                          widget.product.name,
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      Consumer<WishlistProvider>(
                        builder: (context, wishlist, child) {
                          final isLiked = wishlist.isWishlisted(widget.product.id);
                          return AnimatedWishlistButton(
                            size: 28,
                            initialIsLiked: isLiked,
                            onChanged: (liked) {
                              wishlist.toggleWishlist(widget.product);
                            },
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Description
                  const Text(
                    'A masterpiece of organic brutalism, the Elysian Armchair balances architectural precision with unparalleled comfort. Hand-finished walnut meets curated Belgian linen for a timeless presence.',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.black54,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'SEE MORE',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryColor,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Reviews
                  Row(
                    children: const [
                      Icon(Icons.star, color: AppColors.primaryColor, size: 16),
                      Icon(Icons.star, color: AppColors.primaryColor, size: 16),
                      Icon(Icons.star, color: AppColors.primaryColor, size: 16),
                      Icon(Icons.star, color: AppColors.primaryColor, size: 16),
                      Icon(Icons.star_half, color: AppColors.primaryColor, size: 16),
                      SizedBox(width: 8),
                      Text(
                        '4.8 (124 REVIEWS)',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.black54,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
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
                              child: _buildNoteItem('CATEGORY', widget.product.category),
                            ),
                            Expanded(
                              child: _buildNoteItem('MATERIAL', widget.product.material),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _buildNoteItem('STYLE', widget.product.style),
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
                              child: _buildNoteItem('SHOP', widget.product.shopName),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ShopProfilePage(shopName: widget.product.shopName),
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
                  _buildReviewItem('Sarah J.', 'Absolutely love this piece! It fits perfectly in my minimalist living room.', 5),
                  const SizedBox(height: 16),
                  _buildReviewItem('Michael T.', 'Great quality and the material feels premium. Worth the price.', 4),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {},
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

  Widget _buildReviewItem(String name, String comment, int rating) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                name,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87),
              ),
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
          const SizedBox(height: 12),
          Text(
            comment,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black54,
              height: 1.5,
            ),
          ),
        ],
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
            Text('\$${product.price.toStringAsFixed(2)}', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}
