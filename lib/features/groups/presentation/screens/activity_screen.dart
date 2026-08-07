import 'package:flutter/material.dart';
import 'package:hesabu_app/core/constants/app_colors.dart';
import 'package:hesabu_app/features/activity/application/activity_provider.dart';
import 'package:hesabu_app/features/activity/domain/account_activity.dart';
import 'package:hesabu_app/features/groups/presentation/widgets/financial_components.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ActivityScreen extends StatelessWidget {
  const ActivityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ActivityProvider>(
      builder: (context, activityProvider, _) {
        final events = activityProvider.events;
        return Scaffold(
          appBar: AppBar(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Activity',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
                Text(
                  activityProvider.unreadCount == 0
                      ? 'All account events are read'
                      : '${activityProvider.unreadCount} unread account event${activityProvider.unreadCount == 1 ? '' : 's'}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.secondaryText(context),
                  ),
                ),
              ],
            ),
            actions: [
              if (activityProvider.unreadCount > 0)
                TextButton(
                  onPressed: activityProvider.markAllRead,
                  child: const Text('Mark all read'),
                ),
              const SizedBox(width: 8),
            ],
          ),
          body: events.isEmpty
              ? const FinancialEmptyState(
                  icon: Icons.receipt_long_outlined,
                  title: 'No account activity',
                  message:
                      'Deposits, disbursements and statement downloads will appear here.',
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                  itemCount: events.length,
                  separatorBuilder: (_, index) {
                    final currentDay = _dayKey(events[index].occurredAt);
                    final nextDay = _dayKey(events[index + 1].occurredAt);
                    return SizedBox(height: currentDay == nextDay ? 8 : 18);
                  },
                  itemBuilder: (context, index) {
                    final event = events[index];
                    final showHeader =
                        index == 0 ||
                        _dayKey(events[index - 1].occurredAt) !=
                            _dayKey(event.occurredAt);
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (showHeader) ...[
                          Padding(
                            padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
                            child: Text(
                              _dayLabel(event.occurredAt).toUpperCase(),
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(
                                    color: AppColors.secondaryText(context),
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.7,
                                  ),
                            ),
                          ),
                        ],
                        _ActivityLedgerRow(
                          event: event,
                          onTap: () => activityProvider.markRead(event.id),
                        ),
                      ],
                    );
                  },
                ),
        );
      },
    );
  }

  static String _dayKey(DateTime value) =>
      DateFormat('yyyy-MM-dd').format(value.toLocal());

  static String _dayLabel(DateTime value) {
    final local = value.toLocal();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(local.year, local.month, local.day);
    if (day == today) return 'Today';
    if (day == today.subtract(const Duration(days: 1))) return 'Yesterday';
    return DateFormat('EEE, d MMM yyyy').format(local);
  }
}

class _ActivityLedgerRow extends StatelessWidget {
  const _ActivityLedgerRow({required this.event, required this.onTap});

  final AccountActivity event;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final visual = _visualFor(context, event.type);
    final theme = Theme.of(context);

    return FinancialSurface(
      onTap: onTap,
      emphasized: !event.isRead,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: visual.color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(visual.icon, color: visual.color, size: 18),
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
                        event.title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: event.isRead
                              ? FontWeight.w600
                              : FontWeight.w800,
                        ),
                      ),
                    ),
                    Text(
                      DateFormat('h:mm a').format(event.occurredAt.toLocal()),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: AppColors.tertiaryText(context),
                      ),
                    ),
                    if (!event.isRead) ...[
                      const SizedBox(width: 6),
                      Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  event.description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.secondaryText(context),
                    height: 1.35,
                  ),
                ),
                if (event.amount != null ||
                    event.groupName != null ||
                    event.reference != null) ...[
                  const SizedBox(height: 7),
                  Wrap(
                    spacing: 10,
                    runSpacing: 4,
                    children: [
                      if (event.amount != null)
                        _detail(
                          context,
                          NumberFormat.currency(
                            symbol: 'KSh ',
                            decimalDigits: 2,
                          ).format(event.amount),
                        ),
                      if (event.groupName != null)
                        _detail(context, event.groupName!),
                      if (event.reference != null)
                        _detail(context, 'Ref ${event.reference}'),
                      _detail(context, _statusLabel(event.status)),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _detail(BuildContext context, String value) => Text(
    value,
    style: Theme.of(context).textTheme.labelSmall?.copyWith(
      color: AppColors.tertiaryText(context),
      fontWeight: FontWeight.w600,
    ),
  );

  static String _statusLabel(AccountActivityStatus status) => switch (status) {
    AccountActivityStatus.info => 'Info',
    AccountActivityStatus.pending => 'Pending',
    AccountActivityStatus.completed => 'Completed',
    AccountActivityStatus.failed => 'Failed',
  };

  static _ActivityVisual _visualFor(
    BuildContext context,
    AccountActivityType type,
  ) => switch (type) {
    AccountActivityType.deposit => const _ActivityVisual(
      Icons.south_west_rounded,
      Color(0xFF159455),
    ),
    AccountActivityType.withdrawal => _ActivityVisual(
      Icons.north_east_rounded,
      Theme.of(context).colorScheme.error,
    ),
    AccountActivityType.statementRequested ||
    AccountActivityType.statementDownloaded => const _ActivityVisual(
      Icons.description_outlined,
      Color(0xFF3B82F6),
    ),
    AccountActivityType.groupCreated ||
    AccountActivityType.groupUpdated ||
    AccountActivityType.groupJoined => _ActivityVisual(
      Icons.groups_2_outlined,
      Theme.of(context).colorScheme.primary,
    ),
    AccountActivityType.memberInvited => const _ActivityVisual(
      Icons.person_add_alt_1_outlined,
      Color(0xFF8B5CF6),
    ),
    AccountActivityType.welcome => _ActivityVisual(
      Icons.shield_outlined,
      Theme.of(context).colorScheme.primary,
    ),
    AccountActivityType.notification => const _ActivityVisual(
      Icons.notifications_none_rounded,
      Color(0xFFF59E0B),
    ),
  };
}

class _ActivityVisual {
  const _ActivityVisual(this.icon, this.color);

  final IconData icon;
  final Color color;
}
