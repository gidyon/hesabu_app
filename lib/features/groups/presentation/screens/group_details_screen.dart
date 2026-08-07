import 'package:file_saver/file_saver.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:hesabu_app/core/api/api_response.dart';
import 'package:hesabu_app/core/constants/app_colors.dart';
import 'package:hesabu_app/features/activity/application/activity_provider.dart';
import 'package:hesabu_app/features/activity/domain/account_activity.dart';
import 'package:hesabu_app/features/groups/application/group_statement_csv_exporter.dart';
import 'package:hesabu_app/features/groups/application/saved_file_opener.dart';
import 'package:hesabu_app/features/groups/domain/groups_repository.dart';
import 'package:hesabu_app/features/groups/presentation/widgets/financial_components.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class GroupDetailsScreen extends StatefulWidget {
  const GroupDetailsScreen({
    super.key,
    required this.group,
    this.savedFileOpener,
  });

  final Group group;
  final SavedFileOpener? savedFileOpener;

  @override
  State<GroupDetailsScreen> createState() => _GroupDetailsScreenState();
}

class _GroupDetailsScreenState extends State<GroupDetailsScreen> {
  int _currentIndex = 0;
  List<Transaction> _transactions = [];
  List<Member> _members = [];
  double _balance = 0;
  bool _isLoading = true;
  bool _isDownloadingStatement = false;

  bool get _isAdmin => widget.group.role.toLowerCase() == 'admin';
  double get _totalInflow => _transactions
      .where((transaction) => transaction.type.toLowerCase() == 'inflow')
      .fold(0, (sum, transaction) => sum + transaction.amount);
  double get _totalOutflow => _transactions
      .where((transaction) => transaction.type.toLowerCase() == 'outflow')
      .fold(0, (sum, transaction) => sum + transaction.amount);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  Future<void> _loadData() async {
    if (mounted) setState(() => _isLoading = true);
    final repository = context.read<GroupsRepository>();
    final results = await Future.wait<Object>([
      repository.getRecentTransactions(widget.group.id),
      repository.getMembers(widget.group.id),
      repository.getGroupBalance(widget.group.id),
    ]);
    if (!mounted) return;

    final transactions = results[0] as ApiResponse<List<Transaction>>;
    final members = results[1] as ApiResponse<List<Member>>;
    final balance = results[2] as ApiResponse<double>;
    setState(() {
      if (!transactions.hasError) _transactions = transactions.data ?? [];
      if (!members.hasError) _members = members.data ?? [];
      if (!balance.hasError) _balance = balance.data ?? widget.group.balance;
      _isLoading = false;
    });

    final message =
        transactions.errorMessage ??
        members.errorMessage ??
        balance.errorMessage;
    if (message != null) _showMessage(message, isError: true);
  }

  Future<void> _downloadStatement() async {
    if (_isDownloadingStatement) return;
    setState(() => _isDownloadingStatement = true);
    final activityProvider = context.read<ActivityProvider>();
    final groupsRepository = context.read<GroupsRepository>();

    await activityProvider.record(
      type: AccountActivityType.statementRequested,
      title: 'Statement requested',
      description: 'Preparing the ${widget.group.name} transaction ledger.',
      status: AccountActivityStatus.pending,
      groupId: widget.group.id,
      groupName: widget.group.name,
    );

    try {
      final response = await groupsRepository.getGroupStatements(
        widget.group.id,
      );
      if (!mounted) return;

      if (response.hasError) {
        _showMessage(
          response.errorMessage ?? 'Unable to download the statement.',
          isError: true,
        );
        return;
      }
      final entries = response.data ?? [];
      if (entries.isEmpty) {
        _showMessage('There are no posted transactions in this statement.');
        return;
      }

      final generatedAt = DateTime.now();
      final bytes = GroupStatementCsvExporter.build(
        group: widget.group,
        entries: entries,
        generatedAt: generatedAt,
      );
      final groupName = widget.group.name
          .trim()
          .toLowerCase()
          .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
          .replaceAll(RegExp(r'^_+|_+$'), '');
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(generatedAt);
      final savedPath = await FileSaver.instance.saveAs(
        name: '${groupName.isEmpty ? 'group' : groupName}_statement_$timestamp',
        bytes: bytes,
        fileExtension: 'csv',
        mimeType: MimeType.csv,
      );
      if (!mounted || savedPath == null || savedPath.trim().isEmpty) return;

      await activityProvider.record(
        type: AccountActivityType.statementDownloaded,
        title: 'Statement downloaded',
        description:
            '${entries.length} ledger transaction${entries.length == 1 ? '' : 's'} exported as CSV.',
        groupId: widget.group.id,
        groupName: widget.group.name,
        reference: DateFormat('yyyyMMddHHmmss').format(generatedAt),
      );
      if (!mounted) return;
      _showMessage(
        'Statement saved successfully.',
        action: kIsWeb
            ? null
            : SnackBarAction(
                label: 'View',
                onPressed: () => _openSavedStatement(savedPath),
              ),
      );
    } catch (_) {
      if (mounted) {
        _showMessage(
          'Unable to save the statement on this device.',
          isError: true,
        );
      }
    } finally {
      if (mounted) setState(() => _isDownloadingStatement = false);
    }
  }

