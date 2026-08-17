import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../app/theme/tokens.dart';
import '../data/models.dart';
import '../data/profile.dart';
import '../ui/glass_card.dart';
import '../ui/layout.dart';
import '../ui/primitives.dart';
import '../ui/reveal.dart';

/// How a request actually travels through the service.
///
/// Two renderings of the same data: a painted diagram with a packet animating
/// along the path on wide screens, and a plain vertical list on narrow ones.
/// A scaled-down diagram would be illegible on a phone, and an unreadable
/// diagram communicates nothing — so the phone gets prose instead.
class ArchitectureSection extends StatelessWidget {
  const ArchitectureSection({super.key});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);

    return ContentShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Reveal(
            child: SectionHeader(
              eyebrow: 'How it fits together',
              title: 'One request, end to end',
              lead: 'The path a single API call takes through the Spring Boot '
                  'service — from the app that made it to the row it touches. '
                  'Every box below exists in the repository.',
            ),
          ),
          const SizedBox(height: Space.xl),
          Reveal(
            child: GlassCard(
              interactive: false,
              padding: EdgeInsets.all(context.isCompact ? Space.md : Space.lg),
              child:
                  context.isCompact ? const _ArchList() : const _ArchDiagram(),
            ),
          ),
          const SizedBox(height: Space.md),
          Reveal(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 2,
                  height: 34,
                  margin: const EdgeInsets.only(right: Space.md),
                  decoration: BoxDecoration(
                    color: c.accent,
                    borderRadius: BorderRadius.circular(Radii.pill),
                  ),
                ),
                Expanded(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 720),
                    child: Text(
                      Profile.architectureNote,
                      style: Theme.of(context).textTheme.bodyMedium,
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

/// Wide rendering: columns of node cards with painted connectors behind them
/// and a packet travelling left to right.
class _ArchDiagram extends StatefulWidget {
  const _ArchDiagram();

  @override
  State<_ArchDiagram> createState() => _ArchDiagramState();
}

class _ArchDiagramState extends State<_ArchDiagram>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 6),
  );

  bool _started = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // One repeating controller, started once, and never at all under
    // reduced-motion — the diagram is fully legible standing still.
    if (!_started && !MediaQuery.disableAnimationsOf(context)) {
      _started = true;
      _controller.repeat();
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    const layers = Profile.architectureLayers;

    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            // Connectors are painted underneath the cards so the lines appear
            // to run behind them rather than across their faces.
            Positioned.fill(
              child: RepaintBoundary(
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, _) => CustomPaint(
                    painter: _FlowPainter(
                      t: _controller.isAnimating ? _controller.value : 0.35,
                      columns: layers.length,
                      line: c.hairline,
                      accent: c.accent,
                      accentAlt: c.accentAlt,
                    ),
                  ),
                ),
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var i = 0; i < layers.length; i++) ...[
                  Expanded(child: _LayerColumn(layer: layers[i], index: i)),
                  if (i != layers.length - 1) const SizedBox(width: Space.md),
                ],
              ],
            ),
          ],
        );
      },
    );
  }
}

class _LayerColumn extends StatelessWidget {
  const _LayerColumn({required this.layer, required this.index});

  final ArchLayer layer;
  final int index;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(layer.icon, size: 14, color: c.accent),
            const SizedBox(width: 7),
            Expanded(
              child: Text(
                layer.title.toUpperCase(),
                style: theme.textTheme.labelSmall?.copyWith(color: c.accent),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: Space.md),
        for (final node in layer.nodes)
          Padding(
            padding: const EdgeInsets.only(bottom: Space.sm),
            child: _NodeCard(node: node),
          ),
      ],
    );
  }
}

class _NodeCard extends StatelessWidget {
  const _NodeCard({required this.node});
  final ArchNode node;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(Radii.sm),
        border: Border.all(color: c.hairline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            node.label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: c.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 12.5,
            ),
          ),
          if (node.badge != null) ...[
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: c.accentSoft,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                node.badge!,
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  color: c.accent,
                ),
              ),
            ),
          ],
          const SizedBox(height: 5),
          Text(
            node.detail,
            style:
                theme.textTheme.bodySmall?.copyWith(fontSize: 11, height: 1.4),
          ),
        ],
      ),
    );
  }
}

/// Draws the horizontal spine between columns plus a travelling packet.
class _FlowPainter extends CustomPainter {
  const _FlowPainter({
    required this.t,
    required this.columns,
    required this.line,
    required this.accent,
    required this.accentAlt,
  });

  final double t;
  final int columns;
  final Color line;
  final Color accent;
  final Color accentAlt;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || columns < 2) return;

    // The spine sits just under the column headers, where every column has
    // clear space regardless of how many nodes it holds.
    const y = 7.0;
    final left = size.width * 0.06;
    final right = size.width * 0.94;

    canvas.drawLine(
      Offset(left, y),
      Offset(right, y),
      Paint()
        ..color = line
        ..strokeWidth = 1.5,
    );

    // Tick per column boundary.
    for (var i = 0; i < columns; i++) {
      final x = left + (right - left) * (i / (columns - 1));
      canvas.drawCircle(
        Offset(x, y),
        2.5,
        Paint()..color = line,
      );
    }

    // Packet: eases across, pauses at the far edge, repeats. The pause is what
    // makes it read as a request completing rather than a looping marquee.
    final progress = Curves.easeInOutCubic.transform(
      (t / 0.82).clamp(0.0, 1.0),
    );
    final x = left + (right - left) * progress;

    // Comet tail behind the head.
    final tail = Paint()
      ..shader = LinearGradient(
        colors: [accent.withValues(alpha: 0), accent],
      ).createShader(
        Rect.fromPoints(Offset(math.max(left, x - 70), y), Offset(x, y)),
      )
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(math.max(left, x - 70), y), Offset(x, y), tail);

    canvas.drawCircle(
      Offset(x, y),
      9,
      Paint()..color = accentAlt.withValues(alpha: 0.20),
    );
    canvas.drawCircle(Offset(x, y), 3.5, Paint()..color = accentAlt);
  }

  @override
  bool shouldRepaint(_FlowPainter old) =>
      old.t != t || old.line != line || old.accent != accent;
}

/// Compact rendering: the same layers as a readable vertical sequence.
class _ArchList extends StatelessWidget {
  const _ArchList();

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final theme = Theme.of(context);
    const layers = Profile.architectureLayers;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < layers.length; i++) ...[
          Row(
            children: [
              Icon(layers[i].icon, size: 14, color: c.accent),
              const SizedBox(width: 8),
              Text(
                layers[i].title.toUpperCase(),
                style: theme.textTheme.labelSmall?.copyWith(color: c.accent),
              ),
            ],
          ),
          const SizedBox(height: Space.sm),
          for (final node in layers[i].nodes)
            Padding(
              padding: const EdgeInsets.only(bottom: Space.sm),
              child: _NodeCard(node: node),
            ),
          if (i != layers.length - 1)
            Padding(
              padding: const EdgeInsets.only(bottom: Space.sm),
              child: Row(
                children: [
                  const SizedBox(width: 6),
                  Icon(Icons.south_rounded, size: 15, color: c.textTertiary),
                ],
              ),
            ),
        ],
      ],
    );
  }
}
