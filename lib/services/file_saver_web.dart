import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart' as web;

/// Triggers a browser download for [bytes].
///
/// Uses `package:web` + `dart:js_interop` rather than the deprecated
/// `dart:html`, which is a hard blocker for Wasm compilation.
Future<void> saveBytes(
    List<int> bytes, String fileName, String mimeType) async {
  final data = bytes is Uint8List ? bytes : Uint8List.fromList(bytes);

  final blob = web.Blob(
    [data.toJS].toJS,
    web.BlobPropertyBag(type: mimeType),
  );

  final url = web.URL.createObjectURL(blob);
  final anchor = web.document.createElement('a') as web.HTMLAnchorElement
    ..href = url
    ..download = fileName
    ..style.display = 'none';

  web.document.body!.appendChild(anchor);
  anchor.click();
  anchor.remove();

  // Without this the blob is retained for the lifetime of the document.
  web.URL.revokeObjectURL(url);
}
