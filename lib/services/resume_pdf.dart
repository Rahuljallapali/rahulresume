import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../data/models.dart';
import '../data/notes.dart';
import '../data/profile.dart';

/// Builds the downloadable résumé from [Profile].
///
/// The point of generating rather than shipping a static file: the PDF and the
/// page are the same data. A correction to a job description updates both, so
/// the document a recruiter downloads can never contradict the site they
/// downloaded it from.
abstract final class ResumePdf {
  static const _accent = PdfColor.fromInt(0xFF3355E8);
  static const _ink = PdfColor.fromInt(0xFF14161C);
  static const _muted = PdfColor.fromInt(0xFF585F6E);
  static const _rule = PdfColor.fromInt(0xFFD9DDE6);

  static Future<List<int>> build() async {
    final doc = pw.Document(
      title: '${Profile.name} — Résumé',
      author: Profile.name,
      subject: Profile.title,
      creator: 'rahuljallapalli.dev',
    );

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.fromLTRB(42, 40, 42, 40),
        footer: (context) => pw.Container(
          alignment: pw.Alignment.centerRight,
          margin: const pw.EdgeInsets.only(top: 12),
          child: pw.Text(
            '${Profile.name} · page ${context.pageNumber} of ${context.pagesCount}',
            style: const pw.TextStyle(fontSize: 8, color: _muted),
          ),
        ),
        build: (context) => [
          _header(),
          pw.SizedBox(height: 16),
          _summary(),
          pw.SizedBox(height: 16),
          _storeApps(),
          pw.SizedBox(height: 18),
          _experience(),
          pw.SizedBox(height: 16),
          _projects(),
          pw.SizedBox(height: 16),
          _skills(),
          pw.SizedBox(height: 16),
          _delivery(),
          pw.SizedBox(height: 16),
          _writing(),
        ],
      ),
    );

    return doc.save();
  }

  static pw.Widget _header() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          Profile.name,
          style: pw.TextStyle(
            fontSize: 26,
            fontWeight: pw.FontWeight.bold,
            color: _ink,
            letterSpacing: -0.6,
          ),
        ),
        pw.SizedBox(height: 3),
        pw.Text(
          Profile.title,
          style: const pw.TextStyle(fontSize: 12, color: _accent),
        ),
        pw.SizedBox(height: 8),
        pw.Text(
          [
            Profile.email,
            Profile.location,
            'github.com/${Profile.githubUser}',
            Profile.linkedInUrl.replaceFirst('https://www.', ''),
          ].join('  ·  '),
          style: const pw.TextStyle(fontSize: 8.5, color: _muted),
        ),
        pw.SizedBox(height: 3),
        // Experience and notice period are what a recruiter screens on first,
        // so they sit in the header rather than buried in the body.
        pw.Text(
          [
            '${Profile.experience} experience',
            if (Profile.noticePeriod.isNotEmpty)
              'Notice period: ${Profile.noticePeriod}',
            Profile.openToRelocation,
          ].join('  ·  '),
          style: const pw.TextStyle(fontSize: 8.5, color: _muted),
        ),
        pw.SizedBox(height: 10),
        pw.Container(height: 2, color: _accent, width: 46),
      ],
    );
  }

  static pw.Widget _sectionTitle(String text) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          text.toUpperCase(),
          style: pw.TextStyle(
            fontSize: 9.5,
            fontWeight: pw.FontWeight.bold,
            color: _accent,
            letterSpacing: 1.1,
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Divider(color: _rule, thickness: 0.6, height: 1),
        pw.SizedBox(height: 8),
      ],
    );
  }

  static pw.Widget _summary() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _sectionTitle('Profile'),
        pw.Text(
          Profile.summary,
          textAlign: pw.TextAlign.justify,
          style:
              const pw.TextStyle(fontSize: 9.5, color: _ink, lineSpacing: 2.2),
        ),
      ],
    );
  }

  /// One line per store app: what it is, what was done, where it lives. The
  /// store presence is the strongest single claim on the document, so it sits
  /// directly under the profile paragraph.
  static pw.Widget _storeApps() {
    String presence(StoreApp app) {
      final stores = [
        if (app.appStoreUrl != null) 'Apple App Store',
        if (app.playStoreUrl != null) 'Google Play',
        if (app.releaseOnly) 'released via App Store Connect',
        if (app.enterprise) 'enterprise distribution, no public listing',
      ];
      return stores.join(' · ');
    }

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _sectionTitle('Published Apps'),
        for (final app in Profile.storeApps)
          pw.Container(
            margin: const pw.EdgeInsets.only(bottom: 4),
            child: pw.RichText(
              text: pw.TextSpan(
                style: const pw.TextStyle(
                  fontSize: 9,
                  color: _ink,
                  lineSpacing: 1.8,
                ),
                children: [
                  pw.TextSpan(
                    text: '${app.name} — ',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                  pw.TextSpan(text: '${app.tagline}. ${app.role}.  '),
                  pw.TextSpan(
                    text: presence(app),
                    style: const pw.TextStyle(color: _muted),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  static pw.Widget _bullet(String text) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 4),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Container(
            width: 3,
            height: 3,
            margin: const pw.EdgeInsets.only(top: 4.5, right: 6),
            decoration: const pw.BoxDecoration(
              color: _accent,
              shape: pw.BoxShape.circle,
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              text,
              style: const pw.TextStyle(
                fontSize: 9,
                color: _ink,
                lineSpacing: 1.8,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _experience() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _sectionTitle('Experience'),
        for (final e in Profile.experiences) ...[
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                child: pw.Text(
                  '${e.role} · ${e.company}',
                  style: pw.TextStyle(
                    fontSize: 11,
                    fontWeight: pw.FontWeight.bold,
                    color: _ink,
                  ),
                ),
              ),
              pw.Text(
                e.period,
                style: const pw.TextStyle(fontSize: 9, color: _muted),
              ),
            ],
          ),
          pw.SizedBox(height: 2),
          pw.Text(
            e.location,
            style: const pw.TextStyle(fontSize: 8.5, color: _muted),
          ),
          pw.SizedBox(height: 6),
          pw.Text(
            e.summary,
            style: const pw.TextStyle(
              fontSize: 9,
              color: _ink,
              lineSpacing: 1.8,
            ),
          ),
          pw.SizedBox(height: 6),
          for (final a in e.achievements) _bullet(a),
          pw.SizedBox(height: 6),
          pw.Text(
            'Stack: ${e.stack.join(', ')}',
            style: const pw.TextStyle(fontSize: 8.5, color: _muted),
          ),
          pw.SizedBox(height: 10),
        ],
      ],
    );
  }

  static pw.Widget _projects() {
    // Flagship work only — the résumé is a summary, the site is the detail.
    final featured =
        Profile.projects.where((p) => p.isFlagship || p.tags.contains('AI'));

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _sectionTitle('Selected Work'),
        for (final p in featured) ...[
          pw.Text(
            p.name,
            style: pw.TextStyle(
              fontSize: 10.5,
              fontWeight: pw.FontWeight.bold,
              color: _ink,
            ),
          ),
          pw.SizedBox(height: 2),
          pw.Text(
            p.summary,
            style: const pw.TextStyle(
              fontSize: 9,
              color: _ink,
              lineSpacing: 1.8,
            ),
          ),
          pw.SizedBox(height: 3),
          pw.Text(
            p.stack.join(' · '),
            style: const pw.TextStyle(fontSize: 8.5, color: _muted),
          ),
          pw.SizedBox(height: 9),
        ],
      ],
    );
  }

  static pw.Widget _skills() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _sectionTitle('Technical Skills'),
        for (final g in Profile.skillGroups)
          pw.Container(
            margin: const pw.EdgeInsets.only(bottom: 5),
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.SizedBox(
                  width: 96,
                  child: pw.Text(
                    g.title,
                    style: pw.TextStyle(
                      fontSize: 9,
                      fontWeight: pw.FontWeight.bold,
                      color: _ink,
                    ),
                  ),
                ),
                pw.Expanded(
                  child: pw.Text(
                    g.skills.map((s) => s.name).join(' · '),
                    style: const pw.TextStyle(
                      fontSize: 9,
                      color: _muted,
                      lineSpacing: 1.6,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  static pw.Widget _delivery() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _sectionTitle('Build & Deployment'),
        for (final s in Profile.deliveryStages)
          _bullet('${s.label} — ${s.detail}'),
      ],
    );
  }

  /// Titles and URLs only. The résumé points at the writing; the site hosts it.
  static pw.Widget _writing() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _sectionTitle('Writing'),
        for (final n in Notes.all)
          pw.Container(
            margin: const pw.EdgeInsets.only(bottom: 4),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  '${n.title} — ${n.date}',
                  style: pw.TextStyle(
                    fontSize: 9,
                    fontWeight: pw.FontWeight.bold,
                    color: _ink,
                  ),
                ),
                pw.UrlLink(
                  destination: '${Profile.siteUrl}/#/notes/${n.slug}',
                  child: pw.Text(
                    '${Profile.siteUrl}/#/notes/${n.slug}',
                    style: const pw.TextStyle(fontSize: 8, color: _accent),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
