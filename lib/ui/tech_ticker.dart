import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';

import '../app/theme/tokens.dart';
import '../data/profile.dart';

/// Slow-drifting strip of the working stack, between the hero and the first
/// section. Pure texture: it carries no information the skills section does
/// not, so it is excluded from semantics apart from a single summary label.
///
/// Implemented as an unscrollable infinite ListView driven by a ticker —
/// items repeat modulo the list, so the strip needs no width measurement and
/// never runs out. Static under reduced motion.
class TechTicker extends StatefulWidget {
  const TechTicker({super.key});

  @override
  State<TechTicker> createState() => _TechTickerState();
}

class _TechTickerState extends State<TechTicker>
    with SingleTickerProviderStateMixin {
  final _scroll = ScrollController();
  Ticker? _ticker;
  Duration _last = Duration.zero;

  /// Logical pixels per second. Slow enough to read, fast enough to be alive.
  static const _speed = 26.0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final still = MediaQuery.disableAnimationsOf(context);
    if (still) {
      _ticker?.dispose();
      _ticker = null;
    } else {
      _ticker ??= createTicker(_onTick)..start();
    }
  }

  void _onTick(Duration elapsed) {
    final dt =
        (elapsed - _last).inMicroseconds / Duration.microsecondsPerSecond;
    // Advanced unconditionally, so a frame skipped by the guards below does
    // not accumulate into one large jump on the next eligible tick.
    _last = elapsed;

    if (!_scroll.hasClients) return;

    // `hasClients` only means a position is attached — not that it has been
    // through layout. The ticker starts from didChangeDependencies, which
    // runs before the ListView below is laid out, so on the first frame the
    // position exists but its scroll extents do not. Reading them then (which
    // `jumpTo` does, via `outOfRange`) throws on a null extent.
    final position = _scroll.position;
    if (!position.haveDimensions) return;

    // dt spikes when the tab regains focus after being backgrounded; skip
    // rather than clamp, so the strip resumes where it left off.
    if (dt <= 0 || dt >= 0.1) return;

    _scroll.jumpTo(position.pixels + _speed * dt);
  }

  @override
  void dispose() {
    _ticker?.dispose();
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    const items = Profile.ticker;

    return Semantics(
      label: 'Technologies: ${items.join(', ')}',
      child: ExcludeSemantics(
        child: Container(
          height: 54,
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: c.hairline),
              bottom: BorderSide(color: c.hairline),
            ),
          ),
          // Fade the strip out at both edges so items enter and leave softly.
          child: ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [
                Colors.transparent,
                Colors.white,
                Colors.white,
                Colors.transparent,
              ],
              stops: [0.0, 0.08, 0.92, 1.0],
            ).createShader(bounds),
            blendMode: BlendMode.dstIn,
            child: ListView.builder(
              controller: _scroll,
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, i) =>
                  _TickerItem(label: items[i % items.length]),
            ),
          ),
        ),
      ),
    );
  }
}

class _TickerItem extends StatelessWidget {
  const _TickerItem({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Transform.rotate(
            angle: 0.785398, // 45° — a diamond, matching nothing else on page.
            child: Container(width: 5, height: 5, color: c.accent),
          ),
          const SizedBox(width: 14),
          Text(
            label.toUpperCase(),
            style: GoogleFonts.jetBrainsMono(
              fontSize: 11,
              letterSpacing: 2.2,
              fontWeight: FontWeight.w500,
              color: c.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}
