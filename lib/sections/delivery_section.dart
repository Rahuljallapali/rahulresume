import 'package:flutter/material.dart';

import '../app/theme/tokens.dart';
import '../data/profile.dart';
import '../ui/glass_card.dart';
import '../ui/layout.dart';
import '../ui/primitives.dart';
import '../ui/reveal.dart';

/// Build and deployment. Scoped strictly to what exists in the repositories:
/// the container image and its AWS integrations. The closing note states
/// plainly what is not yet automated, because a recruiter will ask and an
/// honest boundary is more credible than an unverifiable claim.
class DeliverySection extends StatelessWidget {
  const DeliverySection({super.key});

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
              eyebrow: 'Build & deployment',
              title: 'How the backend reaches production',
              lead: 'The service ships as a container image built on a JRE 21 '
                  'base and runs on EC2. Layer ordering is the part worth '
                  'looking at.',
            ),
          ),
          const SizedBox(height: Space.xl),
          const Reveal(child: _PipelineFlow()),
          const SizedBox(height: Space.lg),
          Reveal(
            child: GlassCard(
              interactive: false,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline_rounded,
                      size: 16, color: c.accentAlt),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      Profile.devOpsNote,
                      style: theme.textTheme.bodyMedium,
                    ),
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

/// The stage sequence. Renders as a horizontal flow with connectors on wide
/// screens and a vertical list on narrow ones, rather than shrinking the
/// horizontal version into illegibility.
class _PipelineFlow extends StatelessWidget {
  const _PipelineFlow();

  @override
  Widget build(BuildContext context) {
    const stages = Profile.deliveryStages;

    if (context.isCompact) {
      return Column(
        children: [
          for (var i = 0; i < stages.length; i++) ...[
            _StageCard(index: i, total: stages.length),
            if (i < stages.length - 1) const _VerticalConnector(),
          ],
        ],
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        // Two rows of stages read better than five cramped columns.
        const perRow = 3;
        final rows = <List<int>>[];
        for (var i = 0; i < stages.length; i += perRow) {
          rows.add([
            for (var j = i; j < i + perRow && j < stages.length; j++) j,
          ]);
        }

        return Column(
          children: [
            for (var r = 0; r < rows.length; r++)
              Padding(
                padding:
                    EdgeInsets.only(bottom: r < rows.length - 1 ? Space.md : 0),
                // IntrinsicHeight gives the row a bounded height so the cards
                // can stretch to match the tallest one. Without it, `stretch`
                // inside a vertically unbounded scroll view asks each child to
                // lay out at infinite height.
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (var k = 0; k < rows[r].length; k++) ...[
                        Expanded(
                          child: _StageCard(
                            index: rows[r][k],
                            total: stages.length,
                          ),
                        ),
                        if (k < rows[r].length - 1) const _Connector(),
                      ],
                      // Pad the final short row so its cards keep the same
                      // width as the row above instead of stretching.
                      for (var f = rows[r].length; f < perRow; f++) ...[
                        const _Connector(invisible: true),
                        const Expanded(child: SizedBox()),
                      ],
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _StageCard extends StatelessWidget {
  const _StageCard({required this.index, required this.total});

  final int index;
  final int total;

  @override
  Widget build(BuildContext context) {
    final stage = Profile.deliveryStages[index];
    final c = AppColors.of(context);
    final theme = Theme.of(context);

    return GlassCard(
      padding: const EdgeInsets.all(Space.md),
      semanticLabel:
          'Stage ${index + 1} of $total: ${stage.label}. ${stage.detail}',
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
                child: Icon(stage.icon, size: 14, color: c.accent),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(stage.label,
                    style: theme.textTheme.titleSmall
                        ?.copyWith(color: c.textPrimary)),
              ),
              Text(
                '0${index + 1}',
                style:
                    theme.textTheme.labelSmall?.copyWith(color: c.textTertiary),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(stage.detail, style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _Connector extends StatelessWidget {
  const _Connector({this.invisible = false});
  final bool invisible;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return SizedBox(
      width: 26,
      child: invisible
          ? null
          : Center(
              child: Icon(Icons.arrow_forward_rounded,
                  size: 15, color: c.textTertiary),
            ),
    );
  }
}

class _VerticalConnector extends StatelessWidget {
  const _VerticalConnector();

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child:
          Icon(Icons.arrow_downward_rounded, size: 15, color: c.textTertiary),
    );
  }
}
