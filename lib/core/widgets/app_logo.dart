import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hesabu_app/core/theme/inherited_theme_controller.dart';
import 'package:hesabu_app/core/theme/theme_controller.dart';

class AppLogo extends StatelessWidget {
  final double size;
  final bool showText;
  final Color? color;

  const AppLogo({
    super.key,
    this.size = 80.0,
    this.showText = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final themeController = InheritedThemeController.of(context);
    final accent = themeController.accentColor.primary;
    final isDark = themeController.isDark;

    // Adapt color based on theme if not provided
    final logoColor = color ?? (isDark ? Colors.white : accent);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SvgPicture.asset(
          'assets/logos/logo.svg',
          width: size,
          height: size,
          fit: BoxFit.contain,
          colorFilter: ColorFilter.mode(logoColor, BlendMode.srcIn),
          placeholderBuilder: (context) => Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: accent.withOpacity(0.15),
              borderRadius: BorderRadius.circular(size * 0.25),
            ),
            child: Icon(
              Icons.account_balance_wallet,
              color: accent,
              size: size * 0.5,
            ),
          ),
        ),
        if (showText) ...[
          const SizedBox(height: 16),
          Text(
            'Hesabu Online',
            style: TextStyle(
              color: logoColor,
              fontSize: size * 0.3,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ],
    );
  }
}
