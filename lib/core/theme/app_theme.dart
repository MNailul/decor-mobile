import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: AppColors.primaryColor,
      scaffoldBackgroundColor: Colors.white,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryColor,
        secondary: AppColors.secondaryColor,
      ),
      textTheme: GoogleFonts.interTextTheme(),
      useMaterial3: true,
    );
  }
}
