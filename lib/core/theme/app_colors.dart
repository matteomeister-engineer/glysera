import 'package:flutter/material.dart';

abstract class AppColors {
  // ── Brand palette ──────────────────────────────────────────
  static const Color backgroundPrimary = Color(0xFFFFFFFF);
  static const Color backgroundSurface = Color(0xFFF3F2E9);
  static const Color accent = Color(0xFFE7FE54);
  static const Color textPrimary = Color(0xFF1F1F1F);
  static const Color black = Color(0xFF000000);
  static const Color textSecondary = Color(0xFF6B6B6B);
  static const Color textTertiary = Color(0xFF9E9E9E);
  static const Color textOnAccent = Color(0xFF1F1F1F);
  static const Color textOnDark = Color(0xFFF3F2E9);

  // ── Glucose status ─────────────────────────────────────────
  static const Color glucoseUrgentLow = Color(0xFFFF4545);
  static const Color glucoseLow = Color(0xFFFF8C42);
  static const Color glucoseInRange = Color(0xFFE7FE54);
  static const Color glucoseHigh = Color(0xFFFF8C42);
  static const Color glucoseUrgentHigh = Color(0xFFFF4545);

  // ── UI surfaces ────────────────────────────────────────────
  static const Color cardBorder = Color(0x1A1F1F1F);
  static const Color divider = Color(0x1A1F1F1F);
  static const Color inputFill = Color(0xFFF3F2E9);
  static const Color chartLine = Color(0xFF1F1F1F);
  static const Color chartFill = Color(0x1AE7FE54);

  // ── Purple accent palette (secondary card style) ──────────
  /// Soft violet — card background (from reference screenshot)
  static const Color purpleCard = Color(0xFFA093FE);
  /// Deep purple — text, icons, chart bars on purple cards
  static const Color purplePrimary = Color(0xFF443F7A);
  /// Light purple text on purple background
  static const Color purpleText = Color(0xFF1E1A4A);
  /// Muted purple for subtitles on purple cards
  static const Color purpleSubtext = Color(0xFF6A5FBF);
  /// Bar fill color on purple cards
  static const Color purpleBarFill = Color(0xFF6A5FBF);
  /// Bar background on purple cards
  static const Color purpleBarBg = Color(0xFF7B70D4);

  // ── iOS 26 Liquid Glass tokens ─────────────────────────────
  /// Frosted white glass — for cards on dark/image backgrounds
  static const Color glassFill = Color(0x1FFFFFFF);         // 12% white
  static const Color glassBorder = Color(0x40FFFFFF);       // 25% white
  static const Color glassHighlight = Color(0x33FFFFFF);    // 20% white top edge

  /// Dark glass — for cards on light backgrounds
  static const Color glassDarkFill = Color(0x40000000);     // 25% black
  static const Color glassDarkBorder = Color(0x1A000000);   // 10% black

  /// Tinted glass variants for alerts
  static const Color glassRedFill = Color(0x26FF4545);      // 15% red
  static const Color glassRedBorder = Color(0x4DFF4545);    // 30% red
  static const Color glassAmberFill = Color(0x26FF8C42);
  static const Color glassAmberBorder = Color(0x4DFF8C42);
  static const Color glassGreenFill = Color(0x26E7FE54);
  static const Color glassGreenBorder = Color(0x4DE7FE54);

  // ── Helpers ────────────────────────────────────────────────
  static Color forGlucose(double mgdl) {
    if (mgdl < 54) return glucoseUrgentLow;
    if (mgdl < 70) return glucoseLow;
    if (mgdl <= 180) return glucoseInRange;
    if (mgdl <= 250) return glucoseHigh;
    return glucoseUrgentHigh;
  }

  static String statusLabel(double mgdl) {
    if (mgdl < 54) return 'Urgent low';
    if (mgdl < 70) return 'Low';
    if (mgdl <= 180) return 'In range';
    if (mgdl <= 250) return 'High';
    return 'Urgent high';
  }

  /// Glass fill color tinted by glucose status
  static Color glassFillForGlucose(double mgdl) {
    if (mgdl < 54) return glassRedFill;
    if (mgdl < 70) return glassAmberFill;
    if (mgdl <= 180) return glassGreenFill;
    if (mgdl <= 250) return glassAmberFill;
    return glassRedFill;
  }
}

