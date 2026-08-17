import 'package:flutter/material.dart';

import '../app/theme/tokens.dart';
import '../data/profile.dart';
import '../ui/glass_card.dart';
import '../ui/layout.dart';
import '../ui/primitives.dart';
import '../ui/reveal.dart';

/// Career timeline. One honest entry beats an invented history — the rail
/// treatment gives it presence without padding it out.
class ExperienceSection extends StatelessWidget {
  const ExperienceSection({super.key});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final theme = Theme.of(context);
    final compact = context.isCompact;

    return ContentShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Reveal(
            child: SectionHeader(
              eyebrow: 'Experience',
              title: 'Where I have done it',
            ),
          ),
          const SizedBox(height: Space.xl),
          for (final e in Profile.experiences)
            Reveal(
              // A Stack, not IntrinsicHeight + Expanded. IntrinsicHeight has to
              // predict the card's height from its subtree's intrinsics, and
              // the summary's ConstrainedBox(maxWidth: 720) reports intrinsics
              // at the width handed to it rather than its own cap — so on a
              // wide viewport the entry was sized for a two-line summary and
              // then laid out a four-line one, and overflowed. Here the card
              // sizes the entry and the rail stretches to whatever that is.
              child: Stack(
                // The current-role dot carries a glow that reaches past the
                // rail's 14px column.
                clipBehavior: Clip.none,
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                      left: compact ? 0 : _railWidth + Space.lg,
                    ),
                    child: GlassCard(
                      padding: EdgeInsets.all(compact ? Space.lg : Space.xl),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            spacing: Space.md,
                            runSpacing: Space.sm,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text(e.role,
                                  style: theme.textTheme.headlineSmall),
                              if (e.isCurrent)
                                const TagChip('Current', accent: true),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: Space.md,
                            runSpacing: Space.xs,
                            children: [
                              Text(
                                e.company,
                                style: theme.textTheme.titleMedium
                                    ?.copyWith(color: c.accent),
                              ),
                              Text(e.period, style: theme.textTheme.bodySmall),
                              Text(e.location,
                                  style: theme.textTheme.bodySmall),
                            ],
                          ),
                          const SizedBox(height: Space.md),
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 720),
                            child: Text(e.summary,
                                style: theme.textTheme.bodyLarge),
                          ),
                          const SizedBox(height: Space.lg),
                          for (final a in e.achievements)
                            Padding(
                              padding: const EdgeInsets.only(bottom: Space.sm),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    margin: const EdgeInsets.only(
                                        top: 8, right: 11),
                                    width: 5,
                                    height: 5,
                                    decoration: BoxDecoration(
                                      color: c.accentAlt,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(a,
                                        style: theme.textTheme.bodyMedium),
                                  ),
                                ],
                              ),
                            ),
                          const SizedBox(height: Space.lg),
                          Wrap(
                            spacing: Space.sm,
                            runSpacing: Space.sm,
                            children: [
                              for (final s in e.stack) TagChip(s),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (!compact)
                    Positioned(
                      top: 0,
                      bottom: 0,
                      left: 0,
                      width: _railWidth,
                      child: _TimelineRail(isCurrent: e.isCurrent),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// Width of the timeline gutter. Shared so the card's left inset and the rail
/// itself cannot drift apart.
const _railWidth = 14.0;

/// Vertical marker beside a timeline entry. Sized by its [Positioned] parent,
/// which stretches it to the height of the card it sits next to.
class _TimelineRail extends StatelessWidget {
  const _TimelineRail({required this.isCurrent});
  final bool isCurrent;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.only(top: 26),
          width: 11,
          height: 11,
          decoration: BoxDecoration(
            color: isCurrent ? c.accent : c.surfaceElevated,
            shape: BoxShape.circle,
            border: Border.all(color: c.accent, width: 2),
            boxShadow: isCurrent
                ? [
                    BoxShadow(
                      color: c.accent.withValues(alpha: 0.45),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ]
                : null,
          ),
        ),
        Expanded(
          child: Container(
            width: 1.5,
            margin: const EdgeInsets.only(top: 6),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [c.accent.withValues(alpha: 0.55), Colors.transparent],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
