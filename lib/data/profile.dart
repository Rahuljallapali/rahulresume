import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../app/lens.dart';
import 'models.dart';

/// The single source of truth for every word and number on this site.
///
/// Ground rules, deliberately enforced:
///  * Every metric below is countable from a repository. No estimates, no
///    rounded-up "10+ years" figures, no invented percentages.
///  * Employer is named; internal product names are not. Systems are described
///    by what they do, which is what an interviewer actually cares about.
///  * Nothing is claimed that could not survive a follow-up question.
///
/// Provenance for the numbers, so they can be re-verified later:
///   Spring backend    — 180 @RestController classes, 185 JPA entities,
///                       79 commits authored (git log --author=rahul)
///   Flutter platform  — 554 .dart files / 95,352 LOC, pubspec version 1.5.6+52
///   Commit share      — 540 of 727 commits on the mobile repo (74%)
///   Store presence    — Serveiz on App Store (id6470789389) & Google Play
///                       (com.swensa.serveiz); MIDC on Google Play
///                       (com.swensa.m1dc); DIMS released via App Store Connect
///   Crash-free users  — Firebase Crashlytics console: 98.9% at build 30 →
///                       99.7% at build 52 (read off by Rahul, Aug 2026)
///   Tenure            — joined Swensa Sept 2022 (4 years this Sept); the
///                       Flutter platform work starts at its first commit,
///                       2024-01-22, and is still active 2026-08
abstract final class Profile {
  static const name = 'Rahul Jallapalli';
  static const firstName = 'Rahul';
  static const lastName = 'Jallapalli';

  /// Backend named first, deliberately: the positioning is a Spring Boot
  /// engineer who also ships the Flutter apps on top of the service.
  static const title = 'Software Engineer — Java · Spring Boot · Flutter';

  static const location = 'Hyderabad, India';
  static const email = 'rahuljallapalli57@gmail.com';
  static const githubUser = 'rahuljallapalli';
  static const githubUrl = 'https://github.com/rahuljallapalli';
  static const linkedInUrl = 'https://www.linkedin.com/in/rahul-jallapalli';
  static const siteUrl = 'https://rahuljallapali.github.io/rahulresume';

  /// Headline. Concrete enough that a reader knows within one sentence what
  /// kind of engineer this is.
  ///
  /// Default (no lens chosen) leads with both halves, because a reader who
  /// has not told us which role they are hiring for should see the whole
  /// picture.
  static const headline =
      'I build Spring Boot backends that run a business — and ship the '
      'Flutter apps on top of them.';

  /// Per-lens headline. Each one leads with the specialism being hired for
  /// and *still* names the other — "he also builds the other half" is an
  /// argument for hiring him, not a distraction from it.
  static String headlineFor(Lens lens) => switch (lens) {
        Lens.both => headline,
        Lens.backend =>
          'I own the security-critical paths of a Spring Boot service that '
              'runs a field-service business.',
        Lens.mobile =>
          'I ship Flutter apps that keep working when the network does not.',
      };

  static String subheadlineFor(Lens lens) => switch (lens) {
        Lens.both => subheadline,
        Lens.backend =>
          'Java 21 / Spring Boot 3 across a multi-tenant service of 180 REST '
              'controllers and 185 JPA entities. I own the in-house Agora '
              'token signing, the de-duplicated push delivery and the OTP '
              'verification paths — and I also build the Flutter clients that '
              'consume them, so I design APIs knowing exactly what it costs '
              'to consume one badly.',
        Lens.mobile =>
          'Primary engineer on a 95,000-line Flutter platform shipped through '
              '52 releases to the App Store and Google Play: offline-first '
              'SQLite sync, real-time video with live annotation, CallKit and '
              'VoIP push, Google Maps tracking, on-device OCR. I write the '
              'Spring Boot endpoints behind it too, so I am never blocked '
              'waiting on someone else\'s API.',
      };

  /// The line in the availability pill.
  static String availabilityFor(Lens lens) => switch (lens) {
        Lens.both => availability,
        Lens.backend => 'Open to senior Java / Spring Boot roles',
        Lens.mobile => 'Open to senior Flutter / mobile roles',
      };

  /// Metric strip, ordered so the number that matters to this reader is first.
  static List<Stat> statsFor(Lens lens) => switch (lens) {
        Lens.both => stats,
        // stats = [backend systems, apps shipped, crash-free, commit share]
        Lens.backend => [stats[0], stats[1], stats[3], stats[2]],
        Lens.mobile => [stats[1], stats[2], stats[3], stats[0]],
      };

  /// Work, ordered so the flagship for this lens leads.
  static List<Project> projectsFor(Lens lens) {
    if (lens == Lens.both) return projects;
    final leadSlug =
        lens == Lens.backend ? 'service-backend' : 'field-service-platform';
    final lead = projects.where((p) => p.slug == leadSlug);
    final rest = projects.where((p) => p.slug != leadSlug);
    return [...lead, ...rest];
  }

  /// Skill groups, with the relevant discipline pulled to the front.
  static List<SkillGroup> skillGroupsFor(Lens lens) {
    if (lens == Lens.both) return skillGroups;
    final leadTitle = lens == Lens.backend ? 'Backend' : 'Mobile';
    final lead = skillGroups.where((g) => g.title == leadTitle);
    final rest = skillGroups.where((g) => g.title != leadTitle);
    return [...lead, ...rest];
  }

  /// Owned systems, not proximity counts. "180 controllers" appears only as
  /// context for where the owned paths live — a claim of breadth would not
  /// survive the follow-up question, and this page only says things that do.
  static const subheadline =
      'In a Java 21 / Spring Boot 3 multi-tenant service I own the real-time '
      'token-signing, push-delivery and OTP paths end to end — and I\'m '
      'primary engineer on the Flutter apps it powers, live on the App Store '
      'and Google Play. Secured APIs, offline-first sync, real-time video, '
      'GPS tracking, OCR pipelines.';

