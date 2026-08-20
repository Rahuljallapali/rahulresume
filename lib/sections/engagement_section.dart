import 'package:flutter/material.dart';

import '../app/theme/tokens.dart';
import '../data/models.dart';
import '../data/profile.dart';
import '../ui/glass_card.dart';
import '../ui/layout.dart';
import '../ui/primitives.dart';
import '../ui/reveal.dart';
import '../utils/link.dart';

/// What a client can actually buy, and on what terms.
///
/// Rendered only under the hidden freelance lens — a recruiter reading rates
/// and engagement lengths hears "will leave in three months", which is the
/// impression the rest of this site exists to avoid. See `lens.dart`.
class EngagementSection extends StatelessWidget {
  const EngagementSection({super.key});

  @override
  Widget build(BuildContext context) {
    return ContentShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Reveal(
            child: SectionHeader(
              eyebrow: 'Working together',
              title: 'What you can hire me for',
              lead: 'Start small if you want to — the discovery week below is '
                  'designed for exactly that. If your project is none of '
                  'these but sounds close, say so; the worst outcome is a '
                  'straight answer.',
            ),
          ),
          const SizedBox(height: Space.lg),
          const Reveal(child: _ProofStrip()),
          const SizedBox(height: Space.lg),
          const Reveal(
            delay: Duration(milliseconds: 60),
            child: _EngagementCard(
              engagement: Profile.discovery,
              featured: true,
            ),
          ),
          const SizedBox(height: Space.xl),
          AutoGrid(
            columns: context.responsive(compact: 1, medium: 2, wide: 3),
            spacing: Space.md,
            equalHeight: true,
            children: [
              for (var i = 0; i < Profile.engagements.length; i++)
                Reveal(
                  delay: Duration(milliseconds: 80 * i),
                  child: _EngagementCard(engagement: Profile.engagements[i]),
                ),
            ],
          ),
          const SizedBox(height: Space.xxl),
          Reveal(
            child: context.isCompact
                ? const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _WorkingAgreement(),
                      SizedBox(height: Space.lg),
                      _BookingCard(),
                    ],
                  )
                : const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 6, child: _WorkingAgreement()),
                      SizedBox(width: Space.xxl),
                      Expanded(flex: 5, child: _BookingCard()),
                    ],
                  ),
          ),
          const SizedBox(height: Space.xxl),
          const Reveal(child: _NotTakingOn()),
        ],
      ),
    );
  }
}

class _EngagementCard extends StatelessWidget {
  const _EngagementCard({required this.engagement, this.featured = false});
  final Engagement engagement;

  /// The discovery card, rendered full width above the grid so the cheapest
  /// way in is also the most visible one.
  final bool featured;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final theme = Theme.of(context);
    final e = engagement;

    return GlassCard(
      semanticLabel: '${e.title}. ${e.pitch}',
      accentBorder: featured,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: c.accentSoft,
                  borderRadius: BorderRadius.circular(Radii.sm),
                ),
                child: Icon(e.icon, size: 17, color: c.accent),
              ),
              const SizedBox(width: 11),
              Expanded(child: Text(e.title, style: theme.textTheme.titleLarge)),
            ],
          ),
          if (e.typicalLength != null) ...[
            const SizedBox(height: Space.sm),
            TagChip(e.typicalLength!, icon: Icons.schedule_rounded),
          ],
          const SizedBox(height: Space.md),
          Text(e.pitch, style: theme.textTheme.bodyMedium),
          if (e.investment != null) ...[
            const SizedBox(height: Space.md),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.payments_outlined, size: 15, color: c.accent),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    e.investment!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: c.accent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: Space.md),
          Divider(color: c.hairline),
          const SizedBox(height: Space.sm),
          Text('You get', style: theme.textTheme.labelSmall),
          const SizedBox(height: Space.sm),
          for (final d in e.deliverables)
            Padding(
              padding: const EdgeInsets.only(bottom: 7),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.check_rounded, size: 14, color: c.success),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      d,
                      style: theme.textTheme.bodySmall?.copyWith(height: 1.5),
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

class _WorkingAgreement extends StatelessWidget {
  const _WorkingAgreement();

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('How the work runs', style: theme.textTheme.headlineSmall),
        const SizedBox(height: Space.lg),
        for (final line in Profile.workingAgreement)
          Padding(
            padding: const EdgeInsets.only(bottom: Space.md),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 8, right: 12),
                  width: 5,
                  height: 5,
                  decoration:
                      BoxDecoration(color: c.accentAlt, shape: BoxShape.circle),
                ),
                Expanded(child: Text(line, style: theme.textTheme.bodyMedium)),
              ],
            ),
          ),
      ],
    );
  }
}

/// Falls back to a pre-filled email when no scheduling link is configured —
/// a mailto always works, and a dead calendar embed does not.
class _BookingCard extends StatelessWidget {
  const _BookingCard();

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final theme = Theme.of(context);
    final hasBooking = Profile.bookingUrl.isNotEmpty;

