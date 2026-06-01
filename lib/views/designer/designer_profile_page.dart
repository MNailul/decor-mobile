import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../providers/auth_provider.dart';
import '../../providers/designer_provider.dart';
import '../../models/designer_model.dart';
import '../auth/login_page.dart';
import 'designer_booking_page.dart';
import 'free_chat_page.dart';
import 'portfolio_detail_page.dart';

class DesignerProfilePage extends StatefulWidget {
  final DesignerModel designer;

  const DesignerProfilePage({super.key, required this.designer});

  @override
  State<DesignerProfilePage> createState() => _DesignerProfilePageState();
}

class _DesignerProfilePageState extends State<DesignerProfilePage> {
  late DesignerModel currentDesigner;
  bool _isRefreshing = false;

  static const Color primaryColor = Color(0xFFB5733A);
  static const Color textColor = Color(0xFF1E1E1E);

  @override
  void initState() {
    super.initState();
    currentDesigner = widget.designer;
    _refreshDesignerData();
  }

  Future<void> _refreshDesignerData() async {
    setState(() => _isRefreshing = true);
    try {
      final updatedDesigner = await context.read<DesignerProvider>().getDesignerDetail(widget.designer.id);
      if (updatedDesigner != null && mounted) {
        setState(() {
          currentDesigner = updatedDesigner;
        });
      }
    } finally {
      if (mounted) setState(() => _isRefreshing = false);
    }
  }

