import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hesabu_app/core/api/api_response.dart';
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
  int _currentIndex = 0; // Default to Home tab
  List<Transaction> _transactions = [];
  List<Member> _members = [];
  double _balance = 0.0;
  bool _isLoading = true;
  double _totalInflow = 0.0;
  double _totalOutflow = 0.0;

  Future<void> _fetchTransactions() async {
    final repo = context.read<GroupsRepository>();
    try {
      final response = await repo.getRecentTransactions(widget.group.id);
      if (mounted && !response.hasError) {
        setState(() {
          _transactions = response.data!;
          _totalInflow = _transactions
              .where((t) => t.type == 'Inflow')
              .fold(0.0, (sum, item) => sum + item.amount);
          _totalOutflow = _transactions
              .where((t) => t.type == 'Outflow')
              .fold(0.0, (sum, item) => sum + item.amount);
        });
      }
    } catch (e) {
      // Ignore silently for background refresh
    }
  }

  Future<void> _fetchMembers() async {
    final repo = context.read<GroupsRepository>();
    try {
      final response = await repo.getMembers(widget.group.id);
      if (mounted && !response.hasError) {
        setState(() {
          _members = response.data!;
        });
      }
    } catch (e) {
      // Ignore silently for background refresh
    }
  }

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

      final txResponse = results[0] as ApiResponse<List<Transaction>>;
      final memberResponse = results[1] as ApiResponse<List<Member>>;
      final balanceResponse = results[2] as ApiResponse<double>;

      if (mounted) {
        setState(() {
          if (!txResponse.hasError) {
            _transactions = txResponse.data!;
            _totalInflow = _transactions
                .where((t) => t.type == 'Inflow')
                .fold(0.0, (sum, item) => sum + item.amount);
            _totalOutflow = _transactions
                .where((t) => t.type == 'Outflow')
                .fold(0.0, (sum, item) => sum + item.amount);
          }

          if (!memberResponse.hasError) {
            _members = memberResponse.data!;
          }

          if (!balanceResponse.hasError) {
            _balance = balanceResponse.data!;
          }

          _isLoading = false;
        });

        if (txResponse.hasError ||
            memberResponse.hasError ||
            balanceResponse.hasError) {
          final error =
              txResponse.errorMessage ??
              memberResponse.errorMessage ??
              balanceResponse.errorMessage;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error ?? 'Error loading some data'),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = widget.group.role.toLowerCase() == 'admin';
    final currencyFormat = NumberFormat.currency(
      symbol: 'KSh ',
      decimalDigits: 2,
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
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  layoutBuilder:
                      (Widget? currentChild, List<Widget> previousChildren) {
                        return Stack(
                          alignment: Alignment.topCenter,
                          children: <Widget>[
                            ...previousChildren,
                            if (currentChild != null) currentChild,
                          ],
                        );
                      },
                  switchInCurve: Curves.easeInOut,
                  switchOutCurve: Curves.easeInOut,
                  transitionBuilder:
                      (Widget child, Animation<double> animation) {
                        return FadeTransition(
                          opacity: animation,
                          child: ScaleTransition(
                            scale: Tween<double>(
                              begin: 0.98,
                              end: 1.0,
                            ).animate(animation),
                            child: child,
                          ),
                        );
                      },
                  child: KeyedSubtree(
                    key: ValueKey<int>(_currentIndex),
                    child: _buildBody(
                      currencyFormat,
                      isAdmin,
                      accent,
                      titleColor,
                      cardColor,
                    ),
                  ),
                ),
              ),
              SafeArea(
                top: false,
                child: _buildBottomNavBar(accent, titleColor),
              ),
            ],
          ),
          if (_currentIndex == 0)
            _buildFixedInsights(
              currencyFormat,
              accent,
              cardColor,
              titleColor,
              backgroundColor,
            ),
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
    if (_currentIndex == 0) {
      return _buildHomeView(fmt, isAdmin, accent, titleColor, cardColor);
    } else if (_currentIndex == 1) {
      return _buildWalletView(fmt, accent, titleColor);
    } else if (_currentIndex == 2) {
      return _buildMembersView(accent, titleColor, isAdmin);
    } else if (_currentIndex == 3) {
      return _buildSettingsView(titleColor);
    }
    return const SizedBox.shrink();
  }

  Widget _buildHomeView(
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
          _buildMainActionButton(isAdmin, accent, titleColor),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Transactions',
                style: TextStyle(
                  color: titleColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                onPressed: () {
                  setState(() => _currentIndex = 1);
                  _fetchTransactions();
                },
                child: Text(
                  'See All',
                  style: TextStyle(
                    color: accent,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildTransactionsList(fmt, accent, titleColor),
          const SizedBox(height: 120), // Spacer for fixed inflow/outflow
        ],
      ),
    );
  }

  Widget _buildWalletView(NumberFormat fmt, Color accent, Color titleColor) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Text(
            'Group Statements',
            style: TextStyle(
              color: titleColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          _buildTransactionsList(fmt, accent, titleColor),
          const SizedBox(height: 40),
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
        gradient: LinearGradient(
          colors: [accent, accent.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'TOTAL GROUP BALANCE',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                fmt.format(_balance),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                '.00',
                style: TextStyle(color: Colors.white70, fontSize: 20),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.trending_up, color: Colors.white, size: 14),
              const SizedBox(width: 6),
              Text(
                '+4.2% from last month',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
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
    Color backgroundColor,
  ) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    return Positioned(
      bottom: bottomPadding + 96,
      left: 20,
      right: 20,
      child: Row(
        children: [
          Expanded(
            child: _buildInsightCard(
              'TOTAL INFLOW',
              fmt.format(_totalInflow),
              accent,
              cardColor,
              backgroundColor,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildInsightCard(
              'TOTAL OUTFLOW',
              fmt.format(_totalOutflow),
              titleColor,
              cardColor,
              backgroundColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightCard(
    String label,
    String amount,
    Color amountColor,
    Color cardColor,
    Color backgroundColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color.alphaBlend(cardColor, backgroundColor),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            amount,
            style: TextStyle(
              color: amountColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainActionButton(bool isAdmin, Color accent, Color titleColor) {
    final btnColor = accent;
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: btnColor.withOpacity(0.2),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: () {
          if (isAdmin) {
            context
                .push('/groups/withdraw', extra: widget.group)
                .then((_) => _loadData());
          } else {
            context.push('/groups/deposit').then((_) => _loadData());
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: btnColor,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        icon: Icon(
          isAdmin ? Icons.payments_outlined : Icons.savings_outlined,
          size: 20,
          color: Colors.black,
        ),
        label: Text(
          isAdmin ? 'Disburse Funds' : 'Deposit Funds',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: Colors.black,
          ),
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
      return Container(
        alignment: Alignment.topCenter,
        padding: const EdgeInsets.only(top: 40),
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
        final amountColor = isInflow ? accent : titleColor;
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
                      ? Icons.arrow_downward_rounded
                      : Icons.arrow_upward_rounded,
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
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${tx.type} • ${tx.date}',
                      style: TextStyle(
                        color: titleColor.withOpacity(0.5),
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
                    '${isInflow ? '+' : '-'}${fmt.format(tx.amount)}',
                    style: TextStyle(
                      color: amountColor,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    tx.method.toUpperCase(),
                    style: TextStyle(
                      color: titleColor.withOpacity(0.5),
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
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

  Widget _buildMembersView(Color accent, Color titleColor, bool isAdmin) {
    if (_isLoading)
      return Center(child: CircularProgressIndicator(color: accent));
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Members (${_members.length})',
                style: TextStyle(
                  color: titleColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (isAdmin)
                IconButton(
                  onPressed: () async {
                    await context.push(
                      '/groups/invite',
                      extra: widget.group.id,
                    );
                    _loadData();
                  },
                  icon: Icon(Icons.person_add_alt_1, color: accent),
                  tooltip: 'Invite Member',
                ),
            ],
          ),
        ),
        Expanded(
          child: _members.isEmpty
              ? Container(
                  alignment: Alignment.topCenter,
                  padding: const EdgeInsets.only(top: 40),
                  child: Text(
                    'No members yet',
                    style: TextStyle(color: titleColor.withOpacity(0.4)),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
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
                              member.name.isNotEmpty ? member.name[0] : '?',
                              style: TextStyle(
                                color: accent,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  member.name.isNotEmpty
                                      ? member.name
                                      : member.msisdn,
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
                ),
        ),
      ],
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
        children: [
          _buildNavItem(
            Icons.space_dashboard_outlined,
            'Home',
            _currentIndex == 0,
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
    bool isSelected,
    int index,
    Color accent,
    Color titleColor,
  ) {
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          setState(() => _currentIndex = index);
          if (index == 1) {
            _fetchTransactions();
          } else if (index == 2) {
            _fetchMembers();
          }
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? accent : titleColor.withOpacity(0.24),
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? accent : titleColor.withOpacity(0.24),
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
