import 'package:flutter/material.dart';
import 'package:hesabu_app/core/constants/app_colors.dart';
import 'package:hesabu_app/core/theme/theme_controller.dart';
import 'package:hesabu_app/core/theme/inherited_theme_controller.dart';
import 'package:hesabu_app/features/groups/domain/groups_repository.dart';
import 'package:hesabu_app/features/groups/data/mock_groups_repository.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';

class MyGroupsScreen extends StatefulWidget {
  const MyGroupsScreen({super.key});

  @override
  State<MyGroupsScreen> createState() => _MyGroupsScreenState();
}

class _MyGroupsScreenState extends State<MyGroupsScreen> {
  final GroupsRepository _groupsRepository = MockGroupsRepository();
  List<Group> _groups = [];
  double _totalSavings = 0.0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final groups = await _groupsRepository.getActiveGroups();
    final total = await _groupsRepository.getTotalSavings();
    if (mounted) {
      setState(() {
        _groups = groups;
        _totalSavings = total;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = InheritedThemeController.of(context);
    final accent = controller.accentColor.primary;
    final isDark = controller.isDark;
    final currencyFormat = NumberFormat.currency(
      symbol: 'KSh ',
      decimalDigits: 2,
    );

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Header
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 10,
                bottom: 10,
                left: 16,
                right: 16,
              ),
              color: Theme.of(
                context,
              ).scaffoldBackgroundColor.withOpacity(0.95),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: accent.withOpacity(0.3)),
                          color: accent.withOpacity(0.12),
                        ),
                        child: const CircleAvatar(
                          radius: 18,
                          backgroundImage: NetworkImage(
                            "https://i.pravatar.cc/100?img=12",
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          _buildHeaderIcon(
                            context,
                            Icons.notifications_outlined,
                            isDark,
                          ),
                          const SizedBox(width: 8),
                          _buildHeaderIcon(
                            context,
                            Icons.visibility_off_outlined,
                            isDark,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'My Groups',
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Main Content
          Padding(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 110,
            ),
            child: _isLoading
                ? Center(child: CircularProgressIndicator(color: accent))
                : SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                    child: Column(
                      children: [
                        // Total Savings Card
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [accent, accent.withOpacity(0.8)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: accent.withOpacity(0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'TOTAL GROUP SAVINGS',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.8),
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.15),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.account_balance_wallet,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                currencyFormat.format(_totalSavings),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 30,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.trending_up,
                                      size: 14,
                                      color: Colors.white,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      '+12.5% from last month',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Quick Actions Row
                        Row(
                          children: [
                            Expanded(
                              child: _quickAction(
                                context,
                                icon: Icons.group_add_outlined,
                                label: 'Join Group',
                                accent: accent,
                                onTap: () => context.push('/groups/join'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _quickAction(
                                context,
                                icon: Icons.savings_outlined,
                                label: 'Deposit',
                                accent: accent,
                                onTap: () => context.push('/groups/deposit'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _quickAction(
                                context,
                                icon: Icons.bar_chart_rounded,
                                label: 'Reports',
                                accent: accent,
                                onTap: () {},
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 28),

                        // Active Groups Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Your Active Groups',
                              style: TextStyle(
                                color: Theme.of(
                                  context,
                                ).textTheme.bodyLarge?.color,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${_groups.length} Total',
                              style: const TextStyle(
                                color: AppColors.slate500,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Groups List
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _groups.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 16),
                          itemBuilder: (context, index) => _buildGroupCard(
                            context,
                            _groups[index],
                            currencyFormat,
                            accent,
                            isDark,
                          ),
                        ),
                      ],
                    ),
                  ),
          ),

          // FAB
          Positioned(
            bottom: 100,
            right: 24,
            child: GestureDetector(
              onTap: () {},
              child: Container(
                height: 56,
                width: 56,
                decoration: BoxDecoration(
                  color: accent,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: accent.withOpacity(0.35),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 30),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderIcon(BuildContext context, IconData icon, bool isDark) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.1) : AppColors.slate100,
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        color: Theme.of(context).textTheme.bodyLarge?.color,
        size: 22,
      ),
    );
  }

  Widget _quickAction(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color accent,
    required VoidCallback onTap,
  }) {
    final isDark = InheritedThemeController.of(context).isDark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: accent.withOpacity(0.25)),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: accent.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: accent, size: 20),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyLarge?.color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupCard(
    BuildContext context,
    Group group,
    NumberFormat fmt,
    Color accent,
    bool isDark,
  ) {
    final cardBg = isDark ? Colors.white.withOpacity(0.05) : Colors.white;
    final cardBorder = isDark
        ? Colors.white.withOpacity(0.1)
        : AppColors.slate100;

    return GestureDetector(
      onTap: () => context.push('/treasurer-dashboard'),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: cardBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: accent.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      group.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          Icon(Icons.group, color: accent),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        group.name,
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        '${group.membersCount} • ${group.frequency}',
                        style: const TextStyle(
                          color: AppColors.slate500,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.more_horiz, color: AppColors.slate400),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'GROUP BALANCE',
                      style: TextStyle(
                        color: AppColors.slate500,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                    Text(
                      fmt.format(group.balance),
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: accent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    group.status,
                    style: TextStyle(
                      color: accent,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: group.progressPercentage,
                backgroundColor: isDark
                    ? Colors.white.withOpacity(0.1)
                    : AppColors.slate100,
                valueColor: AlwaysStoppedAnimation<Color>(accent),
                minHeight: 8,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
