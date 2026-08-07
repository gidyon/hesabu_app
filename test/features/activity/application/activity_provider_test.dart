import 'package:flutter_test/flutter_test.dart';
import 'package:hesabu_app/features/activity/application/activity_provider.dart';
import 'package:hesabu_app/features/activity/domain/account_activity.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('records and persists local financial activity', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final provider = ActivityProvider(preferences);

    await provider.record(
      type: AccountActivityType.deposit,
      title: 'Deposit initiated',
      description: 'M-Pesa contribution initiated.',
      groupId: '10',
      groupName: 'Utawala Unfit',
      amount: 500,
    );

    expect(provider.events.first.type, AccountActivityType.deposit);
    expect(provider.events.first.amount, 500);
    expect(provider.unreadCount, greaterThan(0));

    final restored = ActivityProvider(preferences);
    expect(restored.events.first.type, AccountActivityType.deposit);
    expect(restored.events.first.groupName, 'Utawala Unfit');
  });

  test('ingests remote notification payloads into the same model', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final provider = ActivityProvider(preferences);

    await provider.ingestRemoteNotification({
      'id': 'firebase-message-1',
      'type': 'withdrawal',
      'title': 'Disbursement posted',
      'description': 'Group funds were sent.',
      'status': 'completed',
      'group_id': '10',
      'group_name': 'Utawala Unfit',
      'amount': 200,
      'reference': 'TX-22',
      'occurred_at': '2026-08-07T12:00:00Z',
    });

    final event = provider.events.singleWhere(
      (activity) => activity.id == 'firebase-message-1',
    );
    expect(event.source, AccountActivitySource.remote);
    expect(event.type, AccountActivityType.withdrawal);
    expect(event.reference, 'TX-22');
  });

  test('marks local and remote activity as read', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final provider = ActivityProvider(preferences);

    await provider.markAllRead();

    expect(provider.unreadCount, 0);
    expect(provider.events.every((event) => event.isRead), isTrue);
  });
}
