import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hesabu_app/core/constants/app_colors.dart';
import 'package:hesabu_app/core/theme/inherited_theme_controller.dart';
import 'package:hesabu_app/core/theme/theme_controller.dart';
import 'package:hesabu_app/core/widgets/app_logo.dart';
import 'package:hesabu_app/core/widgets/app_background_blobs.dart';
import 'package:hesabu_app/features/auth/domain/auth_repository.dart';
import 'package:provider/provider.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<IntroItem> _items = [
    IntroItem(
      eyebrow: 'CORE PURPOSE',
      title: 'Manage group money from one wallet',
      description:
          'Hesabu Online helps groups collect contributions, track balances, and keep everyone aligned through one shared financial workspace.',
      icon: Icons.account_balance_wallet_outlined,
      bullets: [
        'Centralized group wallet management',
        'Transparent contribution tracking',
        'Member self-service visibility',
      ],
    ),
    IntroItem(
      eyebrow: 'GROUP MANAGEMENT',
      title: 'Create, join, and coordinate groups',
      description:
          'Create a group, receive a unique account number, onboard members, and keep contributions attributed to the right people in real time.',
      icon: Icons.groups_2_outlined,
      bullets: [
        'Group creation and registration',
        'Join via Group ID or Account Number',
        'Live member contribution records',
      ],
    ),
    IntroItem(
      eyebrow: 'PAYMENTS',
      title: 'Move funds securely when needed',
      description:
          'Admins and treasurers can handle payouts to individuals, businesses, till numbers, and paybills directly from the group wallet.',
      icon: Icons.send_to_mobile_outlined,
      bullets: [
        'B2C and B2B payments',
        'Mobile, till, and paybill transfers',
        'Role-aware transaction controls',
      ],
    ),
    IntroItem(
      eyebrow: 'REPORTING',
      title: 'Keep clear records for accountability',
      description:
          'Automated statements and exportable reports make it easier for every group to maintain trust and financial accountability.',
      icon: Icons.assignment_outlined,
      bullets: [
        'Automated financial records',
        'Exportable contribution reports',
        'Transparent history for every group',
      ],
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeController = InheritedThemeController.of(context);
    final accent = themeController.accentColor.primary;
    final isDark = themeController.isDark;
    final cardColor = theme.cardColor;
    final borderColor = isDark ? theme.dividerColor : AppColors.slate200;
    final titleColor = theme.textTheme.bodyLarge?.color ?? Colors.white;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          const Positioned.fill(child: AppBackgroundBlobs()),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                  child: Row(
                    children: [
                      const AppLogo(size: 44, showText: false),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Hesabu Online',
                          style: TextStyle(
                            color: titleColor,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: _goToLogin,
                        child: Text(
                          'Skip',
                          style: TextStyle(
                            color: AppColors.secondaryText(context),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) =>
                        setState(() => _currentPage = index),
                    itemCount: _items.length,
                    itemBuilder: (context, index) {
                      final item = _items[index];
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(22),
                              decoration: BoxDecoration(
                                color: cardColor,
                                borderRadius: BorderRadius.circular(22),
                                border: Border.all(color: borderColor),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 64,
                                    height: 64,
                                    decoration: BoxDecoration(
                                      color: accent.withValues(alpha: 0.14),
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                    child: Icon(
                                      item.icon,
                                      size: 34,
                                      color: accent,
                                    ),
                                  ),
                                  const SizedBox(height: 22),
                                  Text(
                                    item.eyebrow,
                                    style: TextStyle(
                                      color: accent,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    item.title,
                                    style: TextStyle(
                                      color: titleColor,
                                      fontSize: 26,
                                      fontWeight: FontWeight.w900,
                                      height: 1.12,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    item.description,
                                    style: TextStyle(
                                      color: AppColors.secondaryText(context),
                                      fontSize: 14,
                                      height: 1.5,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  ...item.bullets.map(
                                    (bullet) => Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 10,
                                      ),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Icon(
                                            Icons.check_circle_rounded,
                                            color: accent,
                                            size: 18,
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Text(
                                              bullet,
                                              style: TextStyle(
                                                color: titleColor,
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600,
                                                height: 1.3,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 18),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: accent.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: accent.withValues(alpha: 0.22),
                                ),
                              ),
                              child: Text(
                                'Built for savings groups, welfare associations, investment groups, and community financial cooperatives.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: AppColors.secondaryText(context),
                                  fontSize: 13,
                                  height: 1.45,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                // Indicators
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _items.length,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      height: 8,
                      width: _currentPage == index ? 24 : 8,
                      decoration: BoxDecoration(
                        color: _currentPage == index
                            ? accent
                            : accent.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ElevatedButton(
                        onPressed: _currentPage == _items.length - 1
                            ? _goToRegister
                            : _nextPage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accent,
                          foregroundColor: isDark
                              ? AppColors.backgroundDark
                              : Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          _currentPage == _items.length - 1
                              ? 'Get Started'
                              : 'Next',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: _goToLogin,
                        child: Text(
                          'Already have an account? Login',
                          style: TextStyle(
                            color: accent,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _nextPage() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _goToRegister() async {
    await context.read<AuthRepository>().setOnboarded();
    if (mounted) context.push('/register');
  }

  Future<void> _goToLogin() async {
    await context.read<AuthRepository>().setOnboarded();
    if (mounted) context.push('/login');
  }
}

class IntroItem {
  final String eyebrow;
  final String title;
  final String description;
  final IconData icon;
  final List<String> bullets;

  IntroItem({
    required this.eyebrow,
    required this.title,
    required this.description,
    required this.icon,
    required this.bullets,
  });
}
