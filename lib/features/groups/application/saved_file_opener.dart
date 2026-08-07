import 'package:flutter/foundation.dart';
import 'package:open_filex/open_filex.dart';

typedef PlatformFileLauncher = Future<OpenResult> Function(String path);

class SavedFileOpenResult {
  const SavedFileOpenResult.success() : succeeded = true, message = null;

  const SavedFileOpenResult.failure(this.message) : succeeded = false;

  final bool succeeded;
  final String? message;
}

class SavedFileOpener {
  SavedFileOpener({PlatformFileLauncher? launcher})
    : _launcher = launcher ?? _launchCsv;

  final PlatformFileLauncher _launcher;

  Future<SavedFileOpenResult> open(String path) async {
    if (path.trim().isEmpty) {
      return const SavedFileOpenResult.failure(
        'The saved statement path is unavailable.',
      );
    }
    if (kIsWeb) {
      return const SavedFileOpenResult.failure(
        'Downloaded files must be opened from your browser downloads.',
      );
    }

    try {
      final result = await _launcher(path);
      return switch (result.type) {
        ResultType.done => const SavedFileOpenResult.success(),
        ResultType.fileNotFound => const SavedFileOpenResult.failure(
          'The saved statement could not be found.',
        ),
        ResultType.noAppToOpen => const SavedFileOpenResult.failure(
          'Install a spreadsheet or CSV viewer to open this statement.',
        ),
        ResultType.permissionDenied => const SavedFileOpenResult.failure(
          'Permission to open the saved statement was denied.',
        ),
        ResultType.error => SavedFileOpenResult.failure(
          result.message.isEmpty
              ? 'Unable to open the saved statement.'
              : result.message,
        ),
      };
    } catch (_) {
      return const SavedFileOpenResult.failure(
        'Unable to open the saved statement on this device.',
      );
    }
  }

  static Future<OpenResult> _launchCsv(String path) => OpenFilex.open(
    path,
    type: 'text/csv',
    uti: 'public.comma-separated-values-text',
  );
}
