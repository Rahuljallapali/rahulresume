import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:rahul_resume/app/lens.dart';
import 'package:rahul_resume/app/router.dart';
import 'package:rahul_resume/data/notes.dart';
import 'package:rahul_resume/data/profile.dart';
import 'package:rahul_resume/main.dart';
import 'package:rahul_resume/pages/home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Layout regression net for small screens.
///
/// Recruiters open links on phones, and a Flutter overflow stripe on a
/// portfolio is the worst possible advertisement for the person who built it.
/// Rather than eyeball a couple of breakpoints, this walks the real device
/// widths at both ends of the text-scale range the app allows.
///
/// It found three genuine defects when first written: an eyebrow rule that
/// could not wrap, a note byline that overflowed at 320px, and a callout
/// whose non-uniform border made every note page throw at every width.
void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    // The suite has no network, so google_fonts must fall back rather than
    // throw. Metrics differ slightly from production — these assertions are
    // about "does it fit at all", not pixel geometry.
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  /// Widths of devices people actually hold, plus the tablet sizes either
  /// side of the layout breakpoints.
  const widths = <double>[320, 360, 375, 390, 414, 428, 600, 768, 820, 1024];

  Future<void> pumpAt(
    WidgetTester tester,
    double width, {
    double textScale = 1.0,
  }) async {
    tester.view.physicalSize = Size(width, 3000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MediaQuery(
        data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
        child: const PortfolioApp(),
      ),
    );
    await tester.pump(const Duration(milliseconds: 60));
  }

  group('home page fits', () {
    for (final width in widths) {
      // 1.3 is the ceiling main.dart clamps to, so it is the worst case a
      // visitor with enlarged system text can produce.
      for (final scale in <double>[1.0, 1.3]) {
        testWidgets('at ${width.toInt()}px, text scale $scale',
            (tester) async {
          await pumpAt(tester, width, textScale: scale);
          expect(tester.takeException(), isNull);
        });
      }
    }
  });

  // The freelance lens is the only way the engagement section ever renders,
  // so the sweep above — which runs under the default lens — never touches
  // it. Without this group the client-facing page is the one page on the
  // site with no overflow net, which is precisely backwards: it is the page
  // a paying stranger reads.
  group('the freelance lens fits', () {
    for (final width in <double>[320, 360, 390, 768, 1024]) {
      for (final scale in <double>[1.0, 1.3]) {
        testWidgets('at ${width.toInt()}px, text scale $scale',
            (tester) async {
          await pumpAt(tester, width, textScale: scale);

          // Simulates arriving via ?role=freelance, the only route in.
          Provider.of<LensController>(
            tester.element(find.byType(HomePage)),
            listen: false,
          ).select(Lens.freelance);
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 100));

          expect(find.byType(HomePage), findsOneWidget);
          expect(tester.takeException(), isNull);
        });
      }
    }
  });

  group('detail pages fit', () {
    Future<void> pushAndSettle(WidgetTester tester, String route) async {
      tester
          .state<NavigatorState>(find.byType(Navigator).first)
          .pushNamed(route);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
    }

    for (final width in <double>[320, 360, 390, 768]) {
      testWidgets('case study at ${width.toInt()}px', (tester) async {
        await pumpAt(tester, width);
        await pushAndSettle(
            tester, AppRouter.workPath(Profile.projects.first.slug));
        expect(tester.takeException(), isNull);
      });

      testWidgets('note at ${width.toInt()}px', (tester) async {
        await pumpAt(tester, width);
        await pushAndSettle(tester, AppRouter.notePath(Notes.all.first.slug));
        expect(tester.takeException(), isNull);
      });
    }
  });

  // Every note renders its own mix of block types, and the callout crash only
  // showed up in notes that use one — so cover them all rather than the first.
  group('every note renders', () {
    for (final note in Notes.all) {
      testWidgets('${note.slug} at 390px', (tester) async {
        await pumpAt(tester, 390);
        tester
            .state<NavigatorState>(find.byType(Navigator).first)
            .pushNamed(AppRouter.notePath(note.slug));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 400));
        expect(tester.takeException(), isNull);
      });
    }
  });

  // Same for case studies: they differ in which optional blocks they carry.
  group('every case study renders', () {
    for (final project in Profile.projects) {
      testWidgets('${project.slug} at 390px', (tester) async {
        await pumpAt(tester, 390);
        tester
            .state<NavigatorState>(find.byType(Navigator).first)
            .pushNamed(AppRouter.workPath(project.slug));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 400));
        expect(tester.takeException(), isNull);
      });
    }
  });
}
