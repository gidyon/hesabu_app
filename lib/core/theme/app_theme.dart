import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hesabu_app/core/constants/app_colors.dart';
import 'package:hesabu_app/core/theme/theme_controller.dart';

class AppTheme {
  /// Build a theme for the given accent and brightness.
  static ThemeData themeFor(AppAccentColor accent, Brightness brightness) {
    final primary = accent.primary;
    final isDark = brightness == Brightness.dark;
    final bgColor = isDark ? accent.darkBackground : AppColors.backgroundLight;
    final surfaceColor = isDark
        ? Color.alphaBlend(Colors.black.withValues(alpha: 0.24), bgColor)
        : AppColors.surfaceLight;
    final surfaceVariantColor = isDark
        ? Color.alphaBlend(Colors.black.withValues(alpha: 0.16), bgColor)
        : AppColors.slate100;
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.18)
        : AppColors.slate200;
    final textColor = isDark ? AppColors.textDark : AppColors.textLight;

    final colorScheme = isDark
        ? ColorScheme.dark(
            primary: primary,
            secondary: primary,
            surface: surfaceColor,
            surfaceContainerHighest: surfaceVariantColor,
            outline: borderColor,
            onPrimary: isDark ? AppColors.textLight : Colors.white,
            onSurface: textColor,
          )
        : ColorScheme.light(
            primary: primary,
            secondary: primary,
            surface: surfaceColor,
            surfaceContainerHighest: surfaceVariantColor,
            outline: borderColor,
            onPrimary: AppColors.textLight,
            onSurface: textColor,
          );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: bgColor,
      cardColor: surfaceColor,
      dividerColor: borderColor,
      primaryColor: primary,
      colorScheme: colorScheme,
      visualDensity: VisualDensity.compact,
      textTheme: GoogleFonts.interTextTheme(
        (isDark ? ThemeData.dark().textTheme : ThemeData.light().textTheme)
            .copyWith(
              displayLarge: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              displayMedium: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
              displaySmall: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              headlineLarge: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
              headlineMedium: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
              headlineSmall: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              titleLarge: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              titleMedium: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              titleSmall: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              bodyLarge: const TextStyle(fontSize: 14),
              bodyMedium: const TextStyle(fontSize: 12),
              bodySmall: const TextStyle(fontSize: 11),
              labelLarge: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
              labelMedium: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
              labelSmall: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
      ).apply(bodyColor: textColor, displayColor: textColor),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: bgColor,
        surfaceTintColor: Colors.transparent,
        clipBehavior: Clip.antiAlias,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
    );
  }

  // Keep legacy statics so existing imports don't break.
  static final ThemeData lightTheme = themeFor(
    AppAccentColor.emerald,
    Brightness.light,
  );
  static final ThemeData darkTheme = themeFor(
    AppAccentColor.emerald,
    Brightness.dark,
  );
}
