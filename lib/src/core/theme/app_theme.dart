import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Colors
  static const Color primary = Color(0xFFD4AF37); // Gold
  static const Color black = Color(0xFF000000); // Black
  static const Color gold = Color(0xFFD4AF37); // Gold Alias
  static const Color onPrimary = Color(0xFF000000); // Black
  static const Color background = Color(0xFF121212); // Dark background
  static const Color surface = Color(0xFF1E1E1E); // Surface
  static const Color surfaceDark = Color(0xFF1E1E1E); // Surface Dark Alias
  static const Color onBackground = Color(0xFFFFFFFF); // White text
  static const Color onSurface = Color(0xFFE0E0E0); // Lighter text
  static const Color error = Color(0xFFCF6679);
  static const Color secondary = Color(0xFF37474F); // Lead Gray

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme(
        brightness: Brightness.dark,
        primary: primary,
        onPrimary: onPrimary,
        secondary: secondary,
        onSecondary: OnSurface,
        error: error,
        onError: onPrimary,
        background: background,
        onBackground: onBackground,
        surface: surface,
        onSurface: onSurface,
      ),
      scaffoldBackgroundColor: background,
      textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme).apply(
        bodyColor: onBackground,
        displayColor: onBackground,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primary),
        ),
        hintStyle: const TextStyle(color: Colors.grey),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          textStyle: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: onBackground),
        titleTextStyle: TextStyle(
          color: onBackground,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
  
  static const Color OnSurface = Color(0xFFFFFFFF);
}
