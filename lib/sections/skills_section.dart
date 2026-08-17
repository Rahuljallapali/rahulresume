import 'package:flutter/material.dart';

import '../app/theme/tokens.dart';
import '../data/profile.dart';
import '../ui/glass_card.dart';
import '../ui/layout.dart';
import '../ui/primitives.dart';
import '../ui/reveal.dart';

/// Skills, grouped and evidenced.
///
/// Bars are annotated with where the skill was actually used. A proficiency
/// bar with no provenance is a claim; with provenance it is a reference.
class SkillsSection extends StatelessWidget {
  const SkillsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final theme = Theme.of(context);

    return ContentShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Reveal(
            child: SectionHeader(
              eyebrow: 'Capability',
              title: 'Tools, and where I used them',
              lead: 'Levels are deliberately coarse — daily ownership, shipped '
                  'features, used in production, or working familiarity. '
                  'Where a claim has a specific origin, it is named.',
            ),
          ),
          const SizedBox(height: Space.xl),

          AutoGrid(
            columns: context.responsive(compact: 1, medium: 2, wide: 3),
            children: [
              for (var i = 0; i < Profile.skillGroups.length; i++)
                Reveal(
                  delay: Duration(milliseconds: 40 * i),
                  child: GlassCard(
                    interactive: false,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(7),
                              decoration: BoxDecoration(
                                color: c.accentSoft,
                                borderRadius: BorderRadius.circular(Radii.sm),
                              ),
                              child: Icon(Profile.skillGroups[i].icon,
                                  size: 15, color: c.accent),
                            ),
                            const SizedBox(width: 11),
                            Expanded(
                              child: Text(
                                Profile.skillGroups[i].title,
                                style: theme.textTheme.titleMedium,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: Space.lg),
                        for (final s in Profile.skillGroups[i].skills)
                          SkillBar(
                            name: s.name,
                            level: s.level,
                            evidence: s.evidence,
                          ),
                      ],
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: Space.xxl),

          // "What I can build" — reframes the same skills as deliverables,
          // which is the form a hiring manager actually thinks in.
          Reveal(
            child: GlassCard(
              interactive: false,
              padding: EdgeInsets.all(context.isCompact ? Space.lg : Space.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('What you can hand me on day one',
                      style: theme.textTheme.headlineSmall),
                  const SizedBox(height: Space.lg),
                  AutoGrid(
                    columns: context.responsive(compact: 1, medium: 2, wide: 2),
                    runSpacing: Space.sm,
                    children: [
                      for (final cap in Profile.capabilities)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.check_rounded,
                                size: 15, color: c.success),
                            const SizedBox(width: 10),
                            Expanded(
                              child:
                                  Text(cap, style: theme.textTheme.bodyMedium),
                            ),
                          ],
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
