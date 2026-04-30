import 'package:flutter/material.dart';
import 'package:hesabu_app/core/constants/app_colors.dart';
import 'package:hesabu_app/core/theme/theme_controller.dart';
import 'package:hesabu_app/core/theme/inherited_theme_controller.dart';
import 'package:go_router/go_router.dart';
import 'package:hesabu_app/core/widgets/app_background_blobs.dart';

class SettingsAboutScreen extends StatelessWidget {
  const SettingsAboutScreen({super.key});

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
    final tertiaryTextColor = isDark
        ? Colors.white.withValues(alpha: 0.58)
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
                    'About Hesabu Online',
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
                  // Hero banner
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      vertical: 32,
                      horizontal: 24,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          accent.withValues(alpha: 0.2),
                          accent.withValues(alpha: 0.05),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: accent.withValues(alpha: 0.25)),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            color: accent.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            Icons.account_balance_wallet,
                            color: accent,
                            size: 36,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'HESABU ONLINE',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Version 1.0.0+1',
                          style: TextStyle(
                            color: accent,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'A digital platform designed to help groups efficiently manage '
                          'contributions, track member participation, and facilitate secure '
                          'financial transactions.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: secondaryTextColor,
                            fontSize: 13,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  _sectionLabel(context, 'CORE PURPOSE'),
                  _featureCard(
                    context,
                    cardBg,
                    cardBorder,
                    children: const [
                      '• Centralized group wallet management',
                      '• Transparent contribution tracking',
                      '• Secure digital payments',
                      '• Member self-service contribution visibility',
                      '• Automated financial records and reporting',
                    ],
                  ),

                  const SizedBox(height: 20),

                  _sectionLabel(context, 'GROUP MANAGEMENT'),
                  _card(
                    context,
                    cardBg,
                    cardBorder,
                    accent,
                    children: [
                      _featureTile(
                        context,
                        Icons.group_add_outlined,
                        accent,
                        'Group Creation & Registration',
                        'Create a group and receive a unique Group Account Number as the official contribution reference.',
                      ),
                      _featureTile(
                        context,
                        Icons.person_add_outlined,
                        Colors.blue,
                        'Member Onboarding',
                        'Members join via Group ID or Account Number — or are added by the admin.',
                      ),
                      _featureTile(
                        context,
                        Icons.savings_outlined,
                        Colors.green,
                        'Contributions Management',
                        'All contributions are credited to the group wallet and attributed to each member in real time.',
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  _sectionLabel(context, 'PAYMENTS & REPORTING'),
                  _card(
                    context,
                    cardBg,
                    cardBorder,
                    accent,
                    children: [
                      _featureTile(
                        context,
                        Icons.send_to_mobile_outlined,
                        Colors.orange,
                        'B2C & B2B Payments',
                        'Pay individuals, businesses, till numbers, and paybills directly from the group wallet.',
                      ),
                      _featureTile(
                        context,
                        Icons.bar_chart_outlined,
                        Colors.purple,
                        'Reports & Export',
                        'Export member contribution reports to Excel and share summaries directly to WhatsApp groups.',
                      ),
                      _featureTile(
                        context,
                        Icons.visibility_outlined,
                        accent,
                        'Financial Transparency',
                        'Role-based visibility: admins see everything, members see their own contribution history.',
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  _sectionLabel(context, 'TARGET USERS'),
                  _featureCard(
                    context,
                    cardBg,
                    cardBorder,
                    children: const [
                      '• Savings groups (chamas)',
                      '• Investment groups',
                      '• Welfare associations',
                      '• Community groups',
                      '• Informal financial cooperatives',
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Vision
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: accent.withValues(alpha: 0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.rocket_launch_outlined,
                              color: accent,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'OUR VISION',
                              style: TextStyle(
                                color: accent,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'To provide a secure, transparent, and scalable digital financial '
                          'management platform that empowers groups to manage contributions '
                          'and payments efficiently while strengthening trust and accountability '
                          'among members.',
                          style: TextStyle(
                            color: secondaryTextColor,
                            fontSize: 13,
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  Center(
                    child: Column(
                      children: [
                        Text(
                          'Hesabu Online v1.0.0+1',
                          style: TextStyle(
                            color: secondaryTextColor,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '© 2024 Hesabu Online. All rights reserved.',
                          style: TextStyle(
                            color: tertiaryTextColor,
                            fontSize: 11,
                          ),
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

  Widget _featureCard(
    BuildContext context,
    Color bg,
    Color border, {
    required List<String> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children
            .map(
              (c) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Text(
                  c,
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _card(
    BuildContext context,
    Color bg,
    Color border,
    Color accent, {
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
      ),
      child: Column(children: children),
    );
  }

  Widget _featureTile(
    BuildContext context,
    IconData icon,
    Color iconColor,
    String title,
    String subtitle,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secondaryTextColor = isDark
        ? Colors.white.withValues(alpha: 0.68)
        : AppColors.slate500;

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
        crossAxisAlignment: CrossAxisAlignment.start,
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
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: secondaryTextColor,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