  Future<void> _launchURL(String? urlString) async {
    if (urlString == null || urlString.isEmpty) return;
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $urlString');
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: _isRefreshing ? Colors.grey : textColor, size: 20),
            onPressed: _isRefreshing ? null : _refreshDesignerData,
          ),
          if (currentDesigner.instagramUrl != null && currentDesigner.instagramUrl!.isNotEmpty)
            IconButton(
              icon: const FaIcon(FontAwesomeIcons.instagram, color: textColor, size: 20),
              onPressed: () => _launchURL(currentDesigner.instagramUrl),
            ),
          if (currentDesigner.linkedinUrl != null && currentDesigner.linkedinUrl!.isNotEmpty)
            IconButton(
              icon: const FaIcon(FontAwesomeIcons.linkedin, color: textColor, size: 20),
              onPressed: () => _launchURL(currentDesigner.linkedinUrl),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshDesignerData,
        color: primaryColor,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cover Banner and Profile Image Stack
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: double.infinity,
                    height: 160,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      image: DecorationImage(
                        image: NetworkImage(currentDesigner.banner ?? 'https://images.unsplash.com/photo-1618221195710-dd6b41faaea6?q=80&w=1200'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -50,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 54,
                            backgroundImage: NetworkImage(currentDesigner.image),
                            backgroundColor: Colors.white,
                          ),
                          if (currentDesigner.isOpen)
                            Positioned(
                              bottom: 2,
                              right: 4,
                              child: Container(
                                width: 18,
                                height: 18,
                                decoration: BoxDecoration(
                                  color: Colors.green.shade500,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 2.5),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 66),

              // Profile Name, Specialty and Open Status Details
              Center(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          currentDesigner.studioName,
                          style: GoogleFonts.epilogue(
                            color: textColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.verified, color: Colors.blue, size: 24),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      currentDesigner.specialty,
                      style: GoogleFonts.epilogue(
                        color: primaryColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: currentDesigner.isOpen ? Colors.green.shade50 : Colors.red.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: currentDesigner.isOpen ? Colors.green.shade200 : Colors.red.shade200,
                          width: 0.5,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: currentDesigner.isOpen ? Colors.green.shade500 : Colors.red.shade500,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            currentDesigner.isOpen ? 'OPEN FOR PROJECTS' : 'CLOSED FOR PROJECTS',
                            style: GoogleFonts.epilogue(
                              color: currentDesigner.isOpen ? Colors.green.shade700 : Colors.red.shade700,
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),
              
              // Stats Row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatItem('Rating', currentDesigner.rating.toStringAsFixed(1), Icons.star_rounded, primaryColor),
                    Container(width: 1, height: 40, color: Colors.grey.shade300),
                    _buildStatItem('Projects', '${currentDesigner.projectsCompleted}', Icons.task_alt, primaryColor),
                    Container(width: 1, height: 40, color: Colors.grey.shade300),
                    _buildStatItem('Avg. Duration', currentDesigner.averageProjectDuration ?? '-', Icons.timer_outlined, primaryColor),
                  ],
                ),
              ),

              const SizedBox(height: 32),
              
              // About Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'About Designer',
                      style: GoogleFonts.epilogue(
                        color: textColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      currentDesigner.bio ?? 'No bio provided.',
                      style: GoogleFonts.epilogue(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                        height: 1.6,
                      ),
                    ),
                    if (currentDesigner.education != null && currentDesigner.education!.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          const Icon(Icons.school_outlined, color: primaryColor, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Education',
                            style: GoogleFonts.epilogue(
                              color: textColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        currentDesigner.education!,
                        style: GoogleFonts.epilogue(
                          color: Colors.grey.shade600,
                          fontSize: 13,
                          height: 1.5,
                        ),
                      ),
                    ],
                    if (currentDesigner.awards != null && currentDesigner.awards!.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          const Icon(Icons.emoji_events_outlined, color: primaryColor, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Awards & Achievements',
                            style: GoogleFonts.epilogue(
                              color: textColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        currentDesigner.awards!,
                        style: GoogleFonts.epilogue(
                          color: Colors.grey.shade600,
                          fontSize: 13,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Portfolio Section
              if (currentDesigner.portfolios != null && currentDesigner.portfolios!.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Portfolio',
                        style: GoogleFonts.epilogue(
                          color: textColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      if ((currentDesigner.instagramUrl != null && currentDesigner.instagramUrl!.isNotEmpty) ||
                          (currentDesigner.linkedinUrl != null && currentDesigner.linkedinUrl!.isNotEmpty))
                        Row(
                          children: [
                            const Icon(Icons.info_outline, size: 12, color: primaryColor),
                            const SizedBox(width: 4),
                            Text(
                              'Lihat sosmed untuk karya lengkap',
                              style: GoogleFonts.epilogue(
                                color: primaryColor,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 240,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    scrollDirection: Axis.horizontal,
                    itemCount: currentDesigner.portfolios!.length,
                    itemBuilder: (context, index) {
                      final portfolio = currentDesigner.portfolios![index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PortfolioDetailPage(portfolio: portfolio),
                            ),
                          );
                        },
                        child: Container(
                          width: 200,
                          margin: const EdgeInsets.symmetric(horizontal: 8.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            image: DecorationImage(
                              image: NetworkImage(portfolio.imageUrl),
                              fit: BoxFit.cover,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(24),
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withOpacity(0.7),
                                ],
                              ),
                            ),
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    if (portfolio.category != null)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          portfolio.category!.toUpperCase(),
                                          style: GoogleFonts.epilogue(
                                            color: Colors.white,
                                            fontSize: 8,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 1,
                                          ),
                                        ),
                                      )
                                    else
                                      const SizedBox.shrink(),
                                    if (portfolio.is360)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: primaryColor,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(Icons.panorama_photosphere_outlined, color: Colors.white, size: 8),
                                            const SizedBox(width: 2),
                                            Text(
                                              '360°',
                                              style: GoogleFonts.epilogue(
                                                color: Colors.white,
                                                fontSize: 8,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  portfolio.title ?? 'Untitled Project',
                                  style: GoogleFonts.epilogue(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 32),
              ] else if (!_isRefreshing) ...[
                 Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Center(
                    child: Text(
                      'No portfolio items found.',
                      style: GoogleFonts.epilogue(color: Colors.grey, fontSize: 12),
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 120), // Bottom padding
            ],
          ),
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(24.0),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Builder(
          builder: (context) {
            bool hasUsedFreeChat = false;
            bool isActiveFreeChat = false;
            int timeLeft = 0;

            if (currentDesigner.freeConsultation != null) {
              final fc = currentDesigner.freeConsultation!;
              hasUsedFreeChat = fc['is_completed'] == true || !(fc['is_active'] ?? false);
              isActiveFreeChat = fc['is_active'] == true;
              timeLeft = fc['time_left'] ?? 0;
            }

            String buttonText = 'Book Consultation';
            if (isActiveFreeChat) {
              buttonText = 'Continue Free Chat (${timeLeft ~/ 60}m left)';
            } else if (!hasUsedFreeChat) {
              buttonText = 'Start 10 Min Free Chat';
            }

            return SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: () async {
                  final authProvider = Provider.of<AuthProvider>(context, listen: false);
                  
                  if (!authProvider.isLoggedIn) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Please login to book a consultation'),
                        behavior: SnackBarBehavior.floating,
                        action: SnackBarAction(
                          label: 'LOGIN',
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const LoginPage()),
                            );
                          },
                        ),
                      ),
                    );
                    return;
                  }

                  if (isActiveFreeChat) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FreeChatPage(
                          designer: currentDesigner,
                          initialTimeLeft: timeLeft,
                        ),
                      ),
                    ).then((_) => _refreshDesignerData());
                  } else if (!hasUsedFreeChat) {
                    // Start free chat API call
                    final result = await context.read<DesignerProvider>().startFreeChat(currentDesigner.id);
                    if (result != null && mounted) {
                      final fc = result['free_consultation'];
                      int newTimeLeft = result['time_left'] ?? 600;
                      if (fc != null && fc['is_completed'] == true) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DesignerBookingPage(designer: currentDesigner),
                          ),
                        );
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FreeChatPage(
                              designer: currentDesigner,
                              initialTimeLeft: newTimeLeft,
                            ),
                          ),
                        ).then((_) => _refreshDesignerData());
                      }
                    } else if (mounted) {
                       ScaffoldMessenger.of(context).showSnackBar(
                         const SnackBar(content: Text('Failed to start free consultation')),
                       );
                    }
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DesignerBookingPage(designer: currentDesigner),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: !hasUsedFreeChat ? Colors.green.shade600 : primaryColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: context.watch<DesignerProvider>().isLoading && (!hasUsedFreeChat || isActiveFreeChat)
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : Text(
                        buttonText,
                        style: GoogleFonts.epilogue(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          letterSpacing: 0.5,
                        ),
                      ),
              ),
            );
          }
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color iconColor) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, color: iconColor, size: 20),
            const SizedBox(width: 4),
            Text(
              value,
              style: GoogleFonts.epilogue(
                color: textColor,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.epilogue(
            color: Colors.grey.shade500,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
