import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hesabu_app/core/constants/app_colors.dart';
import 'package:hesabu_app/features/activity/application/activity_provider.dart';
import 'package:hesabu_app/features/activity/domain/account_activity.dart';
import 'package:hesabu_app/features/groups/domain/groups_repository.dart';
import 'package:hesabu_app/features/groups/presentation/widgets/financial_components.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class DepositToGroupScreen extends StatefulWidget {
  const DepositToGroupScreen({super.key, this.group});

  final Group? group;

  @override
  State<DepositToGroupScreen> createState() => _DepositToGroupScreenState();
}

class _DepositToGroupScreenState extends State<DepositToGroupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  List<Group> _groups = [];
  Group? _selectedGroup;
  bool _isLoadingGroups = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadGroups());
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _loadGroups() async {
    final response = await context.read<GroupsRepository>().getActiveGroups();
    if (!mounted) return;

    final groups = response.data ?? [];
    Group? selected;
    if (groups.isNotEmpty) {
      selected = groups.first;
      final preferredId = widget.group?.id;
      if (preferredId != null) {
        for (final group in groups) {
          if (group.id == preferredId) {
            selected = group;
            break;
          }
        }
      }
    }

    setState(() {
      _groups = groups;
      _selectedGroup = selected;
      _isLoadingGroups = false;
    });
    if (response.hasError) {
      _showMessage(
        response.errorMessage ?? 'Unable to load active groups.',
        isError: true,
      );
    }
  }

  double? get _amount =>
      double.tryParse(_amountController.text.replaceAll(',', '').trim());

  Future<void> _reviewDeposit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final group = _selectedGroup;
    final amount = _amount;
    if (group == null || amount == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Confirm deposit'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _reviewRow('Group', group.name),
            _reviewRow(
              'Account',
              group.accountNo.isEmpty ? 'Pending' : group.accountNo,
            ),
            _reviewRow('Amount', _currency(amount)),
            _reviewRow('Payment', 'M-Pesa STK push'),
            const SizedBox(height: 10),
            Text(
              'Check your phone and approve the M-Pesa prompt to complete this contribution.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.secondaryText(context),
                height: 1.4,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Request M-Pesa prompt'),
          ),
        ],
      ),
    );
    if (confirmed == true) await _deposit(group, amount);
  }

  Future<void> _deposit(Group group, double amount) async {
    setState(() => _isSubmitting = true);
    final response = await context.read<GroupsRepository>().deposit(
      group.id,
      amount,
      'mpesa',
    );
    if (!mounted) return;

    setState(() => _isSubmitting = false);
    if (response.hasError || response.data != true) {
      _showMessage(
        response.errorMessage ?? 'Deposit failed. Please try again.',
        isError: true,
      );
      return;
    }

    await context.read<ActivityProvider>().record(
      type: AccountActivityType.deposit,
      title: 'Deposit initiated',
      description: 'An M-Pesa contribution was initiated for ${group.name}.',
      groupId: group.id,
      groupName: group.name,
      amount: amount,
      status: AccountActivityStatus.pending,
      metadata: {'channel': 'mpesa', 'account_no': group.accountNo},
    );
    if (mounted) _showSuccessSheet(group, amount);
  }

  void _showSuccessSheet(Group group, double amount) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isDismissible: false,
      enableDrag: false,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.phonelink_lock_rounded,
                size: 42,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 12),
              Text(
                'M-Pesa request sent',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 5),
              Text(
                '${_currency(amount)} for ${group.name}. Approve the prompt on your phone; the ledger will update after confirmation.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.secondaryText(context),
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    Navigator.pop(sheetContext);
                    context.pop(true);
                  },
                  child: const Text('Done'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _reviewRow(String label, String value) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 78,
          child: Text(
            label,
            style: TextStyle(color: AppColors.secondaryText(context)),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    ),
  );

  String _currency(double amount) =>
      NumberFormat.currency(symbol: 'KSh ', decimalDigits: 2).format(amount);

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
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Deposit funds',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: _isLoadingGroups
          ? const Center(child: CircularProgressIndicator())
          : _groups.isEmpty
          ? FinancialEmptyState(
              icon: Icons.account_balance_wallet_outlined,
              title: 'No active groups',
              message: 'Join or create a group before making a contribution.',
              action: FilledButton(
                onPressed: () => context.push('/groups/join'),
                child: const Text('Join a group'),
              ),
            )
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
                children: [
                  const FinancialSectionHeader(
                    title: 'Contribution details',
                    subtitle: 'Credit a group collection ledger using M-Pesa',
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<Group>(
                    initialValue: _selectedGroup,
                    decoration: const InputDecoration(
                      labelText: 'Group account',
                      prefixIcon: Icon(Icons.groups_2_outlined),
                    ),
                    items: _groups
                        .map(
                          (group) => DropdownMenuItem(
                            value: group,
                            child: Text(
                              group.accountNo.isEmpty
                                  ? group.name
                                  : '${group.name} • ${group.accountNo}',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(growable: false),
                    onChanged: (group) =>
                        setState(() => _selectedGroup = group),
                  ),
                  if (_selectedGroup != null) ...[
                    const SizedBox(height: 8),
                    FinancialSurface(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Current ledger balance',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: AppColors.secondaryText(context),
                              ),
                            ),
                          ),
                          Text(
                            _currency(_selectedGroup!.balance),
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _amountController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    textInputAction: TextInputAction.done,
                    onChanged: (_) => setState(() {}),
                    onFieldSubmitted: (_) => _reviewDeposit(),
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Contribution amount',
                      prefixText: 'KSh  ',
                      prefixIcon: Icon(Icons.payments_outlined),
                      hintText: '0.00',
                    ),
                    validator: (value) {
                      final amount = double.tryParse(
                        value?.replaceAll(',', '').trim() ?? '',
                      );
                      if (amount == null || amount <= 0) {
                        return 'Enter an amount greater than zero';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 7,
                    runSpacing: 7,
                    children: [500, 1000, 2000, 5000]
                        .map(
                          (amount) => ChoiceChip(
                            label: Text(
                              NumberFormat.decimalPattern().format(amount),
                            ),
                            selected: _amountController.text == '$amount',
                            onSelected: (_) => setState(
                              () => _amountController.text = '$amount',
                            ),
                          ),
                        )
                        .toList(growable: false),
                  ),
                  const SizedBox(height: 18),
                  FinancialSurface(
                    emphasized: true,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.phone_android_rounded,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'M-Pesa STK push',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                'A secure payment prompt will be sent to your registered phone number.',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: AppColors.secondaryText(context),
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const FinancialStatusBadge(label: 'Secure'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  FilledButton.icon(
                    onPressed: _isSubmitting ? null : _reviewDeposit,
                    icon: _isSubmitting
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.arrow_forward_rounded),
                    label: const Text('Review deposit'),
                  ),
                ],
              ),
            ),
    );
  }
}
