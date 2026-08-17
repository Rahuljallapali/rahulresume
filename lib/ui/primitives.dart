import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app/theme/tokens.dart';

/// Applies the accent gradient to any text via a shader mask.
class GradientText extends StatelessWidget {
  const GradientText(this.text, {super.key, this.style, this.textAlign});

  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return ShaderMask(
      // srcIn keeps only the glyph coverage, so the gradient paints the
      // letterforms rather than a box behind them.
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => LinearGradient(
        colors: [c.accent, c.accentAlt],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(bounds),
      child: Text(
        text,
        textAlign: textAlign,
        // Colour must be opaque white for srcIn to keep full glyph alpha.
        style: (style ?? const TextStyle()).copyWith(color: Colors.white),
      ),
    );
  }
}

/// Primary/secondary button with a subtle magnetic pull toward the cursor.
///
/// The pull is capped at 6px and disabled under reduced-motion; enough to feel
/// responsive, not enough to make the target hard to hit.
class MagneticButton extends StatefulWidget {
  const MagneticButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.filled = true,
    this.expand = false,
    this.busy = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool filled;
  final bool expand;
  final bool busy;

  @override
  State<MagneticButton> createState() => _MagneticButtonState();
}

class _MagneticButtonState extends State<MagneticButton> {
  Offset _pull = Offset.zero;
  bool _hovered = false;

  void _onHover(PointerEvent e) {
    if (MediaQuery.disableAnimationsOf(context)) return;
    final box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return;

    final local = box.globalToLocal(e.position);
    final center = Offset(box.size.width / 2, box.size.height / 2);
    final delta = local - center;
    const maxPull = 6.0;

    setState(() {
      _pull = Offset(
        (delta.dx / center.dx).clamp(-1.0, 1.0) * maxPull,
        (delta.dy / center.dy).clamp(-1.0, 1.0) * maxPull,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final theme = Theme.of(context);
    final enabled = widget.onPressed != null && !widget.busy;

    final fg = widget.filled
        ? (theme.brightness == Brightness.dark
            ? const Color(0xFF06070A)
            : Colors.white)
        : c.textPrimary;

    return MouseRegion(
      cursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _hovered = true),
      onHover: _onHover,
      onExit: (_) => setState(() {
        _hovered = false;
        _pull = Offset.zero;
      }),
      child: AnimatedSlide(
        duration: Motion.fast,
        // Offset is a fraction of the button size; converting the pixel pull
        // to a fraction keeps the effect consistent across button widths.
        offset: Offset(_pull.dx / 100, _pull.dy / 100),
        child: Semantics(
          button: true,
          enabled: enabled,
          label: widget.label,
          child: AnimatedContainer(
            duration: Motion.base,
            curve: Motion.standard,
            width: widget.expand ? double.infinity : null,
            decoration: BoxDecoration(
              gradient: widget.filled
                  ? LinearGradient(
                      colors: _hovered
                          ? [c.accentAlt, c.accent]
                          : [c.accent, c.accentAlt],
                    )
                  : null,
              color: widget.filled ? null : c.glassFill,
              borderRadius: BorderRadius.circular(Radii.pill),
              border: Border.all(
                color: widget.filled
                    ? Colors.transparent
                    : (_hovered ? c.accent : c.glassBorder),
              ),
              boxShadow: _hovered && widget.filled
                  ? [
                      BoxShadow(
                        color: c.accent.withValues(alpha: 0.4),
                        blurRadius: 28,
                        offset: const Offset(0, 8),
                      ),
                    ]
                  : null,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: enabled ? widget.onPressed : null,
                borderRadius: BorderRadius.circular(Radii.pill),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 26,
                    vertical: 15,
                  ),
                  child: Row(
                    mainAxisSize:
                        widget.expand ? MainAxisSize.max : MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (widget.busy)
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(fg),
                          ),
                        )
                      else if (widget.icon != null)
                        Icon(widget.icon, size: 17, color: fg),
                      if (widget.busy || widget.icon != null)
                        const SizedBox(width: 10),
                      // Flexible so a long label inside an expanded button —
                      // or a narrow column — ellipsises instead of overflowing
                      // the pill. Unconstrained rows are unaffected.
                      Flexible(
                        child: Text(
                          widget.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style:
                              theme.textTheme.labelLarge?.copyWith(color: fg),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Small pill used for technology tags.
class TagChip extends StatelessWidget {
  const TagChip(this.label, {super.key, this.accent = false, this.icon});

  final String label;
  final bool accent;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: icon != null ? 10 : 11,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: accent ? c.accentSoft : c.glassFill,
        borderRadius: BorderRadius.circular(Radii.sm),
        border: Border.all(
          color: accent ? c.accent.withValues(alpha: 0.35) : c.glassBorder,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: accent ? c.accent : c.textTertiary),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: accent ? c.accent : c.textSecondary,
                  fontWeight: FontWeight.w500,
                  fontSize: 12.5,
                ),
          ),
        ],
      ),
    );
  }
}

/// Counts up to [value] once revealed. Pure display — the number itself comes
/// from profile data, this only animates reaching it.
class AnimatedCounter extends StatefulWidget {
  const AnimatedCounter({
    super.key,
    required this.value,
    this.prefix = '',
    this.suffix = '',
    this.style,
  });

  final int value;
  final String prefix;
  final String suffix;
  final TextStyle? style;

  @override
  State<AnimatedCounter> createState() => _AnimatedCounterState();
}

class _AnimatedCounterState extends State<AnimatedCounter>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..forward();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) {
      return Text('${widget.prefix}${widget.value}${widget.suffix}',
          style: widget.style);
    }
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = Curves.easeOutExpo.transform(_controller.value);
        final shown = (widget.value * t).round();
        return Text(
          '${widget.prefix}$shown${widget.suffix}',
          style: widget.style,
        );
      },
    );
  }
}

