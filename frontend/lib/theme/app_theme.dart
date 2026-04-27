import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._();

  static const background = Color(0xFFF0F4F8);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceAlt = Color(0xFFE8EEF4);
  static const cardBorder = Color(0xFFDDE3EC);
  static const accentNavy = Color(0xFF1A3A5C);
  static const accentBlue = Color(0xFF2563EB);
  static const accentBlueLight = Color(0xFFEFF6FF);
  static const threatRed = Color(0xFFDC2626);
  static const threatRedLight = Color(0xFFFEF2F2);
  static const safeGreen = Color(0xFF059669);
  static const safeGreenLight = Color(0xFFECFDF5);
  static const warningAmber = Color(0xFFD97706);
  static const warningAmberLight = Color(0xFFFFFBEB);
  static const textPrimary = Color(0xFF0F172A);
  static const textSecondary = Color(0xFF64748B);
  static const textMuted = Color(0xFF94A3B8);
  static const divider = Color(0xFFE2E8F0);

  static final List<BoxShadow> cardShadow = [
    BoxShadow(
      color: accentNavy.withOpacity(0.06),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];

  static ThemeData get lightTheme {
    final base = ThemeData.light();
    return base.copyWith(
      scaffoldBackgroundColor: background,
      primaryColor: accentNavy,
      canvasColor: surface,
      cardColor: surface,
      dividerColor: divider,
      highlightColor: Colors.transparent,
      splashFactory: NoSplash.splashFactory,
      textSelectionTheme: const TextSelectionThemeData(cursorColor: accentNavy),
      colorScheme: ColorScheme.light(
        surface: surface,
        primary: accentNavy,
        secondary: accentBlue,
        error: threatRed,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textPrimary,
      ),
      textTheme: GoogleFonts.interTextTheme(base.textTheme).copyWith(
        displayLarge: GoogleFonts.spaceGrotesk(
          fontSize: 48,
          fontWeight: FontWeight.w800,
          color: textPrimary,
        ),
        displayMedium: GoogleFonts.spaceGrotesk(
          fontSize: 36,
          fontWeight: FontWeight.w700,
          color: textPrimary,
        ),
        headlineSmall: GoogleFonts.spaceGrotesk(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: textPrimary,
        ),
        titleLarge: GoogleFonts.spaceGrotesk(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: textPrimary,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 16,
          color: textPrimary,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14,
          color: textSecondary,
        ),
        labelLarge: GoogleFonts.jetBrainsMono(
          fontSize: 13,
          color: textMuted,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: surface,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: accentNavy,
          fontFamily: 'Space Grotesk',
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
        iconTheme: IconThemeData(color: accentNavy),
        surfaceTintColor: surface,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        hintStyle: const TextStyle(color: textMuted),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: accentBlue, width: 2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentNavy,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
          shadowColor: accentNavy.withOpacity(0.06),
          textStyle: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surface,
        elevation: 0,
        selectedItemColor: accentBlue,
        unselectedItemColor: textMuted,
        showUnselectedLabels: true,
        selectedLabelStyle: TextStyle(fontSize: 11, fontFamily: 'Inter'),
        unselectedLabelStyle: TextStyle(fontSize: 11, fontFamily: 'Inter'),
        type: BottomNavigationBarType.fixed,
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        shadowColor: accentNavy.withOpacity(0.06),
      ),
    );
  }
}
