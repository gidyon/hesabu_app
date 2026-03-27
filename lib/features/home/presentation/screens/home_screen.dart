import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hesabu_app/core/constants/app_colors.dart';
import 'package:hesabu_app/core/theme/inherited_theme_controller.dart';
import 'package:hesabu_app/core/theme/theme_controller.dart';
import 'package:hesabu_app/features/groups/domain/groups_repository.dart';
import 'package:hesabu_app/features/settings/domain/settings_repository.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Group> _groups = [];
  double _totalSavings = 0.0;
  bool _isLoading = true;
  bool _isBalanceVisible = true;
  UserProfile? _profile;

  @override
  void initState() {
    super.initState();
    _loadData().then((_) {
      _checkBiometricPrompt();
    });
  }

  Future<void> _checkBiometricPrompt() async {
    const storage = FlutterSecureStorage();
    final bioEnabled = await storage.read(key: 'bio_enabled');

    // If already enabled, don't show
    if (bioEnabled == 'true') return;

    // Check if we should snooze
    final nextPromptStr = await storage.read(key: 'next_bio_prompt');
    if (nextPromptStr != null) {
      final nextPrompt = DateTime.parse(nextPromptStr);
      if (DateTime.now().isBefore(nextPrompt)) return;
    }

    // Check if device supports biometrics
    final auth = LocalAuthentication();
    final canAuth =
        await auth.canCheckBiometrics || await auth.isDeviceSupported();
    if (!canAuth) return;

    if (mounted) {
      _showBiometricDialog();
    }
  }

  void _showBiometricDialog() {
    final accent = InheritedThemeController.of(context).accentColor.primary;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.fingerprint, color: accent, size: 28),
            const SizedBox(width: 12),
            const Text('Security Prompt'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Secure your account with biometric login for faster and safer access.',
              style: TextStyle(fontSize: 15),
            ),
            const SizedBox(height: 12),
            Text(
              'You can also enable or disable this later in Settings > Security Settings.',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(
                  context,
                ).textTheme.bodySmall?.color?.withOpacity(0.7),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              const storage = FlutterSecureStorage();
              final nextDate = DateTime.now().add(const Duration(days: 7));
              await storage.write(
                key: 'next_bio_prompt',
                value: nextDate.toIso8601String(),
              );
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text(
              'Maybe Later',
              style: TextStyle(color: AppColors.slate500),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.push('/settings/security');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: accent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Enable Now'),
          ),
        ],
      ),
    );
  }

  Future<void> _loadData() async {
    final groupsRepository = context.read<GroupsRepository>();
    final settingsRepository = context.read<SettingsRepository>();

    final groups = await groupsRepository.getActiveGroups();
    final total = await groupsRepository.getTotalSavings();
    final profile = await settingsRepository.getUserProfile();

    if (mounted) {
      setState(() {
        _groups = groups;
        _totalSavings = total;
        _profile = profile;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = InheritedThemeController.of(context);
    final accent = controller.accentColor.primary;
    final isDark = controller.isDark;
    final titleColor = isDark ? Colors.white : Colors.black87;

    return Scaffold(
      backgroundColor: isDark
          ? controller.accentColor.darkBackground
          : Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).padding.top + 10,
                    width: 0,
                  ),
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
                        child: CircleAvatar(
                          radius: 18,
                          backgroundColor: accent.withOpacity(0.12),
                          backgroundImage:
                              _profile?.avatarUrl.startsWith('/') == true
                              ? null
                              : NetworkImage(
                                      _profile?.avatarUrl ??
                                          "https://i.pravatar.cc/100?img=12",
                                    )
                                    as ImageProvider,
                          child: _profile?.avatarUrl.startsWith('/') == true
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(18),
                                  child: Image.file(
                                    File(_profile!.avatarUrl),
                                    fit: BoxFit.cover,
                                    width: 36,
                                    height: 36,
                                  ),
                                )
                              : null,
                        ),
                      ),
                      Row(
                        children: [
                          _buildHeaderIcon(
                            context,
                            Icons.notifications_outlined,
                            isDark,
                            onTap: () => context.go('/activity'),
                          ),
                          const SizedBox(width: 8),
                          _buildHeaderIcon(
                            context,
                            _isBalanceVisible
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            isDark,
                            onTap: () => setState(
                              () => _isBalanceVisible = !_isBalanceVisible,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Welcome, Gideon',
                    style: TextStyle(
                      color: titleColor,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Total Savings Hero Card
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
                        Text(
                          'TOTAL GROUP SAVINGS',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _isBalanceVisible
                              ? NumberFormat.currency(
                                  symbol: 'KSh ',
                                  decimalDigits: 2,
                                ).format(_totalSavings)
                              : 'KSh ••••••••',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
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
                  // Actions Row
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
                          icon: Icons.add_circle_outline_rounded,
                          label: 'New Group',
                          accent: accent,
                          onTap: () => context.push('/groups/create'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  Text(
                    'Your Active Groups',
                    style: TextStyle(
                      color: titleColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _groups.isEmpty
                      ? _buildEmptyGroups(accent, titleColor)
                      : _buildGroupsList(accent, titleColor, isDark),
                ],
              ),
            ),
          ),
        ],
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

  Widget _buildHeaderIcon(
    BuildContext context,
    IconData icon,
    bool isDark, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
      ),
    );
  }

  Widget _buildGroupsList(Color accent, Color titleColor, bool isDark) {
    final currencyFormat = NumberFormat.currency(
      symbol: 'KSh ',
      decimalDigits: 2,
    );
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _groups.take(3).length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        return _buildGroupCard(
          context,
          _groups[index],
          currencyFormat,
          accent,
          isDark,
        );
      },
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
      onTap: () => context.push('/groups/details', extra: group),
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
                        '${group.membersCount} Members • ${group.frequency}',
                        style: const TextStyle(
                          color: AppColors.slate500,
                          fontSize: 12,
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
                      fmt.format(group.balance),
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Text(
                  '${(group.progressPercentage * 100).toInt()}% of Goal',
                  style: TextStyle(
                    color: accent,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
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

  Widget _buildEmptyGroups(Color accent, Color titleColor) {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 20),
          Icon(
            Icons.group_outlined,
            size: 48,
            color: titleColor.withOpacity(0.2),
          ),
          const SizedBox(height: 12),
          Text(
            'No groups yet',
            style: TextStyle(color: titleColor.withOpacity(0.5)),
          ),
        ],
      ),
    );
  }
}
