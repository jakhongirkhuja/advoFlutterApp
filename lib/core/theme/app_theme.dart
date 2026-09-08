import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryBlue = Color(0xFF0056B3);
  static const Color primaryBlueDark = Color(0xFF0B5DB5);
  static const Color primaryGold = Color(0xFFD3A944);
  static const Color buttonGold = Color(0xFFE0B75E);
  static const Color secondaryBlue = Color(0xFFE7F1FF);
  static const Color backgroundWhite = Color(0xFFF5F8FF);
  static const Color pageBackground = Color(0xFFF5F5F5);
  static const Color surface = Colors.white;
  static const Color surfaceMuted = Color(0xFFF2F0EE);
  static const Color tagBackground = Color(0xFFF1F1F1);
  static const Color avatarBackground = Color(0xFFE5EDF5);
  static const Color textPrimary = Color(0xFF222222);
  static const Color textSecondary = Color(0xFF555555);
  static const Color textMuted = Color(0xFF777777);
  static const Color textLight = Color(0xFF999999);
  static const Color divider = Color(0xFFECECEC);
  static const Color success = Color(0xFF16A36D);
  static const Color star = Color(0xFFFFB900);
  static const Color danger = Color(0xFFD64545);
  static const Color textChoco = Color(0xff5B4F4B);
  static const TextStyle titleBold = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
  );
  static ThemeData get lightTheme {
    final baseTheme = ThemeData.light();
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryBlue,
        primary: primaryBlue,
        secondary: secondaryBlue,
        surface: backgroundWhite,
      ),
      textTheme: GoogleFonts.interTextTheme(
        baseTheme.textTheme,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primaryGold,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 46),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    final baseTheme = ThemeData.dark();
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryBlue,
        brightness: Brightness.dark,
      ),
      textTheme: GoogleFonts.interTextTheme(
        baseTheme.textTheme,
      ),
      inputDecorationTheme: InputDecorationTheme(
        labelStyle: GoogleFonts.inter(),
        hintStyle: GoogleFonts.inter(
          color: Colors.grey,
        ),
      ),
    );
  }
}
