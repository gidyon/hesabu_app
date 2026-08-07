enum AccountActivityType {
  welcome,
  deposit,
  withdrawal,
  statementRequested,
  statementDownloaded,
  groupCreated,
  groupUpdated,
  groupJoined,
  memberInvited,
  notification,
}

enum AccountActivityStatus { info, pending, completed, failed }

enum AccountActivitySource { local, remote }

class AccountActivity {
  const AccountActivity({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.occurredAt,
    required this.status,
    required this.source,
    this.groupId,
    this.groupName,
    this.amount,
    this.reference,
    this.isRead = false,
    this.metadata = const {},
  });

  final String id;
  final AccountActivityType type;
  final String title;
  final String description;
  final DateTime occurredAt;
  final AccountActivityStatus status;
  final AccountActivitySource source;
  final String? groupId;
  final String? groupName;
  final double? amount;
  final String? reference;
  final bool isRead;
  final Map<String, String> metadata;

  AccountActivity copyWith({bool? isRead}) => AccountActivity(
    id: id,
    type: type,
    title: title,
    description: description,
    occurredAt: occurredAt,
    status: status,
    source: source,
    groupId: groupId,
    groupName: groupName,
    amount: amount,
    reference: reference,
    isRead: isRead ?? this.isRead,
    metadata: metadata,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.name,
    'title': title,
    'description': description,
    'occurred_at': occurredAt.toUtc().toIso8601String(),
    'status': status.name,
    'source': source.name,
    'group_id': groupId,
    'group_name': groupName,
    'amount': amount,
    'reference': reference,
    'is_read': isRead,
    'metadata': metadata,
  };

  factory AccountActivity.fromJson(Map<String, dynamic> json) {
    return AccountActivity(
      id: json['id']?.toString() ?? '',
      type: _enumByName(
        AccountActivityType.values,
        json['type'],
        AccountActivityType.notification,
      ),
      title: json['title']?.toString() ?? 'Account activity',
      description: json['description']?.toString() ?? '',
      occurredAt:
          DateTime.tryParse(json['occurred_at']?.toString() ?? '')?.toLocal() ??
          DateTime.now(),
      status: _enumByName(
        AccountActivityStatus.values,
        json['status'],
        AccountActivityStatus.info,
      ),
      source: _enumByName(
        AccountActivitySource.values,
        json['source'],
        AccountActivitySource.local,
      ),
      groupId: json['group_id']?.toString(),
      groupName: json['group_name']?.toString(),
      amount: json['amount'] is num
          ? (json['amount'] as num).toDouble()
          : double.tryParse(json['amount']?.toString() ?? ''),
      reference: json['reference']?.toString(),
      isRead: json['is_read'] == true,
      metadata:
          (json['metadata'] as Map?)?.map(
            (key, value) => MapEntry(key.toString(), value.toString()),
          ) ??
          const {},
    );
  }
}

T _enumByName<T extends Enum>(List<T> values, Object? name, T fallback) {
  final normalizedName = name?.toString();
  for (final value in values) {
    if (value.name == normalizedName) return value;
  }
  return fallback;
}