/// Label + animated bar for a skill proficiency.
class SkillBar extends StatelessWidget {
  const SkillBar({
    super.key,
    required this.name,
    required this.level,
    this.evidence,
  });

  final String name;
  final double level;
  final String? evidence;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  name,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: c.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (evidence != null)
                Flexible(
                  child: Text(
                    evidence!,
                    textAlign: TextAlign.right,
                    style: theme.textTheme.bodySmall?.copyWith(fontSize: 11.5),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 7),
          // Semantics carries the level as a percentage so a screen reader
          // conveys the same information the bar does visually.
          Semantics(
            label: '$name proficiency',
            value: '${(level * 100).round()} percent',
            child: ClipRRect(
              borderRadius: BorderRadius.circular(Radii.pill),
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: level),
                duration: const Duration(milliseconds: 1100),
                curve: Curves.easeOutCubic,
                builder: (context, v, _) => LinearProgressIndicator(
                  value: v,
                  minHeight: 5,
                  backgroundColor: c.hairline,
                  valueColor: AlwaysStoppedAnimation(
                    Color.lerp(c.accentAlt, c.accent, level)!,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Copies [value] to the clipboard and confirms inline.
class CopyButton extends StatefulWidget {
  const CopyButton({super.key, required this.value, required this.label});

  final String value;
  final String label;

  @override
  State<CopyButton> createState() => _CopyButtonState();
}

class _CopyButtonState extends State<CopyButton> {
  bool _copied = false;

  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: widget.value));
    if (!mounted) return;
    setState(() => _copied = true);
    await Future<void>.delayed(const Duration(milliseconds: 1600));
    if (mounted) setState(() => _copied = false);
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Tooltip(
      message: _copied ? 'Copied' : 'Copy ${widget.label}',
      child: IconButton(
        onPressed: _copy,
        splashRadius: 18,
        iconSize: 16,
        // Announce the state change so the confirmation is not visual-only.
        icon: AnimatedSwitcher(
          duration: Motion.fast,
          child: Icon(
            _copied ? Icons.check_rounded : Icons.copy_rounded,
            key: ValueKey(_copied),
            color: _copied ? c.success : c.textTertiary,
            size: 16,
            semanticLabel: _copied ? 'Copied' : 'Copy ${widget.label}',
          ),
        ),
      ),
    );
  }
}

/// Section heading with an eyebrow label and optional lead paragraph.
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.eyebrow,
    required this.title,
    this.lead,
  });

  final String eyebrow;
  final String title;
  final String? lead;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 18,
              height: 2,
              decoration: BoxDecoration(
                color: c.accent,
                borderRadius: BorderRadius.circular(Radii.pill),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              eyebrow.toUpperCase(),
              style: theme.textTheme.labelMedium?.copyWith(color: c.accent),
            ),
          ],
        ),
        const SizedBox(height: Space.md),
        // A heading element for assistive tech and for the document outline.
        Semantics(
          header: true,
          child: Text(title, style: theme.textTheme.displaySmall),
        ),
        if (lead != null) ...[
          const SizedBox(height: Space.md),
          ConstrainedBox(
            // ~70 characters at this size — the readable measure.
            constraints: const BoxConstraints(maxWidth: 640),
            child: Text(lead!, style: theme.textTheme.bodyLarge),
          ),
        ],
      ],
    );
  }
}

