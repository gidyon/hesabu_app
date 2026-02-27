import 'package:flutter/material.dart';
import 'package:hesabu_app/core/theme/app_theme.dart';
import 'package:hesabu_app/core/theme/theme_controller.dart';
import 'package:hesabu_app/core/theme/inherited_theme_controller.dart';
import 'package:hesabu_app/core/router/app_router.dart';

final ThemeController _themeController = ThemeController();

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return InheritedThemeController(
      notifier: _themeController,
      child: ListenableBuilder(
        listenable: _themeController,
        builder: (context, _) {
          return MaterialApp.router(
            title: 'Hesabu Online',
            theme: AppTheme.themeFor(
              _themeController.accentColor,
              Brightness.light,
            ),
            darkTheme: AppTheme.themeFor(
              _themeController.accentColor,
              Brightness.dark,
            ),
            themeMode: _themeController.themeMode,
            routerConfig: AppRouter.router,
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
