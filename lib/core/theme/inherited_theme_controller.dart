import 'package:flutter/material.dart';
import 'package:hesabu_app/core/theme/theme_controller.dart';

/// Provides [ThemeController] to the widget tree.
class InheritedThemeController extends InheritedNotifier<ThemeController> {
  const InheritedThemeController({
    super.key,
    required ThemeController super.notifier,
    required super.child,
  });

  static ThemeController of(BuildContext context) {
    final result = context
        .dependOnInheritedWidgetOfExactType<InheritedThemeController>();
    assert(result != null, 'No InheritedThemeController found in context');
    return result!.notifier!;
  }
}