  /// Used in <meta name="description"> and the résumé PDF.
  static const summary =
      'Software engineer who owns the real-time token-signing, push-delivery '
      'and OTP verification paths of a Java 21 / Spring Boot 3 multi-tenant '
      'backend (180 REST controllers, 185 JPA entities, JWT security, Quartz '
      'scheduling, AWS S3/Textract pipelines, deployed as a Docker image on '
      'EC2), and holds production ownership of the 95,000-line Flutter '
      'field-service platform on top of it, shipped to the Apple App Store '
      'and Google Play. Real-time video with in-house Agora token signing, '
      'offline-first SQLite synchronisation, Google Maps live tracking and '
      'on-device OCR.';

  /// Recruiter-facing on purpose. This site is a résumé, not a services
  /// page — freelance framing reads as divided attention to a hiring manager.
  static const availability = 'Open to senior Spring Boot & Flutter roles';

  /// One human line under the name. Everything else on the page is evidence;
  /// this is the only sentence allowed to just be a person.
  static const bio =
      'Hyderabad-based; happiest when a system keeps working after the '
      'network gives up.';

  /// Shown in the footer status line.
  static const timezone = 'IST · UTC+5:30';

  // ---------------------------------------------------------------------------
  // Screening facts. A recruiter asks these before anything else; answering
  // them on the page removes a round-trip email from the process.
  //
  // The two below are empty until filled in — each row renders only when it
  // has a value, so nothing is ever asserted on Rahul's behalf.
  // ---------------------------------------------------------------------------

  /// Publishing a number invites spam calls; left blank deliberately until
  /// that trade-off is made knowingly.
  static const phone = '';

  /// The first question in almost every Indian recruiter screen.
  static const noticePeriod = '30 days';

  static const openToRelocation = 'Open to relocation and remote';

  /// Start at Swensa. Distinct from the mobile repository's first commit
  /// (2024-01-22) — that is when the Flutter platform work began, more than a
  /// year into the tenure.
  static final DateTime careerStart = DateTime(2022, 9);

  /// Derived rather than written down, so the figure cannot go stale between
  /// edits — the same reason the résumé PDF is generated from this file.
  static String get experience {
    final now = DateTime.now();
    var months =
        (now.year - careerStart.year) * 12 + (now.month - careerStart.month);
    if (now.day < careerStart.day) months--;
    if (months < 0) months = 0;

    final years = months ~/ 12;
    final rest = months % 12;
    final yearPart = years == 1 ? '1 year' : '$years years';
    if (rest == 0) return yearPart;
    final monthPart = rest == 1 ? '1 month' : '$rest months';
    return years == 0 ? monthPart : '$yearPart $monthPart';
  }

  static const socials = <SocialLink>[
    SocialLink(
      label: 'GitHub',
      url: githubUrl,
      icon: FontAwesomeIcons.github,
      handle: '@rahuljallapalli',
    ),
    SocialLink(
      label: 'LinkedIn',
      url: linkedInUrl,
      icon: FontAwesomeIcons.linkedinIn,
      handle: 'rahul-jallapalli',
    ),
    SocialLink(
      label: 'Email',
      url: 'mailto:$email',
      icon: Icons.alternate_email_rounded,
      handle: email,
    ),
  ];

  // ---------------------------------------------------------------------------
  // Headline metrics
  // ---------------------------------------------------------------------------

  static const stats = <Stat>[
    Stat(
      value: 3,
      label: 'Backend systems owned end to end',
      detail: 'Agora token signing · FCM de-duplication · OTP verification — '
          'inside a 180-controller Spring Boot 3 service',
    ),
    Stat(
      value: 4,
      label: 'Apps shipped to users',
      detail: 'Serveiz & MIDC on public stores; DIMS through App Store '
          'review; NNIMS distributed internally',
    ),
    // The one outcome number on the strip: what the users got, not what was
    // typed. Counter animates to 99, the suffix carries the decimal.
    Stat(
      value: 99,
      suffix: '.7%',
      label: 'Crash-free users on the current build',
      detail: 'Up from 98.9% at build 30 — Firebase Crashlytics, builds 30→52',
    ),
    Stat(
      value: 74,
      suffix: '%',
      label: 'Share of mobile commits',
      detail: '540 of 727 commits — largest contributor on the repository',
    ),
  ];

  // ---------------------------------------------------------------------------
  // Experience — only verifiable roles. No prior positions are asserted.
  // ---------------------------------------------------------------------------

