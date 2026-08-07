import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hesabu_app/core/api/api_response.dart';
import 'package:hesabu_app/core/theme/inherited_theme_controller.dart';
import 'package:hesabu_app/core/theme/theme_controller.dart';
import 'package:hesabu_app/features/groups/application/saved_file_opener.dart';
import 'package:hesabu_app/features/activity/application/activity_provider.dart';
import 'package:hesabu_app/features/groups/domain/groups_repository.dart';
import 'package:hesabu_app/features/groups/presentation/screens/group_details_screen.dart';
import 'package:open_filex/open_filex.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const fileSaverChannel = MethodChannel('file_saver');

  setUp(() {
    SharedPreferences.setMockInitialValues({
      'theme_mode': ThemeMode.light.index,
    });
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(fileSaverChannel, (call) async {
          expect(call.method, 'saveAs');
          return '/tmp/utawala_statement.csv';
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(fileSaverChannel, null);
  });

  testWidgets('saved statement snackbar View action opens the saved path', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final prefs = await SharedPreferences.getInstance();
    final themeController = ThemeController(prefs);
    String? openedPath;
    final opener = SavedFileOpener(
      launcher: (path) async {
        openedPath = path;
        return OpenResult(type: ResultType.done);
      },
    );

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<GroupsRepository>.value(value: _FakeGroupsRepository()),
          ChangeNotifierProvider<ActivityProvider>(
            create: (_) => ActivityProvider(prefs),
          ),
        ],
        child: InheritedThemeController(
          notifier: themeController,
          child: MaterialApp(
            home: GroupDetailsScreen(group: _group(), savedFileOpener: opener),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Download group statement'));
    await tester.pumpAndSettle();

    expect(find.text('Statement saved successfully.'), findsOneWidget);
    expect(find.text('View'), findsOneWidget);

    await tester.tap(find.text('View'));
    await tester.pumpAndSettle();

    expect(openedPath, '/tmp/utawala_statement.csv');
  });
}

class _FakeGroupsRepository extends Fake implements GroupsRepository {
  @override
  Future<ApiResponse<List<Transaction>>> getRecentTransactions(
    String groupId,
  ) async => ApiResponse.success([]);

  @override
  Future<ApiResponse<List<Member>>> getMembers(String groupId) async =>
      ApiResponse.success([]);

  @override
  Future<ApiResponse<double>> getGroupBalance(String groupId) async =>
      ApiResponse.success(150);

  @override
  Future<ApiResponse<List<GroupStatementEntry>>> getGroupStatements(
    String groupId,
  ) async => ApiResponse.success([
    GroupStatementEntry(
      amount: 100,
      balanceAfter: 150,
      balanceBefore: 50,
      dateCreated: '2026-08-07T12:00:00Z',
      memberName: 'Eustace',
      msisdn: '254700000000',
      operation: 'deposit',
      transactionId: 'TX-1',
    ),
  ]);
}

Group _group() => Group(
  id: '10',
  name: 'Utawala Unfit',
  membersCount: '2',
  frequency: 'Monthly',
  imageUrl: '',
  balance: 150,
  goal: 0,
  progressPercentage: 0,
  status: 'active',
  role: 'admin',
  accountNo: '10800921',
  location: 'Nairobi',
  description: '',
);
