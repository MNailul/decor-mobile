import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../widgets/custom_footer.dart';
import 'designer_profile_page.dart';

class DesignerListPage extends StatefulWidget {
  const DesignerListPage({super.key});

  @override
  State<DesignerListPage> createState() => _DesignerListPageState();
}

class _DesignerListPageState extends State<DesignerListPage> {
  static const Color primaryColor = Color(0xFFB5733A);
  static const Color secondaryColor = Color(0xFFE3DCD6);
  static const Color textColor = Color(0xFF1E1E1E);

  int currentPage = 1;

  // Dummy Data
  final List<Map<String, dynamic>> allDesigners = [
    {
      'name': 'Sarah Chen',
      'specialty': 'Minimalist Living',
      'rating': '4.9',
      'price': 'Mulai Rp 500k',
      'isOnline': true,
      'isVerified': true,
      'bio': 'Award-winning architect specializing in clean lines and natural light.',
      'image': 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200&q=80',
      'portfolio': [
        'https://images.unsplash.com/photo-1618220179428-22790b46a0eb?w=200&q=80',
        'https://images.unsplash.com/photo-1584100936595-c0654b55a2e2?w=200&q=80',
        'https://images.unsplash.com/photo-1513694203232-719a280e022f?w=200&q=80',
      ]
    },
    {
      'name': 'Mark Doe',
      'specialty': 'Space Planner',
      'rating': '4.8',
      'price': 'Mulai Rp 400k',
      'isOnline': false,
      'isVerified': true,
      'bio': 'Expert in maximizing small spaces without compromising aesthetics.',
      'image': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200&q=80',
      'portfolio': [
        'https://images.unsplash.com/photo-1513519245088-0e12902e5a38?w=200&q=80',
        'https://images.unsplash.com/photo-1507473885765-e6ed057f782c?w=200&q=80',
        'https://images.unsplash.com/photo-1616486029423-aaa4789e8c9a?w=200&q=80',
      ]
    },
    {
      'name': 'Alia Smith',
      'specialty': 'Decor Specialist',
      'rating': '4.7',
      'price': 'Mulai Rp 350k',
      'isOnline': true,
      'isVerified': false,
      'bio': 'Bringing warmth and texture to modern spaces with curated decor.',
      'image': 'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=200&q=80',
      'portfolio': [
        'https://images.unsplash.com/photo-1616486029423-aaa4789e8c9a?w=200&q=80',
        'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=200&q=80',
        'https://images.unsplash.com/photo-1505691938895-1758d7feb511?w=200&q=80',
      ]
    },
    {
      'name': 'Evan Wright',
      'specialty': 'Lighting Design',
      'rating': '5.0',
      'price': 'Mulai Rp 600k',
      'isOnline': true,
      'isVerified': true,
      'bio': 'Illuminating your space to create the perfect mood for every occasion.',
      'image': 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=200&q=80',
      'portfolio': [
        'https://images.unsplash.com/photo-1513694203232-719a280e022f?w=200&q=80',
        'https://images.unsplash.com/photo-1505691938895-1758d7feb511?w=200&q=80',
        'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?w=200&q=80',
      ]
    },
    {
      'name': 'Chloe Adams',
      'specialty': 'Sustainable Design',
      'rating': '4.6',
      'price': 'Mulai Rp 450k',
      'isOnline': false,
      'isVerified': true,
      'bio': 'Creating beautiful, eco-friendly spaces with responsibly sourced items.',
      'image': 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200&q=80',
      'portfolio': [
        'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?w=200&q=80',
        'https://images.unsplash.com/photo-1600566753190-17f0baa2a6c3?w=200&q=80',
        'https://images.unsplash.com/photo-1505843490538-5133c6c7d0e1?w=200&q=80',
      ]
    },
    {
      'name': 'David Kim',
      'specialty': 'Industrial Modern',
      'rating': '4.8',
      'price': 'Mulai Rp 550k',
      'isOnline': true,
      'isVerified': true,
      'bio': 'Blending raw elements with modern comfort for a bold aesthetic.',
      'image': 'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=200&q=80',
      'portfolio': [
        'https://images.unsplash.com/photo-1505843490538-5133c6c7d0e1?w=200&q=80',
        'https://images.unsplash.com/photo-1512918728675-ed5a9ecdebfd?w=200&q=80',
        'https://images.unsplash.com/photo-1618220179428-22790b46a0eb?w=200&q=80',
      ]
    },
  ];