  static const experiences = <Experience>[
    Experience(
      role: 'Software Engineer',
      company: 'Swensa',
      period: 'Sept 2022 — Present',
      location: 'Hyderabad, India',
      isCurrent: true,
      summary:
          'Engineer across the company\'s Java 21 / Spring Boot 3 multi-tenant '
          'backend and principal engineer on the Flutter field-service apps it '
          'powers. Work runs end to end: schema and REST endpoint through to '
          'the screen a technician taps in the field — and on to the App '
          'Store listing it ships under.',
      achievements: [
        'Own three backend systems end to end in the Java 21 / Spring Boot '
            '3.2 service: the in-house Agora RTC/RTM token-signing service, '
            'Firebase Cloud Messaging delivery with its de-duplication '
            'table, and OTP verification through the MIDC SMS gateway — '
            'plus endpoints, JPA entities and multi-language support across '
            '79 commits in a 180-controller, 185-entity codebase.',
        'Own the Serveiz Flutter client end to end — 554 Dart files, ~95k '
            'lines, shipped through 52 production builds to the Apple App '
            'Store and Google Play. Authored 540 of the repository\'s 727 '
            'commits.',
        'Contribute to MIDC, the healthcare field app serving Metro '
            'Infectious Disease Consultants\' 100+ physicians, backed by the '
            'same Spring Boot platform — including OTP verification through '
            'the MIDC SMS gateway.',
        'Build NNIMS, a Bluetooth Low Energy beacon-scanning app, across '
            'both ends — native iOS and Android BLE bridged into the Flutter '
            'client through platform channels, and the Spring Boot endpoints '
            'that ingest the readings. Distributed internally rather than '
            'through a public store.',
        'Run iOS release engineering for the product line: signing, '
            'provisioning, TestFlight and App Store review — including '
            'carrying the DIMS app through App Store submission end to end.',
        'Built real-time video assistance so a remote expert can see a '
            'technician\'s camera and draw on the live feed: Agora RTC with '
            'RTC/RTM tokens signed server-side, native full-screen incoming '
            'call UI via CallKit, and APNs VoIP push so calls land on a '
            'locked iPhone.',
        'Designed the offline-first data layer on SQLite so work orders, '
            'captured photos and signatures survive a total loss of '
            'connectivity and reconcile when the device comes back online.',
        'Shipped live GPS tracking and route rendering with Google Maps, '
            'geolocation, polyline decoding and reverse geocoding for '
            'technician dispatch.',
        'Integrated on-device Tesseract OCR and barcode scanning for asset '
            'and inventory capture, with client-side image and video '
            'compression to keep uploads viable on weak mobile networks.',
        'Built the localisation pipeline — English and Spanish ARB catalogues '
            'plus a Python generator that folds server-delivered strings into '
            'the app, so copy changes ship without a store release.',
        'Wrote the integration test suite covering task, work-order and '
            'inventory flows against a real device via Flutter integration_test.',
        'Instrumented the app with Crashlytics and Analytics and worked the '
            'crash signal down release over release: crash-free users rose '
            'from 98.9% at build 30 to 99.7% at build 52, with the '
            'notification and call-handling fixes found through it.',
      ],
      stack: [
        'Java 21',
        'Spring Boot 3',
        'MySQL',
        'JPA / Hibernate',
        'Flutter',
        'Dart',
        'SQLite',
        'Agora RTC',
        'Firebase',
        'Google Maps',
        'AWS S3',
        'Docker',
      ],
    ),
  ];

  // ---------------------------------------------------------------------------
  // Projects
  // ---------------------------------------------------------------------------

  static const projectFilters = <String>[
    'All',
    'Mobile',
    'Backend',
    'Real-time',
    'Cloud & DevOps',
    'AI',
  ];

