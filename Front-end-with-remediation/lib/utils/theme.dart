import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Light Mode Colors - 65% Green, 35% White design
  static const Color lightPrimary = Color(0xFF2E7D32); // Deep green
  static const Color lightSecondary = Color(0xFF4CAF50); // Medium green
  static const Color lightBackground = Color(0xFFFFFFFF); // White background
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightError = Color(0xFFD32F2F);
  static const Color lightOnPrimary = Color(0xFFFFFFFF);
  static const Color lightOnBackground = Color(0xFF1B5E20);
  static const Color lightOnSurface = Color(0xFF2E3A3B);

  // Dark Mode Colors
  static const Color darkPrimary = Color(0xFF8BC34A);
  static const Color darkSecondary = Color(0xFFAED581);
  static const Color darkBackground = Color(0xFF0A2F0F);
  static const Color darkSurface = Color(0xFF1B3A1F);
  static const Color darkError = Color(0xFFEF5350);
  static const Color darkOnPrimary = Color(0xFF000000);
  static const Color darkOnBackground = Color(0xFFE8F5E9);
  static const Color darkOnSurface = Color(0xFFE8F5E9);

  // Light Theme
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: lightPrimary,
    scaffoldBackgroundColor: lightBackground,
    colorScheme: const ColorScheme.light(
      primary: lightPrimary,
      secondary: lightSecondary,
      surface: lightSurface,
      error: lightError,
      onPrimary: lightOnPrimary,
      onSecondary: lightOnPrimary,
      onSurface: lightOnSurface,
      onError: lightOnPrimary,
    ),
    textTheme: GoogleFonts.notoSansTextTheme(
      const TextTheme(
        displayLarge: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: lightOnBackground),
        displayMedium: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: lightOnBackground),
        displaySmall: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: lightOnBackground),
        headlineLarge: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: lightOnBackground),
        headlineMedium: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: lightOnBackground),
        headlineSmall: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: lightOnBackground),
        titleLarge: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: lightOnBackground),
        titleMedium: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: lightOnBackground),
        titleSmall: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: lightOnBackground),
        bodyLarge: TextStyle(fontSize: 16, color: lightOnBackground),
        bodyMedium: TextStyle(fontSize: 14, color: lightOnBackground),
        bodySmall: TextStyle(fontSize: 12, color: lightOnBackground),
        labelLarge: TextStyle(
            fontSize: 16, fontWeight: FontWeight.w600, color: lightOnPrimary),
        labelMedium: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: lightOnBackground),
        labelSmall: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: lightOnBackground),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: lightPrimary,
        foregroundColor: lightOnPrimary,
        minimumSize: const Size(88, 88),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 4,
      ),
    ),
    cardTheme: CardThemeData(
      color: lightSurface.withValues(alpha: 0.9),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: lightPrimary,
      foregroundColor: lightOnPrimary,
      elevation: 0,
      centerTitle: true,
    ),
  );

  // Dark Theme
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: darkPrimary,
    scaffoldBackgroundColor: darkBackground,
    colorScheme: const ColorScheme.dark(
      primary: darkPrimary,
      secondary: darkSecondary,
      surface: darkSurface,
      error: darkError,
      onPrimary: darkOnPrimary,
      onSecondary: darkOnPrimary,
      onSurface: darkOnSurface,
      onError: darkOnPrimary,
    ),
    textTheme: GoogleFonts.notoSansTextTheme(
      const TextTheme(
        displayLarge: TextStyle(
            fontSize: 32, fontWeight: FontWeight.bold, color: darkOnBackground),
        displayMedium: TextStyle(
            fontSize: 28, fontWeight: FontWeight.bold, color: darkOnBackground),
        displaySmall: TextStyle(
            fontSize: 24, fontWeight: FontWeight.bold, color: darkOnBackground),
        headlineLarge: TextStyle(
            fontSize: 22, fontWeight: FontWeight.w600, color: darkOnBackground),
        headlineMedium: TextStyle(
            fontSize: 20, fontWeight: FontWeight.w600, color: darkOnBackground),
        headlineSmall: TextStyle(
            fontSize: 18, fontWeight: FontWeight.w600, color: darkOnBackground),
        titleLarge: TextStyle(
            fontSize: 18, fontWeight: FontWeight.w500, color: darkOnBackground),
        titleMedium: TextStyle(
            fontSize: 16, fontWeight: FontWeight.w500, color: darkOnBackground),
        titleSmall: TextStyle(
            fontSize: 14, fontWeight: FontWeight.w500, color: darkOnBackground),
        bodyLarge: TextStyle(fontSize: 16, color: darkOnBackground),
        bodyMedium: TextStyle(fontSize: 14, color: darkOnBackground),
        bodySmall: TextStyle(fontSize: 12, color: darkOnBackground),
        labelLarge: TextStyle(
            fontSize: 16, fontWeight: FontWeight.w600, color: darkOnPrimary),
        labelMedium: TextStyle(
            fontSize: 14, fontWeight: FontWeight.w600, color: darkOnBackground),
        labelSmall: TextStyle(
            fontSize: 12, fontWeight: FontWeight.w600, color: darkOnBackground),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: darkPrimary,
        foregroundColor: darkOnPrimary,
        minimumSize: const Size(88, 88),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 4,
      ),
    ),
    cardTheme: CardThemeData(
      color: darkSurface.withValues(alpha: 0.9),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: darkPrimary,
      foregroundColor: darkOnPrimary,
      elevation: 0,
      centerTitle: true,
    ),
  );
}
