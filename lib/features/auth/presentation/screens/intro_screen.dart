import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hesabu_app/core/constants/app_colors.dart';
import 'package:hesabu_app/core/theme/inherited_theme_controller.dart';
import 'package:hesabu_app/core/theme/theme_controller.dart';
import 'package:hesabu_app/core/widgets/app_logo.dart';
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
      title: 'Group Wallet Management',
      description:
          'Hesabu Online simplifies how groups collect, manage, monitor, and utilize contributions with a centralized wallet.',
      icon: Icons.account_balance_wallet_outlined,
    ),
    IntroItem(
      title: 'Transparent Tracking',
      description:
          'Promote financial transparency through real-time tracking of individual contributions and total group balance.',
      icon: Icons.analytics_outlined,
    ),
    IntroItem(
      title: 'Secure Digital Payments',
      description:
          'Treasurers can make B2C and B2B payments directly from the group wallet to Till, Paybill, or mobile numbers.',
      icon: Icons.security_outlined,
    ),
    IntroItem(
      title: 'Financial Accountability',
      description:
          'Automated records and easy export to Excel ensure accountability and record-keeping for every group member.',
      icon: Icons.assignment_outlined,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeController = InheritedThemeController.of(context);
    final accent = themeController.accentColor.primary;
    final isDark = themeController.isDark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Background Glows
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                color: accent.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 40),
                const AppLogo(size: 100, showText: true),

                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) =>
                        setState(() => _currentPage = index),
                    itemCount: _items.length,
                    itemBuilder: (context, index) {
                      final item = _items[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: accent.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(32),
                              ),
                              child: Icon(item.icon, size: 64, color: accent),
                            ),
                            const SizedBox(height: 40),
                            Text(
                              item.title,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: theme.textTheme.bodyLarge?.color,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              item.description,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: AppColors.slate400,
                                fontSize: 16,
                                height: 1.5,
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
                            : accent.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 48),

                // Buttons
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          await context.read<AuthRepository>().setOnboarded();
                          if (mounted) context.push('/register');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accent,
                          foregroundColor: isDark
                              ? AppColors.backgroundDark
                              : Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Get Started',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () async {
                          await context.read<AuthRepository>().setOnboarded();
                          if (mounted) context.push('/login');
                        },
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
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class IntroItem {
  final String title;
  final String description;
  final IconData icon;

  IntroItem({
    required this.title,
    required this.description,
    required this.icon,
  });
}
