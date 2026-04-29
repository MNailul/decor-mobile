import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'ABOUT US',
          style: GoogleFonts.epilogue(
            color: Colors.black,
            fontWeight: FontWeight.w700,
            fontSize: 16,
            letterSpacing: 1.5,
          ),
        ),
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
                    text: TextSpan(
                      style: GoogleFonts.epilogue(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        height: 1.1,
                        color: const Color(0xFF1E1E1E),
                      ),
                      children: [
                        const TextSpan(text: 'Elevating\n'),
                        TextSpan(
                          text: 'Atmosphe\nre.',
                          style: GoogleFonts.epilogue(
                            color: AppColors.primaryColor,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  Container(
                    width: 140,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '2026',
                          style: GoogleFonts.epilogue(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'THE NEW ERA OF CURATORIAL LIVING',
                          style: GoogleFonts.epilogue(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'DECOR presents a premium furniture collection that blends the art of interior design with future technology. We believe every corner of your home is a reflection of your identity.',
                    style: GoogleFonts.epilogue(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 48),

            // AI Section
            Container(
              padding: const EdgeInsets.all(24),
              color: Colors.grey.shade50,
              child: Column(
                children: [
                  Text(
                    'FUTURE INTELLIGENCE',
                    style: GoogleFonts.epilogue(
                      color: AppColors.primaryColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Generative AI Assistance',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.epilogue(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1E1E1E),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Kami mengintegrasikan kecerdasan buatan untuk membantu Anda memvisualisasikan hunian impian secara instan.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.epilogue(
                      color: Colors.grey.shade500,
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 40),
                  
                  _buildAiCard(
                    Icons.auto_awesome_mosaic_outlined,
                    'Prompt to Design',
                    'Ketikkan visi Anda, dan biarkan Generative-AI kami menyusun moodboard furnitur yang paling sesuai dalam hitungan detik.',
                  ),
                  const SizedBox(height: 16),
                  _buildAiCard(
                    Icons.psychology_outlined,
                    'Smart Curation',
                    'AI kami mempelajari preferensi material dan warna Anda untuk menyarankan furnitur dari katalog yang melengkapi koleksi Anda.',
                  ),
                  const SizedBox(height: 16),
                  _buildAiCard(
                    Icons.view_in_ar_outlined,
                    'Virtual Staging',
                    'Ubah floor plan Anda menjadi visualisasi yang nyata menggunakan teknologi yang kami sediakan.',
                  ),
                ],
              ),
            ),

            // Mission Quote
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 80.0),
              child: Column(
                children: [
                  Text(
                    'OUR CORE MISSION',
                    style: GoogleFonts.epilogue(
                      color: Colors.grey.shade400,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 32),
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: GoogleFonts.epilogue(
                        fontSize: 22,
                        height: 1.6,
                        color: Colors.grey.shade500,
                      ),
                      children: [
                        const TextSpan(text: '"Empowering every individual to be the '),
                        TextSpan(
                          text: 'creator',
                          style: GoogleFonts.epilogue(
                            color: const Color(0xFF1E1E1E),
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                            decorationColor: AppColors.primaryColor,
                          ),
                        ),
                        const TextSpan(text: ' of their own home, supported by the best designers and the most advanced technology."'),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Mini Footer
            Container(
              padding: const EdgeInsets.all(40),
              color: AppColors.primaryColor,
              width: double.infinity,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.chair_outlined, color: Colors.white, size: 24),
                      const SizedBox(width: 12),
                      Text(
                        'DECOR',
                        style: GoogleFonts.epilogue(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Text(
                    '© 2026 DECOR MARKETPLACE. ALL RIGHTS RESERVED.',
                    style: GoogleFonts.epilogue(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAiCard(IconData icon, String title, String description) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primaryColor, size: 24),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: GoogleFonts.epilogue(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1E1E1E),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: GoogleFonts.epilogue(
              color: Colors.grey.shade500,
              fontSize: 12,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
