import 'dart:convert';
import 'dart:typed_data';

import 'package:hesabu_app/features/groups/domain/groups_repository.dart';

class GroupStatementCsvExporter {
  const GroupStatementCsvExporter._();

  static Uint8List build({
    required Group group,
    required List<GroupStatementEntry> entries,
    required DateTime generatedAt,
  }) {
    final rows = <List<String>>[
      ['Hesabu Online Group Statement'],
      ['Group', _safeText(group.name)],
      ['Group Account Number', _safeText(group.accountNo)],
      ['Generated At (UTC)', generatedAt.toUtc().toIso8601String()],
      <String>[],
      [
        'Transaction ID',
        'Date Created',
        'Operation',
        'Member',
        'MSISDN',
        'Amount (KES)',
        'Balance Before (KES)',
        'Balance After (KES)',
      ],
      ...entries.map(
        (entry) => [
          _safeText(entry.transactionId),
          _safeText(entry.dateCreated),
          _safeText(entry.operation),
          _safeText(entry.memberName),
          _safeText(entry.msisdn),
          entry.amount.toStringAsFixed(2),
          entry.balanceBefore.toStringAsFixed(2),
          entry.balanceAfter.toStringAsFixed(2),
        ],
      ),
    ];

    final csv = rows.map(_encodeRow).join('\r\n');
    return Uint8List.fromList(utf8.encode('\uFEFF$csv\r\n'));
  }

  static String _encodeRow(List<String> row) => row.map(_escape).join(',');

  static String _escape(String value) {
    if (value.contains(RegExp(r'[,"\r\n]'))) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }

  // Prevent spreadsheet applications from interpreting API-provided text as
  // a formula when the CSV is opened.
  static String _safeText(String value) {
    if (value.isEmpty) return value;
    final trimmedLeft = value.trimLeft();
    if (trimmedLeft.startsWith(RegExp(r'[=+\-@]'))) {
      return "'$value";
    }
    return value;
  }
}
