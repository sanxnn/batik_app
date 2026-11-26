import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_radius.dart';
import 'app_spacing.dart';
import 'app_typography.dart';

class AppTheme {
  AppTheme._();

  // Brand colors
  static const Color primary = AppColors.ink;
  static const Color primaryDark = AppColors.ink;
  static const Color primaryLight = AppColors.yellowSoft;
  static const Color accent = AppColors.brandYellow;
  static const Color onAccent = AppColors.onBrandYellow;

  // Surface colors
  static const Color background = AppColors.background;
  static const Color surface = AppColors.surface;
  static const Color border = AppColors.border;

  // Text colors
  static const Color textPrimary = AppColors.ink;
  static const Color textSecondary = AppColors.textSecondary;
  static const Color textHint = AppColors.textTertiary;

  // Shared semantic surfaces used by catalog and cart widgets.
  static const Color imagePlaceholder = AppColors.surfaceMuted;
  static const Color warningSurface = AppColors.yellowSoft;
  static const Color warningText = AppColors.warning;
  static const Color darkSurface = AppColors.ink;
  static const Color danger = AppColors.danger;

  // Status colors
  static const Color error = AppColors.danger;
  static const Color success = AppColors.success;
  static const Color warning = AppColors.warning;
  static const Color disabled = AppColors.disabled;
  static const double spaceSmall = AppSpacing.xs;
  static const double spaceMedium = AppSpacing.md;
  static const double spaceLarge = AppSpacing.xl;
  static const double pagePadding = AppSpacing.page;
  static const double contentMaxWidth = AppSpacing.contentMaxWidth;
  static const double iconSize = 22;
  static const double iconSmall = 16;
  static const double iconLarge = 32;
  static const double iconHero = 48;
  static const double controlHeight = AppSpacing.touchTarget;

  static const double radiusSmall = AppRadius.sm;
  static const double radiusMedium = AppRadius.md;
  static const double radiusLarge = AppRadius.lg;

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme.light(
        primary: primary,
        onPrimary: Colors.white,
        secondary: accent,
        onSecondary: onAccent,
        surface: surface,
        onSurface: textPrimary,
        error: error,
        onError: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        foregroundColor: textPrimary,
        elevation: 0,
        centerTitle: false,
        surfaceTintColor: Colors.transparent,
      ),
      iconTheme: const IconThemeData(color: textPrimary, size: iconSize),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          side: const BorderSide(color: border),
        ),
      ),
      dividerTheme: const DividerThemeData(color: border, thickness: 1),
      chipTheme: ChipThemeData(
        backgroundColor: surface,
        selectedColor: primaryLight,
        side: const BorderSide(color: border),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusSmall),
        ),
        labelStyle: const TextStyle(
          color: textPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLarge),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: surface,
        showDragHandle: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(radiusLarge),
          ),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        indicatorColor: primaryLight,
        labelTextStyle: WidgetStateProperty.all(
          const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
        ),
      ),
      textTheme: AppTypography.textTheme,
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 18,
        ),
        hintStyle: const TextStyle(color: textHint, fontSize: 13),
        prefixIconColor: textSecondary,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(color: primaryDark, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(color: error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(color: error, width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: disabled,
          elevation: 0,
          minimumSize: const Size(double.infinity, 54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
          ),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: disabled,
          minimumSize: const Size(0, controlHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textPrimary,
          backgroundColor: background,
          minimumSize: const Size(double.infinity, 53),
          side: const BorderSide(color: border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
          ),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: textPrimary,
          textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: textPrimary,
        contentTextStyle: const TextStyle(color: Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
        ),
      ),
      tabBarTheme: const TabBarThemeData(
        labelColor: textPrimary,
        unselectedLabelColor: textSecondary,
        indicatorColor: accent,
        dividerColor: border,
      ),
    );
  }
}
