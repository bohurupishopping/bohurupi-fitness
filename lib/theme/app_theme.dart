import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Primary Colors - Refined for a fresher look
  static const Color primaryColor = Color(0xFF6C63FF); // Modern Purple-Blue
  static const Color secondaryColor = Color(0xFF00BFA5); // Teal
  static const Color accentColor = Color(0xFFFF6584); // Soft Red/Pink

  // Background Colors
  static const Color backgroundColor = Color(
    0xFFF8F9FE,
  ); // Very light cool grey
  static const Color surfaceColor = Colors.white;
  static const Color cardColor = Colors.white;

  // Text Colors
  static const Color textColor = Color(0xFF2D3142);
  static const Color subtitleColor = Color(0xFF9094A6);

  // Status Colors
  static const Color successColor = Color(0xFF00D2B4);
  static const Color errorColor = Color(0xFFFF4B4B);

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: backgroundColor,
    colorScheme: const ColorScheme.light(
      primary: primaryColor,
      secondary: secondaryColor,
      surface: surfaceColor,
      error: errorColor,
    ),
    textTheme: GoogleFonts.outfitTextTheme(
      // Switched to Outfit for a modern feel
      ThemeData.light().textTheme.copyWith(
        displayLarge: const TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: textColor,
          letterSpacing: -0.5,
        ),
        displayMedium: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: textColor,
          letterSpacing: -0.5,
        ),
        titleLarge: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textColor,
          letterSpacing: -0.2,
        ),
        titleMedium: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: textColor,
          letterSpacing: -0.1,
        ),
        bodyLarge: const TextStyle(
          fontSize: 16,
          color: textColor,
          letterSpacing: 0.1,
          height: 1.5,
        ),
        bodyMedium: const TextStyle(
          fontSize: 14,
          color: subtitleColor,
          letterSpacing: 0.1,
          height: 1.5,
        ),
      ),
    ),
    cardTheme: CardThemeData(
      color: cardColor,
      elevation: 0, // No shadow
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24), // More rounded
        side: BorderSide(color: Colors.black.withValues(alpha: 0.03), width: 1),
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: backgroundColor,
      elevation: 0,
      centerTitle: true,
      scrolledUnderElevation: 0,
      iconTheme: IconThemeData(color: textColor),
      titleTextStyle: TextStyle(
        color: textColor,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: surfaceColor,
      selectedItemColor: primaryColor,
      unselectedItemColor: subtitleColor,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
      showSelectedLabels: false,
      showUnselectedLabels: false,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: backgroundColor,
      selectedColor: primaryColor.withValues(alpha: 0.1),
      disabledColor: backgroundColor,
      labelStyle: const TextStyle(
        color: textColor,
        fontWeight: FontWeight.w500,
      ),
      secondaryLabelStyle: const TextStyle(
        color: primaryColor,
        fontWeight: FontWeight.w600,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(100),
        side: BorderSide(color: Colors.black.withValues(alpha: 0.05), width: 1),
      ),
      elevation: 0,
      pressElevation: 0,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(color: Colors.black.withValues(alpha: 0.03)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: primaryColor, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    ),
    iconTheme: const IconThemeData(color: textColor, size: 24),
    dividerTheme: DividerThemeData(
      color: Colors.black.withValues(alpha: 0.05),
      thickness: 1,
      space: 1,
    ),
  );
}