  Future<void> _openSavedStatement(String path) async {
    final result = await (widget.savedFileOpener ?? SavedFileOpener()).open(
      path,
    );
    if (!mounted || result.succeeded) return;
    _showMessage(
      result.message ?? 'Unable to open the saved statement.',
      isError: true,
    );
  }

  Future<void> _copyAccountNumber() async {
    if (widget.group.accountNo.isEmpty) return;
    await Clipboard.setData(ClipboardData(text: widget.group.accountNo));
    if (mounted) _showMessage('Group account number copied.');
  }

  Future<void> _openDeposit() async {
    await context.push('/groups/deposit', extra: widget.group);
    await _loadData();
  }

  Future<void> _openDisbursement() async {
    await context.push('/groups/withdraw', extra: widget.group);
    await _loadData();
  }

  void _showMessage(
    String message, {
    bool isError = false,
    SnackBarAction? action,
  }) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? Theme.of(context).colorScheme.error : null,
          action: action,
          duration: action == null
              ? const Duration(seconds: 4)
              : const Duration(seconds: 8),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.group.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            Text(
              widget.group.accountNo.isEmpty
                  ? 'Group financial account'
                  : 'Account ${widget.group.accountNo}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.secondaryText(context),
              ),
            ),
          ],
        ),
        actions: [
          _isDownloadingStatement
              ? const Padding(
                  padding: EdgeInsets.all(14),
                  child: SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : IconButton(
                  tooltip: 'Download group statement',
                  onPressed: _downloadStatement,
                  icon: const Icon(Icons.download_for_offline_outlined),
                ),
          const SizedBox(width: 6),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: IndexedStack(
                index: _currentIndex,
                children: [
                  _buildOverview(),
                  _buildWallet(),
                  _buildMembers(),
                  _buildSettings(),
                ],
              ),
            ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        height: 68,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.account_balance_outlined),
            selectedIcon: Icon(Icons.account_balance_rounded),
            label: 'Overview',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long_rounded),
            label: 'Ledger',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline_rounded),
            selectedIcon: Icon(Icons.people_rounded),
            label: 'Members',
          ),
          NavigationDestination(
            icon: Icon(Icons.tune_outlined),
            selectedIcon: Icon(Icons.tune_rounded),
            label: 'Manage',
          ),
        ],
      ),
    );
  }

  Widget _buildOverview() {
    return ListView(
      key: const PageStorageKey('group-overview'),
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        FinancialBalancePanel(
          label: 'Available group balance',
          amount: _balance,
          accountNumber: widget.group.accountNo,
          status: widget.group.status.isEmpty ? 'Active' : widget.group.status,
          onCopyAccount: _copyAccountNumber,
          footer:
              'Use this account number when paying through the Hesabu Online Paybill. Contributors do not need an app account.',
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: _openDeposit,
                icon: const Icon(Icons.add_card_rounded),
                label: const Text('Deposit'),
              ),
            ),
            if (_isAdmin) ...[
              const SizedBox(width: 9),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _openDisbursement,
                  icon: const Icon(Icons.north_east_rounded),
                  label: const Text('Disburse'),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: FinancialMetricCard(
                label: 'Total inflow',
                amount: _totalInflow,
                icon: Icons.south_west_rounded,
                color: const Color(0xFF159455),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: FinancialMetricCard(
                label: 'Total outflow',
                amount: _totalOutflow,
                icon: Icons.north_east_rounded,
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        FinancialSectionHeader(
          title: 'Recent transactions',
          subtitle: 'Latest posted ledger entries',
          action: TextButton(
            onPressed: () => setState(() => _currentIndex = 1),
            child: const Text('Full ledger'),
          ),
        ),
        const SizedBox(height: 9),
        if (_transactions.isEmpty)
          const FinancialEmptyState(
            icon: Icons.receipt_long_outlined,
            title: 'No transactions yet',
            message: 'Deposits and disbursements will be listed here.',
          )
        else
          ..._transactions
              .take(4)
              .map(
                (transaction) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: LedgerTransactionTile(
                    transaction: transaction,
                    onTap: () => _showTransactionDetails(transaction),
                  ),
                ),
              ),
        const SizedBox(height: 4),
        Text(
          'Wallet currency: KES • ${widget.group.role.isEmpty ? 'Member' : widget.group.role} access',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.secondaryText(context),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildWallet() {
    return ListView(
      key: const PageStorageKey('group-wallet'),
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        FinancialSectionHeader(
          title: 'Transaction ledger',
          subtitle: '${_transactions.length} posted entries • KES wallet',
          action: IconButton(
            tooltip: 'Download group statement',
            onPressed: _isDownloadingStatement ? null : _downloadStatement,
            icon: const Icon(Icons.download_outlined),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: FinancialMetricCard(
                label: 'Inflow',
                amount: _totalInflow,
                icon: Icons.south_west_rounded,
                color: const Color(0xFF159455),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: FinancialMetricCard(
                label: 'Outflow',
                amount: _totalOutflow,
                icon: Icons.north_east_rounded,
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_transactions.isEmpty)
          const FinancialEmptyState(
            icon: Icons.receipt_long_outlined,
            title: 'Ledger is empty',
            message: 'Completed group transactions will appear here.',
          )
        else
          ..._transactions.map(
            (transaction) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: LedgerTransactionTile(
                transaction: transaction,
                onTap: () => _showTransactionDetails(transaction),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildMembers() {
    return ListView(
      key: const PageStorageKey('group-members'),
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        FinancialSectionHeader(
          title: 'Members',
          subtitle:
              '${_members.length} group participant${_members.length == 1 ? '' : 's'}',
          action: _isAdmin
              ? FilledButton.tonalIcon(
                  onPressed: () async {
                    await context.push('/groups/invite', extra: widget.group);
                    await _loadData();
                  },
                  icon: const Icon(Icons.person_add_alt_1_outlined, size: 18),
                  label: const Text('Invite'),
                )
              : null,
        ),
        const SizedBox(height: 10),
        if (_members.isEmpty)
          const FinancialEmptyState(
            icon: Icons.people_outline_rounded,
            title: 'No members listed',
            message: 'Active members will appear here when available.',
          )
        else
          ..._members.map(
            (member) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: MemberLedgerTile(member: member),
            ),
          ),
      ],
    );
  }

  Widget _buildSettings() {
    return ListView(
      key: const PageStorageKey('group-settings'),
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        const FinancialSectionHeader(
          title: 'Group management',
          subtitle: 'Account and member controls',
        ),
        const SizedBox(height: 10),
        FinancialSurface(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              _managementTile(
                icon: Icons.info_outline_rounded,
                title: 'Group profile',
                subtitle: widget.group.location.isEmpty
                    ? 'View group information'
                    : widget.group.location,
                onTap: _isAdmin
                    ? () async {
                        final updated = await context.push(
                          '/groups/create',
                          extra: widget.group,
                        );
                        if (updated == true) await _loadData();
                      }
                    : null,
              ),
              const Divider(height: 1),
              _managementTile(
                icon: Icons.person_add_alt_1_outlined,
                title: 'Invite members',
                subtitle: 'Share the group account and invitation link',
                onTap: _isAdmin
                    ? () => context.push('/groups/invite', extra: widget.group)
                    : null,
              ),
              const Divider(height: 1),
              _managementTile(
                icon: Icons.description_outlined,
                title: 'Export statement',
                subtitle: 'Download the complete transaction ledger',
                onTap: _downloadStatement,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        FinancialSurface(
          emphasized: true,
          child: Row(
            children: [
              Icon(
                Icons.verified_user_outlined,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Role: ${widget.group.role.isEmpty ? 'Member' : widget.group.role}. Financial actions are limited by your group permissions.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.secondaryText(context),
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _managementTile({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: AppColors.secondaryText(context)),
      ),
      trailing: onTap == null
          ? const FinancialStatusBadge(label: 'View only')
          : const Icon(Icons.chevron_right_rounded),
      onTap: onTap,
    );
  }

  void _showTransactionDetails(Transaction transaction) {
    final isInflow = transaction.type.toLowerCase() == 'inflow';
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isInflow ? 'Deposit details' : 'Disbursement details',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 14),
              LedgerTransactionTile(transaction: transaction),
              const SizedBox(height: 14),
              _detailRow(
                'Reference',
                transaction.id.isEmpty ? 'Pending' : transaction.id,
              ),
              _detailRow('Channel', transaction.method),
              _detailRow('Posted', transaction.date),
              _detailRow('Status', 'Posted'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 88,
          child: Text(
            label,
            style: TextStyle(color: AppColors.secondaryText(context)),
          ),
        ),
        Expanded(
          child: SelectableText(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    ),
  );
}
