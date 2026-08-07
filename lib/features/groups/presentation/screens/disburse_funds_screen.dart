import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_contacts/flutter_contacts.dart' hide Group;
import 'package:go_router/go_router.dart';
import 'package:hesabu_app/core/constants/app_colors.dart';
import 'package:hesabu_app/core/utils/phone_utils.dart';
import 'package:hesabu_app/features/activity/application/activity_provider.dart';
import 'package:hesabu_app/features/activity/domain/account_activity.dart';
import 'package:hesabu_app/features/groups/domain/groups_repository.dart';
import 'package:hesabu_app/features/groups/presentation/widgets/financial_components.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class DisburseFundsScreen extends StatefulWidget {
  const DisburseFundsScreen({super.key, this.group});

  final Group? group;

  @override
  State<DisburseFundsScreen> createState() => _DisburseFundsScreenState();
}

class _DisburseFundsScreenState extends State<DisburseFundsScreen> {
  final _destinationController = TextEditingController();
  final _amountController = TextEditingController();
  final _paybillController = TextEditingController();

  bool _isIndividual = true;
  String _businessType = 'TILLNO';
  bool _isSubmitting = false;
  bool _isReviewing = false;
  bool _isFeeLoading = false;
  double? _withdrawalFee;
  double? _quotedAmount;
  String? _feeError;
  Timer? _feeDebounce;
  int _feeRequestId = 0;

  @override
  void dispose() {
    _feeDebounce?.cancel();
    _destinationController.dispose();
    _amountController.dispose();
    _paybillController.dispose();
    super.dispose();
  }

  double? get _amount =>
      double.tryParse(_amountController.text.replaceAll(',', '').trim());

  void _setRecipientType(bool individual) {
    if (_isIndividual == individual) return;
    setState(() {
      _isIndividual = individual;
      _destinationController.clear();
      _paybillController.clear();
    });
  }

  void _scheduleFeeLookup() {
    _feeDebounce?.cancel();
    final requestId = ++_feeRequestId;
    final amount = _amount;
    setState(() {
      _withdrawalFee = null;
      _quotedAmount = null;
      _feeError = null;
      _isFeeLoading = amount != null && amount > 0;
    });
    if (amount == null || amount <= 0) return;

    _feeDebounce = Timer(
      const Duration(milliseconds: 350),
      () => _loadFee(requestId, amount),
    );
  }

  Future<void> _loadFee(int requestId, double amount) async {
    final response = await context.read<GroupsRepository>().getWithdrawalFee(
      amount: amount,
    );
    if (!mounted || requestId != _feeRequestId) return;

    setState(() {
      _isFeeLoading = false;
      if (response.hasError || response.data == null) {
        _feeError = response.errorMessage ?? 'Current tariff is unavailable.';
      } else {
        _withdrawalFee = response.data;
        _quotedAmount = amount;
      }
    });
  }

