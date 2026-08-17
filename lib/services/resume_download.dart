// Conditional import keeps the DOM-specific implementation out of non-web
// builds, so the project still analyses and compiles for every platform.
import 'file_saver_io.dart' if (dart.library.js_interop) 'file_saver_web.dart';
import 'resume_pdf.dart';

abstract final class ResumeDownload {
  static const fileName = 'Rahul_Jallapalli_Resume.pdf';

  /// Renders the résumé from profile data and hands it to the browser.
  static Future<void> generateAndDownload() async {
    final bytes = await ResumePdf.build();
    await saveBytes(bytes, fileName, 'application/pdf');
  }
}