  static const projects = <Project>[
    Project(
      slug: 'service-backend',
      name: 'Multi-Tenant Service Backend',
      role: 'Backend engineer · Swensa',
      kind: ProjectKind.professional,
      isFlagship: true,
      summary: 'Java 21 / Spring Boot 3.2 service backing the field platform: '
          'work-order lifecycle, inventory, scheduling, document generation, '
          'payments and push delivery across multiple customer tenants. My '
          'owned paths within it: real-time token signing, push delivery '
          'with de-duplication, and OTP verification.',
      tags: ['Backend', 'Cloud & DevOps'],
      stack: [
        'Java 21',
        'Spring Boot 3.2',
        'Spring Security',
        'JWT',
        'JPA / Hibernate',
        'MySQL',
        'Quartz',
        'MapStruct',
        'Caffeine',
        'AWS S3',
        'AWS Textract',
        'Stripe',
        'OpenAPI',
      ],
      architecture:
          'Layered controller → service → repository with MapStruct DTO '
          'mapping and Lombok. Stateless JWT auth via a request filter over '
          'Spring Security, with OAuth2 resource-server support and Authy '
          'two-factor. Caffeine caches hot reference data. Quartz drives '
          'scheduled inventory and job processing. Cross-cutting audit '
          'logging is applied with a Spring AOP aspect rather than scattered '
          'call sites, and email is dispatched through an application event '
          'listener so request threads never block on SMTP.',
      challenge:
          'A single deployment serves many customer tenants with different '
          'templates, attribute schemas and locales, so nearly every entity '
          'is tenant-scoped and the query layer has to enforce that '
          'consistently.',
      highlights: [
        ProjectHighlight(
          title: 'Breadth',
          body: '180 REST controllers over 185 JPA entities, documented with '
              'springdoc OpenAPI and exposed through Swagger UI.',
        ),
        ProjectHighlight(
          title: 'Security',
          body: 'Stateless JWT filter, Spring Security configuration, OAuth2 '
              'resource server and Authy-based two-factor authentication.',
        ),
        ProjectHighlight(
          title: 'In-house real-time token signing',
          body: 'Agora RTC and RTM access tokens built and signed inside the '
              'service — no third-party token broker in the trust path.',
        ),
        ProjectHighlight(
          title: 'Document and media pipeline',
          body:
              'AWS S3 storage with Textract OCR, plus Apache POI spreadsheets, '
              'iText PDFs and zip4j archives for customer exports.',
        ),
        ProjectHighlight(
          title: 'Reliable push delivery',
          body: 'Firebase Admin FCM with a dedicated de-duplication table, and '
              'a separate APNs VoIP path so incoming calls reach locked iOS '
              'devices.',
        ),
        ProjectHighlight(
          title: 'Scheduled work',
          body: 'Quartz-driven jobs for recurring inventory and forecast '
              'processing, with cron expressions parsed by cron-utils.',
        ),
      ],
      metrics: [
        Stat(
            value: 180,
            label: 'REST controllers',
            detail: 'across the service'),
        Stat(value: 185, label: 'JPA entities', detail: 'tenant-scoped domain'),
        Stat(value: 21, label: 'Java version', detail: 'Spring Boot 3.2.5'),
      ],
      privateNote: 'Private repository — architecture discussion welcome.',
    ),
    Project(
      slug: 'field-service-platform',
      name: 'Field-Service Mobile Platform',
      role: 'Lead engineer · Swensa',
      kind: ProjectKind.professional,
      isFlagship: true,
      summary:
          'Cross-platform application used by field technicians to run work '
          'orders, capture evidence, track inventory and call for remote '
          'expert help. Built to stay useful when the network is not.',
      tags: ['Mobile', 'Real-time'],
      stack: [
        'Flutter',
        'Dart',
        'GetX',
        'SQLite',
        'Dio',
        'Agora RTC',
        'Google Maps',
        'Firebase',
        'Tesseract OCR',
      ],
      architecture:
          'Feature-sliced modules (tasks, inventory, video call, survey, '
          'notifications, transaction files), each with its own controller, '
          'service and model layer. A shared SQLite helper backs the offline '
          'cache; Dio handles transport with a single interceptor chain; GetX '
          'carries reactive state and routing.',
      challenge:
          'Technicians work in basements, lift shafts and rural sites where '
          'connectivity disappears mid-job. Every capture path — photos, '
          'signatures, meter readings, status changes — had to be durable '
          'locally and reconcilable later, without asking the user to think '
          'about sync at all.',
      highlights: [
        ProjectHighlight(
          title: 'Remote video assistance with live annotation',
          body: 'Agora RTC video with a drawing layer over the stream, so an '
              'expert can circle the exact valve a technician is looking at. '
              'Native full-screen call UI through CallKit and APNs VoIP push '
              'so a call rings on a locked device.',
        ),
        ProjectHighlight(
          title: 'Offline-first persistence',
          body: 'SQLite-backed local store with a bundled seed database. Work '
              'continues uninterrupted through total connectivity loss and '
              'reconciles on reconnect.',
        ),
        ProjectHighlight(
          title: 'Live tracking and dispatch',
          body: 'Google Maps with continuous geolocation, decoded polyline '
              'routes, custom info windows, place search and reverse '
              'geocoding.',
        ),
        ProjectHighlight(
          title: 'Capture pipeline',
          body:
              'Camera, gallery, barcode scanning and on-device Tesseract OCR, '
              'with EXIF preservation plus image and video compression tuned '
              'for low-bandwidth uploads.',
        ),
        ProjectHighlight(
          title: 'Runtime localisation',
          body: 'English and Spanish ARB catalogues plus server-delivered '
              'strings merged by a Python code generator — copy ships without '
              'an app-store release.',
        ),
        ProjectHighlight(
          title: 'Verified on real devices',
          body: 'Integration test suites drive task, work-order, inventory and '
              'settings journeys end to end through Flutter integration_test.',
        ),
      ],
      metrics: [
        Stat(
          value: 95,
          suffix: 'k',
          label: 'lines of Dart',
          detail: '95,352 across 554 files',
        ),
        Stat(value: 52, label: 'production builds', detail: 'version 1.5.6+52'),
        Stat(
          value: 99,
          suffix: '.7%',
          label: 'crash-free users',
          detail: 'up from 98.9% at build 30 (Crashlytics)',
        ),
        Stat(
            value: 8, label: 'feature modules', detail: 'independently scoped'),
      ],
      privateNote: 'Private repository — happy to walk through the '
          'architecture in an interview.',
    ),
    Project(
      slug: 'nl-data-assistant',
      name: 'Natural-Language Data Assistant',
      role: 'Backend integration · Swensa',
      kind: ProjectKind.professional,
      summary:
          'A question-answering endpoint that lets operations staff ask about '
          'their own service data in plain English instead of waiting on a '
          'custom report.',
      tags: ['AI', 'Backend'],
      stack: ['Spring Boot', 'REST', 'Python (Flask)', 'Tenant scoping'],
      architecture:
          'The Spring service exposes a POST endpoint that composes the '
          'question with the resolved tenant identifier and pagination bounds, '
          'then delegates to a Python inference service over HTTP through a '
          'configured RestTemplate. Every hop carries a generated request id '
          'so a single question can be traced across both services, and '
          'inference failures degrade to a handled error rather than a 500.',
      challenge: 'Tenant isolation cannot be left to the model. The customer '
          'identifier is injected server-side from the authenticated context '
          'rather than accepted from the client, so a crafted question cannot '
          'reach another tenant\'s rows.',
      highlights: [
        ProjectHighlight(
          title: 'Server-enforced tenant boundary',
          body: 'Customer scope is resolved from application context, never '
              'from the request body — the model cannot be prompted across '
              'the boundary.',
        ),
        ProjectHighlight(
          title: 'Cross-service tracing',
          body: 'A generated request id is logged at every stage so a question '
              'can be followed from HTTP entry through inference and back.',
        ),
        ProjectHighlight(
          title: 'Isolated inference tier',
          body:
              'The Python service is addressed through injected configuration, '
              'so it can move or scale without touching the Java service.',
        ),
      ],
      privateNote: 'Private repository.',
    ),
    Project(
      slug: 'this-portfolio',
      name: 'This Portfolio',
      role: 'Personal project',
      kind: ProjectKind.personal,
      summary:
          'Built in Flutter web rather than a JavaScript framework — the site '
          'is itself a sample of the toolchain the rest of this page talks '
          'about. Custom design system, no UI kit, no template.',
      tags: ['Mobile', 'Cloud & DevOps'],
      stack: [
        'Flutter Web',
        'Dart',
        'Provider',
        'CustomPainter',
        'GitHub Pages'
      ],
      architecture:
          'One content file drives everything: the rendered page, the command '
          'palette index and the downloadable résumé PDF are all generated '
          'from the same immutable models, so the document can never contradict '
          'the site. Theme state is a ChangeNotifier persisted to '
          'localStorage; scroll reveals are driven off a single scroll '
          'controller rather than per-widget listeners.',
      highlights: [
        ProjectHighlight(
          title: 'Résumé generated from source',
          body: 'The downloadable PDF is composed at runtime from the same '
              'profile data the page renders — one edit updates both.',
        ),
        ProjectHighlight(
          title: 'Command palette',
          body: 'Ctrl/⌘K opens fuzzy navigation and actions, keyboard-driven '
              'throughout.',
        ),
        ProjectHighlight(
          title: 'Accessible by construction',
          body:
              'Semantic labels on interactive elements, visible focus, honours '
              'reduced-motion, and AA contrast in both themes.',
        ),
      ],
      repoUrl: 'https://github.com/rahuljallapalli/rahulresume',
      liveUrl: siteUrl,
    ),
  ];

