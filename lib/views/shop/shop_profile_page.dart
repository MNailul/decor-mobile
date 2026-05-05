import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/product_model.dart';
import '../../providers/cart_provider.dart';
import '../product/product_detail_page.dart';
import '../chat/chat_detail_page.dart';
import '../../widgets/bounce_tap.dart';

class ShopProfilePage extends StatelessWidget {
  final String shopName;

  const ShopProfilePage({super.key, required this.shopName});

  static const Color primaryColor = Color(0xFFB5733A);
  static const Color textColor = Color(0xFF1E1E1E);

  @override
  Widget build(BuildContext context) {
    // Filter products by shop name
    final shopProducts = dummyCatalog.where((p) => p.shopName == shopName).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // Elegant Shop Header
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Cover Image
                  Image.network(
                    'https://images.unsplash.com/photo-1556228453-efd6c1ff04f6?w=800&q=80',
                    fit: BoxFit.cover,
                  ),
                  // Dark Gradient Overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.4),
                          Colors.black.withValues(alpha: 0.1),
                          Colors.black.withValues(alpha: 0.6),
                        ],
                      ),
                    ),
                  ),
                  // Shop Info Overlay
                  Positioned(
                    bottom: 20,
                    left: 20,
                    right: 20,
                    child: Row(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                            image: const DecorationImage(
                              image: NetworkImage('https://images.unsplash.com/photo-1541746972996-4e0b0f43e01a?w=100&q=80'),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                shopName,
                                style: GoogleFonts.epilogue(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Row(
                                children: [
                                  const Icon(Icons.star, color: Colors.amber, size: 14),
                                  const SizedBox(width: 4),
                                  Text(
                                    '4.9 | 1.2k Followers',
                                    style: GoogleFonts.epilogue(
                                      color: Colors.white.withValues(alpha: 0.9),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ChatDetailPage(shopName: shopName),
                                  ),
                                );
                              },
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.white.withOpacity(0.2),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.all(8),
                              ),
                              icon: const Icon(Icons.chat_bubble_outline, size: 20),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: primaryColor,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              child: Text(
                                'Follow',
                                style: GoogleFonts.epilogue(fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Shop Stats / Quick Links
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'CURATED COLLECTIONS',
                    style: GoogleFonts.epilogue(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade500,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Specializing in organic modernism and timeless functional art. Each piece is hand-selected to elevate your living experience.',
                    style: GoogleFonts.epilogue(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Divider(),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem('124', 'Products'),
                      _buildStatItem('4.9', 'Rating'),
                      _buildStatItem('2.4k', 'Sales'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 32),
                  Text(
                    'ALL PRODUCTS',
                    style: GoogleFonts.epilogue(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade500,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Product Grid
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.7,
                crossAxisSpacing: 16,
                mainAxisSpacing: 24,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final product = shopProducts[index];
                  return _buildProductCard(context, product);
                },
                childCount: shopProducts.length,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 48)),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.epilogue(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.epilogue(
            fontSize: 11,
            color: Colors.grey.shade500,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildProductCard(BuildContext context, FurnitureProduct product) {
    return BounceTap(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ProductDetailPage(product: product)),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                product.imagePath,
                fit: BoxFit.cover,
                width: double.infinity,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            product.name,
            style: GoogleFonts.epilogue(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: textColor,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            '\$${product.price.toStringAsFixed(2)}',
            style: GoogleFonts.epilogue(
              color: primaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
