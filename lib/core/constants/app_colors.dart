import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF2bee6c);
  static const Color backgroundLight = Color(0xFFe2e8f0); // Slate 200
  static const Color backgroundDark = Color(0xFF102216);
  static const Color textLight = Color(
    0xFF334155,
  ); // Slate 700 (softer than 900)
  static const Color textDark = Color(0xFFFFFFFF);
  static const Color slate500 = Color(0xFF64748b);
  static const Color slate400 = Color(0xFF94a3b8);
  static const Color slate200 = Color(0xFFe2e8f0);
  static const Color slate100 = Color(0xFFf1f5f9);

  // Additional colors from design
  static const Color surfaceDark = Color(0xFF1a2e20); // Darker surface
  static const Color surfaceLight = Color(0xFFFFFFFF);

  static bool isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  static Color secondaryText(BuildContext context) =>
      isDark(context) ? Colors.white.withValues(alpha: 0.68) : slate500;

  static Color tertiaryText(BuildContext context) =>
      isDark(context) ? Colors.white.withValues(alpha: 0.56) : slate400;

  static Color mutedIcon(BuildContext context) =>
      isDark(context) ? Colors.white.withValues(alpha: 0.58) : slate400;

  static Color subtleText(BuildContext context) =>
      isDark(context) ? Colors.white.withValues(alpha: 0.48) : slate500;
}
