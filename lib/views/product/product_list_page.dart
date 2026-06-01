import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/cart_provider.dart';
import '../../providers/wishlist_provider.dart';
import '../../models/product_model.dart';
import 'product_detail_page.dart';
import '../../widgets/custom_footer.dart';
import '../search/search_page.dart';
import 'widgets/filter_bottom_sheet.dart';
import '../../widgets/bounce_tap.dart';
import '../../widgets/animated_wishlist_button.dart';
import '../../core/utils/currency_formatter.dart';
import '../../providers/product_provider.dart';




class ProductListPage extends StatefulWidget {
  final bool showBackButton;
  final String? initialCategory;
  
  const ProductListPage({
    super.key, 
    this.showBackButton = true,
    this.initialCategory,
  });

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  final List<String> categories = [
    'All', 
    'Sofa', 
    'Chair', 
    'Table', 
    'Bed', 
    'Lighting', 
    'Cabinet', 
    'Decor', 
    'Living Room', 
    'Bedroom', 
    'Dining Room', 
    'Workspace', 
    'Kitchen', 
    'Outdoor', 
    'Decoration'
  ];
  int selectedCategoryIndex = 0;

  RangeValues? _filterPriceRange;
  String? _filterStyle;

  @override
  void initState() {
    super.initState();
    if (widget.initialCategory != null) {
      final index = categories.indexWhere(
        (cat) => cat.toLowerCase() == widget.initialCategory!.toLowerCase()
      );
      if (index != -1) {
        selectedCategoryIndex = index;
      }
    }
    // Fetch always to get the latest data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().loadProducts();
    });

  }

  List<FurnitureProduct> getFilteredProducts(List<ProductModel> apiProducts) {
    // If API has products, use them, otherwise fallback to dummyCatalog for development
    final baseProducts = apiProducts.isNotEmpty 
        ? apiProducts.map((p) => p.toFurnitureProduct()).toList() 
        : dummyCatalog;

    return baseProducts.where((product) {
      // Perbaikan: Gunakan case-insensitive comparison untuk kategori
      bool matchCategory = selectedCategoryIndex == 0 || 
          product.category.toLowerCase().trim() == categories[selectedCategoryIndex].toLowerCase().trim();
      
      bool matchStyle = _filterStyle == null || _filterStyle == 'All' || product.style == _filterStyle;
      bool matchPrice = _filterPriceRange == null || (product.price >= _filterPriceRange!.start && product.price <= _filterPriceRange!.end);
      
      return matchCategory && matchStyle && matchPrice;
    }).toList();
  }


  void _showFilterBottomSheet() async {
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return FractionallySizedBox(
          heightFactor: 0.85,
          child: const FilterBottomSheet(),
        );
      },
    );

    if (result != null) {
      setState(() {
        _filterPriceRange = result['priceRange'];
        _filterStyle = result['style'];
        
        // Sync selectedCategoryIndex with the filter result
        final String selectedCat = result['category'] ?? 'All';
        final int newIndex = categories.indexWhere(
          (c) => c.toLowerCase() == selectedCat.toLowerCase()
        );
        if (newIndex != -1) {
          selectedCategoryIndex = newIndex;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        automaticallyImplyLeading: false,
        leading: (widget.showBackButton && Navigator.canPop(context)) ? IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ) : null,
        title: const Text(
          'All Products',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: Column(
        children: [
          // Search & Filter
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
            child: Row(
              children: [
                Expanded(
                  child: BounceTap(
                    onTap: () {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (context, animation, secondaryAnimation) => const SearchPage(),
                          transitionsBuilder: (context, animation, secondaryAnimation, child) {
                            return FadeTransition(opacity: animation, child: child);
                          },
                        ),
                      );
                    },
                    child: Material(
                      type: MaterialType.transparency,
                      child: Container(
                        height: 48,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: Colors.grey.shade100),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.search, color: Colors.grey, size: 20),
                            const SizedBox(width: 8),
                            Text('Search products...', style: TextStyle(color: Colors.grey.shade400, fontSize: 14)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                BounceTap(
                  onTap: _showFilterBottomSheet,
                  child: Container(
                    height: 48,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.grey.shade100),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.filter_list, size: 18, color: Colors.black87),
                        SizedBox(width: 6),
                        Text('Filter', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black87, fontSize: 14)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Category Chips
          ScrollConfiguration(
            behavior: ScrollConfiguration.of(context).copyWith(
              dragDevices: PointerDeviceKind.values.toSet(),
            ),
            child: SizedBox(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final isSelected = index == selectedCategoryIndex;
                  return BounceTap(
                    onTap: () {
                      setState(() {
                        selectedCategoryIndex = index;
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 8.0, top: 8.0, bottom: 8.0),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primaryColor : Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? AppColors.primaryColor : Colors.grey.shade100,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          categories[index],
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black87,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Product Grid and Footer
          Expanded(
            child: Consumer<ProductProvider>(
              builder: (context, productProvider, child) {
                if (productProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                final filteredProducts = getFilteredProducts(productProvider.products);

                if (filteredProducts.isEmpty) {
                  return RefreshIndicator(
                    onRefresh: () => productProvider.loadProducts(),
                    color: AppColors.primaryColor,
                    child: ListView(
                      children: [
                        SizedBox(height: MediaQuery.of(context).size.height * 0.3),
                        const Center(
                          child: Text(
                            'No products found.\nPull to refresh.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey, height: 1.5),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => productProvider.loadProducts(),
                  color: AppColors.primaryColor,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      children: [
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.65,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 24,
                          ),
                          itemCount: filteredProducts.length,
                          itemBuilder: (context, index) {
                            final FurnitureProduct product = filteredProducts[index];
                            return BounceTap(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ProductDetailPage(
                                      product: product, 
                                      heroTag: 'list_${product.id}',
                                    ),
                                  ),
                                );
                              },
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Image Card
                                  Expanded(
                                    child: Stack(
                                      children: [
                                        Positioned.fill(
                                          child: Hero(
                                            tag: 'list_${product.id}',
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
                                        ),
                                        Positioned(
                                          top: 8,
                                          right: 8,
                                          child: Container(
                                            padding: const EdgeInsets.all(6),
                                            decoration: const BoxDecoration(
                                              color: Colors.white,
                                              shape: BoxShape.circle,
                                            ),
                                            child: Consumer<WishlistProvider>(
                                              builder: (context, wishlist, child) {
                                                final isLiked = wishlist.isWishlisted(product.id);
                                                return AnimatedWishlistButton(
                                                  size: 16,
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
                                  // Details
                                  Text(
                                    product.name,
                                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.black87),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    product.shopName,
                                    style: TextStyle(
                                      color: Colors.grey.shade500,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    product.price.toIDR(),
                                    style: const TextStyle(
                                      color: AppColors.primaryColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        const CustomFooter(),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
