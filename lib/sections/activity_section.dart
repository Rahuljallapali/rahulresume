import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

import '../app/theme/tokens.dart';
import '../data/profile.dart';
import '../services/github_service.dart';
import '../ui/glass_card.dart';
import '../ui/layout.dart';
import '../ui/primitives.dart';
import '../ui/reveal.dart';
import '../utils/link.dart';

/// Live GitHub contribution graph.
///
/// The whole point is that this is not a screenshot — it is fetched when the
/// page loads, so it is current by construction. It also carries an explicit
/// note that the production work is private, because a thin public graph left
/// unexplained reads as "does not ship code".
class ActivitySection extends StatefulWidget {
  const ActivitySection({super.key});

  @override
  State<ActivitySection> createState() => _ActivitySectionState();
}

class _ActivitySectionState extends State<ActivitySection> {
  late final Future<ContributionYear?> _future = GitHubService.contributions();

  @override
  Widget build(BuildContext context) {
    return ContentShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Reveal(
            child: SectionHeader(
              eyebrow: 'Still shipping',
              title: 'Live activity',
              lead: 'Pulled from the GitHub API when this page loaded — not a '
                  'screenshot, and not something I can quietly let go stale.',
            ),
          ),
          const SizedBox(height: Space.xl),
          Reveal(
            child: GlassCard(
              interactive: false,
              padding: EdgeInsets.all(
                context.isCompact ? Space.md : Space.lg,
              ),
              child: FutureBuilder<ContributionYear?>(
                future: _future,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const _ActivityPlaceholder();
                  }
                  final data = snapshot.data;
                  if (data == null) return const _ActivityUnavailable();
                  // A graph of 365 empty squares is worse than no graph: it
                  // reads as "writes no code" when the truth is that the
                  // commits are in private repositories under a work email.
                  // Below the threshold, say that instead of drawing it.
                  if (data.total < _minMeaningfulContributions) {
                    return const _ActivityPrivate();
                  }
                  return _ContributionGraph(year: data);
                },
              ),
            ),
          ),
          const SizedBox(height: Space.md),
          Reveal(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: 14,
                  color: AppColors.of(context).textTertiary,
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 720),
                    child: Text(
                      Profile.activityNote,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
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

class _ContributionGraph extends StatelessWidget {
  const _ContributionGraph({required this.year});
  final ContributionYear year;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final theme = Theme.of(context);

    // Align the grid to whole weeks so columns are Sunday-to-Saturday, the
    // way GitHub renders it — otherwise the first column reads as a gap.
    final days = year.days;
    final leading = days.first.date.weekday % 7;
    final cells = <ContributionDay?>[
      ...List<ContributionDay?>.filled(leading, null),
      ...days,
    ];
    final weeks = (cells.length / 7).ceil();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: Space.md,
          runSpacing: Space.sm,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(FontAwesomeIcons.github, size: 15, color: c.textPrimary),
                const SizedBox(width: 9),
                Text(
                  '${year.total} contributions',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(width: 7),
                Text('in the last year', style: theme.textTheme.bodySmall),
              ],
            ),
            InkWell(
              onTap: () => openLink(Profile.githubUrl),
              borderRadius: BorderRadius.circular(Radii.sm),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                child: Text(
                  '@${Profile.githubUser} ↗',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: c.accent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: Space.md),
        // Horizontal scroll rather than shrink: a squashed year is unreadable,
        // and the recent weeks (the tail) are the interesting end.
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          reverse: true,
          child: Semantics(
            label: '${year.total} GitHub contributions in the last year',
            child: ExcludeSemantics(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (var w = 0; w < weeks; w++)
                    Padding(
                      padding: const EdgeInsets.only(right: 3),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          for (var d = 0; d < 7; d++)
                            _Cell(
                              day: (w * 7 + d) < cells.length
                                  ? cells[w * 7 + d]
                                  : null,
                            ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: Space.md),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text('Less', style: theme.textTheme.bodySmall),
            const SizedBox(width: 7),
            for (var level = 0; level < 5; level++)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 1.5),
                child: Container(
                  width: 11,
                  height: 11,
                  decoration: BoxDecoration(
                    color: _levelColor(c, level),
                    borderRadius: BorderRadius.circular(2.5),
                  ),
                ),
              ),
            const SizedBox(width: 7),
            Text('More', style: theme.textTheme.bodySmall),
          ],
        ),
      ],
    );
  }
}