  /// Marquee strip under the hero. Order mirrors the positioning: backend
  /// first, then mobile, then the infrastructure both sit on.
  static const ticker = <String>[
    'Java 21',
    'Spring Boot 3',
    'Spring Security',
    'JPA / Hibernate',
    'MySQL',
    'Quartz',
    'REST · OpenAPI',
    'Flutter',
    'Dart',
    'SQLite',
    'Agora RTC',
    'Firebase',
    'Google Maps',
    'Docker',
    'AWS S3',
    'AWS Textract',
    'Tesseract OCR',
    'Stripe',
  ];

  // ---------------------------------------------------------------------------
  // Apps with a public store presence. Listings verified 2026-08; roles state
  // the honest boundary of the contribution — DIMS in particular was release
  // engineering, not feature work, and says so.
  // ---------------------------------------------------------------------------

  static const storeApps = <StoreApp>[
    StoreApp(
      name: 'Serveiz',
      tagline: 'Field-service operations, end to end',
      description:
          'Work orders, inventory, assets, documentation and billing for '
          'service companies — with live GPS tracking, photo evidence, '
          'remote video assistance and offline capture. I build both sides: '
          'the Flutter client and the Spring Boot service behind it.',
      role: 'Primary engineer — 540 of 727 commits, 52 store builds',
      accent: Color(0xFF3B6FE8),
      caseStudy: 'field-service-platform',
      appStoreUrl: 'https://apps.apple.com/in/app/serveiz/id6470789389',
      playStoreUrl:
          'https://play.google.com/store/apps/details?id=com.swensa.serveiz',
      stack: ['Flutter', 'Spring Boot', 'SQLite', 'Agora RTC', 'Google Maps'],
    ),
    StoreApp(
      name: 'MIDC',
      tagline: 'Healthcare field operations',
      description:
          'App for Metro Infectious Disease Consultants — 100+ physicians '
          'across multiple US states. Runs on the same Spring Boot platform; '
          'my backend work includes the OTP verification flow through the '
          'MIDC SMS gateway.',
      role: 'Backend & mobile contributor',
      accent: Color(0xFF0E9C94),
      playStoreUrl:
          'https://play.google.com/store/apps/details?id=com.swensa.m1dc',
      stack: ['Flutter', 'Spring Boot', 'MySQL', 'FCM'],
    ),
    StoreApp(
      name: 'DIMS',
      tagline: 'iOS release engineering',
      description:
          'An app I did not write — and shipped anyway. Owned the entire '
          'path to the App Store: signing certificates, provisioning '
          'profiles, build archiving, TestFlight distribution and App Store '
          'review, through to a live listing.',
      role: 'Release engineer — App Store submission end to end',
      accent: Color(0xFF8B5CF6),
      releaseOnly: true,
      mock: AppMock.release,
      stack: ['Xcode', 'TestFlight', 'App Store Connect', 'Code signing'],
    ),
    StoreApp(
      name: 'NNIMS',
      tagline: 'Bluetooth beacon scanning',
      description:
          'Mobile application that scans for Bluetooth Low Energy beacons to '
          'detect what is nearby, bridging the native iOS and Android BLE '
          'APIs into a Flutter client through platform channels and reporting '
          'readings back to the Spring Boot platform. I work on both ends — '
          'the scanning client and the service that ingests it.',
      role: 'Backend and mobile engineer',
      accent: Color(0xFFE0872C),
      enterprise: true,
      mock: AppMock.beacon,
      stack: [
        'Flutter',
        'Dart',
        'Native BLE',
        'Platform channels',
        'Spring Boot'
      ],
    ),
  ];

  // ---------------------------------------------------------------------------
  // Skills. Levels are coarse on purpose — four honest bands.
  //   1.00 daily production ownership
  //   0.80 shipped substantial features
  //   0.60 used in production, not primary
  //   0.40 working familiarity
  // ---------------------------------------------------------------------------

