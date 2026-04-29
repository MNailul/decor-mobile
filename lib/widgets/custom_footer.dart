import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../views/home/about_us_page.dart';

class CustomFooter extends StatelessWidget {
  const CustomFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          const Divider(color: Colors.black12),
          const SizedBox(height: 24),
          const Text(
            'DECOR',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: 8,
              color: AppColors.primaryColor,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildFooterLink(context, 'Shop', onTap: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              }),
              const SizedBox(width: 24),
              _buildFooterLink(context, 'About', onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AboutUsPage()),
                );
              }),
              const SizedBox(width: 24),
              _buildFooterLink(context, 'Journal'),
              const SizedBox(width: 24),
              _buildFooterLink(context, 'Contact'),
            ],
          ),
          const SizedBox(height: 24),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.camera_alt_outlined, color: Colors.grey, size: 20),
              SizedBox(width: 16),
              Icon(Icons.facebook, color: Colors.grey, size: 20),
            ],
          ),
          const SizedBox(height: 32),
          const Text(
            '© 2026 Decor Studio. All rights reserved.',
            style: TextStyle(fontSize: 10, color: Colors.grey, letterSpacing: 1),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterLink(BuildContext context, String text, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: Colors.black54,
          letterSpacing: 1.5,
        ),
      ),
    );
  }
}
