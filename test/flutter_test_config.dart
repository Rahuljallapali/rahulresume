import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

/// Picked up automatically by `flutter test` and wrapped around every suite in
/// this directory.
///
/// Two things need arranging before any widget test runs:
///
///  1. `google_fonts` fetches font binaries over HTTP on first use. The test
///     sandbox has no network, so runtime fetching is disabled and the engine's
///     default face is used instead.
///  2. With fetching disabled the package falls back to looking for a bundled
///     font, which reads `AssetManifest.bin`. The test asset bundle is empty,
///     so that read throws. Serving an empty manifest makes the lookup miss
///     cleanly rather than blow up.
///
/// Neither affects production; both are artefacts of running headless.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();

  GoogleFonts.config.allowRuntimeFetching = false;

  // The binary manifest is a StandardMessageCodec-encoded map of asset key to
  // variant list. Empty is a well-formed manifest that declares no assets.
  final emptyManifest =
      const StandardMessageCodec().encodeMessage(<String, Object?>{});

  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMessageHandler('flutter/assets', (ByteData? message) async {
    final key = utf8.decode(message!.buffer.asUint8List());
    if (key == 'AssetManifest.bin') return emptyManifest;
    // Anything else genuinely is missing; let the default handling report it.
    return null;
  });

  await testMain();
}
