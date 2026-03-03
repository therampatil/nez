import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ──────────────────────────────────────────────
// COLORS
// ──────────────────────────────────────────────
abstract final class AppColors {
  // Backgrounds
  static const Color background = Color(0xFFE8E8E8); // light grey canvas
  static const Color card = Color(0xFFFFFFFF); // pure white card
  static const Color cardShadow = Color(0xFF000000); // hard drop shadow

  // Text
  static const Color textPrimary = Color(0xFF111111);
  static const Color textSecondary = Color(0xFF555555);
  static const Color textHint = Color(0xFF999999);

  // Accent (CTA button)
  static const Color accent = Color(0xFF1C2B28); // dark muted green
  static const Color accentText = Color(0xFFFFFFFF);

  // Borders & dividers
  static const Color border = Color(0xFF111111);
  static const Color inputUnderline = Color(0xFF111111);
  static const Color divider = Color(0xFFDDDDDD);

  // Category chip selected
  static const Color chipSelected = Color(0xFF3A3A3A);
  static const Color chipUnselected = Color(0xFFFFFFFF);

  // States
  static const Color error = Color(0xFFD32F2F);
  static const Color disabled = Color(0xFFAAAAAA);

  // Keep these for legacy compat across existing widget files
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceLight = Color(0xFFF5F5F5);
  static const Color accentMuted = Color(0xFF3A3A3A);
}

// ──────────────────────────────────────────────
// TEXT STYLES
// Headings  → Sulphur Point (via google_fonts)
// Body/UI   → Buenard       (via google_fonts)
// ──────────────────────────────────────────────
abstract final class AppTextStyles {
  // ── Heading font (Sulphur Point) ──
  static TextStyle get displayLarge => GoogleFonts.sulphurPoint(
    fontSize: 48,
    fontWeight: FontWeight.w700,
    letterSpacing: -1.0,
    height: 1.05,
    color: AppColors.textPrimary,
  );

  static TextStyle get displayMedium => GoogleFonts.sulphurPoint(
    fontSize: 40,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.8,
    height: 1.1,
    color: AppColors.textPrimary,
  );

  static TextStyle get headlineLarge => GoogleFonts.sulphurPoint(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.3,
    height: 1.2,
    color: AppColors.textPrimary,
  );

  static TextStyle get headlineMedium => GoogleFonts.sulphurPoint(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    height: 1.25,
    color: AppColors.textPrimary,
  );

  // ── Body / UI font (Buenard) ──
  static TextStyle get bodyLarge => GoogleFonts.buenard(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: AppColors.textPrimary,
  );

  static TextStyle get bodyMedium => GoogleFonts.buenard(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: AppColors.textSecondary,
  );

  static TextStyle get bodySmall => GoogleFonts.buenard(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.4,
    color: AppColors.textSecondary,
  );

  static TextStyle get labelLarge => GoogleFonts.buenard(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.3,
    height: 1.0,
    color: AppColors.textPrimary,
  );

  static TextStyle get labelMedium => GoogleFonts.buenard(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.2,
    height: 1.0,
    color: AppColors.textPrimary,
  );

  static TextStyle get labelSmall => GoogleFonts.buenard(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.2,
    height: 1.0,
    color: AppColors.textSecondary,
  );
}

// ──────────────────────────────────────────────
// SHADOWS — hard offset (as in mockup)
// ──────────────────────────────────────────────
abstract final class AppShadows {
  // The signature layered card effect from the mockup
  static const List<BoxShadow> card = [
    BoxShadow(color: Color(0xFF000000), offset: Offset(10, 10), blurRadius: 0),
  ];

  static const List<BoxShadow> elevated = [
    BoxShadow(color: Color(0x33000000), blurRadius: 16, offset: Offset(0, 6)),
  ];
}

// ──────────────────────────────────────────────
// THEME DATA
// ──────────────────────────────────────────────
final ThemeData appTheme = ThemeData(
  useMaterial3: true,
  scaffoldBackgroundColor: AppColors.background,
  fontFamily: 'Inter',
  colorScheme: const ColorScheme.light(
    primary: AppColors.accent,
    onPrimary: AppColors.accentText,
    surface: AppColors.card,
    error: AppColors.error,
  ),
  textTheme: TextTheme(
    displayLarge: AppTextStyles.displayLarge,
    displayMedium: AppTextStyles.displayMedium,
    headlineLarge: AppTextStyles.headlineLarge,
    headlineMedium: AppTextStyles.headlineMedium,
    bodyLarge: AppTextStyles.bodyLarge,
    bodyMedium: AppTextStyles.bodyMedium,
    bodySmall: AppTextStyles.bodySmall,
    labelLarge: AppTextStyles.labelLarge,
    labelMedium: AppTextStyles.labelMedium,
    labelSmall: AppTextStyles.labelSmall,
  ),
  dividerColor: AppColors.divider,
  // Underline input style — matches mockup
  inputDecorationTheme: const InputDecorationTheme(
    filled: false,
    contentPadding: EdgeInsets.symmetric(vertical: 10),
    hintStyle: TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w400,
      color: AppColors.textPrimary,
    ),
    labelStyle: TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
    ),
    border: UnderlineInputBorder(
      borderSide: BorderSide(color: AppColors.inputUnderline, width: 1),
    ),
    enabledBorder: UnderlineInputBorder(
      borderSide: BorderSide(color: AppColors.inputUnderline, width: 1),
    ),
    focusedBorder: UnderlineInputBorder(
      borderSide: BorderSide(color: AppColors.textPrimary, width: 1.5),
    ),
    errorBorder: UnderlineInputBorder(
      borderSide: BorderSide(color: AppColors.error, width: 1),
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.accent,
      foregroundColor: AppColors.accentText,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      padding: const EdgeInsets.symmetric(vertical: 18),
      textStyle: const TextStyle(
        fontFamily: 'Inter',
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.3,
      ),
    ),
  ),
);
