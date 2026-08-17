import 'package:flutter/material.dart';

import '../app/theme/tokens.dart';
import '../data/profile.dart';
import '../ui/glass_card.dart';
import '../ui/layout.dart';
import '../ui/primitives.dart';
import '../ui/reveal.dart';

/// Engineering principles.
///
/// The failure mode of this section on most portfolios is a wall of adjectives
/// ("clean code", "scalable", "best practices"). Each principle here carries an
/// `evidence` line naming the thing that was actually built, so the claim is
/// checkable in an interview.
class PrinciplesSection extends StatelessWidget {
  const PrinciplesSection({super.key});

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
              eyebrow: 'How I work',
              title: 'Opinions I hold, and what earned them',
              lead: 'Each of these came out of something breaking, or nearly '
                  'breaking, in production.',
            ),
          ),
          const SizedBox(height: Space.xl),
          AutoGrid(
            columns: context.responsive(compact: 1, medium: 2, wide: 2),
            children: [
              for (var i = 0; i < Profile.principles.length; i++)
                Reveal(
                  delay: Duration(milliseconds: 50 * i),
                  child: GlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: c.accentSoft,
                                borderRadius: BorderRadius.circular(Radii.sm),
                              ),
                              child: Icon(Profile.principles[i].icon,
                                  size: 15, color: c.accent),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 3),
                                child: Text(
                                  Profile.principles[i].title,
                                  style: theme.textTheme.titleLarge,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: Space.md),
                        Text(Profile.principles[i].body,
                            style: theme.textTheme.bodyMedium),
                        const SizedBox(height: Space.md),
                        Container(
                          padding: const EdgeInsets.all(11),
                          decoration: BoxDecoration(
                            color: c.canvas.withValues(alpha: 0.45),
                            borderRadius: BorderRadius.circular(Radii.sm),
                            border: Border(
                              left: BorderSide(color: c.accentAlt, width: 2),
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.check_circle_outline_rounded,
                                  size: 13, color: c.accentAlt),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  Profile.principles[i].evidence,
                                  style: theme.textTheme.bodySmall
                                      ?.copyWith(fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
