import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:rahul_resume/app/lens.dart';
import 'package:rahul_resume/app/router.dart';
import 'package:rahul_resume/app/theme/app_theme.dart';
import 'package:rahul_resume/app/theme/tokens.dart';
import 'package:rahul_resume/data/models.dart';
import 'package:rahul_resume/data/notes.dart';
import 'package:rahul_resume/data/profile.dart';
import 'package:rahul_resume/main.dart';
import 'package:rahul_resume/pages/home_page.dart';
import 'package:rahul_resume/sections/engagement_section.dart';
import 'package:rahul_resume/ui/reveal.dart';
import 'package:rahul_resume/ui/tech_ticker.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Effective opacity applied to [target] by everything above it, so a test can
/// assert "this is actually on screen" rather than merely "this is in the
/// tree" — a widget faded to zero is still findable.
double _effectiveOpacity(WidgetTester tester, Finder target) {
  final values = tester
      .widgetList<Opacity>(
        find.ancestor(of: target, matching: find.byType(Opacity)),
      )
      .map((o) => o.opacity);
  return values.isEmpty ? 1.0 : values.reduce((a, b) => a < b ? a : b);
}

/// The site renders from `Profile`, so most defects worth catching are
/// content-integrity defects: a filter facet that matches nothing, a skill
/// level out of range, a placeholder that slipped back in. Those are asserted
/// directly. One smoke test covers the widget tree.
void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    // google_fonts fetches over the network at runtime, which the test
    // sandbox blocks. Disabling it makes the package fall back to the bundled
    // default face instead of throwing — layout metrics differ slightly from
    // production, so this suite asserts on structure and content, not on
    // pixel geometry.
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('renders the headline and primary calls to action',
      (tester) async {
    // Wide surface so the desktop layout branch is the one exercised.
    tester.view.physicalSize = const Size(1440, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const PortfolioApp());
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text(Profile.headline), findsOneWidget);
    expect(find.text('View my work'), findsOneWidget);
    expect(find.text('Download resume'), findsOneWidget);
    expect(find.text(Profile.name), findsWidgets);
  });

  // The load-bearing guarantee of the whole lens design: a recruiter opening
  // the plain URL must never see engagement pricing. Asserted through the
  // real widget tree rather than the data layer, because the data is always
  // present — it is the rendering that is gated.
  group('freelance content is gated', () {
    Future<void> pumpWide(WidgetTester tester) async {
      tester.view.physicalSize = const Size(1600, 3000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(const PortfolioApp());
      await tester.pump(const Duration(milliseconds: 100));
    }

    testWidgets('the default page shows no engagement section',
        (tester) async {
      await pumpWide(tester);

      expect(find.byType(EngagementSection), findsNothing);
      expect(find.text('What you can hire me for'), findsNothing);
      // And the switcher must not advertise a way to reach it.
      expect(find.text('Freelance'), findsNothing);
    });

    testWidgets('the freelance lens reveals it', (tester) async {
      await pumpWide(tester);

      // Simulates arriving via ?role=freelance, which is the only route in.
      Provider.of<LensController>(
        tester.element(find.byType(HomePage)),
        listen: false,
      ).select(Lens.freelance);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(EngagementSection), findsOneWidget);
    });
  });

  // The app cards share a height via IntrinsicHeight. Wrap reports its
  // intrinsic height by measuring each child at its *unwrapped* width — one
  // line — so a chip whose text wraps at layout time is taller than the row
  // was sized for, and overflows. It cost 48 pixels in the browser at this
  // width. The fix is structural: every chip in that Wrap is capped to one
  // line, so layout height always equals intrinsic height.
  //
  // Honest scope: this exercises the narrowest four-across layout (the wide
  // breakpoint starts at 1080) but does NOT reproduce the original overflow.
  // The suite falls back to a narrower font than the Manrope the site ships,
  // so the chip never wraps here — it passes with or without the fix.
  testWidgets('app cards fit at the narrowest four-column width',
      (tester) async {
    tester.view.physicalSize = const Size(1080, 2600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const PortfolioApp());
    await tester.pump(const Duration(milliseconds: 100));

    expect(tester.takeException(), isNull);
  });

  // Regression: the ticker starts from didChangeDependencies, which runs
  // before its ListView has been laid out. It guarded on `hasClients`, which
  // is true as soon as a position attaches — but a position without
  // dimensions throws on `minScrollExtent`, which `jumpTo` reads. The first
  // animation frame crashed the scheduler on every page load.
  // The ticker crashed on web: it guarded its per-frame `jumpTo` on
  // `hasClients`, which is true the moment a ScrollPosition attaches — but a
  // position that has not been through layout has no scroll extents, and
  // `jumpTo` reads them. Every page load threw on the first animation frame.
  // The guard is now `position.haveDimensions`.
  //
  // Honest scope: this test does NOT reproduce that race. `pumpWidget`
  // completes layout before the first tick can fire, and an unlaid-out
  // Scrollable (Offstage) attaches no position at all, so it exits on the
  // `hasClients` guard instead. Both pass with or without the real fix. What
  // is covered below is that the ticker mounts, runs and advances — which is
  // what caught the theme-extension and large-delta mistakes along the way.
  testWidgets('the tech ticker runs and advances', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: const Scaffold(body: TechTicker()),
      ),
    );

    final controller =
        tester.widget<ListView>(find.byType(ListView)).controller!;

    // Frame-sized steps on purpose: the ticker deliberately skips any tick
    // whose delta exceeds 100ms, since that means the tab was backgrounded.
    // One 300ms pump would be discarded by exactly that rule.
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 16));
    }

    expect(tester.takeException(), isNull);
    expect(controller.offset, greaterThan(0),
        reason: 'the strip should have drifted');
  });

  // Regression: Reveal used to listen for ScrollNotification from inside the
  // scroll view. Notifications bubble upwards from the Scrollable, so a
  // listener among its descendants never received one — everything below the
  // first viewport stayed at opacity 0 for the whole visit.
  testWidgets('a Reveal below the fold appears once scrolled into view',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 2000),
                Reveal(child: Text('below the fold')),
                SizedBox(height: 2000),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();

    final target = find.text('below the fold');
    expect(target, findsOneWidget);
    expect(_effectiveOpacity(tester, target), 0.0,
        reason: 'nothing off screen should be painted yet');

    await tester.drag(
        find.byType(SingleChildScrollView), const Offset(0, -2000));
    await tester.pump(); // settles the drag and schedules the visibility check
    await tester.pump(); // the check runs and starts the animation
    await tester.pump(Motion.slow);

    expect(_effectiveOpacity(tester, target), 1.0);
  });

  // Sections now run the full width of the viewport rather than sitting in a
  // 1180px column, so every row and grid inside them is laid out at a width it
  // was never previously given. Scrolling the whole page surfaces any overflow
  // as a test failure.
  for (final width in [420.0, 900.0, 1440.0, 1920.0]) {
    testWidgets('the whole page lays out and reveals at ${width.toInt()}px',
        (tester) async {
      tester.view.physicalSize = Size(width, 1080);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(const PortfolioApp());
      await tester.pump(const Duration(milliseconds: 100));

      // The page scroll view is the one inside the Scrollbar; the header has
      // its own horizontal scroller for the link strip.
      final position = tester
          .state<ScrollableState>(
            find
                .descendant(
                  of: find.byType(Scrollbar),
                  matching: find.byType(Scrollable),
                )
                .first,
          )
          .position;

      for (var y = 0.0; y <= position.maxScrollExtent; y += 400) {
        position.jumpTo(y);
        await tester.pump(); // runs the deferred visibility checks
        await tester.pump(const Duration(milliseconds: 700)); // finish reveals
      }

      // A section far down the page: proof the reveal chain survives the trip,
      // not just the first screenful.
      final deep = find.text(Profile.principles.first.title);
      expect(deep, findsOneWidget);
      expect(_effectiveOpacity(tester, deep), 1.0);
    });
  }

  group('content integrity', () {
    test('no placeholder content survives', () {
      final corpus = [
        Profile.headline,
        Profile.subheadline,
        Profile.summary,
        for (final e in Profile.experiences) ...[
          e.company,
          e.role,
          e.summary,
          ...e.achievements,
        ],
        for (final p in Profile.projects) ...[p.name, p.summary],
      ].join(' ').toLowerCase();

      // These are the strings the previous version of this site shipped.
      for (final banned in [
        'lorem ipsum',
        'example.com',
        'company name',
        'previous company',
        'tech solutions inc',
        'mobile innovations',
        'your name here',
        'todo',
        'coming soon',
      ]) {
        expect(corpus.contains(banned), isFalse,
            reason: 'placeholder "$banned" is still present');
      }
    });

    test('contact details are real', () {
      expect(Profile.email, contains('@'));
      expect(Profile.email, isNot(contains('example.com')));
      expect(Profile.githubUrl, startsWith('https://github.com/'));
      expect(Profile.linkedInUrl, startsWith('https://'));
    });

    test('every project tag maps to a declared filter', () {
      final facets = Profile.projectFilters.toSet();
      for (final p in Profile.projects) {
        expect(p.tags, isNotEmpty, reason: '${p.name} has no tags');
        for (final tag in p.tags) {
          expect(facets, contains(tag),
              reason: '${p.name} uses tag "$tag" with no matching filter');
        }
      }
    });

    test('every filter except All matches at least one project', () {
      for (final f in Profile.projectFilters.where((f) => f != 'All')) {
        expect(
          Profile.projects.any((p) => p.tags.contains(f)),
          isTrue,
          reason: 'filter "$f" would render an empty state',
        );
      }
    });

    test('skill levels are within range', () {
      for (final g in Profile.skillGroups) {
        expect(g.skills, isNotEmpty);
        for (final s in g.skills) {
          expect(s.level, inInclusiveRange(0.0, 1.0),
              reason: '${s.name} has level ${s.level}');
        }
      }
    });

    test('projects have substantive detail', () {
      for (final p in Profile.projects) {
        expect(p.stack, isNotEmpty, reason: '${p.name} lists no stack');
        expect(p.highlights, isNotEmpty,
            reason: '${p.name} lists no highlights');
        // A project with neither a link nor an explanation for its absence
        // reads as an unfinished card.
        expect(
          p.repoUrl != null || p.liveUrl != null || p.privateNote != null,
          isTrue,
          reason: '${p.name} has no link and no note explaining why',
        );
      }
    });

    test('flagship work is marked and non-empty', () {
      final flagship = Profile.projects.where((p) => p.isFlagship);
      expect(flagship, isNotEmpty);
      for (final p in flagship) {
        expect(p.kind, ProjectKind.professional);
        expect(p.metrics, isNotEmpty);
      }
    });

    test('principles are evidenced rather than asserted', () {
      for (final p in Profile.principles) {
        expect(p.evidence.trim(), isNotEmpty,
            reason: '"${p.title}" has no supporting evidence');
        expect(p.evidence.length, greaterThan(20));
      }
    });

    test('stats carry provenance', () {
      for (final s in Profile.stats) {
        expect(s.value, greaterThan(0));
        expect(s.detail.trim(), isNotEmpty,
            reason: '"${s.label}" is an unauditable number');
      }
    });
  });

  // A duplicate or malformed slug does not throw — it silently routes two
  // different documents to the same URL, or none. Only a test catches that.
  group('routing', () {
    test('project slugs are unique and URL-safe', () {
      final seen = <String>{};
      for (final p in Profile.projects) {
        expect(seen.add(p.slug), isTrue, reason: 'duplicate slug: ${p.slug}');
        expect(p.slug, matches(RegExp(r'^[a-z0-9-]+$')),
            reason: '"${p.slug}" is not a clean URL segment');
      }
    });

    test('note slugs are unique and URL-safe', () {
      final seen = <String>{};
      for (final n in Notes.all) {
        expect(seen.add(n.slug), isTrue, reason: 'duplicate slug: ${n.slug}');
        expect(n.slug, matches(RegExp(r'^[a-z0-9-]+$')));
      }
    });

    test('every store app case-study link resolves to a project', () {
      final slugs = Profile.projects.map((p) => p.slug).toSet();
      for (final app in Profile.storeApps) {
        if (app.caseStudy == null) continue;
        expect(slugs, contains(app.caseStudy),
            reason: '${app.name} points at a case study that does not exist');
      }
    });

    test('an unknown route falls back to the home page', () {
      final route = AppRouter.generate(
        const RouteSettings(name: '/work/does-not-exist'),
      );
      expect(route.settings.name, AppRouter.home);
    });

    test('known routes resolve to their own settings', () {
      final work = AppRouter.generate(
        RouteSettings(name: AppRouter.workPath(Profile.projects.first.slug)),
      );
      expect(work.settings.name, isNot(AppRouter.home));

      final note = AppRouter.generate(
        RouteSettings(name: AppRouter.notePath(Notes.all.first.slug)),
      );
      expect(note.settings.name, isNot(AppRouter.home));
    });
  });

  group('new content integrity', () {
    test('store apps state a real presence', () {
      for (final app in Profile.storeApps) {
        final hasStore = app.appStoreUrl != null || app.playStoreUrl != null;
        // An app with no listing must declare why — release-only work, or
        // enterprise distribution. Otherwise the card implies a store
        // presence a reader would go looking for and fail to find.
        expect(hasStore || app.releaseOnly || app.enterprise, isTrue,
            reason: '${app.name} claims a presence it cannot evidence');
        expect(app.role.trim(), isNotEmpty);
        // The inverse: never render a store badge for an app declared as
        // having no public listing.
        if (app.enterprise) {
          expect(hasStore, isFalse,
              reason: '${app.name} is enterprise but carries a store link');
        }
      }
    });

    test('api endpoints are well formed', () {
      for (final e in Profile.apiEndpoints) {
        expect(e.path, startsWith('/'));
        expect(e.status, inInclusiveRange(100, 599));
        expect(e.latencyMs, greaterThan(0));
        expect(e.note.trim(), isNotEmpty,
            reason: '${e.path} demonstrates nothing in particular');
        expect(() => jsonDecode(e.response), returnsNormally,
            reason: '${e.path} returns invalid JSON');
        if (e.requestBody != null) {
          expect(() => jsonDecode(e.requestBody!), returnsNormally,
              reason: '${e.path} sends invalid JSON');
        }
      }
    });

    test('notes have a body worth opening', () {
      for (final n in Notes.all) {
        expect(n.body, isNotEmpty);
        expect(n.readingMinutes, greaterThan(0));
        expect(n.tags, isNotEmpty);
        final prose = n.body
            .where((b) => b.kind == NoteBlockKind.paragraph)
            .fold<int>(0, (sum, b) => sum + b.text.length);
        expect(prose, greaterThan(400),
            reason: '"${n.title}" is too thin to publish');
      }
    });

    // The lens reorders content but must never drop or invent any: a
    // recruiter switching to their specialism should see the same body of
    // work rearranged, not a shorter page.
    test('every lens keeps the full body of work', () {
      for (final lens in Lens.values) {
        expect(Profile.projectsFor(lens).toSet(), Profile.projects.toSet(),
            reason: '${lens.slug} lens changed which projects exist');
        expect(Profile.skillGroupsFor(lens).toSet(),
            Profile.skillGroups.toSet(),
            reason: '${lens.slug} lens changed which skills exist');
        expect(Profile.statsFor(lens).toSet(), Profile.stats.toSet(),
            reason: '${lens.slug} lens changed which metrics exist');
      }
    });

    test('engagement content exists only for the freelance lens', () {
      // The data may exist; what matters is that nothing renders it outside
      // the freelance lens. That is enforced in home_page via
      // _SectionSpec.onlyFor, and asserted at the widget level below.
      expect(Profile.engagements, isNotEmpty);
      for (final e in Profile.engagements) {
        expect(e.deliverables.length, greaterThanOrEqualTo(3),
            reason: '"${e.title}" is vague about what a client receives');
        expect(e.pitch.length, greaterThan(40));
      }
      expect(Profile.workingAgreement, isNotEmpty);
    });

    test('each lens leads with its own specialism', () {
      expect(Profile.projectsFor(Lens.backend).first.slug, 'service-backend');
      expect(Profile.projectsFor(Lens.mobile).first.slug,
          'field-service-platform');
      expect(Profile.skillGroupsFor(Lens.backend).first.title, 'Backend');
      expect(Profile.skillGroupsFor(Lens.mobile).first.title, 'Mobile');
    });

    test('every lens names both disciplines', () {
      // The whole argument for this candidate is that he does both, so no
      // lens may hide the other half.
      for (final lens in Lens.values) {
        final copy =
            '${Profile.headlineFor(lens)} ${Profile.subheadlineFor(lens)}'
                .toLowerCase();
        expect(copy, contains('spring boot'),
            reason: '${lens.slug} lens never mentions Spring Boot');
        expect(copy, contains('flutter'),
            reason: '${lens.slug} lens never mentions Flutter');
      }
    });

    test('role aliases resolve to a sensible lens', () {
      expect(Lens.fromSlug('flutter'), Lens.mobile);
      expect(Lens.fromSlug('springboot'), Lens.backend);
      expect(Lens.fromSlug('java'), Lens.backend);
      expect(Lens.fromSlug('freelance'), Lens.freelance);
      expect(Lens.fromSlug('client'), Lens.freelance);
      expect(Lens.fromSlug('nonsense'), Lens.both);
      expect(Lens.fromSlug(null), Lens.both);
    });

    // The freelance lens exists to be handed to a client, never stumbled
    // into by a recruiter — engagement pricing on a CV reads as divided
    // attention, which is the impression the site is built to avoid.
    test('freelance is reachable only by link', () {
      expect(Lens.offered, isNot(contains(Lens.freelance)),
          reason: 'the switcher must not offer the freelance lens');
      expect(Lens.freelance.isHidden, isTrue);
      for (final lens in Lens.offered) {
        expect(lens.isHidden, isFalse);
      }
    });

    test('architecture nodes are explained', () {
      for (final layer in Profile.architectureLayers) {
        expect(layer.nodes, isNotEmpty);
        for (final node in layer.nodes) {
          expect(node.detail.trim(), isNotEmpty,
              reason: '${node.label} is an unlabelled box');
        }
      }
    });
  });
}
