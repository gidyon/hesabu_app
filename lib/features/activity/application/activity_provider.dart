import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:hesabu_app/features/activity/domain/account_activity.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ActivityProvider extends ChangeNotifier {
  ActivityProvider(this._preferences) {
    _load();
  }

  static const String storageKey = 'account_activity_v1';
  static const int maximumStoredEvents = 200;

  final SharedPreferences _preferences;
  final List<AccountActivity> _events = [];

  List<AccountActivity> get events => List.unmodifiable(_events);
  int get unreadCount => _events.where((event) => !event.isRead).length;

  void _load() {
    final encoded = _preferences.getString(storageKey);
    if (encoded != null) {
      try {
        final decoded = jsonDecode(encoded);
        if (decoded is List) {
          _events.addAll(
            decoded
                .whereType<Map>()
                .map(
                  (item) => AccountActivity.fromJson(
                    item.map((key, value) => MapEntry(key.toString(), value)),
                  ),
                )
                .where((event) => event.id.isNotEmpty),
          );
        }
      } on FormatException {
        _events.clear();
      }
    }

    _events.sort((a, b) => b.occurredAt.compareTo(a.occurredAt));
    if (_events.isEmpty) {
      _events.add(
        AccountActivity(
          id: 'welcome-${DateTime.now().microsecondsSinceEpoch}',
          type: AccountActivityType.welcome,
          title: 'Welcome to Hesabu Online',
          description:
              'Your group savings, collections and disbursements will appear here.',
          occurredAt: DateTime.now(),
          status: AccountActivityStatus.info,
          source: AccountActivitySource.local,
        ),
      );
      unawaited(_persist());
    }
  }

  Future<void> record({
    required AccountActivityType type,
    required String title,
    required String description,
    AccountActivityStatus status = AccountActivityStatus.completed,
    String? groupId,
    String? groupName,
    double? amount,
    String? reference,
    Map<String, String> metadata = const {},
  }) async {
    final occurredAt = DateTime.now();
    _events.insert(
      0,
      AccountActivity(
        id: '${occurredAt.microsecondsSinceEpoch}-${type.name}',
        type: type,
        title: title,
        description: description,
        occurredAt: occurredAt,
        status: status,
        source: AccountActivitySource.local,
        groupId: groupId,
        groupName: groupName,
        amount: amount,
        reference: reference,
        metadata: metadata,
      ),
    );
    _trim();
    notifyListeners();
    await _persist();
  }

  /// Adapter boundary for future Firebase Messaging integration. Firebase
  /// payloads can be passed here without changing the Activity UI or storage.
  Future<void> ingestRemoteNotification(Map<String, dynamic> payload) async {
    final occurredAt =
        DateTime.tryParse(
          payload['occurred_at']?.toString() ?? '',
        )?.toLocal() ??
        DateTime.now();
    final type = AccountActivityType.values.firstWhere(
      (value) => value.name == payload['type']?.toString(),
      orElse: () => AccountActivityType.notification,
    );
    final status = AccountActivityStatus.values.firstWhere(
      (value) => value.name == payload['status']?.toString(),
      orElse: () => AccountActivityStatus.info,
    );

    _events.removeWhere((event) => event.id == payload['id']?.toString());
    _events.add(
      AccountActivity(
        id:
            payload['id']?.toString() ??
            '${occurredAt.microsecondsSinceEpoch}-remote',
        type: type,
        title: payload['title']?.toString() ?? 'Hesabu Online update',
        description: payload['description']?.toString() ?? '',
        occurredAt: occurredAt,
        status: status,
        source: AccountActivitySource.remote,
        groupId: payload['group_id']?.toString(),
        groupName: payload['group_name']?.toString(),
        amount: payload['amount'] is num
            ? (payload['amount'] as num).toDouble()
            : double.tryParse(payload['amount']?.toString() ?? ''),
        reference: payload['reference']?.toString(),
        metadata: payload.map(
          (key, value) => MapEntry(key, value?.toString() ?? ''),
        ),
      ),
    );
    _events.sort((a, b) => b.occurredAt.compareTo(a.occurredAt));
    _trim();
    notifyListeners();
    await _persist();
  }

  Future<void> markAllRead() async {
    for (var index = 0; index < _events.length; index++) {
      _events[index] = _events[index].copyWith(isRead: true);
    }
    notifyListeners();
    await _persist();
  }

  Future<void> markRead(String id) async {
    final index = _events.indexWhere((event) => event.id == id);
    if (index == -1 || _events[index].isRead) return;
    _events[index] = _events[index].copyWith(isRead: true);
    notifyListeners();
    await _persist();
  }

  void _trim() {
    if (_events.length > maximumStoredEvents) {
      _events.removeRange(maximumStoredEvents, _events.length);
    }
  }

  Future<void> _persist() {
    return _preferences.setString(
      storageKey,
      jsonEncode(_events.map((event) => event.toJson()).toList()),
    );
  }
}
