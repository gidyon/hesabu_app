import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hesabu_app/core/theme/app_theme.dart';
import 'package:hesabu_app/core/theme/theme_controller.dart';
import 'package:hesabu_app/features/groups/domain/groups_repository.dart';
import 'package:hesabu_app/features/groups/presentation/widgets/financial_components.dart';

void main() {
  for (final brightness in Brightness.values) {
    testWidgets(
      'financial ledger components render without overflow in ${brightness.name} mode',
      (tester) async {
        tester.view.physicalSize = const Size(360, 800);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.themeFor(AppAccentColor.emerald, brightness),
            home: Scaffold(
              body: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  GroupLedgerCard(
                    group: _group(),
                    onOpen: () {},
                    onDeposit: () {},
                  ),
                  const SizedBox(height: 8),
                  LedgerTransactionTile(transaction: _transaction()),
                  const SizedBox(height: 8),
                  MemberLedgerTile(member: _member()),
                ],
              ),
            ),
          ),
        );

        expect(find.text('Eustero Group'), findsOneWidget);
        expect(find.text('Deposit'), findsNWidgets(2));
        expect(find.text('Ref TX-100'), findsOneWidget);
        expect(find.text('POSTED'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  }
}

Group _group() => Group(
  id: '10',
  name: 'Eustero Group',
  membersCount: '10',
  frequency: 'Monthly',
  imageUrl: '',
  balance: 193,
  goal: 1000,
  progressPercentage: 0.193,
  status: 'active',
  role: 'admin',
  accountNo: '10800921',
  location: 'Nairobi',
  description: '',
);

Transaction _transaction() => Transaction(
  id: 'TX-100',
  title: 'deposit - Eustace Mwai',
  date: 'Aug 7, 2026, 2:30 PM',
  type: 'Inflow',
  amount: 100,
  method: 'Wallet',
);

Member _member() => Member(
  id: '1',
  name: 'Eustace Mwai',
  msisdn: '254700000000',
  role: 'admin',
  status: 'active',
  dateJoined: '2026-08-01',
);