  static const skillGroups = <SkillGroup>[
    SkillGroup(
      title: 'Languages',
      icon: Icons.code_rounded,
      skills: [
        Skill(name: 'Java', level: 0.8, evidence: 'Java 21, Spring Boot 3'),
        Skill(name: 'Dart', level: 1.0, evidence: '95k lines in production'),
        Skill(
            name: 'SQL', level: 0.8, evidence: 'MySQL schema and JPA queries'),
        Skill(
            name: 'Python',
            level: 0.6,
            evidence: 'localisation codegen, OCR tooling'),
        Skill(
            name: 'Bash',
            level: 0.6,
            evidence: 'container and deploy scripting'),
        Skill(
            name: 'Kotlin / Swift', level: 0.4, evidence: 'platform channels'),
      ],
    ),
    SkillGroup(
      title: 'Backend',
      icon: Icons.dns_rounded,
      skills: [
        Skill(name: 'Spring Boot 3', level: 0.8, evidence: '180 controllers'),
        Skill(
            name: 'Spring Security',
            level: 0.8,
            evidence: 'JWT + OAuth2 resource server'),
        Skill(name: 'JPA / Hibernate', level: 0.8, evidence: '185 entities'),
        Skill(
            name: 'REST API design',
            level: 0.8,
            evidence: 'documented with OpenAPI'),
        Skill(name: 'Quartz scheduling', level: 0.6),
        Skill(name: 'MapStruct', level: 0.6),
      ],
    ),
    SkillGroup(
      title: 'Mobile',
      icon: Icons.phone_iphone_rounded,
      skills: [
        Skill(
            name: 'Flutter',
            level: 1.0,
            evidence: 'primary platform, 52 releases'),
        Skill(name: 'GetX', level: 0.8, evidence: 'state and routing at scale'),
        Skill(name: 'Provider', level: 0.8),
        Skill(
            name: 'Offline-first sync',
            level: 0.8,
            evidence: 'SQLite reconciliation'),
        Skill(
            name: 'Platform channels',
            level: 0.6,
            evidence: 'CallKit, VoIP push, native BLE'),
        Skill(
            name: 'Bluetooth LE',
            level: 0.6,
            evidence: 'beacon scanning on both platforms'),
        Skill(name: 'Flutter Web', level: 0.6, evidence: 'this site'),
      ],
    ),
    SkillGroup(
      title: 'Data',
      icon: Icons.storage_rounded,
      skills: [
        Skill(name: 'MySQL', level: 0.8, evidence: 'multi-tenant schema'),
        Skill(name: 'SQLite', level: 1.0, evidence: 'on-device offline store'),
        Skill(name: 'Caffeine cache', level: 0.6),
        Skill(name: 'Firebase Realtime / FCM', level: 0.8),
      ],
    ),
    SkillGroup(
      title: 'Cloud & DevOps',
      icon: Icons.cloud_rounded,
      skills: [
        Skill(
            name: 'Docker',
            level: 0.8,
            evidence: 'layer-ordered production image'),
        Skill(
            name: 'AWS S3', level: 0.8, evidence: 'media and document storage'),
        Skill(name: 'AWS Textract', level: 0.6, evidence: 'server-side OCR'),
        Skill(
            name: 'AWS EC2',
            level: 0.6,
            evidence: 'container deployment target'),
        Skill(
            name: 'Firebase Crashlytics', level: 0.8, evidence: 'crash triage'),
        Skill(
            name: 'CI/CD pipelines', level: 0.4, evidence: 'actively learning'),
      ],
    ),
    SkillGroup(
      title: 'Real-time & Media',
      icon: Icons.videocam_rounded,
      skills: [
        Skill(
            name: 'Agora RTC',
            level: 0.8,
            evidence: 'video with live annotation'),
        Skill(
            name: 'Push / FCM + APNs VoIP',
            level: 0.8,
            evidence: 'locked-device call delivery'),
        Skill(
            name: 'Google Maps',
            level: 0.8,
            evidence: 'live tracking and routing'),
        Skill(name: 'Tesseract OCR', level: 0.6, evidence: 'on-device capture'),
        Skill(
            name: 'Media compression',
            level: 0.6,
            evidence: 'low-bandwidth upload'),
      ],
    ),
    SkillGroup(
      title: 'Testing & Quality',
      icon: Icons.verified_rounded,
      skills: [
        Skill(
            name: 'Flutter integration_test',
            level: 0.8,
            evidence: 'device-level journeys'),
        Skill(name: 'JUnit 5', level: 0.6, evidence: 'backend report engine'),
        Skill(name: 'Widget testing', level: 0.6),
        Skill(
            name: 'Code review',
            level: 0.8,
            evidence: 'multi-contributor repositories'),
      ],
    ),
    SkillGroup(
      title: 'Tools',
      icon: Icons.build_rounded,
      skills: [
        Skill(
            name: 'Git', level: 1.0, evidence: '600+ commits across two repos'),
        Skill(name: 'Android Studio / VS Code', level: 1.0),
        Skill(name: 'Postman / Swagger UI', level: 0.8),
        Skill(name: 'Maven / Gradle', level: 0.8),
        Skill(name: 'Figma', level: 0.6),
      ],
    ),
  ];

  // ---------------------------------------------------------------------------
  // Architecture — the real request path through the Spring Boot service.
  // Every node corresponds to something that exists in the repository.
  // ---------------------------------------------------------------------------

  static const architectureLayers = <ArchLayer>[
    ArchLayer(
      title: 'Clients',
      icon: Icons.phone_iphone_rounded,
      nodes: [
        ArchNode(
          label: 'Flutter app',
          detail: 'iOS & Android, offline-first SQLite cache',
          badge: 'Dart',
        ),
        ArchNode(
          label: 'Dio interceptors',
          detail: 'Auth header, retry, correlation id',
        ),
      ],
    ),
    ArchLayer(
      title: 'Edge',
      icon: Icons.shield_rounded,
      nodes: [
        ArchNode(
          label: 'JWT filter',
          detail: 'Stateless auth ahead of the controller layer',
          badge: 'Spring Security',
        ),
        ArchNode(
          label: 'Tenant resolution',
          detail: 'Customer scope read from the token, never the body',
        ),
      ],
    ),
    ArchLayer(
      title: 'API',
      icon: Icons.api_rounded,
      nodes: [
        ArchNode(
          label: 'REST controllers',
          detail: 'Work orders, inventory, scheduling, billing',
          badge: '180',
        ),
        ArchNode(
          label: 'OpenAPI',
          detail: 'springdoc contract, browsable in Swagger UI',
        ),
      ],
    ),
    ArchLayer(
      title: 'Domain',
      icon: Icons.settings_suggest_rounded,
      nodes: [
        ArchNode(
          label: 'Services',
          detail: 'Business rules, MapStruct DTO mapping',
        ),
        ArchNode(
          label: 'AOP audit aspect',
          detail: 'Cross-cutting audit trail in one place',
        ),
        ArchNode(
          label: 'Quartz jobs',
          detail: 'Recurring inventory and forecast processing',
        ),
      ],
    ),
    ArchLayer(
      title: 'Data & fan-out',
      icon: Icons.storage_rounded,
      nodes: [
        ArchNode(
          label: 'MySQL via JPA',
          detail: 'Tenant-scoped relational domain',
          badge: '185 entities',
        ),
        ArchNode(
          label: 'S3 + Textract',
          detail: 'Document storage and server-side OCR',
        ),
        ArchNode(
          label: 'FCM / APNs VoIP',
          detail: 'De-duplicated push; calls reach locked devices',
        ),
        ArchNode(
          label: 'Agora token service',
          detail: 'RTC/RTM tokens signed in-process',
        ),
      ],
    ),
  ];

