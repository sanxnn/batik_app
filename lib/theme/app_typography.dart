import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

abstract final class AppTypography {
  static TextTheme get textTheme => GoogleFonts.interTextTheme(
    const TextTheme(
      displaySmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: AppColors.ink,
        height: 1.2,
      ),
      titleLarge: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.ink,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.ink,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
        height: 1.45,
      ),
      bodyLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.ink,
      ),
      headlineSmall: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: AppColors.ink,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
      ),
      labelSmall: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
      ),
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.ink,
      ),
    ),
  );
}
