import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

final themeNotifier = ValueNotifier(ThemeMode.dark);

class ErrorWithRetry extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const ErrorWithRetry({super.key, this.message = 'Something went wrong', required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded, size: 48, color: Colors.amber),
            const SizedBox(height: 16),
            Text(message, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            Text('Check your connection and try again', style: TextStyle(color: Colors.grey, fontSize: 13)),
            const SizedBox(height: 24),
            ElevatedButton.icon(onPressed: onRetry, icon: const Icon(Icons.refresh_rounded), label: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}

class AppTheme {
  static const emeraldGreen = Color(0xFF10B981);
  static const brandNavy = Color(0xFF0A192F);
  static const red = Color(0xFFEF4444);
  static const accent = Color(0xFF38BDF8);

  // Dark Mode (Deep Midnight Navy #0A192F & Mint #10B981)
  static const darkBg = Color(0xFF0A192F);
  static const darkCard = Color(0xFF112240);
  static const darkText = Color(0xFFF8FAFC);
  static const darkMuted = Color(0xFF94A3B8);
  static const darkNav = Color(0xFF0D1B2A);
  static const darkInput = Color(0xFF1E293B);
  static const darkBorder = Color(0xFF233554);

  // Light Mode (Crisp Porcelain White & Deep Navy Text)
  static const lightBg = Color(0xFFF8FAFC);
  static const lightCard = Color(0xFFFFFFFF);
  static const lightText = Color(0xFF0A192F);
  static const lightMuted = Color(0xFF64748B);
  static const lightNav = Color(0xFFFFFFFF);
  static const lightInput = Color(0xFFF1F5F9);
  static const lightBorder = Color(0xFFE2E8F0);

  static Color cardOf(BuildContext context) => Theme.of(context).brightness == Brightness.dark ? darkCard : lightCard;
  static Color mutedOf(BuildContext context) => Theme.of(context).brightness == Brightness.dark ? darkMuted : lightMuted;
  static Color textOf(BuildContext context) => Theme.of(context).brightness == Brightness.dark ? darkText : lightText;
  static Color bgOf(BuildContext context) => Theme.of(context).brightness == Brightness.dark ? darkBg : lightBg;
  static Color borderOf(BuildContext context) => Theme.of(context).brightness == Brightness.dark ? darkBorder : lightBorder;

  static ThemeData get darkTheme => _buildTheme(Brightness.dark, darkBg, darkCard, darkText, darkMuted, darkNav, darkInput, darkBorder);
  static ThemeData get lightTheme => _buildTheme(Brightness.light, lightBg, lightCard, lightText, lightMuted, lightNav, lightInput, lightBorder);

  static ThemeData _buildTheme(Brightness b, Color bg, Color card, Color text, Color muted, Color nav, Color input, Color border) {
    final isDark = b == Brightness.dark;
    return ThemeData(
      brightness: b,
      useMaterial3: true,
      scaffoldBackgroundColor: bg,
      colorScheme: ColorScheme(
        brightness: b,
        primary: emeraldGreen,
        onPrimary: Colors.white,
        secondary: accent,
        onSecondary: text,
        surface: card,
        onSurface: text,
        error: red,
        onError: Colors.white,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(color: text, fontSize: 18, fontWeight: FontWeight.w700, letterSpacing: -0.5),
        iconTheme: IconThemeData(color: text),
      ),
      cardTheme: CardThemeData(
        color: card, elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: border, width: 0.5)),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: isDark ? darkNav : lightNav,
        selectedItemColor: emeraldGreen,
        unselectedItemColor: muted,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: emeraldGreen, foregroundColor: Colors.white, elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true, fillColor: input,
        hintStyle: TextStyle(color: muted, fontSize: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: emeraldGreen, width: 1)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      dividerTheme: DividerThemeData(color: border, thickness: 0.5, space: 0),
      textTheme: GoogleFonts.interTextTheme(isDark ? ThemeData.dark().textTheme : ThemeData.light().textTheme).copyWith(
        headlineLarge: GoogleFonts.inter(fontSize: 32, fontWeight: FontWeight.w700, letterSpacing: -1, color: text),
        headlineMedium: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w700, letterSpacing: -0.5, color: text),
        titleLarge: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, letterSpacing: -0.3, color: text),
        titleMedium: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: text),
        bodyLarge: GoogleFonts.inter(fontSize: 15, color: text),
        bodyMedium: GoogleFonts.inter(fontSize: 14, color: muted),
        labelLarge: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, letterSpacing: 0.5, color: text),
      ),
    );
  }
}
