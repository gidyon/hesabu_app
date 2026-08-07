import 'package:flutter_test/flutter_test.dart';
import 'package:hesabu_app/features/groups/application/saved_file_opener.dart';
import 'package:open_filex/open_filex.dart';

void main() {
  test('maps native file-open results to actionable messages', () async {
    final successOpener = SavedFileOpener(
      launcher: (_) async => OpenResult(type: ResultType.done),
    );
    final missingViewerOpener = SavedFileOpener(
      launcher: (_) async => OpenResult(type: ResultType.noAppToOpen),
    );

    final success = await successOpener.open('/tmp/statement.csv');
    final missingViewer = await missingViewerOpener.open('/tmp/statement.csv');

    expect(success.succeeded, isTrue);
    expect(missingViewer.succeeded, isFalse);
    expect(missingViewer.message, contains('spreadsheet or CSV viewer'));
  });

  test('returns a safe error when the native launcher throws', () async {
    final opener = SavedFileOpener(
      launcher: (_) async => throw Exception('platform details'),
    );

    final result = await opener.open('/tmp/statement.csv');

    expect(result.succeeded, isFalse);
    expect(
      result.message,
      'Unable to open the saved statement on this device.',
    );
  });
}
