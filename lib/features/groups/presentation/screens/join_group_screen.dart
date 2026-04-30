import 'package:flutter/material.dart';
import 'package:hesabu_app/core/constants/app_colors.dart';
import 'package:hesabu_app/core/theme/theme_controller.dart';
import 'package:hesabu_app/core/theme/inherited_theme_controller.dart';
import 'package:provider/provider.dart';
import 'package:hesabu_app/features/groups/domain/groups_repository.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class JoinGroupScreen extends StatefulWidget {
  const JoinGroupScreen({super.key});

  @override
  State<JoinGroupScreen> createState() => _JoinGroupScreenState();
}

class _JoinGroupScreenState extends State<JoinGroupScreen> {
  final _codeController = TextEditingController();
  bool _isLoading = false;
  bool _isSearching = false;

  GroupPreview? _foundGroup;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  void _searchGroup() async {
    final groupId = _codeController.text.trim();
    if (groupId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a Group ID or Account Number'),
        ),
      );
      return;
    }
    setState(() {
      _isSearching = true;
      _foundGroup = null;
    });

    final response = await context.read<GroupsRepository>().previewGroup(
      groupId,
    );

    if (mounted) {
      setState(() {
        _isSearching = false;
        if (!response.hasError && response.data != null) {
          _foundGroup = response.data;
        } else {
          // Fallback if preview fails
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                response.errorMessage ??
                    'Failed to get preview continue anyways',
              ),
              backgroundColor: Colors.orange,
            ),
          );
          // Create a minimal preview object so they can still try to join
          _foundGroup = GroupPreview(
            id: groupId,
            name: 'Group: $groupId',
            balance: 0.0,
            membersCount: 0,
            adminName: 'Unknown',
            description: 'No description available',
          );
        }
      });
    }
  }

  void _joinGroup() async {
    if (_foundGroup == null) return;
    setState(() => _isLoading = true);
    final response = await context.read<GroupsRepository>().joinGroup(
      _foundGroup!.id,
    );
    if (mounted) {
      setState(() => _isLoading = false);
      if (!response.hasError && response.data == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Successfully joined the group!')),
        );
        context.pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              response.errorMessage ??
                  'Failed to join group. Please check the ID.',
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final accent = InheritedThemeController.of(context).accentColor.primary;
    final isDark = InheritedThemeController.of(context).isDark;
    final cardBg = isDark ? Theme.of(context).cardColor : Colors.white;
    final cardBorder = isDark
        ? Theme.of(context).dividerColor
        : AppColors.slate200;
    final secondaryTextColor = AppColors.secondaryText(context);
    final tertiaryTextColor = AppColors.tertiaryText(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Decorative top glow
          Positioned(
            top: -60,
            right: -60,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.08),
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
              color: Theme.of(
                context,
              ).scaffoldBackgroundColor.withValues(alpha: 0.9),
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
                            ? Colors.white.withValues(alpha: 0.07)
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
                    'Join a Group',
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
                  // Hero
                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            color: accent.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.group_add_outlined,
                            color: accent,
                            size: 36,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Find Your Group',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Enter the Group ID or Account Number\nshared by your group administrator.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: secondaryTextColor,
                            fontSize: 13,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 36),

                  // Search input
                  const Padding(
                    padding: EdgeInsets.only(left: 4, bottom: 8),
                    child: Text(
                      'Group ID or Account Number',
                      style: TextStyle(
                        color: AppColors.slate200,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Container(
                    height: 56,
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: _codeController.text.isNotEmpty
                            ? accent.withValues(alpha: 0.5)
                            : cardBorder,
                      ),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 16),
                        Icon(Icons.key_outlined, color: accent),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _codeController,
                            style: TextStyle(
                              color: Theme.of(
                                context,
                              ).textTheme.bodyLarge?.color,
                            ),
                            textCapitalization: TextCapitalization.characters,
                            decoration: InputDecoration(
                              hintText: 'e.g. HSB-2024-001',
                              hintStyle: TextStyle(color: tertiaryTextColor),
                              border: InputBorder.none,
                            ),
                            onChanged: (_) => setState(() {}),
                          ),
                        ),
                        if (_codeController.text.isNotEmpty)
                          IconButton(
                            icon: Icon(
                              Icons.clear,
                              color: AppColors.mutedIcon(context),
                              size: 18,
                            ),
                            onPressed: () =>
                                setState(() => _codeController.clear()),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _isSearching ? null : _searchGroup,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      child: _isSearching
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.search),
                                SizedBox(width: 8),
                                Text(
                                  'Search Group',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Result card
                  if (_foundGroup != null) ...[
                    _resultCard(
                      context,
                      _foundGroup!,
                      accent,
                      cardBg,
                      cardBorder,
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _joinGroup,
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
                                  Icon(Icons.how_to_reg_outlined),
                                  SizedBox(width: 8),
                                  Text(
                                    'Join This Group',
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

                  const SizedBox(height: 32),

                  // How it works
                  _sectionLabel('HOW IT WORKS'),
                  _howItWorksCard(context, accent, cardBg, cardBorder),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _resultCard(
    BuildContext context,
    GroupPreview group,
    Color accent,
    Color bg,
    Color border,
  ) {
    final currencyFormat = NumberFormat.currency(
      symbol: 'KSh ',
      decimalDigits: 2,
    );
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accent.withValues(alpha: 0.4), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.group, color: accent, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      group.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                    Text(
                      'Admin: ${group.adminName}',
                      style: TextStyle(
                        color: AppColors.secondaryText(context),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.check_circle, color: accent, size: 18),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Divider(color: accent.withValues(alpha: 0.15)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _stat(context, 'Members', '${group.membersCount}', accent),
              _stat(context, 'Status', 'Active', accent),
              _stat(
                context,
                'Balance',
                currencyFormat.format(group.balance),
                accent,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _stat(
    BuildContext context,
    String label,
    String value,
    Color accent,
  ) => Column(
    children: [
      Text(
        value,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
          color: Theme.of(context).textTheme.bodyLarge?.color,
        ),
      ),
      const SizedBox(height: 2),
      Text(
        label,
        style: TextStyle(color: AppColors.secondaryText(context), fontSize: 11),
      ),
    ],
  );

  Widget _howItWorksCard(
    BuildContext context,
    Color accent,
    Color bg,
    Color border,
  ) {
    final steps = [
      (Icons.search_outlined, 'Search', 'Enter the Group ID or Account Number'),
      (
        Icons.visibility_outlined,
        'Preview',
        'Review group details before joining',
      ),
      (
        Icons.how_to_reg_outlined,
        'Join',
        'Tap "Join This Group" to send your request',
      ),
    ];
    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: steps.asMap().entries.map((e) {
          final i = e.key;
          final s = e.value;
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: i < steps.length - 1
                ? BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Theme.of(
                          context,
                        ).dividerColor.withValues(alpha: 0.08),
                      ),
                    ),
                  )
                : null,
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${i + 1}',
                      style: TextStyle(
                        color: accent,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        s.$2,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                      Text(
                        s.$3,
                        style: TextStyle(
                          color: AppColors.secondaryText(context),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(s.$1, color: accent, size: 20),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _sectionLabel(String t) => Padding(
    padding: const EdgeInsets.only(left: 4, bottom: 8),
    child: Text(
      t,
      style: TextStyle(
        color: AppColors.secondaryText(context),
        fontSize: 12,
        fontWeight: FontWeight.bold,
        letterSpacing: 1,
      ),
    ),
  );
}
