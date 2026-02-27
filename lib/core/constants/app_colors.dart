import 'package:flutter/material.dart';

/// All app colors — never use hardcoded hex values elsewhere
class AppColors {
  AppColors._();

  static const Color primary       = Color(0xFF02724C);
  static const Color secondary     = Color(0xFFCC8C02);
  static const Color background    = Color(0xFFFFFFFF);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color textPrimary   = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF6B6B6B);
  static const Color error         = Color(0xFFD32F2F);
  static const Color success       = Color(0xFF388E3C);
  static const Color divider       = Color(0xFFE0E0E0);
  static const Color cardBg        = Color(0xFFF9F9F9);

  // Status badge colors
  static const Color activeGreen   = Color(0xFF4CAF50);
  static const Color inactiveGrey  = Color(0xFF9E9E9E);
}