  Future<void> _pickContact() async {
    if (kIsWeb ||
        (defaultTargetPlatform != TargetPlatform.android &&
            defaultTargetPlatform != TargetPlatform.iOS)) {
      _showMessage('Contact selection is available on Android and iOS.');
      return;
    }

    try {
      final permission = await FlutterContacts.permissions.request(
        PermissionType.read,
      );
      final granted =
          permission == PermissionStatus.granted ||
          permission == PermissionStatus.limited;
      if (!granted) {
        if (!mounted) return;
        final requiresSettings =
            permission == PermissionStatus.permanentlyDenied ||
            permission == PermissionStatus.restricted;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              requiresSettings
                  ? 'Enable contacts access in system settings.'
                  : 'Contacts permission is required to choose a recipient.',
            ),
            action: requiresSettings
                ? SnackBarAction(
                    label: 'Settings',
                    onPressed: FlutterContacts.permissions.openSettings,
                  )
                : null,
          ),
        );
        return;
      }

      final contact = await FlutterContacts.native.showPicker(
        properties: const {ContactProperty.phone},
      );
      if (!mounted || contact == null) return;
      if (contact.phones.isEmpty) {
        _showMessage('The selected contact has no phone number.');
        return;
      }

      var selectedPhone = contact.phones.first;
      for (final phone in contact.phones) {
        if (phone.isPrimary == true) selectedPhone = phone;
      }
      _destinationController.text =
          selectedPhone.normalizedNumber ?? selectedPhone.number;
    } on PlatformException {
      if (mounted) _showMessage('Unable to open contacts.', isError: true);
    }
  }

  Future<void> _reviewAndDisburse() async {
    if (_isSubmitting || _isReviewing) return;
    final group = widget.group;
    if (group == null) {
      _showMessage('No source group was selected.', isError: true);
      return;
    }

    final destination = _destinationController.text.trim();
    final amount = _amount;
    if (destination.isEmpty || amount == null || amount <= 0) {
      _showMessage('Enter a valid destination and amount.');
      return;
    }
    if (_isIndividual && !PhoneUtils.isValidMsisdn(destination)) {
      _showMessage('Enter a valid Kenyan phone number, for example 0712…');
      return;
    }
    if (!_isIndividual &&
        _businessType == 'PAYBILL' &&
        _paybillController.text.trim().isEmpty) {
      _showMessage('Enter the Paybill business number.');
      return;
    }
    if (_isFeeLoading) {
      _showMessage('Wait while the current tariff is loaded.');
      return;
    }

    final fee = _withdrawalFee;
    if (fee == null || _quotedAmount != amount) {
      _showMessage(
        _feeError ?? 'Current tariff is unavailable. Re-enter the amount.',
        isError: true,
      );
      return;
    }
    if (amount + fee > group.balance) {
      _showMessage(
        'Amount plus the ${_currency(fee)} fee exceeds the available balance.',
        isError: true,
      );
      return;
    }

    setState(() => _isReviewing = true);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Confirm disbursement'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _reviewRow('Source', group.name),
            _reviewRow(
              'Recipient',
              _isIndividual
                  ? destination
                  : _businessType == 'PAYBILL'
                  ? '${_paybillController.text.trim()} / $destination'
                  : destination,
            ),
            _reviewRow('Amount', _currency(amount)),
            _reviewRow('Fee', _currency(fee)),
            _reviewRow('Total debit', _currency(amount + fee)),
            const SizedBox(height: 10),
            Text(
              'This transfer is immediate. Confirm the destination and amount carefully.',
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
            child: const Text('Disburse'),
          ),
        ],
      ),
    );
    if (!mounted) return;
    setState(() => _isReviewing = false);
    if (confirmed != true) return;

    await _submit(group, destination, amount, fee);
  }

  Future<void> _submit(
    Group group,
    String destination,
    double amount,
    double fee,
  ) async {
    setState(() => _isSubmitting = true);
    final response = await context.read<GroupsRepository>().withdraw(
      groupId: group.id,
      amount: amount,
      withdrawalType: _isIndividual ? 'INDIVIDUAL' : 'BUSINESS',
      destination: destination,
      billerType: _isIndividual ? null : _businessType,
      billerNumber: !_isIndividual && _businessType == 'PAYBILL'
          ? _paybillController.text.trim()
          : null,
    );
    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (response.hasError || response.data != true) {
      _showMessage(
        response.errorMessage ?? 'Disbursement failed. Please try again.',
        isError: true,
      );
      return;
    }

    await context.read<ActivityProvider>().record(
      type: AccountActivityType.withdrawal,
      title: 'Funds disbursed',
      description: '${_currency(amount)} was sent from ${group.name}.',
      groupId: group.id,
      groupName: group.name,
      amount: amount,
      metadata: {
        'destination': destination,
        'fee': fee.toStringAsFixed(2),
        'recipient_type': _isIndividual ? 'individual' : _businessType,
      },
    );
    if (mounted) _showSuccessSheet(amount);
  }

  String _currency(double value) =>
      NumberFormat.currency(symbol: 'KSh ', decimalDigits: 2).format(value);

  Widget _reviewRow(String label, String value) => Padding(
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
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    ),
  );

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Theme.of(context).colorScheme.error : null,
      ),
    );
  }

  void _showSuccessSheet(double amount) {
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
                Icons.verified_rounded,
                size: 42,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 12),
              Text(
                'Disbursement Successful!',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 5),
              Text(
                '${_currency(amount)} has been sent and recorded in the group ledger.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.secondaryText(context),
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

  @override
  Widget build(BuildContext context) {
    final group = widget.group;
    final theme = Theme.of(context);
    final fee = _withdrawalFee;
    final amount = _amount;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Disburse funds',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      bottomNavigationBar: group == null
          ? null
          : SafeArea(
              top: false,
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
                decoration: BoxDecoration(
                  color: theme.scaffoldBackgroundColor,
                  border: Border(
                    top: BorderSide(color: theme.colorScheme.outline),
                  ),
                ),
                child: FilledButton.icon(
                  onPressed: _isSubmitting || _isReviewing
                      ? null
                      : _reviewAndDisburse,
                  icon: _isSubmitting
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.verified_user_outlined),
                  label: const Text('Confirm Disbursement'),
                ),
              ),
            ),
      body: group == null
          ? const FinancialEmptyState(
              icon: Icons.warning_amber_rounded,
              title: 'No source group selected',
              message: 'Open a group ledger and choose Disburse Funds.',
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
              children: [
                FinancialSurface(
                  emphasized: true,
                  child: Row(
                    children: [
                      Icon(
                        Icons.account_balance_wallet_outlined,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              group.name,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Text(
                              group.accountNo.isEmpty
                                  ? 'Group wallet'
                                  : 'Account ${group.accountNo}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: AppColors.secondaryText(context),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'AVAILABLE',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: AppColors.secondaryText(context),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            _currency(group.balance),
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                const FinancialSectionHeader(
                  title: 'Recipient',
                  subtitle: 'Choose where the group funds will be sent',
                ),
                const SizedBox(height: 10),
                SegmentedButton<bool>(
                  segments: const [
                    ButtonSegment(
                      value: true,
                      icon: Icon(Icons.person_outline_rounded),
                      label: Text('Individual'),
                    ),
                    ButtonSegment(
                      value: false,
                      icon: Icon(Icons.storefront_outlined),
                      label: Text('Business'),
                    ),
                  ],
                  selected: {_isIndividual},
                  onSelectionChanged: (selection) =>
                      _setRecipientType(selection.single),
                ),
                if (!_isIndividual) ...[
                  const SizedBox(height: 10),
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: 'TILLNO', label: Text('Till')),
                      ButtonSegment(value: 'PAYBILL', label: Text('Paybill')),
                    ],
                    selected: {_businessType},
                    onSelectionChanged: (selection) => setState(() {
                      _businessType = selection.single;
                      _destinationController.clear();
                      _paybillController.clear();
                    }),
                  ),
                ],
                const SizedBox(height: 12),
                if (!_isIndividual && _businessType == 'PAYBILL') ...[
                  TextField(
                    controller: _paybillController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Paybill number',
                      prefixIcon: Icon(Icons.business_outlined),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
                TextField(
                  controller: _destinationController,
                  keyboardType: _isIndividual
                      ? TextInputType.phone
                      : TextInputType.text,
                  decoration: InputDecoration(
                    labelText: _isIndividual
                        ? 'Recipient phone number'
                        : _businessType == 'PAYBILL'
                        ? 'Account number'
                        : 'Till number',
                    prefixIcon: Icon(
                      _isIndividual
                          ? Icons.phone_outlined
                          : Icons.numbers_rounded,
                    ),
                    suffixIcon: _isIndividual
                        ? IconButton(
                            tooltip: 'Choose from contacts',
                            onPressed: _isSubmitting ? null : _pickContact,
                            icon: const Icon(Icons.contacts_outlined),
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 18),
                const FinancialSectionHeader(
                  title: 'Transfer amount',
                  subtitle: 'The current tariff is loaded before confirmation',
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  onChanged: (_) => _scheduleFeeLookup(),
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Amount',
                    prefixText: 'KSh  ',
                    prefixIcon: Icon(Icons.payments_outlined),
                    hintText: '0.00',
                  ),
                ),
                const SizedBox(height: 10),
                FinancialSurface(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  child: Column(
                    children: [
                      _summaryRow(
                        'Available balance',
                        _currency(group.balance),
                      ),
                      const SizedBox(height: 7),
                      _summaryRow(
                        'Transfer fee',
                        _isFeeLoading
                            ? 'Loading…'
                            : fee != null
                            ? 'Fee: KES ${fee.toStringAsFixed(2)}'
                            : _feeError != null
                            ? 'Unavailable'
                            : 'Fee: —',
                        isError: _feeError != null,
                      ),
                      if (amount != null && fee != null) ...[
                        const Divider(height: 17),
                        _summaryRow(
                          'Total debit',
                          '${_currency(amount + fee)} estimated',
                          emphasized: true,
                        ),
                      ],
                    ],
                  ),
                ),
                if (_feeError != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    _feeError!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                Text(
                  'Only authorised group administrators can disburse funds. Every completed transfer is recorded in the ledger.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.secondaryText(context),
                    height: 1.4,
                  ),
                ),
              ],
            ),
    );
  }

  Widget _summaryRow(
    String label,
    String value, {
    bool emphasized = false,
    bool isError = false,
  }) => Row(
    children: [
      Expanded(
        child: Text(
          label,
          style: TextStyle(color: AppColors.secondaryText(context)),
        ),
      ),
      Text(
        value,
        style: TextStyle(
          color: isError ? Theme.of(context).colorScheme.error : null,
          fontWeight: emphasized ? FontWeight.w800 : FontWeight.w600,
        ),
      ),
    ],
  );
}
