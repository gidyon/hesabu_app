import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hesabu_app/core/theme/inherited_theme_controller.dart';
import 'package:hesabu_app/core/theme/theme_controller.dart';
import 'package:hesabu_app/features/groups/domain/groups_repository.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class GroupDetailsScreen extends StatefulWidget {
  final Group group;

  const GroupDetailsScreen({super.key, required this.group});

  @override
  State<GroupDetailsScreen> createState() => _GroupDetailsScreenState();
}

class _GroupDetailsScreenState extends State<GroupDetailsScreen> {
  int _currentIndex = 1; // Default to Wallet tab
  List<Transaction> _transactions = [];
  List<Member> _members = [];
  double _balance = 0.0;
  bool _isLoading = true;
  double _totalInflow = 0.0;
  double _totalOutflow = 0.0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final repo = context.read<GroupsRepository>();
    try {
      final results = await Future.wait([
        repo.getRecentTransactions(widget.group.id),
        repo.getMembers(widget.group.id),
        repo.getGroupBalance(widget.group.id),
      ]);

      if (mounted) {
        setState(() {
          _transactions = results[0] as List<Transaction>;
          _members = results[1] as List<Member>;
          _balance = results[2] as double;

          _totalInflow = _transactions
              .where((t) => t.type == 'Inflow')
              .fold(0.0, (sum, item) => sum + item.amount);
          _totalOutflow = _transactions
              .where((t) => t.type == 'Outflow')
              .fold(0.0, (sum, item) => sum + item.amount);

          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to load group details: ${e.toString().replaceAll('ApiException: ', '')}',
            ),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = widget.group.role.toLowerCase() == 'admin';
    final currencyFormat = NumberFormat.currency(
      symbol: '\$',
      decimalDigits: 0,
    );

    final themeController = InheritedThemeController.of(context);
    final isDark = themeController.isDark;
    final accent = themeController.accentColor.primary;
    final backgroundColor = isDark
        ? themeController.accentColor.darkBackground
        : Colors.white;
    final titleColor = isDark ? Colors.white : Colors.black87;
    final cardColor = isDark
        ? Colors.white.withOpacity(0.05)
        : Colors.black.withOpacity(0.03);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          Column(
            children: [
              _buildTopNav(context, titleColor, accent),
              Expanded(
                child: _buildBody(
                  currencyFormat,
                  isAdmin,
                  accent,
                  titleColor,
                  cardColor,
                ),
              ),
              _buildBottomNavBar(accent, titleColor),
            ],
          ),
          if (_currentIndex == 1)
            _buildFixedInsights(currencyFormat, accent, cardColor, titleColor),
        ],
      ),
    );
  }

  Widget _buildTopNav(BuildContext context, Color titleColor, Color accent) {
    return Padding(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 10,
        left: 8,
        right: 16,
        bottom: 12,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back_ios_new, color: titleColor, size: 22),
            onPressed: () => context.pop(),
          ),
          Text(
            widget.group.name,
            style: TextStyle(
              color: titleColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Icon(Icons.file_download_outlined, color: accent, size: 24),
        ],
      ),
    );
  }

  Widget _buildBody(
    NumberFormat fmt,
    bool isAdmin,
    Color accent,
    Color titleColor,
    Color cardColor,
  ) {
    if (_currentIndex == 1) {
      return _buildWalletView(fmt, isAdmin, accent, titleColor, cardColor);
    } else if (_currentIndex == 2) {
      return _buildMembersView(accent, titleColor);
    } else if (_currentIndex == 3) {
      return _buildSettingsView(titleColor);
    }
    return const SizedBox.shrink();
  }

  Widget _buildWalletView(
    NumberFormat fmt,
    bool isAdmin,
    Color accent,
    Color titleColor,
    Color cardColor,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          _buildBalanceCard(fmt, accent, titleColor, cardColor),
          const SizedBox(height: 24),
          _buildMainActionButton(isAdmin, accent),
          const SizedBox(height: 32),
          Text(
            'Recent Transactions',
            style: TextStyle(
              color: titleColor,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          _buildTransactionsList(fmt, accent, titleColor),
          const SizedBox(height: 120), // Spacer for fixed inflow/outflow
        ],
      ),
    );
  }

  Widget _buildBalanceCard(
    NumberFormat fmt,
    Color accent,
    Color titleColor,
    Color cardColor,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: titleColor.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'TOTAL GROUP BALANCE',
                style: TextStyle(
                  color: accent,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              Row(
                children: [
                  Icon(
                    Icons.location_on,
                    color: titleColor.withOpacity(0.4),
                    size: 12,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    widget.group.location.isEmpty
                        ? 'Not Set'
                        : widget.group.location,
                    style: TextStyle(
                      color: titleColor.withOpacity(0.4),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                fmt.format(_balance),
                style: TextStyle(
                  color: titleColor,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '.00',
                style: TextStyle(
                  color: titleColor.withOpacity(0.6),
                  fontSize: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            widget.group.description.isEmpty
                ? 'No description provided for this group.'
                : widget.group.description,
            style: TextStyle(
              color: titleColor.withOpacity(0.54),
              fontSize: 13,
              height: 1.4,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildFixedInsights(
    NumberFormat fmt,
    Color accent,
    Color cardColor,
    Color titleColor,
  ) {
    return Positioned(
      bottom: 80, // Above bottom nav
      left: 20,
      right: 20,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: titleColor.withOpacity(0.08)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: _buildInsightItem(
                'TOTAL INFLOW',
                fmt.format(_totalInflow),
                accent,
                titleColor,
              ),
            ),
            Container(
              width: 1,
              height: 32,
              color: titleColor.withOpacity(0.1),
              margin: const EdgeInsets.symmetric(horizontal: 16),
            ),
            Expanded(
              child: _buildInsightItem(
                'TOTAL OUTFLOW',
                fmt.format(_totalOutflow),
                titleColor,
                titleColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightItem(
    String label,
    String amount,
    Color amountColor,
    Color titleColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(
            color: titleColor.withOpacity(0.38),
            fontSize: 9,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          amount,
          style: TextStyle(
            color: amountColor,
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildMainActionButton(bool isAdmin, Color accent) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        icon: Icon(
          isAdmin ? Icons.payments_outlined : Icons.savings_outlined,
          size: 20,
        ),
        label: Text(
          isAdmin ? 'Disburse Funds' : 'Deposit Funds',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
        ),
      ),
    );
  }

  Widget _buildTransactionsList(
    NumberFormat fmt,
    Color accent,
    Color titleColor,
  ) {
    if (_isLoading)
      return Center(child: CircularProgressIndicator(color: accent));
    if (_transactions.isEmpty)
      return Center(
        child: Text(
          'No transactions yet',
          style: TextStyle(color: titleColor.withOpacity(0.4)),
        ),
      );

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _transactions.length,
      itemBuilder: (context, index) {
        final tx = _transactions[index];
        final isInflow = tx.type == 'Inflow';
        return Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: (isInflow ? accent : Colors.red).withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isInflow
                      ? Icons.file_download_outlined
                      : Icons.file_upload_outlined,
                  color: isInflow ? accent : Colors.red,
                  size: 22,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tx.title,
                      style: TextStyle(
                        color: titleColor,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      tx.date,
                      style: TextStyle(
                        color: titleColor.withOpacity(0.4),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${isInflow ? '+' : '-'}${fmt.format(tx.amount)}.00',
                    style: TextStyle(
                      color: isInflow ? accent : titleColor,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    tx.method.toUpperCase(),
                    style: TextStyle(
                      color: titleColor.withOpacity(0.4),
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMembersView(Color accent, Color titleColor) {
    if (_isLoading)
      return Center(child: CircularProgressIndicator(color: accent));
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _members.length,
      itemBuilder: (context, index) {
        final member = _members[index];
        final isMemberAdmin = member.role.toLowerCase() == 'admin';
        return Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: titleColor.withOpacity(0.05),
                child: Text(
                  member.name[0],
                  style: TextStyle(color: accent, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      member.name,
                      style: TextStyle(
                        color: titleColor,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      member.msisdn,
                      style: TextStyle(
                        color: titleColor.withOpacity(0.4),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              if (isMemberAdmin)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: accent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'ADMIN',
                    style: TextStyle(
                      color: accent,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSettingsView(Color titleColor) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildSettingsItem(
          Icons.edit_outlined,
          'Edit Group Profile',
          titleColor: titleColor,
          onTap: () => context.push('/groups/create', extra: widget.group),
        ),
        _buildSettingsItem(
          Icons.group_add_outlined,
          'Invite Members',
          titleColor: titleColor,
          onTap: () => context.push('/groups/invite', extra: widget.group.id),
        ),
        _buildSettingsItem(
          Icons.security_outlined,
          'Permissions',
          titleColor: titleColor,
        ),
        _buildSettingsItem(
          Icons.notifications_outlined,
          'Notification Settings',
          titleColor: titleColor,
        ),
        Divider(color: titleColor.withOpacity(0.1), height: 40),
        _buildSettingsItem(
          Icons.logout,
          'Exit Group',
          color: Colors.orange,
          titleColor: titleColor,
          onTap: () => _showConfirmationDialog(
            'Exit Group',
            'Are you sure you want to exit this group?',
          ),
        ),
        _buildSettingsItem(
          Icons.delete_outline,
          'Delete Group',
          color: Colors.red,
          titleColor: titleColor,
          onTap: () => _showConfirmationDialog(
            'Delete Group',
            'This action is permanent. All group data will be lost. Continue?',
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsItem(
    IconData icon,
    String title, {
    required Color titleColor,
    Color color = Colors.white,
    VoidCallback? onTap,
  }) {
    final effectiveColor = color == Colors.white ? titleColor : color;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      onTap: onTap,
      leading: Icon(icon, color: effectiveColor.withOpacity(0.6), size: 22),
      title: Text(
        title,
        style: TextStyle(color: effectiveColor.withOpacity(0.8), fontSize: 15),
      ),
      trailing: Icon(Icons.chevron_right, color: titleColor.withOpacity(0.1)),
    );
  }

  void _showConfirmationDialog(String title, String message) {
    final themeController = InheritedThemeController.of(context);
    final isDark = themeController.isDark;
    final backgroundColor = isDark
        ? themeController.accentColor.darkBackground
        : Colors.white;
    final titleColor = isDark ? Colors.white : Colors.black87;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: backgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(title, style: TextStyle(color: titleColor)),
        content: Text(
          message,
          style: TextStyle(color: titleColor.withOpacity(0.7)),
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: Text(
              'Cancel',
              style: TextStyle(color: titleColor.withOpacity(0.5)),
            ),
          ),
          TextButton(
            onPressed: () {
              context.pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Action "$title" completed.'),
                  backgroundColor: Colors.orange,
                ),
              );
              context.pushReplacement('/groups');
            },
            child: const Text(
              'Confirm',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavBar(Color accent, Color titleColor) {
    return Container(
      padding: const EdgeInsets.only(top: 12, bottom: 20),
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border(top: BorderSide(color: titleColor.withOpacity(0.05))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(
            Icons.home_outlined,
            'Home',
            false,
            0,
            accent,
            titleColor,
          ),
          _buildNavItem(
            Icons.account_balance_wallet,
            'Wallet',
            _currentIndex == 1,
            1,
            accent,
            titleColor,
          ),
          _buildNavItem(
            Icons.people_outlined,
            'Members',
            _currentIndex == 2,
            2,
            accent,
            titleColor,
          ),
          _buildNavItem(
            Icons.settings_outlined,
            'Settings',
            _currentIndex == 3,
            3,
            accent,
            titleColor,
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    IconData icon,
    String label,
    bool isActive,
    int index,
    Color accent,
    Color titleColor,
  ) {
    final isDisabled = index == 0;
    return GestureDetector(
      onTap: isDisabled ? null : () => setState(() => _currentIndex = index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isDisabled
                ? titleColor.withOpacity(0.1)
                : (isActive ? accent : titleColor.withOpacity(0.24)),
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isDisabled
                  ? titleColor.withOpacity(0.1)
                  : (isActive ? accent : titleColor.withOpacity(0.24)),
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
