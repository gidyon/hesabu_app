import 'package:flutter/material.dart';
import 'package:hesabu_app/core/constants/app_colors.dart';
import 'package:hesabu_app/features/groups/domain/groups_repository.dart';
import 'package:intl/intl.dart';

class FinancialSurface extends StatelessWidget {
  const FinancialSurface({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
    this.emphasized = false,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final surface = emphasized
        ? Color.alphaBlend(
            theme.colorScheme.primary.withValues(alpha: isDark ? 0.10 : 0.06),
            theme.colorScheme.surface,
          )
        : theme.colorScheme.surface;

    return Material(
      color: surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: theme.colorScheme.outline),
          ),
          child: child,
        ),
      ),
    );
  }
}

class FinancialSectionHeader extends StatelessWidget {
  const FinancialSectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.action,
  });

  final String title;
  final String? subtitle;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.secondaryText(context),
                  ),
                ),
              ],
            ],
          ),
        ),
        if (action != null) action!,
      ],
    );
  }
}

class FinancialStatusBadge extends StatelessWidget {
  const FinancialStatusBadge({super.key, required this.label, this.color});

  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? Theme.of(context).colorScheme.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: effectiveColor.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          color: effectiveColor,
          fontSize: 9,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.45,
        ),
      ),
    );
  }
}

class FinancialBalancePanel extends StatelessWidget {
  const FinancialBalancePanel({
    super.key,
    required this.label,
    required this.amount,
    this.accountNumber,
    this.status,
    this.footer,
    this.onCopyAccount,
    this.balanceVisible = true,
  });

  final String label;
  final double amount;
  final String? accountNumber;
  final String? status;
  final String? footer;
  final VoidCallback? onCopyAccount;
  final bool balanceVisible;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = theme.colorScheme.primary;
    final format = NumberFormat.currency(symbol: 'KSh ', decimalDigits: 2);

    return FinancialSurface(
      emphasized: true,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label.toUpperCase(),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppColors.secondaryText(context),
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              if (status != null) FinancialStatusBadge(label: status!),
            ],
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              balanceVisible ? format.format(amount) : 'KSh ••••••••',
              style: theme.textTheme.displayLarge?.copyWith(
                fontSize: 30,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.8,
              ),
            ),
          ),
          if (accountNumber != null && accountNumber!.isNotEmpty) ...[
            const SizedBox(height: 14),
            Divider(color: theme.colorScheme.outline, height: 1),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.account_balance_outlined,
                    color: accent,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'GROUP ACCOUNT NUMBER',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: AppColors.secondaryText(context),
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 1),
                      SelectableText(
                        accountNumber!,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                ),
                if (onCopyAccount != null)
                  IconButton(
                    tooltip: 'Copy account number',
                    visualDensity: VisualDensity.compact,
                    onPressed: onCopyAccount,
                    icon: const Icon(Icons.copy_rounded, size: 18),
                  ),
              ],
            ),
          ],
          if (footer != null) ...[
            const SizedBox(height: 10),
            Text(
              footer!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.secondaryText(context),
                height: 1.35,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class GroupLedgerCard extends StatelessWidget {
  const GroupLedgerCard({
    super.key,
    required this.group,
    required this.onOpen,
    this.onDeposit,
  });

  final Group group;
  final VoidCallback onOpen;
  final VoidCallback? onDeposit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = theme.colorScheme.primary;
    final format = NumberFormat.currency(symbol: 'KSh ', decimalDigits: 2);
    final account = group.accountNo.isEmpty
        ? 'Account pending'
        : 'Account ${group.accountNo}';

    return FinancialSurface(
      onTap: onOpen,
      padding: const EdgeInsets.fromLTRB(14, 14, 10, 10),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.groups_2_outlined, color: accent, size: 21),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      group.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$account • ${_roleLabel(group.role)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.secondaryText(context),
                      ),
                    ),
                  ],
                ),
              ),
              FinancialStatusBadge(
                label: group.status.isEmpty ? 'Active' : group.status,
              ),
            ],
          ),
          const SizedBox(height: 13),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'LEDGER BALANCE',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: AppColors.secondaryText(context),
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      format.format(group.balance),
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              if (onDeposit != null)
                TextButton.icon(
                  onPressed: onDeposit,
                  icon: const Icon(Icons.add_rounded, size: 17),
                  label: const Text('Deposit'),
                ),
              IconButton(
                tooltip: 'Open group ledger',
                visualDensity: VisualDensity.compact,
                onPressed: onOpen,
                icon: const Icon(Icons.chevron_right_rounded),
              ),
            ],
          ),
          if (group.goal > 0) ...[
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: group.progressPercentage.clamp(0, 1),
                minHeight: 5,
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
              ),
            ),
          ],
        ],
      ),
    );
  }

  static String _roleLabel(String value) {
    if (value.trim().isEmpty) return 'Member';
    final normalized = value.trim().toLowerCase();
    return '${normalized[0].toUpperCase()}${normalized.substring(1)}';
  }
}

