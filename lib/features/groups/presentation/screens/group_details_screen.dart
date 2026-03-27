import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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

    return Scaffold(
      backgroundColor: const Color(0xFF0b130d),
      body: Stack(
        children: [
          Column(
            children: [
              _buildTopNav(context),
              Expanded(child: _buildBody(currencyFormat, isAdmin)),
              _buildBottomNavBar(),
            ],
          ),
          if (_currentIndex == 1) _buildFixedInsights(currencyFormat),
        ],
      ),
    );
  }

  Widget _buildTopNav(BuildContext context) {
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
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: Colors.white,
              size: 22,
            ),
            onPressed: () => context.pop(),
          ),
          Text(
            widget.group.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Icon(
            Icons.file_download_outlined,
            color: Color(0xFF2ecc71),
            size: 24,
          ),
        ],
      ),
    );
  }

  Widget _buildBody(NumberFormat fmt, bool isAdmin) {
    if (_currentIndex == 1) {
      return _buildWalletView(fmt, isAdmin);
    } else if (_currentIndex == 2) {
      return _buildMembersView();
    } else if (_currentIndex == 3) {
      return _buildSettingsView();
    }
    return const SizedBox.shrink();
  }

  Widget _buildWalletView(NumberFormat fmt, bool isAdmin) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          _buildBalanceCard(fmt),
          const SizedBox(height: 24),
          _buildMainActionButton(isAdmin),
          const SizedBox(height: 32),
          const Text(
            'Recent Transactions',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          _buildTransactionsList(fmt),
          const SizedBox(height: 120), // Spacer for fixed inflow/outflow
        ],
      ),
    );
  }

  Widget _buildBalanceCard(NumberFormat fmt) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF16221a),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'TOTAL GROUP BALANCE',
                style: TextStyle(
                  color: Color(0xFF2ecc71),
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              Row(
                children: [
                  const Icon(
                    Icons.location_on,
                    color: Colors.white38,
                    size: 12,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    widget.group.location.isEmpty
                        ? 'Not Set'
                        : widget.group.location,
                    style: const TextStyle(color: Colors.white38, fontSize: 11),
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
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                '.00',
                style: TextStyle(color: Colors.white60, fontSize: 20),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            widget.group.description.isEmpty
                ? 'No description provided for this group.'
                : widget.group.description,
            style: const TextStyle(
              color: Colors.white54,
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

  Widget _buildFixedInsights(NumberFormat fmt) {
    return Positioned(
      bottom: 80, // Above bottom nav
      left: 20,
      right: 20,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF16221a),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
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
                const Color(0xFF2ecc71),
              ),
            ),
            Container(
              width: 1,
              height: 32,
              color: Colors.white.withOpacity(0.1),
              margin: const EdgeInsets.symmetric(horizontal: 16),
            ),
            Expanded(
              child: _buildInsightItem(
                'TOTAL OUTFLOW',
                fmt.format(_totalOutflow),
                Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightItem(String label, String amount, Color amountColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white38,
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

  Widget _buildMainActionButton(bool isAdmin) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2ecc71),
          foregroundColor: const Color(0xFF0b130d),
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

  Widget _buildTransactionsList(NumberFormat fmt) {
    if (_isLoading)
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF2ecc71)),
      );
    if (_transactions.isEmpty)
      return const Center(
        child: Text(
          'No transactions yet',
          style: TextStyle(color: Colors.white38),
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
                  color: (isInflow ? const Color(0xFF2ecc71) : Colors.red)
                      .withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isInflow
                      ? Icons.file_download_outlined
                      : Icons.file_upload_outlined,
                  color: isInflow ? const Color(0xFF2ecc71) : Colors.red,
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
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      tx.date,
                      style: const TextStyle(
                        color: Colors.white38,
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
                      color: isInflow ? const Color(0xFF2ecc71) : Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    tx.method.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white38,
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

  Widget _buildMembersView() {
    if (_isLoading)
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF2ecc71)),
      );
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
                backgroundColor: const Color(0xFF16221a),
                child: Text(
                  member.name[0],
                  style: const TextStyle(
                    color: Color(0xFF2ecc71),
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
                      member.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      member.msisdn,
                      style: const TextStyle(
                        color: Colors.white38,
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
                    color: const Color(0xFF2ecc71).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'ADMIN',
                    style: TextStyle(
                      color: Color(0xFF2ecc71),
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

  Widget _buildSettingsView() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildSettingsItem(
          Icons.edit_outlined,
          'Edit Group Profile',
          onTap: () => context.push('/groups/create', extra: widget.group),
        ),
        _buildSettingsItem(
          Icons.group_add_outlined,
          'Invite Members',
          onTap: () => context.push('/groups/invite', extra: widget.group.id),
        ),
        _buildSettingsItem(Icons.security_outlined, 'Permissions'),
        _buildSettingsItem(
          Icons.notifications_outlined,
          'Notification Settings',
        ),
        const Divider(color: Colors.white10, height: 40),
        _buildSettingsItem(
          Icons.logout,
          'Exit Group',
          color: Colors.orange,
          onTap: () => _showConfirmationDialog(
            'Exit Group',
            'Are you sure you want to exit this group?',
          ),
        ),
        _buildSettingsItem(
          Icons.delete_outline,
          'Delete Group',
          color: Colors.red,
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
    Color color = Colors.white,
    VoidCallback? onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      onTap: onTap,
      leading: Icon(icon, color: color.withOpacity(0.6), size: 22),
      title: Text(
        title,
        style: TextStyle(color: color.withOpacity(0.8), fontSize: 15),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.white10),
    );
  }

  void _showInviteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF16221a),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text(
          'Invite Members',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Phone number or Email',
                hintStyle: const TextStyle(color: Colors.white24),
                filled: true,
                fillColor: Colors.black26,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Please only invite people you know. Avoid spamming.',
              style: TextStyle(color: Colors.white38, fontSize: 11),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white54),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              context.pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Invitation sent successfully!'),
                  backgroundColor: Color(0xFF2ecc71),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2ecc71),
              foregroundColor: Colors.black,
            ),
            child: const Text('Send Invite'),
          ),
        ],
      ),
    );
  }

  void _showConfirmationDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF16221a),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(title, style: const TextStyle(color: Colors.white)),
        content: Text(message, style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white54),
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

  Widget _buildBottomNavBar() {
    return Container(
      padding: const EdgeInsets.only(top: 12, bottom: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF0b130d),
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.home_outlined, 'Home', false, 0),
          _buildNavItem(
            Icons.account_balance_wallet,
            'Wallet',
            _currentIndex == 1,
            1,
          ),
          _buildNavItem(
            Icons.people_outlined,
            'Members',
            _currentIndex == 2,
            2,
          ),
          _buildNavItem(
            Icons.settings_outlined,
            'Settings',
            _currentIndex == 3,
            3,
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive, int index) {
    final isDisabled = index == 0;
    return GestureDetector(
      onTap: isDisabled ? null : () => setState(() => _currentIndex = index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isDisabled
                ? Colors.white10
                : (isActive ? const Color(0xFF2ecc71) : Colors.white24),
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isDisabled
                  ? Colors.white10
                  : (isActive ? const Color(0xFF2ecc71) : Colors.white24),
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
