import 'models.dart';

/// Short technical write-ups, deep-linkable at `/#/notes/<slug>`.
///
/// Each one is drawn from a decision actually made in the production Spring
/// Boot service or the Flutter platform it backs — no tutorial rewrites, no
/// borrowed opinions. Kept in their own file because the prose is long enough
/// to make `profile.dart` hard to scan otherwise.
abstract final class Notes {
  static const all = <Note>[
    Note(
      slug: 'signing-agora-tokens-in-service',
      title: 'Sign your own real-time tokens',
      dek: 'Putting a third-party token broker in the path of a support call '
          'means outsourcing the one decision you cannot afford to get wrong: '
          'who is allowed into the channel.',
      date: '12 June 2026',
      readingMinutes: 4,
      tags: ['Spring Boot', 'Security', 'Real-time'],
      body: [
        NoteBlock.paragraph(
          'Our field app lets a technician pull a remote expert into a live '
          'video session — the expert sees the technician\'s camera and draws '
          'on the stream to point at the exact valve in question. The '
          'transport is Agora RTC, and Agora authenticates each join with a '
          'short-lived token signed with your app certificate.',
        ),
        NoteBlock.paragraph(
          'The tempting shortcut is to grab one of the sample token servers '
          'and deploy it next to the app. It works on the first day. What it '
          'also does is put a second service — one nobody on the team owns — '
          'in the trust path of every call, holding a copy of the app '
          'certificate.',
        ),
        NoteBlock.heading('What the token actually decides'),
        NoteBlock.paragraph(
          'A token names a channel, a user id, a role and an expiry. Whoever '
          'mints it decides who may publish video into a customer\'s support '
          'session and for how long. That is an authorisation decision about '
          'our domain, and authorisation decisions belong where the domain '
          'lives — beside the code that already knows which technician is '
          'assigned to which work order.',
        ),
        NoteBlock.paragraph(
          'So the signer moved into the Spring service. The endpoint reads the '
          'caller from the security context, checks that this user is actually '
          'party to the work order the channel belongs to, and only then '
          'builds and signs the token.',
        ),
        NoteBlock.code(
          '''@PostMapping("/api/v1/rtc/token")
public ResponseEntity<RtcTokenDto> mint(
    @RequestBody @Valid TokenRequest req,
    @AuthenticationPrincipal AppUser user) {

  // The channel encodes a work order. Membership is a domain question,
  // and the domain is right here — so ask it before signing anything.
  workOrderService.assertParticipant(req.channel(), user);

  var expiry = Instant.now().plusSeconds(req.ttlSeconds());
  return ResponseEntity.status(CREATED)
      .body(tokenSigner.sign(req.channel(), user.id(), req.role(), expiry));
}''',
          language: 'java',
        ),
        NoteBlock.heading('What this bought us'),
        NoteBlock.bullets([
          'The app certificate exists in exactly one place, alongside every '
              'other secret the service already manages.',
          'Channel membership is checked against the work order, so a valid '
              'login is not by itself a licence to join any session.',
          'Token expiry is a business rule we can change in a code review, '
              'not a config value in somebody else\'s sample project.',
          'One fewer deployment to patch, monitor and explain.',
        ]),
        NoteBlock.callout(
          'The general rule: if a token grants access to your domain, the '
          'thing that signs it should be able to read your domain. Anything '
          'else is an authorisation decision made by a service that does not '
          'have the facts.',
        ),
      ],
    ),
    Note(
      slug: 'offline-first-is-a-data-layer-decision',
      title: 'Offline-first is a data-layer decision',
      dek: 'Technicians work in basements and lift shafts. You cannot solve '
          'that with a retry button — by the time the UI knows, the decision '
          'has already been made in the wrong place.',
      date: '3 May 2026',
      readingMinutes: 5,
      tags: ['Flutter', 'SQLite', 'Architecture'],
      body: [
        NoteBlock.paragraph(
          'The first version of any mobile app treats the network as the '
          'source of truth: tap a button, fire a request, show a spinner, '
          'render whatever comes back. It is a perfectly good model right up '
          'until the user is standing in a plant room with no signal, holding '
          'a phone that will not let them record the work they just finished.',
        ),
        NoteBlock.paragraph(
          'The instinct at that point is to patch the UI — add a retry, cache '
          'the last response, show a friendlier error. All of that treats '
          'connectivity loss as an exception. For a field technician it is not '
          'an exception; it is a normal Tuesday.',
        ),
        NoteBlock.heading('Move the source of truth onto the device'),
        NoteBlock.paragraph(
          'The fix is structural. Every capture path — status changes, photos, '
          'signatures, meter readings, parts used — writes to a local SQLite '
          'store first and returns immediately. The write is complete from the '
          'user\'s point of view the moment it lands on disk. A separate '
          'reconciler drains that store whenever the network happens to be '
          'available.',
        ),
        NoteBlock.code(
          '''Future<void> reconcile() async {
  final pending = await db.pendingCaptures();
  for (final capture in pending) {
    final res = await api.upload(capture);
    // Only the server's acknowledgement clears a row. A crash mid-loop
    // costs a retry, never a lost signature.
    if (res.ok) await db.markSynced(capture.id);
  }
}''',
          language: 'dart',
        ),
        NoteBlock.paragraph(
          'Note what is absent: the UI never asks whether the device is '
          'online, because the answer would be stale by the time it rendered. '
          'Screens read from SQLite and only from SQLite. Connectivity becomes '
          'a property of the sync loop rather than a branch in every widget.',
        ),
        NoteBlock.heading('The parts that are genuinely hard'),
        NoteBlock.bullets([
          'Identity before the server has seen the row. Local records need '
              'client-generated ids so a photo can reference a work order that '
              'does not exist upstream yet.',
          'Ordering. A completion that depends on an earlier status change has '
              'to reach the server after it, so the queue is a sequence, not a '
              'set.',
          'Idempotency. A retry after a timeout must not create a second '
              'invoice, which makes it the server\'s problem too — the '
              'endpoint has to be safe to call twice.',
          'Honest UI. "Saved on this device, not yet synced" is a different '
              'state from "saved", and pretending otherwise is how you lose '
              'someone\'s trust the first time a phone is wiped.',
        ]),
        NoteBlock.callout(
          'Offline-first is not a feature you add to a screen. It is a claim '
          'about where the truth lives, and it has to be made once, in the '
          'data layer, before the first screen is written.',
        ),
      ],
    ),
    Note(
      slug: 'order-your-dockerfile-by-what-changes',
      title: 'Order your Dockerfile by what changes',
      dek: 'Our production image installs an OCR toolchain and the AWS CLI. '
          'Put the jar in the wrong place and every one-line code change '
          'rebuilds all of it.',
      date: '20 March 2026',
      readingMinutes: 3,
      tags: ['Docker', 'AWS', 'Build'],
      body: [
        NoteBlock.paragraph(
          'The service does more than serve JSON. It shells out to Tesseract '
          'for document OCR and talks to S3 and Textract through the AWS CLI, '
          'so the runtime image carries system packages and a Python '
          'environment on top of the JRE.',
        ),
        NoteBlock.paragraph(
          'That is a heavy base — and it is also almost completely static. The '
          'toolchain changes a few times a year. The application jar changes '
          'several times a day. A Dockerfile that installs the toolchain after '
          'copying the jar throws that asymmetry away: every code change '
          'invalidates the layer cache at the copy, and the build reinstalls '
          'the entire toolchain to produce a jar that differs by one line.',
        ),
        NoteBlock.heading('Stable things first'),
        NoteBlock.code(
          '''FROM eclipse-temurin:21-jre

# Changes a few times a year — cached across essentially every build.
RUN apt-get update && apt-get install -y --no-install-recommends \\
      tesseract-ocr poppler-utils python3 python3-pip \\
 && rm -rf /var/lib/apt/lists/*
RUN pip3 install --no-cache-dir awscli

# Changes several times a day — deliberately last, so it is the only
# layer a normal deploy has to rebuild and push.
COPY target/service.jar /app/service.jar
ENTRYPOINT ["java", "-jar", "/app/service.jar"]''',
          language: 'dockerfile',
        ),
        NoteBlock.paragraph(
          'Same image, same contents, ordered by rate of change. A routine '
          'deploy now rebuilds and ships one thin layer instead of several '
          'hundred megabytes of unchanged toolchain.',
        ),
        NoteBlock.heading('The same rule, elsewhere'),
        NoteBlock.paragraph(
          'This is not really a Docker trick. Ordering by change frequency is '
          'the same instinct that puts dependency installation before source '
          'copying in a CI job, keeps volatile feature modules from being '
          'imported by stable ones, and separates configuration that changes '
          'per environment from configuration that never changes at all.',
        ),
        NoteBlock.callout(
          'Ask of any layered structure: what here changes hourly, and what '
          'changes yearly? If the answer is interleaved, the structure is '
          'costing you something on every single build.',
        ),
      ],
    ),
  ];

  static Note? bySlug(String slug) {
    for (final n in all) {
      if (n.slug == slug) return n;
    }
    return null;
  }
}
