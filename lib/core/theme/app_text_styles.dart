import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Typography — Poppins for all text styles
class AppTextStyles {
  AppTextStyles._();

  // Display — for total balance / net worth
  static TextStyle displayLarge = GoogleFonts.poppins(
    fontSize: 40,
    fontWeight: FontWeight.w700,
    color: AppColors.onSurface,
  );

  static TextStyle displayMedium = GoogleFonts.poppins(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: AppColors.onSurface,
  );

  // Headline — section titles
  static TextStyle headlineLarge = GoogleFonts.poppins(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    color: AppColors.onSurface,
  );

  static TextStyle headlineMedium = GoogleFonts.poppins(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: AppColors.onSurface,
  );

  static TextStyle headlineSmall = GoogleFonts.poppins(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.onSurface,
  );

  // Title — card titles, list item titles
  static TextStyle titleLarge = GoogleFonts.poppins(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.onSurface,
  );

  static TextStyle titleMedium = GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.onSurface,
  );

  static TextStyle titleSmall = GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.onSurface,
  );

  // Body — descriptions, form inputs
  static TextStyle bodyLarge = GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.onSurface,
  );

  static TextStyle bodyMedium = GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.onSurface,
  );

  static TextStyle bodySmall = GoogleFonts.poppins(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.onSurfaceVariant,
  );

  // Label — metadata, captions
  static TextStyle labelLarge = GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.outline,
  );

  static TextStyle labelMedium = GoogleFonts.poppins(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.outline,
  );

  static TextStyle labelSmall = GoogleFonts.poppins(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    color: AppColors.outline,
  );
}
