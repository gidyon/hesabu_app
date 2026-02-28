import 'package:flutter/material.dart';
import 'package:hesabu_app/core/constants/app_colors.dart';
import 'package:hesabu_app/core/theme/theme_controller.dart';
import 'package:hesabu_app/core/theme/inherited_theme_controller.dart';
import 'package:go_router/go_router.dart';

class DepositToGroupScreen extends StatefulWidget {
  const DepositToGroupScreen({super.key});

  @override
  State<DepositToGroupScreen> createState() => _DepositToGroupScreenState();
}

class _DepositToGroupScreenState extends State<DepositToGroupScreen> {
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  int _selectedGroupIndex = 0;
  String _selectedMethod = 'mpesa';
  bool _isLoading = false;

  final _groups = [
    {
      'name': 'Hesabu Savings Circle',
      'account': 'HSB-2024-001',
      'balance': 'KSh 128,450',
    },
    {
      'name': 'Investment Club Alpha',
      'account': 'HSB-2024-002',
      'balance': 'KSh 320,000',
    },
    {
      'name': 'Car Club Savings',
      'account': 'HSB-2024-003',
      'balance': 'KSh 56,200',
    },
  ];

  final _methods = [
    {
      'id': 'mpesa',
      'label': 'M-Pesa',
      'icon': Icons.phone_android_outlined,
      'color': Color(0xFF00b300),
    },
    {
      'id': 'bank',
      'label': 'Bank',
      'icon': Icons.account_balance_outlined,
      'color': Colors.blue,
    },
    {
      'id': 'card',
      'label': 'Card',
      'icon': Icons.credit_card_outlined,
      'color': Colors.purple,
    },
  ];

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _deposit() async {
    final amount = double.tryParse(_amountController.text.replaceAll(',', ''));
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount')),
      );
      return;
    }
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      setState(() => _isLoading = false);
      _showSuccessSheet(amount);
    }
  }

  void _showSuccessSheet(double amount) {
    final accent = InheritedThemeController.of(context).accentColor.primary;
    final group = _groups[_selectedGroupIndex];
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
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
              child: Icon(Icons.check_circle_rounded, color: accent, size: 32),
            ),
            const SizedBox(height: 16),
            const Text(
              'Deposit Successful!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'KSh ${amount.toStringAsFixed(2)} has been deposited\nto ${group['name']}',
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
                  Navigator.pop(context);
                  context.pop();
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final accent = InheritedThemeController.of(context).accentColor.primary;
    final isDark = InheritedThemeController.of(context).isDark;
    final cardBg = isDark ? Colors.white.withOpacity(0.05) : Colors.white;
    final cardBorder = isDark
        ? Colors.white.withOpacity(0.1)
        : AppColors.slate200;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Top glow
          Positioned(
            top: -40,
            left: -40,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: accent.withOpacity(0.07),
                shape: BoxShape.circle,
              ),
            ),
          ),

          // Nav bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 10,
                bottom: 12,
                left: 16,
                right: 16,
              ),
              color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.9),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withOpacity(0.07)
                            : AppColors.slate100,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.arrow_back_ios_new,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                        size: 18,
                      ),
                    ),
                  ),
                  Text(
                    'Deposit to Group',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  const SizedBox(width: 40),
                ],
              ),
            ),
          ),

          // Content
          Padding(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 60,
            ),
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Select Group ──────────────────────────────────
                  _sectionLabel('SELECT GROUP'),
                  Column(
                    children: _groups.asMap().entries.map((e) {
                      final i = e.key;
                      final g = e.value;
                      final selected = i == _selectedGroupIndex;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedGroupIndex = i),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: selected ? accent.withOpacity(0.08) : cardBg,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: selected
                                  ? accent.withOpacity(0.5)
                                  : cardBorder,
                              width: selected ? 1.5 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  color:
                                      (selected ? accent : AppColors.slate400)
                                          .withOpacity(0.15),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.group,
                                  color: selected ? accent : AppColors.slate400,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      g['name']!,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                        color: Theme.of(
                                          context,
                                        ).textTheme.bodyLarge?.color,
                                      ),
                                    ),
                                    Text(
                                      '${g['account']} • ${g['balance']}',
                                      style: const TextStyle(
                                        color: AppColors.slate500,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 200),
                                child: selected
                                    ? Icon(
                                        Icons.check_circle_rounded,
                                        color: accent,
                                        key: const ValueKey('on'),
                                      )
                                    : Container(
                                        key: const ValueKey('off'),
                                        width: 22,
                                        height: 22,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: AppColors.slate400
                                                .withOpacity(0.4),
                                          ),
                                        ),
                                      ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 24),

                  // ── Amount ──────────────────────────────────
                  _sectionLabel('AMOUNT'),
                  Container(
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: _amountController.text.isNotEmpty
                            ? accent.withOpacity(0.5)
                            : cardBorder,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 18,
                          ),
                          decoration: BoxDecoration(
                            border: Border(
                              right: BorderSide(color: cardBorder),
                            ),
                          ),
                          child: Text(
                            'KSh',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: accent,
                            ),
                          ),
                        ),
                        Expanded(
                          child: TextField(
                            controller: _amountController,
                            keyboardType: TextInputType.number,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(
                                context,
                              ).textTheme.bodyLarge?.color,
                            ),
                            decoration: const InputDecoration(
                              hintText: '0.00',
                              hintStyle: TextStyle(
                                color: AppColors.slate400,
                                fontSize: 22,
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                            ),
                            onChanged: (_) => setState(() {}),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Quick amounts
                  Row(
                    children: [500, 1000, 2000, 5000].map((v) {
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() {
                            _amountController.text = v.toString();
                          }),
                          child: Container(
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: _amountController.text == v.toString()
                                  ? accent.withOpacity(0.1)
                                  : cardBg,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: _amountController.text == v.toString()
                                    ? accent.withOpacity(0.4)
                                    : cardBorder,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                '$v',
                                style: TextStyle(
                                  color: _amountController.text == v.toString()
                                      ? accent
                                      : Theme.of(
                                          context,
                                        ).textTheme.bodyLarge?.color,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 24),

                  // ── Payment Method ──────────────────────────────────
                  _sectionLabel('PAYMENT METHOD'),
                  Row(
                    children: _methods.map((m) {
                      final selected = m['id'] == _selectedMethod;
                      final color = m['color'] as Color;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => setState(
                            () => _selectedMethod = m['id'] as String,
                          ),
                          child: Container(
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              color: selected ? color.withOpacity(0.1) : cardBg,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: selected
                                    ? color.withOpacity(0.5)
                                    : cardBorder,
                                width: selected ? 1.5 : 1,
                              ),
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  m['icon'] as IconData,
                                  color: selected ? color : AppColors.slate400,
                                  size: 24,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  m['label'] as String,
                                  style: TextStyle(
                                    color: selected
                                        ? color
                                        : AppColors.slate400,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 24),

                  // ── Note ──────────────────────────────────
                  _sectionLabel('NOTE (OPTIONAL)'),
                  Container(
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: cardBorder),
                    ),
                    child: TextField(
                      controller: _noteController,
                      maxLines: 2,
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                      decoration: const InputDecoration(
                        hintText: 'e.g. February contribution',
                        hintStyle: TextStyle(color: AppColors.slate400),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(16),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Summary row
                  if (_amountController.text.isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: accent.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: accent.withOpacity(0.25)),
                      ),
                      child: Column(
                        children: [
                          _summaryRow(
                            context,
                            'To',
                            _groups[_selectedGroupIndex]['name']!,
                          ),
                          const SizedBox(height: 8),
                          _summaryRow(
                            context,
                            'Via',
                            _methods.firstWhere(
                                  (m) => m['id'] == _selectedMethod,
                                )['label']
                                as String,
                          ),
                          const SizedBox(height: 8),
                          _summaryRow(
                            context,
                            'Amount',
                            'KSh ${_amountController.text}',
                            valueColor: accent,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _deposit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.savings_outlined),
                                SizedBox(width: 8),
                                Text(
                                  'Confirm Deposit',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(
    BuildContext context,
    String label,
    String value, {
    Color? valueColor,
  }) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        label,
        style: const TextStyle(color: AppColors.slate500, fontSize: 13),
      ),
      Text(
        value,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 13,
          color: valueColor ?? Theme.of(context).textTheme.bodyLarge?.color,
        ),
      ),
    ],
  );

  Widget _sectionLabel(String t) => Padding(
    padding: const EdgeInsets.only(left: 4, bottom: 10),
    child: Text(
      t,
      style: const TextStyle(
        color: AppColors.slate500,
        fontSize: 12,
        fontWeight: FontWeight.bold,
        letterSpacing: 1,
      ),
    ),
  );
}
