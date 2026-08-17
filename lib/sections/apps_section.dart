import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../app/router.dart';
import '../app/theme/tokens.dart';
import '../data/models.dart';
import '../data/profile.dart';
import '../ui/glass_card.dart';
import '../ui/layout.dart';
import '../ui/primitives.dart';
import '../ui/reveal.dart';
import '../utils/link.dart';

/// Apps with a public store presence.
///
/// This is the one section a visitor does not have to take on trust: every
/// badge links to a live listing. The phone mockups are drawn entirely in
/// widgets — no screenshots to go stale, nothing to license, and they render
/// identically in both themes.
class AppsSection extends StatelessWidget {
  const AppsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return ContentShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Reveal(
            child: SectionHeader(
              eyebrow: 'Shipped, not just written',
              title: 'Apps in the wild',
              lead: 'Four apps I have had my hands on are in real use — two '
                  'on public stores you can open right now, one I carried '
                  'through App Store review, and one distributed inside the '
                  'organisation that runs it. The listings are the part of a '
                  'portfolio you do not have to take my word for.',
            ),
          ),
          const SizedBox(height: Space.xl),
          AutoGrid(
            columns: context.responsive(compact: 1, medium: 2, wide: 3),
            children: [
              for (var i = 0; i < Profile.storeApps.length; i++)
                Reveal(
                  delay: Duration(milliseconds: 90 * i),
                  child: _AppCard(app: Profile.storeApps[i]),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AppCard extends StatelessWidget {
  const _AppCard({required this.app});
  final StoreApp app;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final theme = Theme.of(context);

    return GlassCard(
      semanticLabel: '${app.name}. ${app.tagline}. ${app.role}.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(child: _PhoneMock(app: app)),
          const SizedBox(height: Space.lg),
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [app.accent, app.accent.withValues(alpha: 0.7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Text(
                  app.name.characters.first,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(app.name, style: theme.textTheme.titleLarge),
                    Text(
                      app.tagline,
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: c.textTertiary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: Space.md),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: app.accent.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(Radii.sm),
              border: Border.all(color: app.accent.withValues(alpha: 0.30)),
            ),
            child: Text(
              app.role,
              style: theme.textTheme.bodySmall?.copyWith(
                color: c.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(height: Space.md),
          Text(app.description, style: theme.textTheme.bodyMedium),
          const SizedBox(height: Space.md),
          Wrap(
            spacing: Space.sm,
            runSpacing: Space.sm,
            children: [for (final s in app.stack) TagChip(s)],
          ),
          const SizedBox(height: Space.md),
          Divider(color: c.hairline),
          const SizedBox(height: Space.sm),
          Wrap(
            spacing: Space.sm,
            runSpacing: Space.sm,
            children: [
              if (app.appStoreUrl != null)
                _StoreBadge(
                  icon: FontAwesomeIcons.apple,
                  label: 'App Store',
                  url: app.appStoreUrl!,
                ),
              if (app.playStoreUrl != null)
                _StoreBadge(
                  icon: FontAwesomeIcons.googlePlay,
                  label: 'Google Play',
                  url: app.playStoreUrl!,
                ),
              if (app.releaseOnly) const _ReleaseChip(),
              if (app.enterprise) const _EnterpriseChip(),
            ],
          ),
          if (app.caseStudy != null) ...[
            const SizedBox(height: Space.md),
            Semantics(
              button: true,
              label: 'Read the ${app.name} case study',
              child: InkWell(
                onTap: () => AppRouter.openCaseStudy(context, app.caseStudy!),
                borderRadius: BorderRadius.circular(Radii.sm),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Read the case study',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: c.accent,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Icon(Icons.arrow_forward_rounded,
                          size: 14, color: c.accent),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Store link drawn as a compact badge. Real listings only — this widget is
/// never rendered without a URL.
class _StoreBadge extends StatelessWidget {
  const _StoreBadge({
    required this.icon,
    required this.label,
    required this.url,
  });

  final IconData icon;
  final String label;
  final String url;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final theme = Theme.of(context);

    return Semantics(
      link: true,
      label: 'Open $label listing',
      child: InkWell(
        onTap: () => openLink(url),
        borderRadius: BorderRadius.circular(Radii.sm),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: c.textPrimary.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(Radii.sm),
            border: Border.all(color: c.hairline),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: c.textPrimary),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'LIVE ON',
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontSize: 7.5,
                      letterSpacing: 1.0,
                      color: c.textTertiary,
                    ),
                  ),
                  Text(
                    label,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: c.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 12.5,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Non-link marker for DIMS: the claim is the release work itself.
class _ReleaseChip extends StatelessWidget {
  const _ReleaseChip();

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Radii.sm),
        border: Border.all(color: c.hairline),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.rocket_launch_outlined, size: 14, color: c.textSecondary),
          const SizedBox(width: 8),
          // Flexible: on the narrowest cards the sentence wraps to a second
          // line rather than running out of the chip.
          Flexible(
            child: Text(
              'Shipped via App Store Connect',
              style: theme.textTheme.bodySmall?.copyWith(
                color: c.textSecondary,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Marker for an app with no public listing to link to.
///
/// Deliberately not styled as a store badge: it must not read as something a
/// visitor could click through and verify, because they cannot.
class _EnterpriseChip extends StatelessWidget {
  const _EnterpriseChip();

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Radii.sm),
        border: Border.all(color: c.hairline),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.business_rounded, size: 14, color: c.textSecondary),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              'Enterprise distribution — no public listing',
              style: theme.textTheme.bodySmall?.copyWith(
                color: c.textSecondary,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A stylised phone drawn in pure widgets.
///
/// Kept deliberately abstract — suggestion of an interface, not a fake
/// screenshot. [StoreApp.mock] picks the motif, so an app whose contribution
/// was the release itself gets a release screen rather than a made-up feed.
class _PhoneMock extends StatelessWidget {
  const _PhoneMock({required this.app});
  final StoreApp app;

  @override
  Widget build(BuildContext context) {
    // Device chrome stays dark in both themes, like the real object.
    const bezel = Color(0xFF15171E);
    const screenBase = Color(0xFF0B0D12);

    return Container(
      width: 148,
      height: 268,
      padding: const EdgeInsets.all(7),
      decoration: BoxDecoration(
        color: bezel,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
        boxShadow: [
          BoxShadow(
            color: app.accent.withValues(alpha: 0.22),
            blurRadius: 42,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(21),
        // The screen is illustration, not content: its 7px labels must not
        // grow with the visitor's text scale or the bezel would overflow.
        child: MediaQuery.withNoTextScaling(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color.alphaBlend(
                      app.accent.withValues(alpha: 0.28), screenBase),
                  screenBase,
                ],
              ),
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: switch (app.mock) {
                    AppMock.release => _ReleaseScreen(accent: app.accent),
                    AppMock.beacon => _BeaconScreen(accent: app.accent),
                    AppMock.list =>
                      _AppScreen(accent: app.accent, name: app.name),
                  },
                ),
                // Notch.
                Positioned(
                  top: 6,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      width: 46,
                      height: 6,
                      decoration: BoxDecoration(
                        color: bezel,
                        borderRadius: BorderRadius.circular(Radii.pill),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Abstract app interface: bar, list cards, bottom nav.
class _AppScreen extends StatelessWidget {
  const _AppScreen({required this.accent, required this.name});
  final Color accent;
  final String name;

  @override
  Widget build(BuildContext context) {
    final line = Colors.white.withValues(alpha: 0.16);
    final card = Colors.white.withValues(alpha: 0.07);

    Widget listCard({double leadWidth = 44}) => Container(
          margin: const EdgeInsets.only(bottom: 7),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: card,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 22,
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: BorderRadius.circular(Radii.pill),
                ),
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: leadWidth,
                      height: 5,
                      decoration: BoxDecoration(
                        color: line,
                        borderRadius: BorderRadius.circular(Radii.pill),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.09),
                        borderRadius: BorderRadius.circular(Radii.pill),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );

    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 20, 10, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // App bar: name + avatar dot.
          Row(
            children: [
              Expanded(
                child: Text(
                  name.toUpperCase(),
                  style: TextStyle(
                    fontSize: 8,
                    letterSpacing: 2,
                    fontWeight: FontWeight.w700,
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
              ),
              Container(
                width: 10,
                height: 10,
                decoration:
                    BoxDecoration(color: accent, shape: BoxShape.circle),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Hero tile suggesting a map / dashboard.
          Container(
            height: 52,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  accent.withValues(alpha: 0.55),
                  accent.withValues(alpha: 0.20),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: const EdgeInsets.all(7),
                child: Container(
                  width: 34,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.75),
                    borderRadius: BorderRadius.circular(Radii.pill),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 9),
          // The list runs off the bottom of the visible area like a real
          // scrolled feed. OverflowBox + ClipRect makes that intentional
          // rather than a RenderFlex overflow, whatever the font metrics.
          Expanded(
            child: ClipRect(
              child: OverflowBox(
                maxHeight: double.infinity,
                alignment: Alignment.topCenter,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    listCard(leadWidth: 52),
                    listCard(leadWidth: 38),
                    listCard(leadWidth: 46),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Bottom nav dots.
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              for (var i = 0; i < 4; i++)
                Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color:
                        i == 0 ? accent : Colors.white.withValues(alpha: 0.18),
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Beacon motif: concentric range rings with detected transmitters plotted on
/// them, over a short list of signal readings.
class _BeaconScreen extends StatelessWidget {
  const _BeaconScreen({required this.accent});
  final Color accent;

  /// Fractional offsets from the radar centre, paired with a signal strength.
  /// Fixed rather than random so the illustration is identical every build.
  static const _blips = <(double, double, String)>[
    (0.16, -0.30, '-52'),
    (-0.34, 0.12, '-67'),
    (0.30, 0.26, '-74'),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 26, 12, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'SCANNING',
            style: TextStyle(
              fontSize: 7.5,
              letterSpacing: 2,
              fontWeight: FontWeight.w700,
              color: Colors.white.withValues(alpha: 0.75),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 104,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final size = constraints.biggest;
                final centre = Offset(size.width / 2, size.height / 2);

                return Stack(
                  children: [
                    // Range rings.
                    for (final scale in const [1.0, 0.66, 0.33])
                      Positioned(
                        left: centre.dx - (size.height / 2) * scale,
                        top: centre.dy - (size.height / 2) * scale,
                        child: Container(
                          width: size.height * scale,
                          height: size.height * scale,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: accent.withValues(alpha: 0.22),
                            ),
                          ),
                        ),
                      ),
                    // The scanning device at the centre.
                    Positioned(
                      left: centre.dx - 4,
                      top: centre.dy - 4,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: accent,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: accent.withValues(alpha: 0.6),
                              blurRadius: 8,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Detected beacons.
                    for (final (dx, dy, _) in _blips)
                      Positioned(
                        left: centre.dx + size.height * dx - 3,
                        top: centre.dy + size.height * dy - 3,
                        child: Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.9),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
          const Spacer(),
          // Signal readout, the shape a scan result actually takes.
          for (final blip in _blips)
            Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(
                      color: accent,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 7),
                  Expanded(
                    child: Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(Radii.pill),
                      ),
                    ),
                  ),
                  const SizedBox(width: 7),
                  Text(
                    '${blip.$3} dBm',
                    style: TextStyle(
                      fontSize: 6.5,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// Release motif for the app that was shipped, not written: TestFlight →
/// review → Ready for Sale.
class _ReleaseScreen extends StatelessWidget {
  const _ReleaseScreen({required this.accent});
  final Color accent;

  @override
  Widget build(BuildContext context) {
    Widget step(String label, {required bool done}) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              Icon(
                done ? Icons.check_circle_rounded : Icons.circle_outlined,
                size: 11,
                color: done
                    ? const Color(0xFF46D18C)
                    : Colors.white.withValues(alpha: 0.35),
              ),
              const SizedBox(width: 7),
              // scaleDown: the label is decoration — under an unusually wide
              // font it shrinks to fit rather than overflowing the screen.
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 7.5,
                      letterSpacing: 0.6,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withValues(alpha: done ? 0.85 : 0.45),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 26, 14, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
              ),
              child: const Icon(
                FontAwesomeIcons.apple,
                size: 22,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 14),
          step('ARCHIVE SIGNED', done: true),
          step('TESTFLIGHT BUILD', done: true),
          step('APP REVIEW PASSED', done: true),
          step('READY FOR SALE', done: true),
          const Spacer(),
          Container(
            height: 5,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(Radii.pill),
              gradient: LinearGradient(
                colors: [accent, const Color(0xFF46D18C)],
              ),
            ),
          ),
          const SizedBox(height: 6),
          Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                'RELEASE 1.0 · 100%',
                style: TextStyle(
                  fontSize: 6.5,
                  letterSpacing: 1.6,
                  fontWeight: FontWeight.w700,
                  color: Colors.white.withValues(alpha: 0.6),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
