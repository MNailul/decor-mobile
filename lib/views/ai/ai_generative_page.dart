import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/bounce_tap.dart';
import '../../widgets/animated_wishlist_button.dart';

class AiGenerativePage extends StatefulWidget {
  const AiGenerativePage({super.key});

  @override
  State<AiGenerativePage> createState() => _AiGenerativePageState();
}

class _AiGenerativePageState extends State<AiGenerativePage> {
  String selectedStyle = 'Scandinavian';
  double sliderValue = 0.5;

  final List<Map<String, String>> styles = [
    {
      'name': 'Scandinavian',
      'desc': 'LIGHT & ORGANIC',
      'image': 'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=400&q=80',
    },
    {
      'name': 'Industrial',
      'desc': 'RAW & STRUCTURAL',
      'image': 'https://images.unsplash.com/photo-1513519245088-0e12902e5a38?w=400&q=80',
    },
    {
      'name': 'Minimalist',
      'desc': 'PURE & ESSENTIAL',
      'image': 'https://images.unsplash.com/photo-1555041469-a586c61ea9bc?w=400&q=80',
    },
    {
      'name': 'Modern',
      'desc': 'SLEEK & FLUID',
      'image': 'https://images.unsplash.com/photo-1513694203232-719a280e022f?w=400&q=80',
    },
    {
      'name': 'Classic',
      'desc': 'TIMELESS & ORNATE',
      'image': 'https://images.unsplash.com/photo-1544457070-4cd773b4d71e?w=400&q=80',
    },
  ];

  final List<Map<String, String>> recommendedProducts = [
    {
      'name': 'Aurelius Lounge Chair',
      'desc': 'Brushed Walnut & Tan Leather',
      'price': '\$2,450',
      'image': 'https://images.unsplash.com/photo-1581539250439-c96689b516dd?w=400&q=80',
    },
    {
      'name': 'Zenith Pendant Light',
      'desc': 'Matte Black Steel',
      'price': '\$890',
      'image': 'https://images.unsplash.com/photo-1513506003901-1e6a229e2d15?w=400&q=80',
    },
    {
      'name': 'Nordic Floating Credenza',
      'desc': 'White Oak Finish',
      'price': '\$1,720',
      'image': 'https://images.unsplash.com/photo-1595428774223-ef52624120d2?w=400&q=80',
    },
    {
      'name': 'Handwoven Wool Rug',
      'desc': 'Organic Ivory Fibers',
      'price': '\$640',
      'image': 'https://images.unsplash.com/photo-1531835673320-96f30a6c6731?w=400&q=80',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'DESIGN LAB',
          style: TextStyle(
            color: Colors.black,
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Section
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: const TextSpan(
                      children: [
                        TextSpan(
                          text: 'Reimagine\n',
                          style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.w900,
                            color: Colors.black,
                            height: 1.1,
                          ),
                        ),
                        TextSpan(
                          text: 'Your Space',
                          style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.w900,
                            color: AppColors.primaryColor,
                            fontStyle: FontStyle.italic,
                            height: 1.1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Upload a photo of your room and let our generative AI architect curate a professional interior design tailored to your architectural bones.',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 15,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),

            // Room Upload Area
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                width: double.infinity,
                height: 180,
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.grey.shade200,
                    style: BorderStyle.solid,
                    width: 1,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                          )
                        ],
                      ),
                      child: const Icon(Icons.camera_alt_outlined, color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Upload Room Photo',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'JPEG, PNG or HEIC up to 20MB',
                      style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 40),

            // Comparison Slider Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Stack(
                  children: [
                    // New Image
                    Container(
                      height: 350,
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: NetworkImage('https://images.unsplash.com/photo-1618221195710-dd6b41faaea6?w=800&q=80'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    // Old Image (Clipped)
                    ClipRect(
                      clipper: _ImageClipper(sliderValue),
                      child: Container(
                        height: 350,
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                            image: NetworkImage('https://images.unsplash.com/photo-1513694203232-719a280e022f?w=800&q=80'),
                            fit: BoxFit.cover,
                          ),
                        ),
                        foregroundDecoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.3),
                        ),
                      ),
                    ),
                    // Labels
                    Positioned(
                      top: 16,
                      left: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text('SOURCE PHOTO', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    Positioned(
                      top: 16,
                      right: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text('AI REIMAGINED', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    // Slider Control
                    Positioned.fill(
                      child: SliderTheme(
                        data: SliderThemeData(
                          trackHeight: 0,
                          thumbShape: _CustomThumbShape(),
                          overlayColor: Colors.transparent,
                        ),
                        child: Slider(
                          value: sliderValue,
                          onChanged: (val) => setState(() => sliderValue = val),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 48),

            // Style Selection
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Select Architectural Style',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Our AI filters through thousands of design monographs to apply specific aesthetic principles to your layout.',
                style: TextStyle(color: Colors.grey.shade500, fontSize: 13, height: 1.5),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 220,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: styles.length,
                itemBuilder: (context, index) {
                  final style = styles[index];
                  final isSelected = selectedStyle == style['name'];
                  return GestureDetector(
                    onTap: () => setState(() => selectedStyle = style['name']!),
                    child: Container(
                      width: 140,
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 160,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: isSelected 
                                ? Border.all(color: AppColors.primaryColor, width: 2)
                                : null,
                              image: DecorationImage(
                                image: NetworkImage(style['image']!),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            style['name']!,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: isSelected ? AppColors.primaryColor : Colors.black,
                            ),
                          ),
                          Text(
                            style['desc']!,
                            style: TextStyle(color: Colors.grey.shade500, fontSize: 9, letterSpacing: 1),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 32),

            // Generate Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: BounceTap(
                onTap: () {},
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.auto_awesome, color: Colors.white, size: 18),
                        SizedBox(width: 12),
                        Text(
                          'GENERATE DESIGN',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 48),

            // Shop the Look
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Shop the Look', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  Text(
                    'VIEW ALL 12 ITEMS',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                      color: Colors.grey.shade400,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.7,
                mainAxisSpacing: 24,
                crossAxisSpacing: 16,
              ),
              itemCount: recommendedProducts.length,
              itemBuilder: (context, index) {
                final product = recommendedProducts[index];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(12),
                              image: DecorationImage(
                                image: NetworkImage(product['image']!),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: AnimatedWishlistButton(
                                size: 14,
                                onChanged: (isLiked) {},
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      product['name']!,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    Text(
                      product['desc']!,
                      style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      product['price']!,
                      style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryColor),
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}

class _ImageClipper extends CustomClipper<Rect> {
  final double value;
  _ImageClipper(this.value);

  @override
  Rect getClip(Size size) {
    return Rect.fromLTRB(0, 0, size.width * value, size.height);
  }

  @override
  bool shouldReclip(_ImageClipper oldClipper) => oldClipper.value != value;
}

class _CustomThumbShape extends SliderComponentShape {
  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) => const Size(40, 40);

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final canvas = context.canvas;

    // Draw vertical line
    final linePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2;
    canvas.drawLine(
      Offset(center.dx, center.dy - 175),
      Offset(center.dx, center.dy + 175),
      linePaint,
    );

    // Draw circle thumb
    final circlePaint = Paint()..color = Colors.white;
    canvas.drawCircle(center, 20, circlePaint);

    // Draw icons
    const icon = Icons.unfold_more_rounded;
    final textPainter = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(icon.codePoint),
        style: TextStyle(
          fontSize: 24,
          fontFamily: icon.fontFamily,
          color: Colors.black,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(center.dx - textPainter.width / 2, center.dy - textPainter.height / 2),
    );
  }
}
