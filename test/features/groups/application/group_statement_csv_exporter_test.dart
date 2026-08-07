import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:hesabu_app/features/groups/application/group_statement_csv_exporter.dart';
import 'package:hesabu_app/features/groups/domain/groups_repository.dart';

void main() {
  test('exports statement metadata and auditable transaction fields', () {
    final bytes = GroupStatementCsvExporter.build(
      group: _group(name: 'Eustero Group', accountNo: '10800921'),
      entries: [
        GroupStatementEntry(
          amount: 100,
          balanceAfter: 193,
          balanceBefore: 93,
          dateCreated: '2026-08-06 11:14:00',
          memberName: 'Eustace Mwai',
          msisdn: '254718273753',
          operation: 'deposit',
          transactionId: 'TX-100',
        ),
      ],
      generatedAt: DateTime.utc(2026, 8, 7, 9, 30),
    );

    expect(bytes.take(3), orderedEquals([0xEF, 0xBB, 0xBF]));
    final csv = utf8.decode(bytes);
    expect(csv, contains('Group Account Number,10800921'));
    expect(csv, contains('Generated At (UTC),2026-08-07T09:30:00.000Z'));
    expect(
      csv,
      contains(
        'TX-100,2026-08-06 11:14:00,deposit,Eustace Mwai,254718273753,100.00,93.00,193.00',
      ),
    );
  });

  test('escapes CSV values and neutralizes spreadsheet formulas', () {
    final bytes = GroupStatementCsvExporter.build(
      group: _group(name: '=HYPERLINK("bad")', accountNo: '10000001'),
      entries: [
        GroupStatementEntry(
          amount: 1,
          balanceAfter: 1,
          balanceBefore: 0,
          dateCreated: '2026-08-07',
          memberName: 'Doe, Jane',
          msisdn: '254700000000',
          operation: 'deposit',
          transactionId: '+malicious',
        ),
      ],
      generatedAt: DateTime.utc(2026, 8, 7),
    );

    final csv = utf8.decode(bytes);
    expect(csv, contains('"\'=HYPERLINK(""bad"")"'));
    expect(csv, contains('"Doe, Jane"'));
    expect(csv, contains("'+malicious"));
  });
}

Group _group({required String name, required String accountNo}) => Group(
  id: '10',
  name: name,
  membersCount: '2',
  frequency: 'Monthly',
  imageUrl: '',
  balance: 193,
  goal: 0,
  progressPercentage: 0,
  status: 'active',
  role: 'admin',
  accountNo: accountNo,
  location: 'Nairobi',
  description: '',
);
