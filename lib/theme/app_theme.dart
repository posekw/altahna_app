import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Coffee Color Palette
  static const Color primaryCoffee = Color(0xFF4E342E); // Dark Brown
  static const Color mediumCoffee = Color(0xFF795548); // Medium Brown
  static const Color lightCoffee = Color(0xFFA1887F); // Light Brown
  static const Color cream = Color(0xFFD7CCC8); // Cream/Beige
  static const Color background = Color(0xFFF5F5F5); // Off-white
  static const Color surface = Colors.white;
  static const Color accent = Color(0xFFFFAB40); // Orange/Gold for actions

  static ThemeData get themeData {
    return ThemeData(
      useMaterial3: true,
      primaryColor: primaryCoffee,
      scaffoldBackgroundColor: background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryCoffee,
        primary: primaryCoffee,
        secondary: accent,
        surface: surface,
        background: background,
      ),
      textTheme: GoogleFonts.outfitTextTheme().apply(
        bodyColor: primaryCoffee,
        displayColor: primaryCoffee,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor:  Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: primaryCoffee),
        titleTextStyle: TextStyle(
          color: primaryCoffee,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: primaryCoffee,
        inactiveTrackColor: lightCoffee.withOpacity(0.3),
        thumbColor: primaryCoffee,
        overlayColor: primaryCoffee.withOpacity(0.1),
      ),
      cardTheme: CardTheme(
        color: surface,
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryCoffee,
          foregroundColor: Colors.white,
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
      ),
    );
  }

  static ThemeData get darkThemeData {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: cream, // Use Cream for better contrast in Dark Mode
      scaffoldBackgroundColor: const Color(0xFF1E1E1E), // Dark Grey
      colorScheme: ColorScheme.fromSeed(
        seedColor: cream,
        brightness: Brightness.dark,
        primary: cream,
        secondary: accent,
        surface: const Color(0xFF2C2C2C), // Slightly lighter grey for cards
        background: const Color(0xFF1E1E1E),
      ),
      textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme).apply(
        bodyColor: cream,
        displayColor: cream,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: cream),
        titleTextStyle: TextStyle(
          color: cream,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: accent, // Use accent for slider in dark mode for visibility
        inactiveTrackColor: cream.withOpacity(0.3),
        thumbColor: accent,
        overlayColor: accent.withOpacity(0.1),
      ),
      cardTheme: CardTheme(
        color: const Color(0xFF2C2C2C),
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accent, // High contrast button
          foregroundColor: Colors.black,
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
      ),
    );
  }
}