  static const architectureNote =
      'A request carries its tenant from the token to the query. Nothing '
      'downstream of the filter trusts the client for identity — which is what '
      'makes one deployment safe to share across customers.';

  // ---------------------------------------------------------------------------
  // API playground. Canned responses: a portfolio must not depend on a server
  // that could be down when a recruiter opens it. Shapes mirror the real API.
  // ---------------------------------------------------------------------------

  static const apiEndpoints = <ApiEndpoint>[
    ApiEndpoint(
      method: 'GET',
      path: '/api/v1/workorders?status=OPEN&page=0',
      summary: 'List open work orders for the caller\'s tenant',
      note: 'The tenant filter is not a query parameter. It is resolved from '
          'the JWT server-side, so no client can page through another '
          'customer\'s rows by editing a URL.',
      status: 200,
      latencyMs: 180,
      response: '''{
  "page": 0,
  "size": 20,
  "totalElements": 47,
  "content": [
    {
      "id": 10482,
      "reference": "WO-2026-10482",
      "status": "OPEN",
      "priority": "HIGH",
      "site": { "id": 314, "name": "Northgate Plant" },
      "assignedTo": { "id": 88, "name": "M. Okafor" },
      "scheduledFor": "2026-08-18T09:00:00Z",
      "slaBreachesAt": "2026-08-18T17:00:00Z"
    },
    {
      "id": 10483,
      "reference": "WO-2026-10483",
      "status": "OPEN",
      "priority": "NORMAL",
      "site": { "id": 92, "name": "Harbour Depot" },
      "assignedTo": null,
      "scheduledFor": "2026-08-19T13:30:00Z",
      "slaBreachesAt": null
    }
  ]
}''',
    ),
    ApiEndpoint(
      method: 'POST',
      path: '/api/v1/workorders/10482/complete',
      summary: 'Close a work order with field-captured evidence',
      note: 'The capture ids were created offline on the device. The endpoint '
          'accepts them by reference, so a technician in a basement completes '
          'the job locally and the server reconciles it later.',
      status: 200,
      latencyMs: 260,
      requestBody: '''{
  "completedAt": "2026-08-17T14:22:03Z",
  "notes": "Replaced pressure valve, system re-tested.",
  "captureIds": ["cap_7f21", "cap_7f22"],
  "signatureId": "sig_a91c",
  "partsUsed": [{ "sku": "VLV-204", "qty": 1 }]
}''',
      response: '''{
  "id": 10482,
  "status": "COMPLETED",
  "completedAt": "2026-08-17T14:22:03Z",
  "invoice": { "id": 55019, "state": "DRAFT", "total": 412.50 },
  "inventoryAdjustments": [
    { "sku": "VLV-204", "delta": -1, "onHand": 23 }
  ],
  "notificationsQueued": 2
}''',
    ),
    ApiEndpoint(
      method: 'POST',
      path: '/api/v1/rtc/token',
      summary: 'Mint an Agora RTC token for a support call',
      note: 'Signed inside the service with the app certificate, not fetched '
          'from a third-party broker. No external party sits in the trust path '
          'for a call between a technician and an expert.',
      status: 201,
      latencyMs: 95,
      requestBody: '''{
  "channel": "wo-10482-assist",
  "uid": 88,
  "role": "PUBLISHER",
  "ttlSeconds": 3600
}''',
      response: '''{
  "rtcToken": "006a1b2c3d…<signed, truncated>",
  "rtmToken": "006f9e8d7c…<signed, truncated>",
  "channel": "wo-10482-assist",
  "expiresAt": "2026-08-17T15:22:03Z",
  "issuedBy": "in-service signer"
}''',
    ),
    ApiEndpoint(
      method: 'GET',
      path: '/api/v1/inventory/VLV-204',
      summary: 'Read stock for a part across warehouses',
      note: 'Reference data like this is read constantly and changes slowly, '
          'so it sits behind a Caffeine cache. The response carries the cache '
          'state rather than hiding it.',
      status: 200,
      latencyMs: 40,
      response: '''{
  "sku": "VLV-204",
  "description": "Pressure relief valve, 2 in.",
  "onHand": 23,
  "reserved": 4,
  "available": 19,
  "reorderPoint": 10,
  "locations": [
    { "warehouse": "HYD-1", "qty": 15 },
    { "warehouse": "VAN-2", "qty": 8 }
  ],
  "cache": { "hit": true, "source": "caffeine" }
}''',
    ),
    ApiEndpoint(
      method: 'POST',
      path: '/api/v1/assistant/query',
      summary: 'Ask a question about your own service data',
      note: 'Spring composes the question with the resolved tenant id and a '
          'request id, then delegates to a Python inference tier. One '
          'identifier follows the question across both runtimes.',
      status: 200,
      latencyMs: 820,
      requestBody: '''{
  "question": "Which sites breached SLA more than twice last month?",
  "limit": 5
}''',
      response: '''{
  "requestId": "req_2f8c41ab",
  "answer": "Three sites breached SLA more than twice in July 2026.",
  "rows": [
    { "site": "Northgate Plant", "breaches": 5 },
    { "site": "Harbour Depot",  "breaches": 3 },
    { "site": "Cedar Works",    "breaches": 3 }
  ],
  "tenantScope": "resolved-server-side",
  "inferenceMs": 640
}''',
    ),
  ];

