import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hesabu_app/core/constants/app_colors.dart';

class ScaffoldWithNavBar extends StatelessWidget {
  const ScaffoldWithNavBar({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        switchInCurve: Curves.easeInOut,
        switchOutCurve: Curves.easeInOut,
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.98, end: 1.0).animate(animation),
              child: child,
            ),
          );
        },
        child: KeyedSubtree(
          key: ValueKey<int>(navigationShell.currentIndex),
          child: navigationShell,
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          height: 80, // Height matching design
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.95),
            border: Border(
              top: BorderSide(
                color: isDark
                    ? Colors.white.withOpacity(0.05)
                    : AppColors.slate200,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Row(
            children: [
              _buildNavItem(context, 0, Icons.home_outlined, 'Home'),
              _buildNavItem(context, 1, Icons.group_outlined, 'Groups'),
              _buildNavItem(context, 2, Icons.notifications_none, 'Activity'),
              _buildNavItem(context, 3, Icons.settings_outlined, 'Settings'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    int index,
    IconData icon,
    String label,
  ) {
    final isSelected = navigationShell.currentIndex == index;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = isSelected
        ? (isDark ? Colors.white : AppColors.primary)
        : (isDark ? AppColors.slate400 : AppColors.slate500);

    return Expanded(
      child: InkWell(
        onTap: () => _onTap(context, index),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: color,
              size:
                  24, // Slightly smaller for more compact feel if needed, but keeping UX clear
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onTap(BuildContext context, int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }
}
