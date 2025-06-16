import 'dart:html' as html;
import 'package:flutter/services.dart';

class DownloadHelper {
  static Future<void> downloadFile(String assetPath, String fileName) async {
    try {
      // Load the PDF file from assets
      final bytes = await rootBundle.load(assetPath);
      final blob = html.Blob([bytes.buffer.asUint8List()]);
      
      // Create a URL for the blob
      final url = html.Url.createObjectUrlFromBlob(blob);
      
      // Create an anchor element and trigger download
      final anchor = html.AnchorElement()
        ..href = url
        ..style.display = 'none'
        ..download = fileName;
      
      html.document.body?.children.add(anchor);
      anchor.click();
      
      // Clean up
      html.document.body?.children.remove(anchor);
      html.Url.revokeObjectUrl(url);
    } catch (e) {
      print('Error downloading file: $e');
    }
  }
} 