import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hesabu_app/core/constants/app_colors.dart';
import 'package:hesabu_app/core/widgets/app_background_blobs.dart';
import 'package:hesabu_app/core/theme/theme_controller.dart';
import 'package:hesabu_app/core/theme/inherited_theme_controller.dart';
import 'package:go_router/go_router.dart';
import 'package:local_auth/local_auth.dart';
import 'package:hesabu_app/core/security/security_controller.dart';
import 'package:provider/provider.dart';

class SettingsSecurityScreen extends StatefulWidget {
  const SettingsSecurityScreen({super.key});

  @override
  State<SettingsSecurityScreen> createState() => _SettingsSecurityScreenState();
}

class _SettingsSecurityScreenState extends State<SettingsSecurityScreen> {
  final _auth = LocalAuthentication();

  @override
  void initState() {
    super.initState();
  }

  Future<void> _toggleBiometrics(bool value) async {
    final security = context.read<SecurityController>();
    if (value) {
      // Authenticate with biometrics to confirm the user can use it
      try {
        final didAuth = await _auth.authenticate(
          localizedReason: 'Confirm identity to enable biometric login',
          biometricOnly: true,
        );

        if (didAuth) {
          await security.setBiometricEnabled(true);

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Biometric login enabled successfully!'),
                backgroundColor: Color(0xFF2ecc71),
              ),
            );
          }
        }
      } catch (e) {
        if (kDebugMode) {
          print(e.toString());
        }
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Security error: $e')));
        }
      }
    } else {
      await security.setBiometricEnabled(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final accent = InheritedThemeController.of(context).accentColor.primary;
    final isDark = InheritedThemeController.of(context).isDark;
    final cardBg = isDark ? Theme.of(context).cardColor : Colors.white;
    final cardBorder = isDark
        ? Theme.of(context).dividerColor
        : AppColors.slate200;
    final secondaryTextColor = isDark
        ? Colors.white.withValues(alpha: 0.68)
        : AppColors.slate500;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          const Positioned.fill(child: AppBackgroundBlobs()),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 10,
                bottom: 12,
                left: 16,
                right: 16,
              ),
              color: Theme.of(
                context,
              ).scaffoldBackgroundColor.withValues(alpha: 0.9),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Container(
                      width: 40,
                      height: 40,
                      color: Colors.transparent,
                      alignment: Alignment.centerLeft,
                      child: Icon(
                        Icons.arrow_back_ios,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                  ),
                  Text(
                    'Security Settings',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  const SizedBox(width: 40),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 60,
            ),
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Shield badge
                  Center(
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.shield,
                        color: Colors.blue,
                        size: 36,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: Text(
                      'Your account is protected',
                      style: TextStyle(color: secondaryTextColor, fontSize: 13),
                    ),
                  ),
                  const SizedBox(height: 32),

                  _sectionLabel(context, 'PASSWORD'),
                  _card(
                    context,
                    cardBg,
                    cardBorder,
                    child: Column(
                      children: [
                        _tile(
                          context,
                          icon: Icons.lock_outline,
                          iconColor: Colors.blue,
                          title: 'Change Password',
                          subtitle: 'Last changed 30 days ago',
                          onTap: () => context.push('/reset-password'),
                          showDivider: false,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  _sectionLabel(context, 'AUTHENTICATION'),
                  _card(
                    context,
                    cardBg,
                    cardBorder,
                    child: Column(
                      children: [
                        Consumer<SecurityController>(
                          builder: (context, security, _) {
                            return _switchTile(
                              context,
                              icon: Icons.fingerprint,
                              iconColor: accent,
                              title: 'Biometric Login',
                              subtitle: 'Use Face ID or Fingerprint',
                              value: security.biometricEnabled,
                              onChanged: _toggleBiometrics,
                              accent: accent,
                              showDivider: false,
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  _sectionLabel(context, 'ACTIVE SESSIONS'),
                  _card(
                    context,
                    cardBg,
                    cardBorder,
                    child: Column(
                      children: [
                        _sessionTile(
                          context,
                          device: 'iPhone 14 Pro · Nairobi',
                          time: 'Current session',
                          isCurrent: true,
                          accent: accent,
                        ),
                        _sessionTile(
                          context,
                          device: 'Samsung Galaxy S23',
                          time: '2 days ago',
                          isCurrent: false,
                          accent: accent,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(BuildContext context, String t) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final labelColor = isDark
        ? Colors.white.withValues(alpha: 0.62)
        : AppColors.slate500;

    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        t,
        style: TextStyle(
          color: labelColor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _card(
    BuildContext context,
    Color bg,
    Color border, {
    required Widget child,
  }) => Container(
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: border),
    ),
    child: child,
  );

  Widget _tile(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
    required bool showDivider,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secondaryTextColor = isDark
        ? Colors.white.withValues(alpha: 0.68)
        : AppColors.slate500;
    final chevronColor = isDark
        ? Colors.white.withValues(alpha: 0.54)
        : AppColors.slate400;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: showDivider
            ? BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Theme.of(
                      context,
                    ).dividerColor.withValues(alpha: 0.08),
                  ),
                ),
              )
            : null,
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: iconColor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle,
                      style: TextStyle(color: secondaryTextColor, fontSize: 12),
                    ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: chevronColor),
          ],
        ),
      ),
    );
  }

  Widget _switchTile(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required Color accent,
    required bool showDivider,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secondaryTextColor = isDark
        ? Colors.white.withValues(alpha: 0.68)
        : AppColors.slate500;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: showDivider
          ? BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(context).dividerColor.withValues(alpha: 0.08),
                ),
              ),
            )
          : null,
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(color: secondaryTextColor, fontSize: 12),
                ),
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged, activeColor: accent),
        ],
      ),
    );
  }

  Widget _sessionTile(
    BuildContext context, {
    required String device,
    required String time,
    required bool isCurrent,
    required Color accent,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secondaryTextColor = isDark
        ? Colors.white.withValues(alpha: 0.68)
        : AppColors.slate500;
    final inactiveIconColor = isDark
        ? Colors.white.withValues(alpha: 0.58)
        : AppColors.slate400;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor.withValues(alpha: 0.08),
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: (isCurrent ? accent : inactiveIconColor).withValues(
                alpha: 0.15,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.smartphone,
              color: isCurrent ? accent : inactiveIconColor,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  device,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                Text(
                  time,
                  style: TextStyle(color: secondaryTextColor, fontSize: 12),
                ),
              ],
            ),
          ),
          if (isCurrent)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Active',
                style: TextStyle(
                  color: accent,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          else
            TextButton(
              onPressed: () {},
              child: const Text(
                'Revoke',
                style: TextStyle(color: Colors.red, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }
}
