import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hesabu_app/core/router/scaffold_with_nav_bar.dart';
import 'package:hesabu_app/features/auth/presentation/screens/login_screen.dart';
import 'package:hesabu_app/features/auth/presentation/screens/register_screen.dart';
import 'package:hesabu_app/features/auth/presentation/screens/reset_password_screen.dart';
import 'package:hesabu_app/features/auth/presentation/screens/verify_reset_code_screen.dart';
import 'package:hesabu_app/features/auth/presentation/screens/create_new_password_screen.dart';
import 'package:hesabu_app/features/groups/presentation/screens/my_groups_screen.dart';
import 'package:hesabu_app/features/groups/presentation/screens/treasurer_dashboard_screen.dart';
import 'package:hesabu_app/features/settings/presentation/screens/settings_profile_screen.dart';
import 'package:hesabu_app/features/settings/presentation/screens/settings_appearance_screen.dart';
import 'package:hesabu_app/features/settings/presentation/screens/settings_update_profile_screen.dart';
import 'package:hesabu_app/features/settings/presentation/screens/settings_security_screen.dart';
import 'package:hesabu_app/features/settings/presentation/screens/settings_help_screen.dart';
import 'package:hesabu_app/features/settings/presentation/screens/settings_about_screen.dart';

// Placeholder screens for Wallet and Stats
class PlaceholderScreen extends StatelessWidget {
  final String title;
  const PlaceholderScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text(title)),
    );
  }
}

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'root',
);
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'shell',
);

class AppRouter {
  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/login',
    routes: [
      // ── Auth Routes (outside shell) ──────────────────────────
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/reset-password',
        builder: (context, state) => const ResetPasswordScreen(),
      ),
      GoRoute(
        path: '/verify-reset-code',
        builder: (context, state) => const VerifyResetCodeScreen(),
      ),
      GoRoute(
        path: '/create-password',
        builder: (context, state) => const CreateNewPasswordScreen(),
      ),

      // ── Main App Shell ───────────────────────────────────────
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return ScaffoldWithNavBar(navigationShell: navigationShell);
        },
        branches: [
          // Groups Tab
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/groups',
                builder: (context, state) => const MyGroupsScreen(),
              ),
            ],
          ),
          // Wallet Tab (Placeholder)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/wallet',
                builder: (context, state) =>
                    const PlaceholderScreen(title: 'Wallet'),
              ),
            ],
          ),
          // Stats Tab (Placeholder)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/stats',
                builder: (context, state) =>
                    const PlaceholderScreen(title: 'Stats'),
              ),
            ],
          ),
          // Settings Tab
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/settings',
                builder: (context, state) => const SettingsProfileScreen(),
              ),
            ],
          ),
        ],
      ),

      // ── Settings Sub-pages (pushed on top of shell) ──────────
      GoRoute(
        path: '/settings/appearance',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const SettingsAppearanceScreen(),
      ),
      GoRoute(
        path: '/settings/profile',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const SettingsUpdateProfileScreen(),
      ),
      GoRoute(
        path: '/settings/security',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const SettingsSecurityScreen(),
      ),
      GoRoute(
        path: '/settings/help',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const SettingsHelpScreen(),
      ),
      GoRoute(
        path: '/settings/about',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const SettingsAboutScreen(),
      ),

      // ── Other top-level routes ───────────────────────────────
      GoRoute(
        path: '/treasurer-dashboard',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const TreasurerDashboardScreen(),
      ),
    ],
  );
}
