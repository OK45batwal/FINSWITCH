import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const primaryBlue = Color(0xFF2563EB);
  static const emeraldGreen = Color(0xFF10B981);
  static const red = Color(0xFFEF4444);
  static const bg = Color(0xFF0B1220);
  static const card = Color(0xFF131D2E);
  static const accent = Color(0xFF38BDF8);
  static const text = Color(0xFFF8FAFC);
  static const muted = Color(0xFF64748B);
  static const border = Color(0x0FFFFFFF);

  static ThemeData get darkTheme => ThemeData(
    brightness: Brightness.dark,
    useMaterial3: true,
    scaffoldBackgroundColor: bg,
    colorScheme: const ColorScheme.dark(
      primary: primaryBlue,
      secondary: accent,
      surface: card,
      onSurface: text,
      error: red,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: text, fontSize: 18, fontWeight: FontWeight.700,
        letterSpacing: -0.5,
      ),
    ),
    cardTheme: CardThemeData(
      color: card,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Colors.white10, width: 0.5),
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0xFF0A1628),
      selectedItemColor: primaryBlue,
      unselectedItemColor: muted,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
      selectedLabelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
      unselectedLabelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryBlue,
        foregroundColor: text,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF1A2538),
      hintStyle: const TextStyle(color: muted, fontSize: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryBlue, width: 1),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).copyWith(
      headlineLarge: GoogleFonts.inter(
        fontSize: 32, fontWeight: FontWeight.w700,
        letterSpacing: -1, color: text,
      ),
      headlineMedium: GoogleFonts.inter(
        fontSize: 22, fontWeight: FontWeight.w700,
        letterSpacing: -0.5, color: text,
      ),
      titleLarge: GoogleFonts.inter(
        fontSize: 18, fontWeight: FontWeight.w700,
        letterSpacing: -0.3, color: text,
      ),
      titleMedium: GoogleFonts.inter(
        fontSize: 16, fontWeight: FontWeight.w600, color: text,
      ),
      bodyLarge: GoogleFonts.inter(fontSize: 15, color: text),
      bodyMedium: GoogleFonts.inter(fontSize: 14, color: muted),
      labelLarge: GoogleFonts.inter(
        fontSize: 13, fontWeight: FontWeight.w600,
        letterSpacing: 0.5, color: text,
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: Colors.white10, thickness: 0.5, space: 0,
    ),
  );
}
