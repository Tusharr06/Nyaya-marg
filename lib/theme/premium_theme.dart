import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PremiumTheme {
  static const primaryGold = Color(0xFFD4AF37);
  static const deepBlue = Color(0xFF0A0E21);
  static const surfaceDark = Color(0xFF1D1E33);
  static const accentCyan = Color(0xFF00E5FF);
  static const errorRed = Color(0xFFFF5252);
  static const successGreen = Color(0xFF00C853);
  static const warningYellow = Color(0xFFFFD600);

  static ThemeData get darkTheme {
    return ThemeData.dark().copyWith(
      primaryColor: primaryGold,
      scaffoldBackgroundColor: deepBlue,
      cardTheme: CardThemeData(
        color: surfaceDark,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: deepBlue,
        elevation: 0,
        titleTextStyle: GoogleFonts.outfit(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme).copyWith(
        displayLarge: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
        titleLarge: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
        bodyMedium: GoogleFonts.inter(fontSize: 14, color: Colors.white70),
      ),
      colorScheme: ColorScheme.dark(
        primary: primaryGold,
        secondary: accentCyan,
        surface: surfaceDark,
        error: errorRed,
      ),
    );
  }
}
