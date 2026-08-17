import 'package:flutter/foundation.dart';

/// Non-web fallback.
///
/// This project deploys to the web; the mobile/desktop targets exist only so
/// `flutter analyze` and `flutter test` run against every platform. Saving to
/// disk here would need a file-picker dependency that the shipped build never
/// loads, so the stub logs instead.
Future<void> saveBytes(
    List<int> bytes, String fileName, String mimeType) async {
  debugPrint(
    'saveBytes is web-only; ignoring $fileName (${bytes.length} bytes).',
  );
}
