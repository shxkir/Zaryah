import 'package:flutter/material.dart';

/// Professional Luxury Black & Gold Theme
/// Enterprise-grade color palette and design system
class LuxuryColors {
  // Primary Colors - Professional Black & Gold
  static const Color mainBackground = Color(0xFF0A0A0A); // Matte black
  static const Color secondaryBackground = Color(0xFF111111);
  static const Color cardBackground = Color(0xFF1A1A1A);

  // Gold Palette - Professional & Luxury
  static const Color primaryGold = Color(0xFFFFD700); // Professional gold
  static const Color softGold = Color(0xFFF5C242); // Highlight gold
  static const Color mutedGold = Color(0xFFD4AF37); // Subtle gold
  static const Color borderGold = Color(0x33FFD700); // Semi-transparent

  // Text Colors - Professional Hierarchy
  static const Color headingText = Color(0xFFFFFFFF); // Pure white for headings
  static const Color bodyText = Color(0xE6FFFFFF); // 90% white
  static const Color mutedText = Color(0xB3FFFFFF); // 70% white
  static const Color subtleText = Color(0x80FFFFFF); // 50% white

  // Accent Colors - For status and feedback
  static const Color successGold = Color(0xFFFFD700);
  static const Color errorGold = Color(0xFFFFB000);
  static const Color warningGold = Color(0xFFFFC107);

  // Gradient Backgrounds - Luxury Effect
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF050505), Color(0xFF0D0D0D)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF1A1A1A), Color(0xFF0D0D0D)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFFFD700), Color(0xFFF5C242)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Shadows - Luxury Elevation
  static List<BoxShadow> goldGlow({double opacity = 0.3}) => [
    BoxShadow(
      color: primaryGold.withOpacity(opacity),
      blurRadius: 20,
      spreadRadius: 2,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.5),
      blurRadius: 15,
      spreadRadius: 1,
      offset: const Offset(0, 4),
    ),
  ];
}

/// Professional Typography System
class LuxuryTextStyles {
  // Headings
  static const TextStyle h1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.5,
    color: LuxuryColors.primaryGold,
    height: 1.2,
  );

  static const TextStyle h2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.2,
    color: LuxuryColors.headingText,
    height: 1.3,
  );

  static const TextStyle h3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.0,
    color: LuxuryColors.softGold,
    height: 1.4,
  );

  // Body Text
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: LuxuryColors.bodyText,
    height: 1.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: LuxuryColors.bodyText,
    height: 1.5,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: LuxuryColors.mutedText,
    height: 1.4,
  );

  // Labels
  static const TextStyle label = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    color: LuxuryColors.softGold,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: LuxuryColors.subtleText,
  );

  // Button Text
  static const TextStyle button = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.0,
    color: LuxuryColors.mainBackground,
  );
}

/// Professional Theme Data
class LuxuryTheme {
  static ThemeData get theme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: LuxuryColors.primaryGold,
      scaffoldBackgroundColor: Colors.transparent,

      // Color Scheme
      colorScheme: const ColorScheme.dark(
        primary: LuxuryColors.primaryGold,
        secondary: LuxuryColors.softGold,
        surface: LuxuryColors.cardBackground,
        background: LuxuryColors.mainBackground,
        error: LuxuryColors.errorGold,
        onPrimary: LuxuryColors.mainBackground,
        onSecondary: LuxuryColors.mainBackground,
        onSurface: LuxuryColors.bodyText,
        onBackground: LuxuryColors.bodyText,
      ),

      // AppBar Theme
      appBarTheme: const AppBarTheme(
        backgroundColor: LuxuryColors.secondaryBackground,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: LuxuryColors.primaryGold,
          letterSpacing: 1.0,
        ),
        iconTheme: IconThemeData(
          color: LuxuryColors.primaryGold,
          size: 24,
        ),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        color: LuxuryColors.cardBackground,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(
            color: LuxuryColors.borderGold,
            width: 1,
          ),
        ),
        shadowColor: LuxuryColors.primaryGold.withOpacity(0.1),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: LuxuryColors.secondaryBackground,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),

        // Border Styles
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: LuxuryColors.borderGold,
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: LuxuryColors.borderGold,
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: LuxuryColors.primaryGold,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: LuxuryColors.errorGold,
            width: 1,
          ),
        ),

        // Text Styles
        labelStyle: LuxuryTextStyles.label,
        hintStyle: TextStyle(
          color: LuxuryColors.mutedText.withOpacity(0.5),
          fontSize: 14,
        ),
      ),

      // Button Themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: LuxuryColors.primaryGold,
          foregroundColor: LuxuryColors.mainBackground,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: LuxuryTextStyles.button,
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: LuxuryColors.primaryGold,
          side: const BorderSide(
            color: LuxuryColors.primaryGold,
            width: 1.5,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: LuxuryTextStyles.button.copyWith(
            color: LuxuryColors.primaryGold,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: LuxuryColors.softGold,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          textStyle: LuxuryTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Icon Theme
      iconTheme: const IconThemeData(
        color: LuxuryColors.primaryGold,
        size: 24,
      ),

      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: LuxuryColors.borderGold,
        thickness: 1,
        space: 1,
      ),

      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: LuxuryColors.secondaryBackground,
        selectedItemColor: LuxuryColors.primaryGold,
        unselectedItemColor: LuxuryColors.mutedText,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w400,
        ),
      ),

      // Floating Action Button Theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: LuxuryColors.primaryGold,
        foregroundColor: LuxuryColors.mainBackground,
        elevation: 4,
      ),

      // Dialog Theme
      dialogTheme: DialogThemeData(
        backgroundColor: LuxuryColors.cardBackground,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(
            color: LuxuryColors.borderGold,
            width: 1,
          ),
        ),
        titleTextStyle: LuxuryTextStyles.h2,
        contentTextStyle: LuxuryTextStyles.bodyMedium,
      ),

      // Snackbar Theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: LuxuryColors.cardBackground,
        contentTextStyle: LuxuryTextStyles.bodyMedium,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(
            color: LuxuryColors.primaryGold,
            width: 1,
          ),
        ),
        behavior: SnackBarBehavior.floating,
        elevation: 4,
      ),

      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: LuxuryColors.secondaryBackground,
        selectedColor: LuxuryColors.primaryGold,
        secondarySelectedColor: LuxuryColors.softGold,
        labelStyle: LuxuryTextStyles.bodySmall,
        secondaryLabelStyle: LuxuryTextStyles.bodySmall.copyWith(
          color: LuxuryColors.mainBackground,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(
            color: LuxuryColors.borderGold,
            width: 1,
          ),
        ),
      ),

      // Progress Indicator Theme
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: LuxuryColors.primaryGold,
        circularTrackColor: LuxuryColors.borderGold,
      ),
    );
  }
}
