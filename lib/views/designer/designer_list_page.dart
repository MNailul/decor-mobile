import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/designer_provider.dart';
import '../../models/designer_model.dart';
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DesignerProvider>().loadDesigners();
    });
  }

  @override
  Widget build(BuildContext context) {
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
      body: Consumer<DesignerProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.designers.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.designers.isEmpty) {
            return const Center(child: Text('No designers available'));
          }

          final allDesigners = provider.designers;
          // Top designer is featured
          final featuredDesigner = allDesigners[0];
          
          // Remaining designers for the grid
          final gridDesigners = allDesigners.length > 1 ? allDesigners.sublist(1) : <DesignerModel>[];
          
          // Pagination logic
          const itemsPerPage = 4;
          final totalPages = (gridDesigners.length / itemsPerPage).ceil() == 0 ? 1 : (gridDesigners.length / itemsPerPage).ceil();
          final paginatedDesigners = gridDesigners.skip((currentPage - 1) * itemsPerPage).take(itemsPerPage).toList();

          return SingleChildScrollView(
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
                if (paginatedDesigners.isNotEmpty)
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.54,
                    ),
                    itemCount: paginatedDesigners.length,
                    itemBuilder: (context, index) {
                      final designer = paginatedDesigners[index];
                      return _buildGridDesignerCard(designer);
                    },
                  )
                else if (allDesigners.length == 1)
                  const Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Text('No more designers to explore'),
                  ),

                // Pagination Controls
                if (gridDesigners.isNotEmpty)
                  _buildPaginationControls(totalPages),

                const SizedBox(height: 48),

                // Footer Widget
                const CustomFooter(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFeaturedDesigner(DesignerModel designer) {
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
                    backgroundImage: NetworkImage(designer.image),
                    backgroundColor: secondaryColor,
                  ),
                  if (designer.isOpen)
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
                        'FEATURED DESIGNER',
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
                            designer.studioName,
                            style: GoogleFonts.epilogue(
                              color: textColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.verified, color: Colors.blue, size: 16),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      designer.specialty,
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
            designer.bio ?? 'No bio available.',
            style: GoogleFonts.epilogue(
              color: Colors.grey.shade600,
              fontSize: 13,
              height: 1.5,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 20),
          if (designer.portfolios != null && designer.portfolios!.isNotEmpty) ...[
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
              children: designer.portfolios!.take(3).map((p) {
                return Expanded(
                  child: Container(
                    height: 100,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      image: DecorationImage(
                        image: NetworkImage(p.imageUrl),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
          ],
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
                'View Profile',
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

  Widget _buildGridDesignerCard(DesignerModel designer) {
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
                backgroundImage: NetworkImage(designer.image),
                backgroundColor: secondaryColor,
              ),
              if (designer.isOpen)
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
                  designer.studioName,
                  style: GoogleFonts.epilogue(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.verified, color: Colors.blue, size: 14),
            ],
          ),
          const SizedBox(height: 2),
          
          // Specialty
          Text(
            designer.specialty,
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
                    '4.9',
                    style: GoogleFonts.epilogue(
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                      color: textColor,
                    ),
                  ),
                ],
              ),
              Text(
                '${designer.projectsCompleted} Projects',
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
            designer.bio ?? '',
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
          if (designer.portfolios != null && designer.portfolios!.isNotEmpty)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: designer.portfolios!.take(3).map((p) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    image: DecorationImage(
                      image: NetworkImage(p.imageUrl),
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
                'Consult',
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