class FinancialMetricCard extends StatelessWidget {
  const FinancialMetricCard({
    super.key,
    required this.label,
    required this.amount,
    required this.icon,
    required this.color,
  });

  final String label;
  final double amount;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return FinancialSurface(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, color: color, size: 17),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label.toUpperCase(),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.secondaryText(context),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    NumberFormat.currency(
                      symbol: 'KSh ',
                      decimalDigits: 2,
                    ).format(amount),
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class LedgerTransactionTile extends StatelessWidget {
  const LedgerTransactionTile({
    super.key,
    required this.transaction,
    this.onTap,
  });

  final Transaction transaction;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isInflow = transaction.type.toLowerCase() == 'inflow';
    final color = isInflow ? const Color(0xFF159455) : theme.colorScheme.error;
    final parts = transaction.title.split(' - ');
    final operation = parts.first.trim();
    final source = parts.length > 1
        ? parts.sublist(1).join(' - ').trim()
        : transaction.title;
    final reference = transaction.id.trim().isEmpty
        ? 'Reference pending'
        : 'Ref ${transaction.id}';

    return FinancialSurface(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isInflow ? Icons.south_west_rounded : Icons.north_east_rounded,
              color: color,
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _titleCase(operation),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${isInflow ? '+' : '-'}${NumberFormat.currency(symbol: 'KSh ', decimalDigits: 2).format(transaction.amount)}',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: color,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  source.isEmpty ? 'Group wallet' : source,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.secondaryText(context),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        transaction.date,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: AppColors.tertiaryText(context),
                        ),
                      ),
                    ),
                    Text(
                      reference,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: AppColors.tertiaryText(context),
                      ),
                    ),
                    const SizedBox(width: 6),
                    const FinancialStatusBadge(
                      label: 'Posted',
                      color: Color(0xFF159455),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _titleCase(String value) {
    final normalized = value.trim().toLowerCase();
    if (normalized.isEmpty) return 'Transaction';
    if (normalized == 'withdrawal') return 'Disbursement';
    return '${normalized[0].toUpperCase()}${normalized.substring(1)}';
  }
}

class MemberLedgerTile extends StatelessWidget {
  const MemberLedgerTile({super.key, required this.member});

  final Member member;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = theme.colorScheme.primary;
    final displayName = member.name.trim().isEmpty
        ? member.msisdn
        : member.name;
    final initial = displayName.isEmpty ? '?' : displayName[0].toUpperCase();

    return FinancialSurface(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: accent.withValues(alpha: 0.12),
            child: Text(
              initial,
              style: TextStyle(color: accent, fontWeight: FontWeight.w800),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  member.msisdn,
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
              FinancialStatusBadge(
                label: member.role.isEmpty ? 'Member' : member.role,
              ),
              const SizedBox(height: 4),
              Text(
                member.status.isEmpty ? 'Active' : member.status,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: AppColors.secondaryText(context),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class FinancialEmptyState extends StatelessWidget {
  const FinancialEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.action,
  });

  final IconData icon;
  final String title;
  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: accent),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 5),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.secondaryText(context),
              height: 1.4,
            ),
          ),
          if (action != null) ...[const SizedBox(height: 16), action!],
        ],
      ),
    );
  }
}
