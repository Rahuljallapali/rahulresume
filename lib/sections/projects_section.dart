import 'package:flutter/material.dart';

import '../app/router.dart';
import '../app/theme/tokens.dart';
import '../data/models.dart';
import '../data/profile.dart';
import '../ui/glass_card.dart';
import '../ui/layout.dart';
import '../ui/primitives.dart';
import '../ui/reveal.dart';
import '../utils/link.dart';

/// Work section with facet filtering.
///
/// Filter state is local rather than lifted to a provider: nothing outside
/// this subtree needs to know which facet is selected, and keeping it here
/// means selecting a filter repaints only the grid.
class ProjectsSection extends StatefulWidget {
  const ProjectsSection({super.key});

  @override
  State<ProjectsSection> createState() => _ProjectsSectionState();
}

class _ProjectsSectionState extends State<ProjectsSection> {
  String _filter = Profile.projectFilters.first;

  List<Project> get _visible => _filter == 'All'
      ? Profile.projects
      : Profile.projects.where((p) => p.tags.contains(_filter)).toList();

  @override
  Widget build(BuildContext context) {
    final projects = _visible;

    return ContentShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Reveal(
            child: SectionHeader(
              eyebrow: 'Selected work',
              title: 'Systems I have shipped',
              lead: 'Production software with real users and real constraints. '
                  'Client work lives in private repositories, so the detail '
                  'below is architecture and trade-offs rather than a source '
                  'link.',
            ),
          ),
          const SizedBox(height: Space.xl),
          Reveal(
            child: Wrap(
              spacing: Space.sm,
              runSpacing: Space.sm,
              children: [
                for (final f in Profile.projectFilters)
                  _FilterChip(
                    label: f,
                    selected: _filter == f,
                    count: f == 'All'
                        ? Profile.projects.length
                        : Profile.projects
                            .where((p) => p.tags.contains(f))
                            .length,
                    onTap: () => setState(() => _filter = f),
                  ),
              ],
            ),
          ),
          const SizedBox(height: Space.xl),
          if (projects.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: Space.xxl),
              child: Text(
                'Nothing under this filter yet.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            )
          else
            Column(
              children: [
                for (final p in projects)
                  Padding(
                    padding: const EdgeInsets.only(bottom: Space.lg),
                    // Keying by name so switching filters rebuilds cards
                    // rather than recycling one project's state into another.
                    child: Reveal(
                      key: ValueKey(p.name),
                      child: _ProjectCard(project: p),
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.count,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final int count;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final theme = Theme.of(context);

    return Semantics(
      button: true,
      selected: selected,
      label: '$label filter, $count projects',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Radii.pill),
        child: AnimatedContainer(
          duration: Motion.fast,
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 9),
          decoration: BoxDecoration(
            color: selected ? c.accent : c.glassFill,
            borderRadius: BorderRadius.circular(Radii.pill),
            border: Border.all(color: selected ? c.accent : c.glassBorder),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: selected
                      ? (theme.brightness == Brightness.dark
                          ? const Color(0xFF06070A)
                          : Colors.white)
                      : c.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 7),
              Text(
                '$count',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontSize: 11,
                  color: selected
                      ? (theme.brightness == Brightness.dark
                              ? const Color(0xFF06070A)
                              : Colors.white)
                          .withValues(alpha: 0.7)
                      : c.textTertiary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// One project. Collapsed by default to a scannable summary; the architecture,
/// challenge and highlight detail expand on demand so the section stays
/// skimmable for a recruiter and deep for an engineer.
class _ProjectCard extends StatefulWidget {
  const _ProjectCard({required this.project});
  final Project project;

  @override
  State<_ProjectCard> createState() => _ProjectCardState();
}

class _ProjectCardState extends State<_ProjectCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final p = widget.project;
    final c = AppColors.of(context);
    final theme = Theme.of(context);

    return GlassCard(
      accentBorder: p.isFlagship,
      padding: EdgeInsets.all(context.isCompact ? Space.lg : Space.xl),
      semanticLabel: '${p.name}. ${p.summary}',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: Space.sm,
                      runSpacing: Space.sm,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(p.name, style: theme.textTheme.headlineSmall),
                        if (p.isFlagship)
                          const TagChip('Flagship',
                              accent: true, icon: Icons.star_rounded),
                        if (p.kind == ProjectKind.personal)
                          const TagChip('Personal'),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      p.role,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: c.accent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: Space.md),

          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: Text(p.summary, style: theme.textTheme.bodyLarge),
          ),

          if (p.metrics.isNotEmpty) ...[
            const SizedBox(height: Space.lg),
            Wrap(
              spacing: Space.xl,
              runSpacing: Space.md,
              children: [
                for (final m in p.metrics)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            '${m.prefix}${m.value}${m.suffix}',
                            style: theme.textTheme.headlineSmall
                                ?.copyWith(color: c.accent),
                          ),
                          const SizedBox(width: 6),
                          Text(m.label, style: theme.textTheme.bodySmall),
                        ],
                      ),
                      Text(
                        m.detail,
                        style:
                            theme.textTheme.bodySmall?.copyWith(fontSize: 11),
                      ),
                    ],
                  ),
              ],
            ),
          ],

          const SizedBox(height: Space.lg),
          Wrap(
            spacing: Space.sm,
            runSpacing: Space.sm,
            children: [for (final s in p.stack) TagChip(s)],
          ),

          const SizedBox(height: Space.lg),
          Divider(color: c.hairline),
          const SizedBox(height: Space.sm),

          // Toggle left, links right. A Wrap rather than Row + Spacer because
          // on the narrowest phones the two groups do not fit on one line, and
          // a Spacer cannot give back space it does not have — it overflowed.
          // The full-width box is what lets spaceBetween separate the groups;
          // a bare Wrap would shrink to its content and bunch them together.
          SizedBox(
            width: double.infinity,
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              runSpacing: Space.sm,
              children: [
                _ExpandToggle(
                  expanded: _expanded,
                  label: p.name,
                  onTap: () => setState(() => _expanded = !_expanded),
                ),
                // A nested Wrap, not a Row: with the case-study link added
                // there are now up to three actions plus the private-repo
                // note, which cannot fit on one line on a phone.
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    _LinkAction(
                      icon: Icons.article_outlined,
                      label: 'Case study',
                      accent: true,
                      onTap: () => AppRouter.openCaseStudy(context, p.slug),
                    ),
                    if (p.liveUrl != null)
                      _LinkAction(
                        icon: Icons.open_in_new_rounded,
                        label: 'Live',
                        onTap: () => openLink(p.liveUrl!),
                      ),
                    if (p.repoUrl != null)
                      _LinkAction(
                        icon: Icons.code_rounded,
                        label: 'Source',
                        onTap: () => openLink(p.repoUrl!),
                      ),
                    if (p.repoUrl == null && p.privateNote != null)
                      Padding(
                        padding: const EdgeInsets.only(left: Space.sm),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.lock_outline_rounded,
                                size: 13, color: c.textTertiary),
                            const SizedBox(width: 6),
                            Text(
                              'Private repository',
                              style: theme.textTheme.bodySmall
                                  ?.copyWith(fontSize: 11.5),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),

          // AnimatedSize keeps the expand/collapse from snapping, and the
          // subtree is dropped entirely when collapsed so hidden text is not
          // laid out or exposed to assistive tech.
          AnimatedSize(
            duration: Motion.base,
            curve: Motion.standard,
            alignment: Alignment.topCenter,
            child: _expanded
                ? _ProjectDetail(project: p)
                : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }
}

class _ProjectDetail extends StatelessWidget {
  const _ProjectDetail({required this.project});
  final Project project;

  @override
  Widget build(BuildContext context) {
    final p = project;
    final c = AppColors.of(context);
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(top: Space.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (p.challenge != null) ...[
            _DetailBlock(
              icon: Icons.report_problem_outlined,
              title: 'The hard part',
              body: p.challenge!,
            ),
            const SizedBox(height: Space.md),
          ],
          if (p.architecture != null) ...[
            _DetailBlock(
              icon: Icons.account_tree_outlined,
              title: 'Architecture',
              body: p.architecture!,
            ),
            const SizedBox(height: Space.lg),
          ],
          if (p.highlights.isNotEmpty) ...[
            Text(
              'What it does',
              style: theme.textTheme.titleSmall?.copyWith(color: c.textPrimary),
            ),
            const SizedBox(height: Space.md),
            AutoGrid(
              columns: context.responsive(compact: 1, medium: 2, wide: 2),
              spacing: Space.md,
              runSpacing: Space.md,
              children: [
                for (final h in p.highlights)
                  Container(
                    padding: const EdgeInsets.all(Space.md),
                    decoration: BoxDecoration(
                      color: c.canvas.withValues(alpha: 0.45),
                      borderRadius: BorderRadius.circular(Radii.md),
                      border: Border.all(color: c.hairline),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: const EdgeInsets.only(top: 6, right: 9),
                              width: 5,
                              height: 5,
                              decoration: BoxDecoration(
                                color: c.accentAlt,
                                shape: BoxShape.circle,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                h.title,
                                style: theme.textTheme.titleSmall
                                    ?.copyWith(color: c.textPrimary),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(h.body, style: theme.textTheme.bodySmall),
                      ],
                    ),
                  ),
              ],
            ),
          ],
          if (p.privateNote != null) ...[
            const SizedBox(height: Space.md),
            Text(
              p.privateNote!,
              style: theme.textTheme.bodySmall
                  ?.copyWith(fontStyle: FontStyle.italic, fontSize: 11.5),
            ),
          ],
        ],
      ),
    );
  }
}

class _DetailBlock extends StatelessWidget {
  const _DetailBlock({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
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
            Icon(icon, size: 15, color: c.accentAlt),
            const SizedBox(width: 8),
            Text(
              title,
              style: theme.textTheme.titleSmall?.copyWith(color: c.textPrimary),
            ),
          ],
        ),
        const SizedBox(height: 7),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 780),
          child: Text(body, style: theme.textTheme.bodyMedium),
        ),
      ],
    );
  }
}

class _ExpandToggle extends StatelessWidget {
  const _ExpandToggle({
    required this.expanded,
    required this.onTap,
    required this.label,
  });

  final bool expanded;
  final VoidCallback onTap;
  final String label;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Semantics(
      button: true,
      expanded: expanded,
      label: expanded
          ? 'Hide technical detail for $label'
          : 'Show technical detail for $label',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Radii.sm),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                expanded ? 'Hide detail' : 'Technical detail',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: c.accent,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(width: 5),
              AnimatedRotation(
                turns: expanded ? 0.5 : 0,
                duration: Motion.fast,
                child:
                    Icon(Icons.expand_more_rounded, size: 17, color: c.accent),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LinkAction extends StatelessWidget {
  const _LinkAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.accent = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  /// Draws the action in the accent colour — used for the primary action on
  /// the card, which is the one that opens the full write-up.
  final bool accent;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final color = accent ? c.accent : c.textSecondary;

    return Padding(
      padding: const EdgeInsets.only(left: Space.sm),
      child: Semantics(
        link: true,
        label: label,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(Radii.sm),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 14, color: color),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: color,
                        fontWeight: accent ? FontWeight.w700 : FontWeight.w600,
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
