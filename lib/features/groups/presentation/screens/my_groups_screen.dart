import 'package:flutter/material.dart';
import 'package:hesabu_app/core/constants/app_colors.dart';
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
    final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
            // iOS Blur Header Simulation (simplified for Flutter)
            Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                    padding: EdgeInsets.only(
                        top: MediaQuery.of(context).padding.top + 10,
                        bottom: 10,
                        left: 16,
                        right: 16
                    ),
                    color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.95),
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
                                            border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                                            color: AppColors.primary.withOpacity(0.1),
                                        ),
                                        child: CircleAvatar(
                                            radius: 18,
                                            backgroundImage: const NetworkImage("https://lh3.googleusercontent.com/aida-public/AB6AXuD3_fUP2iH0oh-E6sGicJ0Ek4_2eETYDmZdVAfcrT1ZWwKL2SDU_w3mzHW42T02ZwT2ovsrx-PbRXBcaw3pUXFl4C89I82X74tgKRkvFQKUledoz1y5mimcWCSnIicSctmz8YrjemRuaO-H4xOr-pPebgv40k7ot-Sm0-1AGOA8JKAeaRQgEW9i6pbWvYHKixlIO53g-9F0_Rc4QA2BS4bDINOXdbfsFU3KUtwMJqlh0SgETUwgSOHUE3qr_otxgQGTziJBgYIFVwE"),
                                        ),
                                    ),
                                    Row(
                                        children: [
                                            _buildHeaderIcon(Icons.notifications_outlined),
                                            const SizedBox(width: 8),
                                            _buildHeaderIcon(Icons.visibility_off_outlined),
                                        ],
                                    )
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
              padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 110),
              child: _isLoading 
                ? const Center(child: CircularProgressIndicator()) 
                : SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                  child: Column(
                    children: [
                      // Total Savings Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'TOTAL GROUP SAVINGS',
                              style: TextStyle(
                                color: AppColors.backgroundDark.withOpacity(0.7),
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              currencyFormat.format(_totalSavings),
                              style: const TextStyle(
                                color: AppColors.backgroundDark,
                                fontSize: 30,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.backgroundDark.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.trending_up, size: 14, color: AppColors.backgroundDark),
                                  SizedBox(width: 4),
                                  Text(
                                    '+12.5% from last month',
                                    style: TextStyle(
                                      color: AppColors.backgroundDark,
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
                      
                      const SizedBox(height: 32),
                      
                      // Join Group Button
                      InkWell(
                        onTap: () {},
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 2),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.key, color: AppColors.backgroundDark),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Join Group via ID',
                                      style: TextStyle(
                                        color: Theme.of(context).textTheme.bodyLarge?.color,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const Text(
                                      'Enter a code to join an existing group',
                                      style: TextStyle(
                                        color: AppColors.slate500,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.chevron_right, color: AppColors.slate400),
                            ],
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Active Groups Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Your Active Groups',
                            style: TextStyle(
                              color: Theme.of(context).textTheme.bodyLarge?.color,
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
                        separatorBuilder: (context, index) => const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          final group = _groups[index];
                          return _buildGroupCard(context, group, currencyFormat);
                        },
                      ),
                    ],
                  ),
                ),
            ),
            
            // FAB
            Positioned(
              bottom: 100, // Above nav bar
              right: 24,
              child: Container(
                  height: 56,
                  width: 56,
                  decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      boxShadow: [
                          BoxShadow(
                              color: AppColors.primary.withOpacity(0.3),
                              blurRadius: 30,
                              offset: const Offset(0, 8),
                          )
                      ]
                  ),
                  child: IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.add, color: AppColors.backgroundDark, size: 32),
                  ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeaderIcon(IconData icon) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark 
            ? Colors.white.withOpacity(0.1) 
            : AppColors.slate100,
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        color: Theme.of(context).textTheme.bodyLarge?.color,
        size: 24,
      ),
    );
  }

  Widget _buildGroupCard(BuildContext context, Group group, NumberFormat currencyFormat) {
    // Determine image background color based on group (simplified logic for demo)
    Color iconBgColor = AppColors.primary.withOpacity(0.2);
    Color iconColor = AppColors.primary;
    if (group.name.contains('Investment')) {
        iconBgColor = Colors.blue.withOpacity(0.2);
        iconColor = Colors.blue;
    } else if (group.name.contains('Car')) {
        iconBgColor = Colors.orange.withOpacity(0.2);
        iconColor = Colors.orange;
    }

    return GestureDetector(
      onTap: () {
          // Navigate to dashboard if it's the Investment Club (as per design Screen 9 implies detail view)
          // For now, mapping all to the same dashboard for demo purposes
          context.push('/treasurer-dashboard'); 
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark 
            ? Colors.white.withOpacity(0.05) 
            : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Theme.of(context).brightness == Brightness.dark 
                ? Colors.white.withOpacity(0.1) 
                : AppColors.slate100,
          ),
          boxShadow: [
             BoxShadow(
                 color: Colors.black.withOpacity(0.05),
                 blurRadius: 4,
                 offset: const Offset(0, 2),
             )
          ]
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
                    color: iconBgColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                        group.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (ctx, _, __) => Icon(Icons.group, color: iconColor),
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
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.more_horiz, color: AppColors.slate400),
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
                      currencyFormat.format(group.balance),
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Text(
                  group.status,
                  style: TextStyle(
                    color: group.progressPercentage >= 1.0 ? AppColors.primary : (group.progressPercentage == 0.02 ? AppColors.slate500 : AppColors.primary),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: group.progressPercentage,
                backgroundColor: Theme.of(context).brightness == Brightness.dark 
                    ? Colors.white.withOpacity(0.1) 
                    : AppColors.slate100,
                valueColor: AlwaysStoppedAnimation<Color>(
                    group.progressPercentage >= 1.0 
                        ? AppColors.primary 
                        : (group.progressPercentage < 0.1 ? AppColors.primary.withOpacity(0.2) : AppColors.primary)
                ),
                minHeight: 8,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
