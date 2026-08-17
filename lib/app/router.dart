import 'package:flutter/material.dart';

import '../data/models.dart';
import '../data/notes.dart';
import '../data/profile.dart';
import '../pages/case_study_page.dart';
import '../pages/home_page.dart';
import '../pages/note_page.dart';

/// Route table for the site.
///
/// Hash-based URLs (`/#/work/service-backend`) are the default on Flutter web
/// and the correct choice here: the site is served from a GitHub Pages
/// subpath with no server-side rewrite available, so a path-based route would
/// 404 on a hard refresh or a shared link.
///
/// Unknown routes fall back to the home page rather than an error screen — a
/// stale link someone pasted into a chat should still land on the portfolio.
abstract final class AppRouter {
  static const home = '/';
  static const workPrefix = '/work/';
  static const notePrefix = '/notes/';

  static String workPath(String slug) => '$workPrefix$slug';
  static String notePath(String slug) => '$notePrefix$slug';

  static Route<dynamic> generate(RouteSettings settings) {
    final name = settings.name ?? home;

    if (name.startsWith(workPrefix)) {
      final slug = name.substring(workPrefix.length);
      final project = _projectBySlug(slug);
      if (project != null) {
        return _fade(settings, CaseStudyPage(project: project));
      }
    }

    if (name.startsWith(notePrefix)) {
      final slug = name.substring(notePrefix.length);
      final note = Notes.bySlug(slug);
      if (note != null) {
        return _fade(settings, NotePage(note: note));
      }
    }

    return _fade(const RouteSettings(name: home), const HomePage());
  }

  static Project? _projectBySlug(String slug) {
    for (final p in Profile.projects) {
      if (p.slug == slug) return p;
    }
    return null;
  }

  /// Fade rather than slide: a horizontal push reads as mobile-app chrome on
  /// a desktop site, and these are documents, not screens.
  static PageRouteBuilder<dynamic> _fade(RouteSettings settings, Widget child) {
    return PageRouteBuilder<dynamic>(
      settings: settings,
      pageBuilder: (_, __, ___) => child,
      transitionDuration: const Duration(milliseconds: 260),
      reverseTransitionDuration: const Duration(milliseconds: 200),
      transitionsBuilder: (_, animation, __, child) => FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
        child: child,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Navigation helpers. Callers use these rather than raw strings so a route
  // rename is a single edit.
  // ---------------------------------------------------------------------------

  static void openCaseStudy(BuildContext context, String slug) =>
      Navigator.of(context).pushNamed(workPath(slug));

  static void openNote(BuildContext context, String slug) =>
      Navigator.of(context).pushNamed(notePath(slug));

  /// Returns to the home page from a detail page, popping when there is
  /// history to pop and replacing when the visitor arrived by deep link.
  static void goHome(BuildContext context) {
    final navigator = Navigator.of(context);
    if (navigator.canPop()) {
      navigator.pop();
    } else {
      navigator.pushReplacementNamed(home);
    }
  }
}
