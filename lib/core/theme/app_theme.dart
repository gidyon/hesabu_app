import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hesabu_app/core/constants/app_colors.dart';
import 'package:hesabu_app/core/theme/theme_controller.dart';

class AppTheme {
  /// Build a theme for the given accent and brightness.
  static ThemeData themeFor(AppAccentColor accent, Brightness brightness) {
    final primary = accent.primary;
    final isDark = brightness == Brightness.dark;
    final bgColor = isDark
        ? AppColors.backgroundDark
        : AppColors.backgroundLight;
    final surfaceColor = isDark
        ? Color.alphaBlend(
            primary.withValues(alpha: 0.035),
            AppColors.surfaceDark,
          )
        : AppColors.surfaceLight;
    final surfaceVariantColor = isDark
        ? Color.alphaBlend(Colors.white.withValues(alpha: 0.05), surfaceColor)
        : AppColors.slate100;
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.11)
        : const Color(0xFFDCE2E8);
    final textColor = isDark ? AppColors.textDark : AppColors.textLight;

    final colorScheme = isDark
        ? ColorScheme.dark(
            primary: primary,
            secondary: primary,
            surface: surfaceColor,
            surfaceContainerHighest: surfaceVariantColor,
            outline: borderColor,
            onPrimary: const Color(0xFF07140B),
            onSurface: textColor,
          )
        : ColorScheme.light(
            primary: primary,
            secondary: primary,
            surface: surfaceColor,
            surfaceContainerHighest: surfaceVariantColor,
            outline: borderColor,
            onPrimary: const Color(0xFF07140B),
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
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: surfaceColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: borderColor),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceColor,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        labelStyle: TextStyle(
          color: isDark ? AppColors.slate400 : AppColors.slate500,
        ),
        hintStyle: TextStyle(
          color: isDark
              ? Colors.white.withValues(alpha: 0.38)
              : AppColors.slate400,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primary, width: 1.4),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: const Color(0xFF07140B),
          minimumSize: const Size(0, 48),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textColor,
          minimumSize: const Size(0, 48),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
          side: BorderSide(color: borderColor),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: isDark
            ? const Color(0xFF22312A)
            : const Color(0xFF172033),
        contentTextStyle: const TextStyle(color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