/// Thin progress bar pinned under the header showing read position.
class ScrollProgressBar extends StatelessWidget {
  const ScrollProgressBar({super.key, required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return SizedBox(
      height: 2,
      child: Align(
        alignment: Alignment.centerLeft,
        child: FractionallySizedBox(
          widthFactor: progress.clamp(0.0, 1.0),
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [c.accent, c.accentAlt]),
            ),
          ),
        ),
      ),
    );
  }
}

/// Ambient background: two slow-drifting radial blooms plus a fine grid.
///
/// Painted once behind the whole page rather than per-section, and the
/// animation is a single 40-second controller — cheap enough to leave running,
/// and skipped entirely under reduced-motion.
class AmbientBackground extends StatefulWidget {
  const AmbientBackground({super.key, required this.child});

  final Widget child;

  @override
  State<AmbientBackground> createState() => _AmbientBackgroundState();
}

class _AmbientBackgroundState extends State<AmbientBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 40),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final still = MediaQuery.disableAnimationsOf(context);

    return Stack(
      children: [
        Positioned.fill(
          child: RepaintBoundary(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) => CustomPaint(
                painter: _AmbientPainter(
                  t: still ? 0.12 : _controller.value,
                  glow: c.glow,
                  accent: c.accentAlt,
                  grid: c.hairline,
                ),
              ),
            ),
          ),
        ),
        widget.child,
      ],
    );
  }
}

class _AmbientPainter extends CustomPainter {
  const _AmbientPainter({
    required this.t,
    required this.glow,
    required this.accent,
    required this.grid,
  });

  final double t;
  final Color glow;
  final Color accent;
  final Color grid;

  @override
  void paint(Canvas canvas, Size size) {
    // Grid first, so the blooms sit over it and soften it.
    final gridPaint = Paint()
      ..color = grid.withValues(alpha: 0.5)
      ..strokeWidth = 1;
    const cell = 68.0;
    for (double x = 0; x < size.width; x += cell) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += cell) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Two blooms on offset orbits so they never sync up into one shape.
    final a = 2 * math.pi * t;
    _bloom(
      canvas,
      Offset(size.width * (0.24 + 0.06 * math.cos(a)),
          size.height * (0.16 + 0.05 * math.sin(a))),
      size.width * 0.46,
      glow.withValues(alpha: 0.30),
    );
    _bloom(
      canvas,
      Offset(size.width * (0.82 + 0.05 * math.cos(a + math.pi)),
          size.height * (0.52 + 0.06 * math.sin(a + math.pi))),
      size.width * 0.34,
      accent.withValues(alpha: 0.14),
    );
  }

  void _bloom(Canvas canvas, Offset center, double radius, Color color) {
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..shader = RadialGradient(
          colors: [color, color.withValues(alpha: 0)],
        ).createShader(Rect.fromCircle(center: center, radius: radius)),
    );
  }

  @override
  bool shouldRepaint(_AmbientPainter old) =>
      old.t != t || old.glow != glow || old.grid != grid;
}
