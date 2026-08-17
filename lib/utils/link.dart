import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

/// Opens an external URL, failing quietly rather than throwing into the widget
/// tree — a dead link should never take the page down.
Future<void> openLink(String url) async {
  final uri = Uri.tryParse(url);
  if (uri == null) return;
  try {
    await launchUrl(
      uri,
      // External links open in a new tab so the visitor does not lose the page;
      // mailto: must hand off to the platform handler instead.
      mode: uri.scheme == 'mailto'
          ? LaunchMode.platformDefault
          : LaunchMode.externalApplication,
      webOnlyWindowName: uri.scheme == 'mailto' ? null : '_blank',
    );
  } catch (e) {
    debugPrint('Could not open $url: $e');
  }
}
