import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ──────────────────────────────────────────────
// COLORS - Enhanced Dark Theme
// ──────────────────────────────────────────────
abstract final class AppColors {
  // Backgrounds (deep blacks with subtle variations)
  static const Color background = Color(
    0xFF0A0A0A,
  ); // slightly lighter than pure black
  static const Color backgroundElevated = Color(0xFF121212); // elevated surface
  static const Color card = Color(0xFF1C1C1C); // refined dark card surface
  static const Color cardHover = Color(0xFF242424); // card hover state

  // Text (white hierarchy)
  static const Color textPrimary = Color(
    0xFFF5F5F5,
  ); // soft white for reduced eye strain
  static const Color textSecondary = Color(0xFFB3B3B3); // medium grey
  static const Color textTertiary = Color(0xFF737373); // subtle grey
  static const Color textHint = Color(0xFF525252); // muted grey

  // Accent (minimal red - refined)
  static const Color accent = Color(0xFFEF4444); // refined red for CTAs
  static const Color accentHover = Color(0xFFF87171); // lighter on hover
  static const Color accentSubtle = Color(0xFF991B1B); // darker variant
  static const Color accentText = Color(0xFFFFFFFF);

  // Borders & dividers (subtle greys)
  static const Color border = Color(0xFF2A2A2A); // refined subtle border
  static const Color borderLight = Color(0xFF3A3A3A); // lighter variant
  static const Color divider = Color(0xFF242424); // subtle divider
  static const Color inputBorder = Color(0xFF3A3A3A); // input borders

  // Category chips
  static const Color chipSelected = Color(0xFF2A2A2A); // selected state
  static const Color chipUnselected = Color(0xFF151515); // unselected
  static const Color chipBorder = Color(0xFF3A3A3A); // chip border

  // States
  static const Color error = Color(0xFFEF4444); // red error
  static const Color success = Color(0xFF10B981); // green success
  static const Color warning = Color(0xFFF59E0B); // amber warning
  static const Color disabled = Color(0xFF404040); // disabled state

  // Shadows (refined for depth)
  static const Color shadowLight = Color(0x14000000); // subtle shadow
  static const Color shadowMedium = Color(0x28000000); // medium shadow
  static const Color shadowStrong = Color(0x40000000); // strong shadow

  // Legacy compat
  static const Color surface = Color(0xFF1C1C1C);
  static const Color surfaceLight = Color(0xFF242424);
  static const Color accentMuted = Color(0xFF2A2A2A);
  static const Color inputUnderline = Color(0xFF3A3A3A);
  static const Color cardShadow = Color(0x28000000);
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
// SHADOWS - Subtle depth for dark theme
// ──────────────────────────────────────────────
abstract final class AppShadows {
  // Subtle card elevation
  static const List<BoxShadow> card = [
    BoxShadow(
      color: AppColors.shadowMedium,
      offset: Offset(0, 4),
      blurRadius: 16,
      spreadRadius: 0,
    ),
  ];

  // Medium elevation for floating elements
  static const List<BoxShadow> elevated = [
    BoxShadow(
      color: AppColors.shadowMedium,
      offset: Offset(0, 8),
      blurRadius: 24,
      spreadRadius: 0,
    ),
  ];

  // Strong shadow for modals and dialogs
  static const List<BoxShadow> modal = [
    BoxShadow(
      color: AppColors.shadowStrong,
      offset: Offset(0, 16),
      blurRadius: 48,
      spreadRadius: 0,
    ),
  ];

  // Subtle inner shadow effect
  static const List<BoxShadow> inner = [
    BoxShadow(
      color: AppColors.shadowLight,
      offset: Offset(0, 2),
      blurRadius: 8,
      spreadRadius: -2,
    ),
  ];
}

// ──────────────────────────────────────────────
// THEME DATA
// ──────────────────────────────────────────────
final ThemeData appTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  scaffoldBackgroundColor: AppColors.background,
  fontFamily: 'Inter',
  colorScheme: ColorScheme.dark(
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
  inputDecorationTheme: InputDecorationTheme(
    filled: false,
    contentPadding: const EdgeInsets.symmetric(vertical: 10),
    hintStyle: TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w400,
      color: AppColors.textHint,
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
      borderSide: BorderSide(color: AppColors.accent, width: 1.5),
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: AppColors.textPrimary,
      side: const BorderSide(color: AppColors.border, width: 1.5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: AppColors.textSecondary,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
    ),
  ),
  cardTheme: const CardThemeData(
    color: AppColors.card,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(24)),
    ),
    margin: EdgeInsets.all(0),
  ),
  chipTheme: const ChipThemeData(
    backgroundColor: AppColors.chipUnselected,
    selectedColor: AppColors.chipSelected,
    disabledColor: AppColors.disabled,
    side: BorderSide(color: AppColors.chipBorder, width: 1),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(20)),
    ),
    labelStyle: TextStyle(color: AppColors.textPrimary),
    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  ),
  dialogTheme: const DialogThemeData(
    backgroundColor: AppColors.card,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(28)),
    ),
  ),
  bottomSheetTheme: const BottomSheetThemeData(
    backgroundColor: AppColors.card,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.background,
    elevation: 0,
    centerTitle: false,
    iconTheme: IconThemeData(color: AppColors.textPrimary),
    titleTextStyle: TextStyle(
      color: AppColors.textPrimary,
      fontSize: 20,
      fontWeight: FontWeight.w700,
    ),
  ),
  // Card styling handled by custom NezCard to ensure consistent shadow/corner treatment
);
