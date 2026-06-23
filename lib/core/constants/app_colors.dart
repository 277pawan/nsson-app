import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary Blue
  static const Color primary = Color(0xFF2563EB);
  static const Color primaryDark = Color(0xFF1D4ED8);
  static const Color primaryLight = Color(0xFFDBEAFE);
  static const Color primaryBg = Color(0xFFEFF6FF);
  static const Color primaryFocus = Color(0xFF3B82F6);

  // Neutral / Slate
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF475569);
  static const Color textTertiary = Color(0xFF64748B);
  static const Color textMuted = Color(0xFF94A3B8);
  static const Color borderLight = Color(0xFFF1F5F9);
  static const Color border = Color(0xFFE2E8F0);
  static const Color slate300 = Color(0xFFCBD5E1);

  // Semantic
  static const Color success = Color(0xFF059669);
  static const Color successLight = Color(0xFFECFDF5);
  static const Color successDark = Color(0xFF047857);
  static const Color warning = Color(0xFFD97706);
  static const Color warningDark = Color(0xFFB45309);
  static const Color warningLight = Color(0xFFFFFBEB);
  static const Color danger = Color(0xFFEF4444);
  static const Color dangerLight = Color(0xFFFEF2F2);
  static const Color dangerDark = Color(0xFFDC2626);
  static const Color info = Color(0xFF1D4ED8);
  static const Color infoLight = Color(0xFFE0ECFF);

  // Banner gradients
  static const List<Color> bannerBlue = [Color(0xFF2563EB), Color(0xFF1D4ED8)];
  static const List<Color> bannerSlate = [Color(0xFF0F172A), Color(0xFF1E293B)];
  static const List<Color> bannerEmerald = [
    Color(0xFF059669),
    Color(0xFF047857)
  ];

  // Logo gradient
  static const List<Color> logoGradient = [
    Color(0xFF2563EB),
    Color(0xFF1D4ED8)
  ];

  // Highlight card tints
  static const Color genuineTint = Color(0xFFEAF1FC);
  static const Color priceTint = Color(0xFFEAF7F3);
  static const Color ratedTint = Color(0xFFFBF6E8);
  static const Color returnTint = Color(0xFFF2F4F8);
}