  @override
  Widget build(BuildContext context) {
    // Top designer is featured
    final featuredDesigner = allDesigners[0];
    
    // Remaining designers for the grid
    final gridDesigners = allDesigners.sublist(1);
    
    // Pagination logic
    const itemsPerPage = 4;
    final totalPages = (gridDesigners.length / itemsPerPage).ceil();
    final paginatedDesigners = gridDesigners.skip((currentPage - 1) * itemsPerPage).take(itemsPerPage).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Our Designers',
          style: GoogleFonts.epilogue(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Featured Designer
            _buildFeaturedDesigner(featuredDesigner),
            
            // Section Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Explore Designers',
                  style: GoogleFonts.epilogue(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ),

            // Designer Grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.54, // Adjusted for the expanded card layout
              ),
              itemCount: paginatedDesigners.length,
              itemBuilder: (context, index) {
                final designer = paginatedDesigners[index];
                return _buildGridDesignerCard(designer);
              },
            ),

            // Pagination Controls
            _buildPaginationControls(totalPages),

            const SizedBox(height: 48),

            // Footer Widget
            const CustomFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturedDesigner(Map<String, dynamic> designer) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DesignerProfilePage(designer: designer),
          ),
        );
      },
      child: Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundImage: NetworkImage(designer['image']),
                    backgroundColor: secondaryColor,
                  ),
                  if (designer['isOnline'] == true)
                    Positioned(
                      bottom: 0,
                      right: 4,
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: Colors.green.shade500,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'DESIGNER OF THE MONTH',
                        style: GoogleFonts.epilogue(
                          color: primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            designer['name'],
                            style: GoogleFonts.epilogue(
                              color: textColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (designer['isVerified'] == true) ...[
                          const SizedBox(width: 4),
                          const Icon(Icons.verified, color: Colors.blue, size: 16),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      designer['specialty'],
                      style: GoogleFonts.epilogue(
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            designer['bio'],
            style: GoogleFonts.epilogue(
              color: Colors.grey.shade600,
              fontSize: 13,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Selected Works',
            style: GoogleFonts.epilogue(
              color: textColor,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: (designer['portfolio'] as List<String>).take(3).map((url) {
              return Expanded(
                child: Container(
                  height: 100,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    image: DecorationImage(
                      image: NetworkImage(url),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DesignerProfilePage(designer: designer),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Konsultasi',
                style: GoogleFonts.epilogue(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    ),
    );
  }

  Widget _buildGridDesignerCard(Map<String, dynamic> designer) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DesignerProfilePage(designer: designer),
          ),
        );
      },
      child: Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Avatar & Presence
          Stack(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundImage: NetworkImage(designer['image']),
                backgroundColor: secondaryColor,
              ),
              if (designer['isOnline'] == true)
                Positioned(
                  bottom: 0,
                  right: 4,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.green.shade500,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          
          // Identity & Verified Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  designer['name'],
                  style: GoogleFonts.epilogue(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (designer['isVerified'] == true) ...[
                const SizedBox(width: 4),
                const Icon(Icons.verified, color: Colors.blue, size: 14),
              ]
            ],
          ),
          const SizedBox(height: 2),
          
          // Specialty
          Text(
            designer['specialty'],
            style: GoogleFonts.epilogue(
              color: primaryColor,
              fontWeight: FontWeight.w600,
              fontSize: 10,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),

          // Trust & Pricing Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.star_rounded, color: primaryColor, size: 14),
                  const SizedBox(width: 2),
                  Text(
                    designer['rating'],
                    style: GoogleFonts.epilogue(
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                      color: textColor,
                    ),
                  ),
                ],
              ),
              Text(
                designer['price'],
                style: GoogleFonts.epilogue(
                  color: Colors.grey.shade700,
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Bio
          Text(
            designer['bio'],
            style: GoogleFonts.epilogue(
              color: Colors.grey.shade600,
              fontSize: 10,
              height: 1.3,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),

          // Mini Portfolio Gallery
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: (designer['portfolio'] as List<String>).take(3).map((url) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  image: DecorationImage(
                    image: NetworkImage(url),
                    fit: BoxFit.cover,
                  ),
                ),
              );
            }).toList(),
          ),
          
          const Spacer(),
          
          // Action Footer
          SizedBox(
            width: double.infinity,
            height: 32,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DesignerProfilePage(designer: designer),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Konsultasi',
                style: GoogleFonts.epilogue(
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                ),
              ),
            ),
          ),
        ],
      ),
    ),
    );
  }

  Widget _buildPaginationControls(int totalPages) {
    if (totalPages <= 1) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: currentPage > 1 ? () => setState(() => currentPage--) : null,
            icon: Icon(Icons.chevron_left, color: currentPage > 1 ? textColor : Colors.grey.shade300),
          ),
          const SizedBox(width: 8),
          Text(
            'Page $currentPage of $totalPages',
            style: GoogleFonts.epilogue(
              color: textColor,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: currentPage < totalPages ? () => setState(() => currentPage++) : null,
            icon: Icon(Icons.chevron_right, color: currentPage < totalPages ? textColor : Colors.grey.shade300),
          ),
        ],
      ),
    );
  }
}
