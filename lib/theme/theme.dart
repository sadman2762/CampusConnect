import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFFFF6FA1); // Main pinkish color
  static const Color secondary = Color(0xFFFF9AD1); // Light pink
  static const Color background = Color(0xFFFDF6F9); // Lightest background
  static const Color textDark = Color(0xFF2C2C2C);
  static const Color textLight = Color(0xFF888888);
  static const Color accent = Color(0xFFF48FB1);
}

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.background,
    fontFamily: 'Poppins',
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        textStyle: const TextStyle(fontWeight: FontWeight.bold),
      ),
    ),
    textTheme: const TextTheme(
      headlineSmall: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: AppColors.textDark,
      ),
      bodyMedium: TextStyle(
        fontSize: 16,
        color: AppColors.textDark,
      ),
      bodySmall: TextStyle(
        fontSize: 14,
        color: AppColors.textLight,
      ),
    ),
  );
}
