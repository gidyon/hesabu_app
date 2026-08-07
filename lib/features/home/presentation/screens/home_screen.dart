import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:hesabu_app/core/constants/app_colors.dart';
import 'package:hesabu_app/core/security/security_controller.dart';
import 'package:hesabu_app/features/activity/application/activity_provider.dart';
import 'package:hesabu_app/features/groups/domain/groups_repository.dart';
import 'package:hesabu_app/features/groups/presentation/widgets/financial_components.dart';
import 'package:hesabu_app/features/settings/domain/settings_repository.dart';
import 'package:hesabu_app/main.dart';
import 'package:local_auth/local_auth.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with WidgetsBindingObserver, RouteAware {
  List<Group> _groups = [];
  UserProfile? _profile;
  bool _isLoading = true;
  bool _isBalanceVisible = false;

  double get _totalSavings =>
      _groups.fold(0, (total, group) => total + group.balance);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _loadData();
      await _checkBiometricPrompt();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute) routeObserver.subscribe(this, route);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didPopNext() => _loadData();

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _loadData();
  }

  Future<void> _loadData() async {
    if (mounted) setState(() => _isLoading = true);
    final groupsRepository = context.read<GroupsRepository>();
    final settingsRepository = context.read<SettingsRepository>();
    final groupsResponse = await groupsRepository.getActiveGroups();
    final profile = await settingsRepository.getUserProfile();
    if (!mounted) return;

    setState(() {
      _groups = groupsResponse.data ?? [];
      _profile = profile;
      _isLoading = false;
    });
    if (groupsResponse.hasError) {
      _showMessage(
        groupsResponse.errorMessage ?? 'Unable to load your group ledgers.',
        isError: true,
      );
    }
  }

  Future<void> _checkBiometricPrompt() async {
    const storage = FlutterSecureStorage();
    if (await storage.read(key: 'bio_enabled') == 'true') return;

    final nextPrompt = DateTime.tryParse(
      await storage.read(key: 'next_bio_prompt') ?? '',
    );
    if (nextPrompt != null && DateTime.now().isBefore(nextPrompt)) return;

    final authentication = LocalAuthentication();
    final supported =
        await authentication.canCheckBiometrics ||
        await authentication.isDeviceSupported();
    if (!supported || !mounted) return;

    final enable = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: Icon(
          Icons.fingerprint_rounded,
          color: Theme.of(context).colorScheme.primary,
        ),
        title: const Text('Enable biometric login?'),
        content: const Text(
          'Use your fingerprint or face as the default secure way to open Hesabu Online.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Maybe later'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Enable'),
          ),
        ],
      ),
    );
    if (!mounted) return;

    if (enable == true) {
      await context.read<SecurityController>().setBiometricEnabled(true);
      if (mounted) _showMessage('Biometric login enabled.');
    } else {
      await storage.write(
        key: 'next_bio_prompt',
        value: DateTime.now().add(const Duration(days: 7)).toIso8601String(),
      );
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Theme.of(context).colorScheme.error : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final firstName = _profile?.firstName.trim().isNotEmpty == true
        ? _profile!.firstName.trim()
        : (_profile?.name.split(' ').first ?? 'Member');

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverAppBar(
              floating: true,
              titleSpacing: 16,
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Good to see you, $firstName',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    'Your savings overview',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.secondaryText(context),
                    ),
                  ),
                ],
              ),
              actions: [
                Consumer<ActivityProvider>(
                  builder: (context, activity, _) => Badge(
                    isLabelVisible: activity.unreadCount > 0,
                    label: Text('${activity.unreadCount}'),
                    child: IconButton(
                      tooltip: 'Account activity',
                      onPressed: () => context.go('/activity'),
                      icon: const Icon(Icons.notifications_none_rounded),
                    ),
                  ),
                ),
                IconButton(
                  tooltip: _isBalanceVisible
                      ? 'Hide balances'
                      : 'Show balances',
                  onPressed: () =>
                      setState(() => _isBalanceVisible = !_isBalanceVisible),
                  icon: Icon(
                    _isBalanceVisible
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                ),
                const SizedBox(width: 8),
              ],
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
              sliver: SliverList.list(
                children: [
                  FinancialBalancePanel(
                    label: 'Total group savings',
                    amount: _totalSavings,
                    status:
                        '${_groups.length} group${_groups.length == 1 ? '' : 's'}',
                    balanceVisible: _isBalanceVisible,
                    footer:
                        'Combined posted balances across your active group ledgers.',
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: _QuickFinancialAction(
                          icon: Icons.add_card_rounded,
                          label: 'Deposit',
                          primary: true,
                          onTap: () => context.push('/groups/deposit'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _QuickFinancialAction(
                          icon: Icons.group_add_outlined,
                          label: 'Join group',
                          onTap: () => context.push('/groups/join'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _QuickFinancialAction(
                          icon: Icons.create_new_folder_outlined,
                          label: 'New group',
                          onTap: () async {
                            final created = await context.push(
                              '/groups/create',
                            );
                            if (created == true) _loadData();
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  FinancialSectionHeader(
                    title: 'Group ledgers',
                    subtitle: 'Balances and collection accounts',
                    action: TextButton(
                      onPressed: () => context.go('/groups'),
                      child: const Text('View all'),
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (_isLoading)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 36),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (_groups.isEmpty)
                    FinancialEmptyState(
                      icon: Icons.account_balance_wallet_outlined,
                      title: 'No group ledgers yet',
                      message:
                          'Join an existing group or create one to begin collecting contributions.',
                      action: FilledButton(
                        onPressed: () => context.push('/groups/join'),
                        child: const Text('Join a group'),
                      ),
                    )
                  else
                    ..._groups
                        .take(3)
                        .map(
                          (group) => Padding(
                            padding: const EdgeInsets.only(bottom: 9),
                            child: GroupLedgerCard(
                              group: group,
                              onOpen: () =>
                                  context.push('/groups/details', extra: group),
                              onDeposit: () =>
                                  context.push('/groups/deposit', extra: group),
                            ),
                          ),
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickFinancialAction extends StatelessWidget {
  const _QuickFinancialAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.primary = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = theme.colorScheme.primary;
    return Material(
      color: primary ? accent : theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 68,
          padding: const EdgeInsets.symmetric(horizontal: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: primary ? accent : theme.colorScheme.outline,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 20,
                color: primary ? theme.colorScheme.onPrimary : accent,
              ),
              const SizedBox(height: 5),
              Text(
                label,
                maxLines: 1,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: primary ? theme.colorScheme.onPrimary : null,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
