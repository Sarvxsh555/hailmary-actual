// dart:ui elements provided via flutter/material.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Core palette
  static Color background = const Color(0xFFF8F9FA); // Minimal off-white
  static Color surface = const Color(0xFFFFFFFF);
  static Color cardGlass = const Color(0x75FFFFFF);
  static Color cardGlassBorder = const Color(0x66FFFFFF);

  // Accents (Warm Medical Minimal)
  static Color emergency = const Color(0xFFE57373); // Soft Emergency Coral
  static Color emergencyLight = const Color(0x33E57373); 
  static Color safe = const Color(0xFF81C784); // Medical Green
  static Color safeLight = const Color(0x3381C784);
  static Color info = const Color(0xFF64B5F6); // Soft Medical Blue
  static Color infoLight = const Color(0x3364B5F6);
  static Color warning = const Color(0xFFFFB74D); // Warm Amber
  static Color warningLight = const Color(0x33FFB74D);

  // Text
  static Color textPrimary = const Color(0xFF2C3E50); // Deep Blue-Grey
  static Color textSecondary = const Color(0xFF7F8C8D);
  static Color textTertiary = const Color(0xFFBDC3C7);

  // Misc
  static Color divider = const Color(0xFFEDF2F7);
  static Color shimmer = const Color(0xFFF1F3F5);
}

class AppTheme {
  static void setUpThemeColors(ThemeMode mode) {
    if (mode == ThemeMode.dark) {
      // Dark Mode (Deep Slate Medical)
      AppColors.background = Color(0xFF1E1E24);
      AppColors.surface = Color(0xFF2B2B36);
      AppColors.cardGlass = Color(0x752B2B36);
      AppColors.cardGlassBorder = Color(0x33FFFFFF);

      AppColors.emergency = Color(0xFFE57373); // Keep coral for visibility
      AppColors.emergencyLight = Color(0x33E57373);
      AppColors.safe = Color(0xFF66BB6A);
      AppColors.safeLight = Color(0x3366BB6A);
      AppColors.info = Color(0xFF4FC3F7); // Pop of medical cyan/blue
      AppColors.infoLight = Color(0x334FC3F7);
      AppColors.warning = Color(0xFFFFCC80); // Brighter amber
      AppColors.warningLight = Color(0x33FFCC80);

      AppColors.textPrimary = Color(0xFFF8F9FA); // Off-white
      AppColors.textSecondary = Color(0xFFBDC3C7);
      AppColors.textTertiary = Color(0xFF7F8C8D);

      AppColors.divider = Color(0xFF3B3B4A);
      AppColors.shimmer = Color(0xFF2B2B36);
    } else {
      // Light Mode (Warm Minimal Medical)
      AppColors.background = Color(0xFFF8F9FA);
      AppColors.surface = Color(0xFFFFFFFF);
      AppColors.cardGlass = Color(0x75FFFFFF);
      AppColors.cardGlassBorder = Color(0x66FFFFFF);

      AppColors.emergency = Color(0xFFE57373);
      AppColors.emergencyLight = Color(0x33E57373);
      AppColors.safe = Color(0xFF81C784);
      AppColors.safeLight = Color(0x3381C784);
      AppColors.info = Color(0xFF64B5F6);
      AppColors.infoLight = Color(0x3364B5F6);
      AppColors.warning = Color(0xFFFFB74D);
      AppColors.warningLight = Color(0x33FFB74D);

      AppColors.textPrimary = Color(0xFF2C3E50);
      AppColors.textSecondary = Color(0xFF7F8C8D);
      AppColors.textTertiary = Color(0xFFBDC3C7);

      AppColors.divider = Color(0xFFEDF2F7);
      AppColors.shimmer = Color(0xFFF1F3F5);
    }
  }

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: ColorScheme.light(
        primary: AppColors.info,
        secondary: AppColors.safe,
        error: AppColors.emergency,
        surface: AppColors.surface,
      ),
      textTheme: GoogleFonts.interTextTheme().copyWith(
        displayLarge: GoogleFonts.outfit(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
        displayMedium: GoogleFonts.outfit(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        headlineLarge: GoogleFonts.outfit(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        headlineMedium: GoogleFonts.outfit(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        titleLarge: GoogleFonts.outfit(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
        titleMedium: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: AppColors.textPrimary,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppColors.textSecondary,
        ),
        bodySmall: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: AppColors.textTertiary,
        ),
        labelLarge: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.outfit(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        iconTheme: IconThemeData(color: AppColors.textPrimary),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.info,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(32),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.7),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: BorderSide(color: AppColors.divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: BorderSide(color: AppColors.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: BorderSide(color: AppColors.info, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        hintStyle: GoogleFonts.inter(
          fontSize: 14,
          color: AppColors.textTertiary,
        ),
      ),
    );
  }
}

/// Glass morphism decoration for cards and containers
class GlassDecoration {
  static BoxDecoration get card => BoxDecoration(
        color: Colors.white.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      );

  static BoxDecoration get cardSubtle => BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 0.5,
        ),
      );

  static BoxDecoration cardAccent(Color color) => BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: color.withValues(alpha: 0.15),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      );
}