  // ---------------------------------------------------------------------------
  // Live activity
  // ---------------------------------------------------------------------------

  /// Framing for the GitHub card. This is the work account — the one the
  /// Spring Boot service and the Flutter platform are actually committed to —
  /// and those repositories are private. Saying so is better than letting a
  /// visitor draw the wrong conclusion from a quiet public graph.
  static const activityNote =
      'This is my work GitHub account — the one the Spring Boot service and '
      'the Flutter platform on this page are committed to. Those repositories '
      'are private, so the public graph shows none of the 619 commits behind '
      'the work described above. Happy to walk through any of it live.';

  /// Stamped at build time via `--dart-define=BUILD_DATE=YYYY-MM-DD`. The
  /// fallback is the date of the last manual release.
  static const buildDate =
      String.fromEnvironment('BUILD_DATE', defaultValue: '2026-08-17');

  // ---------------------------------------------------------------------------
  // Deployment. Only what is demonstrably in the repositories — the container
  // image and its AWS integrations. No CI/CD orchestration is claimed.
  // ---------------------------------------------------------------------------

  static const deliveryStages = <PipelineStage>[
    PipelineStage(
      label: 'Build',
      detail: 'Maven package on JDK 21 producing an executable Spring Boot jar',
      icon: Icons.terminal_rounded,
    ),
    PipelineStage(
      label: 'Containerise',
      detail:
          'eclipse-temurin:21-jre base with system packages, AWS CLI and Python '
          'OCR libraries installed in earlier layers — the jar is copied last '
          'so a code change rebuilds one thin layer, not the toolchain',
      icon: FontAwesomeIcons.docker,
    ),
    PipelineStage(
      label: 'Configure',
      detail: 'Profile-scoped YAML — the production profile is selected at '
          'container entrypoint, so no environment secrets are baked into the '
          'image',
      icon: Icons.tune_rounded,
    ),
    PipelineStage(
      label: 'Deploy',
      detail: 'Container runs on AWS EC2 exposing the service port',
      icon: FontAwesomeIcons.aws,
    ),
    PipelineStage(
      label: 'Observe',
      detail: 'Spring Boot Actuator on the service, Firebase Crashlytics and '
          'Analytics on the client, and correlation ids in application logs',
      icon: Icons.monitor_heart_rounded,
    ),
  ];

  static const devOpsNote =
      'Honest scope: I own the container image and its AWS integrations, and '
      'deploy them. I have not yet built the CI orchestration around it — '
      'automating this pipeline is what I am actively working on next.';

  // ---------------------------------------------------------------------------
  // Engineering principles — each one anchored to something shipped.
  // ---------------------------------------------------------------------------

  static const principles = <Principle>[
    Principle(
      icon: Icons.wifi_off_rounded,
      title: 'Design for the worst network, not the demo',
      body: 'Connectivity is a feature that fails. State belongs on the device '
          'first and reconciles later, so the user never waits on a spinner '
          'they cannot resolve.',
      evidence:
          'SQLite-backed capture that survives total connectivity loss in the '
          'field app.',
    ),
    Principle(
      icon: Icons.shield_rounded,
      title: 'Enforce boundaries on the server',
      body: 'Anything a client can send, a client can forge. Tenant scope, '
          'identity and authorisation are resolved from authenticated context, '
          'never from the request body.',
      evidence:
          'Tenant id injected server-side on the AI query path; Agora tokens '
          'signed in-service instead of trusting a third-party broker.',
    ),
    Principle(
      icon: Icons.hub_rounded,
      title: 'Put cross-cutting concerns in one place',
      body:
          'Audit trails, caching and notification fan-out get worse every time '
          'they are copy-pasted into a call site. They belong in an aspect, an '
          'interceptor or a listener.',
      evidence:
          'Audit logging as a Spring AOP aspect; email dispatched through an '
          'application event listener so request threads never block on SMTP.',
    ),
    Principle(
      icon: Icons.layers_rounded,
      title: 'Order work by what changes',
      body: 'Structure should follow change frequency — in a Dockerfile, in a '
          'module graph, in a build. Stable things go first and get cached; '
          'volatile things go last.',
      evidence:
          'Container layers ordered so a code change rebuilds only the jar '
          'layer, not the OCR and AWS toolchain above it.',
    ),
    Principle(
      icon: Icons.travel_explore_rounded,
      title: 'Make failures traceable across services',
      body:
          'A bug that spans two runtimes is only debuggable if one identifier '
          'follows the request through both.',
      evidence: 'Generated request ids logged at every hop between the Spring '
          'service and the Python inference tier.',
    ),
    Principle(
      icon: Icons.published_with_changes_rounded,
      title: 'Ship copy without shipping a build',
      body: 'Anything that changes on a business timescale should not be gated '
          'on an app-store review cycle.',
      evidence:
          'Server-delivered localisation merged into bundled ARB catalogues '
          'by a generator.',
    ),
  ];

  // ---------------------------------------------------------------------------
  // Capability statement — what a hiring manager can hand over on day one.
  // ---------------------------------------------------------------------------

  static const capabilities = <String>[
    'Secured REST APIs on Spring Boot with JWT and multi-tenant isolation',
    'Relational schema design and JPA persistence for complex domains',
    'Containerised backend services deployed to AWS',
    'A cross-platform Flutter application from empty repo to store release',
    'App Store & Play Store releases — signing, TestFlight, review, listing',
    'Offline-first mobile data layers with conflict-aware synchronisation',
    'Real-time video and voice features, including native call integration',
    'Location, mapping and live-tracking features',
    'Camera, OCR and document-capture pipelines backed by cloud storage',
    'Device-level integration test suites for critical user journeys',
  ];
}
