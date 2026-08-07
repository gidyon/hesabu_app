import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hesabu_app/core/api/api_response.dart';
import 'package:hesabu_app/features/activity/application/activity_provider.dart';
import 'package:hesabu_app/core/theme/inherited_theme_controller.dart';
import 'package:hesabu_app/core/theme/theme_controller.dart';
import 'package:hesabu_app/features/groups/domain/groups_repository.dart';
import 'package:hesabu_app/features/groups/presentation/screens/disburse_funds_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('withdraw button confirms and submits exactly once', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'theme_mode': ThemeMode.light.index,
    });
    final prefs = await SharedPreferences.getInstance();
    final themeController = ThemeController(prefs);
    final repository = _FakeGroupsRepository();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<GroupsRepository>.value(value: repository),
          ChangeNotifierProvider<ActivityProvider>(
            create: (_) => ActivityProvider(prefs),
          ),
        ],
        child: InheritedThemeController(
          notifier: themeController,
          child: MaterialApp(home: DisburseFundsScreen(group: _group())),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).at(0), '0712345678');
    await tester.enterText(find.byType(TextField).at(1), '50');
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();
    expect(find.text('Fee: KES 7.00'), findsOneWidget);

    final submitButton = find.text('Confirm Disbursement');
    await tester.ensureVisible(submitButton);
    await tester.tap(submitButton);
    await tester.pumpAndSettle();

    expect(find.text('Confirm disbursement'), findsOneWidget);
    expect(find.text('KSh 7.00'), findsOneWidget);
    expect(find.text('KSh 57.00'), findsOneWidget);
    expect(repository.withdrawCalls, 0);

    await tester.tap(find.widgetWithText(FilledButton, 'Disburse'));
    await tester.pumpAndSettle();

    expect(repository.withdrawCalls, 1);
    expect(repository.lastDestination, '0712345678');
    expect(repository.lastAmount, 50);
    expect(find.text('Disbursement Successful!'), findsOneWidget);
  });
}

class _FakeGroupsRepository extends Fake implements GroupsRepository {
  int withdrawCalls = 0;
  String? lastDestination;
  double? lastAmount;

  @override
  Future<ApiResponse<double>> getWithdrawalFee({
    required double amount,
  }) async => ApiResponse.success(7);

  @override
  Future<ApiResponse<bool>> withdraw({
    required String groupId,
    required double amount,
    required String withdrawalType,
    required String destination,
    String? billerType,
    String? billerNumber,
  }) async {
    withdrawCalls++;
    lastDestination = destination;
    lastAmount = amount;
    return ApiResponse.success(true);
  }
}

Group _group() => Group(
  id: '10',
  name: 'Eustero Group',
  membersCount: '10',
  frequency: 'Monthly',
  imageUrl: '',
  balance: 193,
  goal: 0,
  progressPercentage: 0,
  status: 'active',
  role: 'admin',
  accountNo: '10800921',
  location: 'Nairobi',
  description: '',
);
