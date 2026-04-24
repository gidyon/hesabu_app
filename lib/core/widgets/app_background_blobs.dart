import 'package:flutter/material.dart';

class AppBackgroundBlobs extends StatelessWidget {
  const AppBackgroundBlobs({super.key});

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).primaryColor;

    return Stack(
      children: [
        Positioned(
          top: 0,
          right: 0,
          child: Container(
            width: 256,
            height: 256,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(128),
              boxShadow: [
                BoxShadow(
                  color: accent.withValues(alpha: 0.1),
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
              color: accent.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(192),
              boxShadow: [
                BoxShadow(
                  color: accent.withValues(alpha: 0.05),
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