/// Accent-tinted ramp rather than GitHub green, so the graph belongs to this
/// page's palette instead of looking like a pasted-in widget.
Color _levelColor(AppColors c, int level) => switch (level) {
      0 => c.textTertiary.withValues(alpha: 0.12),
      1 => c.accent.withValues(alpha: 0.30),
      2 => c.accent.withValues(alpha: 0.52),
      3 => c.accent.withValues(alpha: 0.76),
      _ => c.accentAlt,
    };

class _Cell extends StatelessWidget {
  const _Cell({required this.day});
  final ContributionDay? day;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    if (day == null) {
      return const Padding(
        padding: EdgeInsets.only(bottom: 3),
        child: SizedBox(width: 11, height: 11),
      );
    }

    final d = day!;
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Tooltip(
        message: '${d.count} on ${_formatDate(d.date)}',
        child: Container(
          width: 11,
          height: 11,
          decoration: BoxDecoration(
            color: _levelColor(c, d.level),
            borderRadius: BorderRadius.circular(2.5),
          ),
        ),
      ),
    );
  }
}

const _months = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', //
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

String _formatDate(DateTime d) => '${d.day} ${_months[d.month - 1]} ${d.year}';

/// Shimmerless skeleton: a grid of empty cells at the real size, so the card
/// does not resize when the data lands.
class _ActivityPlaceholder extends StatelessWidget {
  const _ActivityPlaceholder();

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Row(
      children: [
        SizedBox(
          width: 15,
          height: 15,
          child: CircularProgressIndicator(strokeWidth: 2, color: c.accent),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            'Fetching contribution graph…',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}

/// Below this, the graph is not worth drawing — see the call site.
///
/// Set deliberately low: the point is to catch "essentially nothing to show",
/// not to hide a quiet quarter.
const _minMeaningfulContributions = 25;

/// Shown when the public graph is empty or near-empty.
///
/// This is the honest state for an engineer whose production work lives in
/// private company repositories committed under a work email. It makes the
/// same point the graph would have — still shipping — without inviting the
/// wrong conclusion from an empty grid.
class _ActivityPrivate extends StatelessWidget {
  const _ActivityPrivate();

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.lock_outline_rounded, size: 16, color: c.accent),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'The work is in private repositories',
                style: theme.textTheme.titleMedium,
              ),
            ),
          ],
        ),
        const SizedBox(height: Space.md),
        Text(
          'Every repository behind this page belongs to my employer and is '
          'private, so GitHub surfaces none of it publicly. Rather than show '
          'an empty grid that says the opposite of the truth, here is what '
          'those repositories actually contain.',
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: Space.lg),
        Wrap(
          spacing: Space.xxl,
          runSpacing: Space.lg,
          children: [
            for (final fact in const [
              ('619', 'commits authored', 'across both repositories'),
              ('180', 'REST controllers', 'in the Spring Boot service'),
              ('52', 'production builds', 'shipped to the app stores'),
            ])
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fact.$1,
                    style: theme.textTheme.headlineMedium
                        ?.copyWith(color: c.accent),
                  ),
                  const SizedBox(height: 2),
                  Text(fact.$2, style: theme.textTheme.bodyMedium),
                  Text(
                    fact.$3,
                    style: theme.textTheme.bodySmall?.copyWith(fontSize: 11.5),
                  ),
                ],
              ),
          ],
        ),
        const SizedBox(height: Space.lg),
        InkWell(
          onTap: () => openLink(Profile.githubUrl),
          borderRadius: BorderRadius.circular(Radii.sm),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Text(
              'github.com/${Profile.githubUser} ↗',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: c.accent,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Shown when the request fails, the endpoint is down, or a network policy
/// blocks it. Never a blank grid — that would imply zero activity.
class _ActivityUnavailable extends StatelessWidget {
  const _ActivityUnavailable();

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.cloud_off_rounded, size: 17, color: c.textTertiary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Could not reach the contribution graph just now.',
                style:
                    theme.textTheme.bodyMedium?.copyWith(color: c.textPrimary),
              ),
              const SizedBox(height: 3),
              Text(
                'It is a third-party mirror of the GitHub profile graph, so it '
                'is occasionally unavailable. The profile itself is not.',
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: Space.sm),
              InkWell(
                onTap: () => openLink(Profile.githubUrl),
                borderRadius: BorderRadius.circular(Radii.sm),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    'Open github.com/${Profile.githubUser} ↗',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: c.accent,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
