import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

abstract class AppTextStyles {
  static final TextStyle glucoseValue = GoogleFonts.montserrat(
    fontSize: 72, fontWeight: FontWeight.w700,
    color: AppColors.textPrimary, letterSpacing: -3, height: 1.0,
  );
  static final TextStyle glucoseValueSmall = GoogleFonts.montserrat(
    fontSize: 48, fontWeight: FontWeight.w700,
    color: AppColors.textPrimary, letterSpacing: -2, height: 1.0,
  );
  static final TextStyle glucoseValueWhite = GoogleFonts.montserrat(
    fontSize: 72, fontWeight: FontWeight.w700,
    color: Colors.white, letterSpacing: -3, height: 1.0,
  );
  static final TextStyle h1 = GoogleFonts.montserrat(
    fontSize: 34, fontWeight: FontWeight.w700,
    color: AppColors.textPrimary, letterSpacing: -1.2, height: 1.1,
  );
  static final TextStyle h1White = GoogleFonts.montserrat(
    fontSize: 34, fontWeight: FontWeight.w700,
    color: Colors.white, letterSpacing: -1.2, height: 1.1,
  );
  static final TextStyle h2 = GoogleFonts.montserrat(
    fontSize: 26, fontWeight: FontWeight.w600,
    color: AppColors.textPrimary, letterSpacing: -0.8, height: 1.2,
  );
  static final TextStyle h3 = GoogleFonts.montserrat(
    fontSize: 20, fontWeight: FontWeight.w600,
    color: AppColors.textPrimary, letterSpacing: -0.5, height: 1.25,
  );
  static final TextStyle h4 = GoogleFonts.montserrat(
    fontSize: 17, fontWeight: FontWeight.w600,
    color: AppColors.textPrimary, letterSpacing: -0.3, height: 1.3,
  );
  static final TextStyle brand = GoogleFonts.montserrat(
    fontSize: 13, fontWeight: FontWeight.w700,
    color: Colors.white, letterSpacing: 3,
  );
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16, fontWeight: FontWeight.w400,
    color: AppColors.textPrimary, height: 1.5,
  );
  static const TextStyle body = TextStyle(
    fontSize: 14, fontWeight: FontWeight.w400,
    color: AppColors.textPrimary, height: 1.5,
  );
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14, fontWeight: FontWeight.w500,
    color: AppColors.textPrimary, height: 1.4,
  );
  static const TextStyle caption = TextStyle(
    fontSize: 12, fontWeight: FontWeight.w400,
    color: AppColors.textSecondary, height: 1.4,
  );
  static const TextStyle captionWhite = TextStyle(
    fontSize: 12, fontWeight: FontWeight.w400,
    color: Colors.white54, height: 1.4,
  );
  static const TextStyle unit = TextStyle(
    fontSize: 15, fontWeight: FontWeight.w400,
    color: AppColors.textSecondary, height: 1.0,
  );
  static const TextStyle unitWhite = TextStyle(
    fontSize: 15, fontWeight: FontWeight.w400,
    color: Colors.white54, height: 1.0,
  );
  static final TextStyle button = GoogleFonts.montserrat(
    fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: -0.2, height: 1.2,
  );
  static final TextStyle label = GoogleFonts.montserrat(
    fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.5, height: 1.2,
  );
  static final TextStyle navLabel = GoogleFonts.montserrat(
    fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 0.3, height: 1.2,
  );
}
