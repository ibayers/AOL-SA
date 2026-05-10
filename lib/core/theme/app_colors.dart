import 'package:flutter/material.dart';

/// Design System: "The Serene Ledger" — extracted from Stitch
class AppColors {
  AppColors._();

  // Primary
  static const Color primary = Color(0xFF006565);
  static const Color primaryContainer = Color(0xFF008080);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onPrimaryContainer = Color(0xFFE3FFFE);

  // Secondary (Income / Growth — Mint)
  static const Color secondary = Color(0xFF006C52);
  static const Color secondaryContainer = Color(0xFF8FF6D0);
  static const Color onSecondary = Color(0xFFFFFFFF);

  // Tertiary (Expense / Outflow — Coral)
  static const Color tertiary = Color(0xFF9A3B35);
  static const Color tertiaryContainer = Color(0xFFB9534B);
  static const Color onTertiary = Color(0xFFFFFFFF);

  // Surfaces
  static const Color surface = Color(0xFFF7F9FC);
  static const Color surfaceBright = Color(0xFFF7F9FC);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF2F4F7);
  static const Color surfaceContainer = Color(0xFFECEEF1);
  static const Color surfaceContainerHigh = Color(0xFFE6E8EB);
  static const Color surfaceContainerHighest = Color(0xFFE0E3E6);
  static const Color surfaceDim = Color(0xFFD8DADD);

  // On Surface
  static const Color onSurface = Color(0xFF191C1E);
  static const Color onSurfaceVariant = Color(0xFF3E4949);

  // Outlines
  static const Color outline = Color(0xFF6E7979);
  static const Color outlineVariant = Color(0xFFBDC9C8);

  // Error
  static const Color error = Color(0xFFBA1A1A);
  static const Color errorContainer = Color(0xFFFFDAD6);

  // Inverse
  static const Color inverseSurface = Color(0xFF2D3133);
  static const Color inversePrimary = Color(0xFF76D6D5);

  // Semantic colors
  static const Color income = secondary;
  static const Color expense = tertiary;
  static const Color incomeLight = secondaryContainer;
  static const Color expenseLight = Color(0xFFFFDAD6);

  // Gradient
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryContainer],
  );
}
