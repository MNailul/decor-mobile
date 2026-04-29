import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../product/product_detail_page.dart';
import '../../models/product_model.dart';
import '../../providers/cart_provider.dart';
import '../../widgets/bounce_tap.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  List<FurnitureProduct> _searchResults = [];

  final List<Map<String, String>> _categories = [
    {'name': 'Seating', 'icon': 'weekend'},
    {'name': 'Lighting', 'icon': 'lightbulb_outline'},
    {'name': 'Tables', 'icon': 'table_restaurant'},
    {'name': 'Decor', 'icon': 'eco'},
    {'name': 'Storage', 'icon': 'inventory_2'},
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Header
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  BounceTap(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back, color: Colors.black87),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Hero(
                      tag: 'search_bar',
                      child: Material(
                        type: MaterialType.transparency,
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: TextField(
                            controller: _searchController,
                            autofocus: true,
                            onChanged: (value) {
                              setState(() {
                                _searchQuery = value;
                                if (value.isNotEmpty) {
                                  _searchResults = dummyCatalog.where((product) => 
                                    product.name.toLowerCase().contains(value.toLowerCase()) || 
                                    product.category.toLowerCase().contains(value.toLowerCase())
                                  ).toList();
                                } else {
                                  _searchResults = [];
                                }
                              });
                            },
                            decoration: InputDecoration(
                              hintText: 'Search for furniture, styles...',
                              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                              prefixIcon: const Icon(Icons.search, color: Colors.grey, size: 20),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            Expanded(
              child: _searchQuery.isEmpty
                  ? SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 16),
                          const Text('Categories', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 16),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: _categories.map((cat) => Padding(
                                padding: const EdgeInsets.only(right: 12.0),
                                child: _buildCategoryChip(cat['name']!),
                              )).toList(),
                            ),
                          ),
                          
                          const SizedBox(height: 40),
                          const Text('Trending Now', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 16),
                          
                          // Trending Products Grid
                          GridView.count(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: 2,
                            mainAxisSpacing: 16,
                            crossAxisSpacing: 16,
                            childAspectRatio: 0.75,
                            children: [
                              _buildTrendingProduct('The Plinth Cushion', '\$115', 'https://images.unsplash.com/photo-1584100936595-c0654b55a2e2?w=400&q=80'),
                              _buildTrendingProduct('Orbital Tray', '\$89', 'https://images.unsplash.com/photo-1616486029423-aaa4789e8c9a?w=400&q=80'),
                              _buildTrendingProduct('Lounge Chair', '\$450', 'https://images.unsplash.com/photo-1506439773649-6e0eb8cfb237?w=400&q=80'),
                              _buildTrendingProduct('Ceramic Vase', '\$65', 'https://images.unsplash.com/photo-1612152505975-6454ce466c6d?w=400&q=80'),
                            ],
                          ),
                          const SizedBox(height: 32),
                        ],
                      ),
                    )
                  : _searchResults.isEmpty
                      ? const Center(child: Text('No products found', style: TextStyle(fontSize: 16, color: Colors.grey)))
                      : GridView.builder(
                          padding: const EdgeInsets.all(20.0),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 16,
                            crossAxisSpacing: 16,
                            childAspectRatio: 0.65,
                          ),
                          itemCount: _searchResults.length,
                          itemBuilder: (context, index) {
                            final product = _searchResults[index];
                            return _buildSearchProductCard(product);
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String title) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Text(
        title,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.black87),
      ),
    );
  }

  Widget _buildTrendingProduct(String name, String price, String imageUrl) {
    return BounceTap(
      onTap: () {
        // Just mock navigation for now
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                  image: NetworkImage(imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          const SizedBox(height: 4),
          Text(price, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildSearchProductCard(FurnitureProduct product) {
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
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                  image: NetworkImage(product.imagePath),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(product.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 4),
          Text('\$${product.price.toStringAsFixed(2)}', style: const TextStyle(color: AppColors.primaryColor, fontWeight: FontWeight.bold, fontSize: 13)),
        ],
      ),
    );
  }
}
