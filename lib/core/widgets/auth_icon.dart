import 'package:flutter/material.dart';
import 'package:hesabu_app/core/theme/inherited_theme_controller.dart';
import 'package:hesabu_app/core/theme/theme_controller.dart';

class AuthIcon extends StatelessWidget {
  const AuthIcon({super.key});

  @override
  Widget build(BuildContext context) {
    final accent = InheritedThemeController.of(context).accentColor.primary;
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: accent.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(child: Icon(Icons.wallet_rounded, color: accent, size: 32)),
    );
  }
}