    return GlassCard(
      interactive: false,
      accentBorder: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.event_available_rounded, size: 17, color: c.accent),
              const SizedBox(width: 9),
              Expanded(
                child: Text('Start with a call',
                    style: theme.textTheme.titleLarge),
              ),
            ],
          ),
          const SizedBox(height: Space.md),
          Text(
            'Tell me what you are building and where it is stuck. If I am not '
            'the right person for it, I will say so and point you somewhere '
            'better.',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: Space.lg),
          MagneticButton(
            label: hasBooking ? 'Book a time' : 'Email me the details',
            icon: hasBooking
                ? Icons.calendar_month_rounded
                : Icons.mail_outline_rounded,
            expand: true,
            onPressed: () => openLink(
              hasBooking ? Profile.bookingUrl : Profile.introMailto,
            ),
          ),
          if (!hasBooking) ...[
            const SizedBox(height: Space.sm),
            Text(
              'Opens your mail client with the useful questions already '
              'filled in.',
              style: theme.textTheme.bodySmall?.copyWith(fontSize: 11.5),
            ),
          ],
          const SizedBox(height: Space.lg),
          Divider(color: c.hairline),
          const SizedBox(height: Space.md),
          const _Fact(icon: Icons.schedule_rounded, text: Profile.timezone),
          const _Fact(
              icon: Icons.reply_rounded, text: 'Replies within one business day'),
          const _Fact(icon: Icons.place_outlined, text: Profile.location),
        ],
      ),
    );
  }
}

class _Fact extends StatelessWidget {
  const _Fact({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: Space.sm),
      child: Row(
        children: [
          Icon(icon, size: 14, color: c.textTertiary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text, style: Theme.of(context).textTheme.bodySmall),
          ),
        ],
      ),
    );
  }
}


/// The one claim on this page a client can check for themselves in thirty
/// seconds.
///
/// Every freelancer's site asserts competence; almost none of them can be
/// installed. Putting the store links above the offer means the reader has
/// already verified the work before they reach the part where they are asked
/// for money.
class _ProofStrip extends StatelessWidget {
  const _ProofStrip();

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final theme = Theme.of(context);
    final app = Profile.storeApps.firstWhere((a) => a.name == 'Serveiz');

    final blurb = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Before you read any further, go and use it',
            style: theme.textTheme.titleLarge),
        const SizedBox(height: Space.sm),
        Text(
          '${app.name} is live on both stores and in daily use by service '
          'crews. I wrote the app and the service behind it — ${app.role}. '
          'Judge the work, not the sales copy.',
          style: theme.textTheme.bodyMedium,
        ),
      ],
    );

    final buttons = [
      if (app.appStoreUrl != null)
        MagneticButton(
          label: 'App Store',
          icon: Icons.apple_rounded,
          filled: false,
          expand: context.isCompact,
          onPressed: () => openLink(app.appStoreUrl!),
        ),
      if (app.playStoreUrl != null)
        MagneticButton(
          label: 'Google Play',
          icon: Icons.shop_rounded,
          filled: false,
          expand: context.isCompact,
          onPressed: () => openLink(app.playStoreUrl!),
        ),
    ];

    return GlassCard(
      interactive: false,
      semanticLabel: 'See a live app I built: ${app.name}',
      child: context.isCompact
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                blurb,
                const SizedBox(height: Space.lg),
                for (final b in buttons) ...[
                  b,
                  const SizedBox(height: Space.sm),
                ],
              ],
            )
          : Row(
              children: [
                Icon(Icons.verified_outlined, size: 20, color: c.success),
                const SizedBox(width: Space.md),
                Expanded(child: blurb),
                const SizedBox(width: Space.lg),
                for (final b in buttons) ...[
                  const SizedBox(width: Space.sm),
                  b,
                ],
              ],
            ),
    );
  }
}

/// The boundaries of the offer.
///
/// Counter-intuitive but reliable: a client trusts a scope with edges more
/// than one without. It also deflects the enquiries that were never going to
/// close, which matters more than it sounds when evenings are the budget.
class _NotTakingOn extends StatelessWidget {
  const _NotTakingOn();

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('What I will turn down', style: theme.textTheme.headlineSmall),
        const SizedBox(height: Space.sm),
        Text(
          'So you can rule me out quickly if this is not a fit.',
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: Space.lg),
        for (final line in Profile.notTakingOn)
          Padding(
            padding: const EdgeInsets.only(bottom: Space.md),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 3, right: 12),
                  child: Icon(Icons.remove_rounded,
                      size: 15, color: c.textTertiary),
                ),
                Expanded(child: Text(line, style: theme.textTheme.bodyMedium)),
              ],
            ),
          ),
      ],
    );
  }
}
