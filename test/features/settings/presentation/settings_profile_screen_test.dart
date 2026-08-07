import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hesabu_app/core/theme/app_theme.dart';
import 'package:hesabu_app/core/theme/inherited_theme_controller.dart';
import 'package:hesabu_app/core/theme/theme_controller.dart';
import 'package:hesabu_app/features/auth/domain/auth_repository.dart';
import 'package:hesabu_app/features/settings/domain/settings_repository.dart';
import 'package:hesabu_app/features/settings/presentation/screens/settings_profile_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  for (final brightness in Brightness.values) {
    testWidgets(
      'settings renders compact account sections in ${brightness.name} mode',
      (tester) async {
        tester.view.physicalSize = const Size(360, 800);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        SharedPreferences.setMockInitialValues({
          'theme_mode': brightness == Brightness.dark
              ? ThemeMode.dark.index
              : ThemeMode.light.index,
        });
        final preferences = await SharedPreferences.getInstance();
        final themeController = ThemeController(preferences);

        await tester.pumpWidget(
          MultiProvider(
            providers: [
              Provider<SettingsRepository>.value(
                value: _FakeSettingsRepository(),
              ),
              Provider<AuthRepository>.value(value: _FakeAuthRepository()),
            ],
            child: InheritedThemeController(
              notifier: themeController,
              child: MaterialApp(
                theme: AppTheme.themeFor(AppAccentColor.emerald, brightness),
                home: const SettingsProfileScreen(),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Settings'), findsOneWidget);
        expect(find.text('Eustace Mwai'), findsOneWidget);
        expect(find.text('Security & biometrics'), findsOneWidget);
        expect(find.text('Appearance'), findsOneWidget);
        expect(find.text('Version 1.1.0+2'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  }
}

class _FakeSettingsRepository implements SettingsRepository {
  @override
  Future<UserProfile> getUserProfile() async => UserProfile(
    name: 'Eustace Mwai',
    membershipType: 'Standard Member',
    activeGroupName: 'My Groups',
    avatarUrl: '',
    firstName: 'Eustace',
    otherNames: 'Mwai',
    msisdn: '254700000000',
  );

  @override
  Future<bool> updateProfile(Map<String, dynamic> profileData) async => true;
}

class _FakeAuthRepository extends Fake implements AuthRepository {}
