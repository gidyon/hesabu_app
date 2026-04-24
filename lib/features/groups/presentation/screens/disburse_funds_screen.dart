import 'package:flutter/material.dart';
import 'package:hesabu_app/core/constants/app_colors.dart';
import 'package:hesabu_app/core/theme/theme_controller.dart';
import 'package:hesabu_app/core/theme/inherited_theme_controller.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:hesabu_app/features/groups/domain/groups_repository.dart';
import 'package:hesabu_app/core/utils/phone_utils.dart';

class DisburseFundsScreen extends StatefulWidget {
  final Group? group;

  const DisburseFundsScreen({super.key, this.group});

  @override
  State<DisburseFundsScreen> createState() => _DisburseFundsScreenState();
}

class _DisburseFundsScreenState extends State<DisburseFundsScreen> {
  final _amountController = TextEditingController();
  final _destController = TextEditingController();
  final _billerNumberController = TextEditingController();
  bool _isIndividual = true;
  String _businessType = 'TILLNO'; // 'TILLNO' or 'PAYBILL'
  bool _isLoading = false;

  @override
  void dispose() {
    _amountController.dispose();
    _destController.dispose();
    _billerNumberController.dispose();
    super.dispose();
  }

  void _disburse() async {
    final amount = double.tryParse(_amountController.text.replaceAll(',', ''));
    final dest = _destController.text.trim();
    if (amount == null || amount <= 0 || dest.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid amount and destination'),
        ),
      );
      return;
    }

    if (widget.group == null) return;

    // Validate phone number if individual
    if (_isIndividual && !PhoneUtils.isValidMsisdn(dest)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid phone number (e.g. 0712...)'),
        ),
      );
      return;
    }

    // Validate Paybill number if needed
    final billerNumber = _billerNumberController.text.trim();
    if (!_isIndividual && _businessType == 'PAYBILL' && billerNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a Paybill number')),
      );
      return;
    }

    setState(() => _isLoading = true);
    final response = await context.read<GroupsRepository>().withdraw(
      groupId: widget.group!.id,
      amount: amount,
      withdrawalType: _isIndividual ? 'INDIVIDUAL' : 'BUSINESS',
      destination: dest,
      billerType: _isIndividual ? null : _businessType,
      billerNumber: (!_isIndividual && _businessType == 'PAYBILL')
          ? billerNumber
          : null,
    );

    if (mounted) {
      setState(() => _isLoading = false);
      if (!response.hasError && response.data == true) {
        _showSuccessSheet(amount);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              response.errorMessage ?? 'Disbursement failed. Please try again.',
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  void _showSuccessSheet(double amount) {
    final accent = InheritedThemeController.of(context).accentColor.primary;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: accent.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle_rounded,
                  color: accent,
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Disbursement Successful!',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'KSh ${amount.toStringAsFixed(2)} has been disbursed.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.slate500,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // close sheet
                    context.pop(); // close screen
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Done',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
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
    final accent = InheritedThemeController.of(context).accentColor.primary;
    final isDark = InheritedThemeController.of(context).isDark;
    final cardBg = isDark ? Colors.white.withOpacity(0.03) : Colors.white;
    final cardBorder = isDark
        ? Colors.white.withOpacity(0.05)
        : AppColors.slate200;
    final titleColor = isDark ? Colors.white : Colors.black87;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Disburse Funds',
          style: TextStyle(
            color: accent,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: accent),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Source Group
            _sectionLabel('SOURCE GROUP'),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: cardBorder),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.group?.name ?? 'Unknown Group',
                          style: TextStyle(
                            color: accent.withOpacity(0.9),
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Available: KSh ${widget.group?.balance.toStringAsFixed(2) ?? '0.00'}',
                          style: TextStyle(
                            color: titleColor.withOpacity(0.6),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.keyboard_arrow_down,
                    color: titleColor.withOpacity(0.5),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Withdrawal Type
            _sectionLabel('WITHDRAWAL TYPE'),
            Container(
              height: 48,
              decoration: BoxDecoration(
                color: isDark ? Colors.black : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _isIndividual = true),
                      child: Container(
                        decoration: BoxDecoration(
                          color: _isIndividual ? accent : Colors.transparent,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'INDIVIDUAL',
                          style: TextStyle(
                            color: _isIndividual
                                ? Colors.white
                                : titleColor.withOpacity(0.5),
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _isIndividual = false),
                      child: Container(
                        decoration: BoxDecoration(
                          color: !_isIndividual ? accent : Colors.transparent,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'BUSINESS',
                          style: TextStyle(
                            color: !_isIndividual
                                ? Colors.white
                                : titleColor.withOpacity(0.5),
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            if (!_isIndividual) ...[
              _sectionLabel('BUSINESS TYPE'),
              Container(
                height: 44,
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: cardBorder),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _businessType = 'TILLNO'),
                        child: Container(
                          decoration: BoxDecoration(
                            color: _businessType == 'TILLNO'
                                ? accent.withOpacity(0.1)
                                : Colors.transparent,
                            borderRadius: const BorderRadius.horizontal(
                              left: Radius.circular(12),
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'TILL',
                            style: TextStyle(
                              color: _businessType == 'TILLNO'
                                  ? accent
                                  : titleColor.withOpacity(0.5),
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ),
                    VerticalDivider(color: cardBorder, width: 1),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _businessType = 'PAYBILL'),
                        child: Container(
                          decoration: BoxDecoration(
                            color: _businessType == 'PAYBILL'
                                ? accent.withOpacity(0.1)
                                : Colors.transparent,
                            borderRadius: const BorderRadius.horizontal(
                              right: Radius.circular(12),
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'PAYBILL',
                            style: TextStyle(
                              color: _businessType == 'PAYBILL'
                                  ? accent
                                  : titleColor.withOpacity(0.5),
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Destination
            if (!_isIndividual && _businessType == 'PAYBILL') ...[
              _sectionLabel('PAYBILL NUMBER'),
              Container(
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: cardBorder),
                ),
                child: TextField(
                  controller: _billerNumberController,
                  keyboardType: TextInputType.number,
                  style: TextStyle(color: titleColor),
                  decoration: InputDecoration(
                    hintText: 'Enter Paybill No (e.g. 247247)',
                    hintStyle: TextStyle(color: titleColor.withOpacity(0.3)),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _sectionLabel('ACCOUNT NUMBER'),
            ] else if (!_isIndividual && _businessType == 'TILLNO') ...[
              _sectionLabel('TILL NUMBER'),
            ] else ...[
              _sectionLabel('PHONE NUMBER'),
            ],

            Container(
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: cardBorder),
              ),
              child: TextField(
                controller: _destController,
                keyboardType: _isIndividual
                    ? TextInputType.phone
                    : TextInputType.text,
                style: TextStyle(color: titleColor),
                decoration: InputDecoration(
                  hintText: _isIndividual
                      ? 'Phone Number'
                      : (_businessType == 'TILLNO'
                            ? 'Till Number'
                            : 'Account Number'),
                  hintStyle: TextStyle(color: titleColor.withOpacity(0.3)),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  suffixIcon: _isIndividual
                      ? Icon(Icons.contacts, color: titleColor.withOpacity(0.5))
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Amount
            _sectionLabel('AMOUNT (KES)'),
            Container(
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: cardBorder),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 16),
                        child: Text(
                          'KES',
                          style: TextStyle(
                            color: accent,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Expanded(
                        child: TextField(
                          controller: _amountController,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: titleColor,
                            fontSize: 28,
                            fontWeight: FontWeight.w500,
                          ),
                          decoration: InputDecoration(
                            hintText: '0.00',
                            hintStyle: TextStyle(
                              color: titleColor.withOpacity(0.2),
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 24,
                            ),
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                      const SizedBox(width: 48), // balance padding
                    ],
                  ),
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withOpacity(0.05)
                          : Colors.black.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      'Fee: KES 15.00',
                      style: TextStyle(
                        color: titleColor.withOpacity(0.8),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // Confirm Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _disburse,
                style: ElevatedButton.styleFrom(
                  backgroundColor: accent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                icon: const Icon(Icons.send, size: 18),
                label: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Confirm Disbursement',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 24),

            // Footer Text
            Center(
              child: Text(
                'Funds will be disbursed instantly to the\nverified recipient.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: titleColor.withOpacity(0.5),
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String t) => Padding(
    padding: const EdgeInsets.only(left: 4, bottom: 8),
    child: Text(
      t,
      style: const TextStyle(
        color: AppColors.slate400,
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
      ),
    ),
  );
}
