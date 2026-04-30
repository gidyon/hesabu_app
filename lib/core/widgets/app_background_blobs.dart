import 'package:flutter/material.dart';

class AppBackgroundBlobs extends StatelessWidget {
  const AppBackgroundBlobs({super.key});

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).primaryColor;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final topAlpha = isDark ? 0.15 : 0.1;
    final bottomAlpha = isDark ? 0.08 : 0.05;

    return Stack(
      children: [
        Positioned(
          top: 0,
          right: 0,
          child: Container(
            width: 256,
            height: 256,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: topAlpha),
              borderRadius: BorderRadius.circular(128),
              boxShadow: [
                BoxShadow(
                  color: accent.withValues(alpha: topAlpha),
                  blurRadius: 100,
                  spreadRadius: 20,
                ),
              ],
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          child: Container(
            width: 384,
            height: 384,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: bottomAlpha),
              borderRadius: BorderRadius.circular(192),
              boxShadow: [
                BoxShadow(
                  color: accent.withValues(alpha: bottomAlpha),
                  blurRadius: 120,
                  spreadRadius: 20,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
