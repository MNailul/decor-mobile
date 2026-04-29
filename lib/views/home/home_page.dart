import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../cart/cart_page.dart';
import '../profile/profile_page.dart';
import '../wishlist/wishlist_page.dart';
import '../product/product_list_page.dart';
import '../search/search_page.dart';
import '../designer/designer_list_page.dart';
import '../../widgets/custom_footer.dart';
import '../../widgets/bounce_tap.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  final ScrollController _scrollController = ScrollController();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_scrollController.hasClients) {
        double maxScroll = _scrollController.position.maxScrollExtent;
        double currentScroll = _scrollController.position.pixels;
        double delta = 160.0 + 16.0; // card width + padding

        if (currentScroll >= maxScroll) {
          _scrollController.animateTo(
            0,
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeInOut,
          );
        } else {
          _scrollController.animateTo(
            currentScroll + delta,
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeInOut,
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _currentIndex == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        setState(() => _currentIndex = 0);
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            IndexedStack(
              index: _currentIndex,
              children: [
                _buildHomeContent(),
                const ProductListPage(showBackButton: false),
                const CartPage(),
                const ProfilePage(),
              ],
            ),
            // Truly Floating Dock
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: Container(
                  height: 70,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(35),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildNavItem(0, Icons.home_filled, Icons.home_outlined),
                      _buildNavItem(1, Icons.grid_view_rounded, Icons.grid_view_outlined),
                      _buildNavItem(2, Icons.shopping_cart_rounded, Icons.shopping_cart_outlined),
                      _buildNavItem(3, Icons.person_rounded, Icons.person_outline),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData selectedIcon, IconData unselectedIcon) {
    bool isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.all(10),
            child: Icon(
              isSelected ? selectedIcon : unselectedIcon,
              color: isSelected ? AppColors.primaryColor : Colors.grey.shade400,
              size: 26,
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: 4,
            width: isSelected ? 4 : 0,
            decoration: const BoxDecoration(
              color: AppColors.primaryColor,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHomeContent() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              // Search bar & AI Icon
              Row(
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
                      child: Hero(
                        tag: 'search_bar',
                        child: Material(
                          type: MaterialType.transparency,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            height: 48,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: Colors.grey.shade100),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.search, color: Colors.grey, size: 20),
                                const SizedBox(width: 8),
                                Text('Search', style: TextStyle(color: Colors.grey.shade500, fontSize: 14)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () {
                      // TODO: Redirect to Generative Design AI page
                    },
                    child: Container(
                      height: 48,
                      width: 48,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.grey.shade100),
                      ),
                      child: const Icon(Icons.auto_awesome, color: Colors.black87, size: 20),
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const WishlistPage()),
                      );
                    },
                    child: Container(
                      height: 48,
                      width: 48,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.grey.shade100),
                      ),
                      child: const Icon(Icons.favorite_border, color: Colors.black87, size: 20),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              // Hero text
              const Text(
                'The Future',
                style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, height: 1.1),
              ),
              Row(
                children: [
                  const Text(
                    'of ',
                    style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, height: 1.1),
                  ),
                  const Text(
                    'Living',
                    style: TextStyle(
                      fontSize: 36, 
                      fontWeight: FontWeight.bold, 
                      color: AppColors.primaryColor,
                      height: 1.1,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // CTA button
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ProductListPage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('SHOP COLLECTIONS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1.2)),
              ),
              const SizedBox(height: 40),
              // Featured Banner
              Container(
                height: 280,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: AppColors.secondaryColor,
                  image: const DecorationImage(
                    image: AssetImage('assets/images/hero_banner.png'),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                    ),
                  ),
                  padding: const EdgeInsets.all(24),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'LIMITED RELEASE',
                        style: TextStyle(color: Colors.white70, fontSize: 10, letterSpacing: 2, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'The Earth Form\nSeries',
                        style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold, height: 1.2),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 48),
              // Collections Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Collections', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ProductListPage()),
                      );
                    },
                    child: const Text('SEE ALL', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1, color: AppColors.primaryColor)),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Horizontal Scroll Cards
              SizedBox(
                height: 240,
                child: ListView(
                  controller: _scrollController,
                  scrollDirection: Axis.horizontal,
                  clipBehavior: Clip.none,
                  children: [
                    _buildCollectionCard('Textiles', 'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=400&q=80'),
                    const SizedBox(width: 16),
                    _buildCollectionCard('Objects', 'https://images.unsplash.com/photo-1513519245088-0e12902e5a38?w=400&q=80'),
                    const SizedBox(width: 16),
                    _buildCollectionCard('Furniture', 'https://images.unsplash.com/photo-1555041469-a586c61ea9bc?w=400&q=80'),
                    const SizedBox(width: 16),
                    _buildCollectionCard('Lighting', 'https://images.unsplash.com/photo-1513694203232-719a280e022f?w=400&q=80'),
                    const SizedBox(width: 16),
                    _buildCollectionCard('Art', 'https://images.unsplash.com/photo-1544457070-4cd773b4d71e?w=400&q=80'),
                  ],
                ),
              ),
              const SizedBox(height: 48),
              // New Arrivals Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('New Arrivals', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ProductListPage()),
                      );
                    },
                    child: const Text('SHOP ALL', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1, color: AppColors.primaryColor)),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Featured New Arrival
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: AppColors.secondaryColor,
                  image: const DecorationImage(
                    image: AssetImage('assets/images/featured_arrival.png'),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                      child: const Text('FEATURED', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Product List
              Row(
                children: [
                  Expanded(child: _buildProductCard('The Plinth Cushion', '\$115', 'https://images.unsplash.com/photo-1584100936595-c0654b55a2e2?w=400&q=80')),
                  const SizedBox(width: 16),
                  Expanded(child: _buildProductCard('Orbital Tray', '\$89', 'https://images.unsplash.com/photo-1616486029423-aaa4789e8c9a?w=400&q=80')),
                ],
              ),
              const SizedBox(height: 48),
              // AI Section
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                      child: const Icon(Icons.auto_awesome, color: Colors.white, size: 28),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'AI Curated For You',
                      style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Our algorithm analyzes your space and style to suggest the perfect finishing pieces.',
                      style: TextStyle(color: Colors.white, fontSize: 14, height: 1.5),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.primaryColor,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Start My Curation', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),
              // Consult a Designer
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Consult a Designer', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const DesignerListPage()),
                      );
                    },
                    child: const Text('VIEW ALL', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1, color: AppColors.primaryColor)),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 200,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  clipBehavior: Clip.none,
                  children: [
                    _buildDesignerCard('Sarah Jen', 'Interior Architect', 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200&q=80'),
                    const SizedBox(width: 16),
                    _buildDesignerCard('Mark Doe', 'Space Planner', 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200&q=80'),
                    const SizedBox(width: 16),
                    _buildDesignerCard('Alia Smith', 'Decor Specialist', 'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=200&q=80'),
                  ],
                ),
              ),
              const SizedBox(height: 48),
              // The Ethos
              const Center(
                child: Column(
                  children: [
                    Text('THE ETHOS', style: TextStyle(fontSize: 10, letterSpacing: 2, color: Colors.grey, fontWeight: FontWeight.bold)),
                    SizedBox(height: 24),
                    Text(
                      'Every object tells a\nstory of its making.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, height: 1.2),
                    ),
                    SizedBox(height: 24),
                    Text(
                      'We partner with independent makers\nworldwide to bring museum-quality design\ninto your daily ritual.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.black87, height: 1.6, fontSize: 14),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              // Bottom Images for Ethos
              Row(
                children: [
                  Expanded(child: _buildEthosImage('https://images.unsplash.com/photo-1513519245088-0e12902e5a38?w=200&q=80')),
                  const SizedBox(width: 4),
                  Expanded(child: _buildEthosImage('https://images.unsplash.com/photo-1618220179428-22790b46a0eb?w=200&q=80')),
                  const SizedBox(width: 4),
                  Expanded(child: _buildEthosImage('https://images.unsplash.com/photo-1584100936595-c0654b55a2e2?w=200&q=80')),
                ],
              ),
              const CustomFooter(),
              const SizedBox(height: 100),
            ],
          ),
        ),
      );
  }

  Widget _buildCollectionCard(String title, String imageUrl) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 160,
          height: 190,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: AppColors.secondaryColor,
            image: DecorationImage(
              image: NetworkImage(imageUrl),
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
      ],
    );
  }

  Widget _buildProductCard(String name, String price, String imageUrl) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 180,
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            image: DecorationImage(
              image: NetworkImage(imageUrl),
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        const SizedBox(height: 6),
        Text(price, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
      ],
    );
  }

  Widget _buildEthosImage(String imageUrl) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: AppColors.secondaryColor,
        image: DecorationImage(
          image: NetworkImage(imageUrl),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildDesignerCard(String name, String role, String imageUrl) {
    return Container(
      width: 140,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 36,
            backgroundImage: NetworkImage(imageUrl),
            backgroundColor: AppColors.secondaryColor,
          ),
          const SizedBox(height: 12),
          Text(name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          const SizedBox(height: 4),
          Text(role, style: TextStyle(color: Colors.grey.shade500, fontSize: 11), textAlign: TextAlign.center),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.primaryColor),
                padding: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Consult', style: TextStyle(color: AppColors.primaryColor, fontSize: 12, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}
