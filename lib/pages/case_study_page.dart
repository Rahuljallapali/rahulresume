import 'package:flutter/material.dart';

import '../app/theme/tokens.dart';
import '../data/models.dart';
import '../data/profile.dart';
import '../ui/detail_shell.dart';
import '../ui/glass_card.dart';
import '../ui/layout.dart';
import '../ui/primitives.dart';
import '../ui/reveal.dart';
import '../utils/link.dart';

/// Full case study for one [Project], at `/#/work/<slug>`.
///
/// The home page shows a project in a card that expands; this is the version
/// you can send someone. Same data, no truncation, its own URL.
class CaseStudyPage extends StatelessWidget {
  const CaseStudyPage({super.key, required this.project});

  final Project project;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final theme = Theme.of(context);
    final p = project;

    // Everything except this one, for the strip at the bottom.
    final others =
        Profile.projects.where((other) => other.slug != p.slug).toList();

    return DetailShell(
      backLabel: 'Back',
      children: [
        ContentShell(
          vertical: Space.xl,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: Space.sm,
                runSpacing: Space.sm,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  if (p.isFlagship)
                    const TagChip('Flagship',
                        accent: true, icon: Icons.star_rounded),
                  if (p.kind == ProjectKind.personal) const TagChip('Personal'),
                  for (final tag in p.tags) TagChip(tag),
                ],
              ),
              const SizedBox(height: Space.lg),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 900),
                child: Text(
                  p.name,
                  style: context.isCompact
                      ? theme.textTheme.displaySmall
                      : theme.textTheme.displayMedium,
                ),
              ),
              const SizedBox(height: Space.md),
              Text(
                p.role,
                style: theme.textTheme.titleMedium?.copyWith(color: c.accent),
              ),
              const SizedBox(height: Space.lg),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: Text(p.summary, style: theme.textTheme.bodyLarge),
              ),
              if (p.metrics.isNotEmpty) ...[
                const SizedBox(height: Space.xl),
                Wrap(
                  spacing: Space.xxl,
                  runSpacing: Space.lg,
                  children: [
                    for (final m in p.metrics)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AnimatedCounter(
                            value: m.value,
                            prefix: m.prefix,
                            suffix: m.suffix,
                            style: theme.textTheme.displaySmall
                                ?.copyWith(color: c.accent),
                          ),
                          const SizedBox(height: 3),
                          Text(m.label, style: theme.textTheme.bodyMedium),
                          Text(
                            m.detail,
                            style: theme.textTheme.bodySmall
                                ?.copyWith(fontSize: 11.5),
                          ),
                        ],
                      ),
                  ],
                ),
              ],
              const SizedBox(height: Space.xl),
              Wrap(
                spacing: Space.sm,
                runSpacing: Space.sm,
                children: [for (final s in p.stack) TagChip(s)],
              ),
              if (p.liveUrl != null || p.repoUrl != null) ...[
                const SizedBox(height: Space.xl),
                Wrap(
                  spacing: Space.md,
                  runSpacing: Space.md,
                  children: [
                    if (p.liveUrl != null)
                      MagneticButton(
                        label: 'View live',
                        icon: Icons.open_in_new_rounded,
                        onPressed: () => openLink(p.liveUrl!),
                      ),
                    if (p.repoUrl != null)
                      MagneticButton(
                        label: 'Source',
                        icon: Icons.code_rounded,
                        filled: false,
                        onPressed: () => openLink(p.repoUrl!),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
        if (p.challenge != null)
          Reveal(
            child: ContentShell(
              vertical: Space.lg,
              child: _Block(
                icon: Icons.report_problem_outlined,
                eyebrow: 'The hard part',
                body: p.challenge!,
              ),
            ),
          ),
        if (p.architecture != null)
          Reveal(
            child: ContentShell(
              vertical: Space.lg,
              child: _Block(
                icon: Icons.account_tree_outlined,
                eyebrow: 'Architecture',
                body: p.architecture!,
              ),
            ),
          ),
        if (p.highlights.isNotEmpty)
          Reveal(
            child: ContentShell(
              vertical: Space.lg,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('What it does', style: theme.textTheme.headlineSmall),
                  const SizedBox(height: Space.lg),
                  AutoGrid(
                    columns: context.responsive(compact: 1, medium: 2, wide: 2),
                    children: [
                      for (final h in p.highlights)
                        GlassCard(
                          interactive: false,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    margin: const EdgeInsets.only(
                                        top: 7, right: 10),
                                    width: 5,
                                    height: 5,
                                    decoration: BoxDecoration(
                                      color: c.accentAlt,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(h.title,
                                        style: theme.textTheme.titleMedium),
                                  ),
                                ],
                              ),
                              const SizedBox(height: Space.sm),
                              Text(h.body, style: theme.textTheme.bodyMedium),
                            ],
                          ),
                        ),
                    ],
                  ),
                  if (p.privateNote != null) ...[
                    const SizedBox(height: Space.lg),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.lock_outline_rounded,
                            size: 14, color: c.textTertiary),
                        const SizedBox(width: 9),
                        Expanded(
                          child: Text(
                            p.privateNote!,
                            style: theme.textTheme.bodySmall
                                ?.copyWith(fontStyle: FontStyle.italic),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        if (others.isNotEmpty)
          Reveal(
            child: ContentShell(
              vertical: Space.xl,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Other work', style: theme.textTheme.headlineSmall),
                  const SizedBox(height: Space.lg),
                  AutoGrid(
                    columns: context.responsive(compact: 1, medium: 3, wide: 3),
                    children: [
                      for (final other in others) _MiniCard(project: other),
                    ],
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _Block extends StatelessWidget {
  const _Block({
    required this.icon,
    required this.eyebrow,
    required this.body,
  });

  final IconData icon;
  final String eyebrow;
  final String body;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: c.accentAlt),
            const SizedBox(width: 9),
            Text(
              eyebrow.toUpperCase(),
              style: theme.textTheme.labelMedium?.copyWith(color: c.accentAlt),
            ),
          ],
        ),
        const SizedBox(height: Space.md),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: Text(
            body,
            style: theme.textTheme.bodyLarge?.copyWith(height: 1.75),
          ),
        ),
      ],
    );
  }
}

class _MiniCard extends StatelessWidget {
  const _MiniCard({required this.project});
  final Project project;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final theme = Theme.of(context);

    return GlassCard(
      // pushReplacement, not push: chaining case studies would otherwise build
      // an unbounded back stack of sibling pages.
      onTap: () =>
          Navigator.of(context).pushReplacementNamed('/work/${project.slug}'),
      semanticLabel: 'Read the ${project.name} case study',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(project.name, style: theme.textTheme.titleLarge),
          const SizedBox(height: 5),
          Text(
            project.role,
            style: theme.textTheme.bodySmall?.copyWith(color: c.accent),
          ),
          const SizedBox(height: Space.sm),
          Text(
            project.summary,
            style: theme.textTheme.bodySmall,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
