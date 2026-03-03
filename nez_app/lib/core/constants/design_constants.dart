import 'package:flutter/material.dart';

/// Central design tokens — no magic numbers anywhere else.
abstract final class DesignConstants {
  // ── Spacing ──
  static const double spacingXS = 4;
  static const double spacingSM = 8;
  static const double spacingMD = 16;
  static const double spacingLG = 24;
  static const double spacingXL = 32;
  static const double spacingXXL = 48;
  static const double spacingHuge = 64;

  // ── Screen padding ──
  static const EdgeInsets screenPadding = EdgeInsets.symmetric(
    horizontal: 24,
    vertical: 16,
  );

  // ── Border radius ──
  static const double radiusSM = 8;
  static const double radiusMD = 14;
  static const double radiusLG = 20;
  static const double radiusXL = 28;
  static const double radiusFull = 100;

  // ── Button ──
  static const double buttonHeight = 56;
  static const double buttonHeightSmall = 44;

  // ── Card ──
  static const double cardPaddingH = 20;
  static const double cardPaddingV = 18;

  // ── Input ──
  static const double inputHeight = 56;

  // ── Animation ──
  static const Duration animFast = Duration(milliseconds: 200);
  static const Duration animMedium = Duration(milliseconds: 400);
  static const Duration animSlow = Duration(milliseconds: 800);
  static const Curve animCurve = Curves.easeOutCubic;
}
