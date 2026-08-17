import 'package:flutter/material.dart';

import '../app/theme/tokens.dart';

/// Fades and lifts its child in the first time it scrolls into view.
///
/// Triggers off layout geometry rather than a scroll listener per widget, and
/// never reverses — content that has been read does not animate away when
/// scrolled past, which is distracting.
///
/// Honours `MediaQuery.disableAnimations`, so a visitor with reduced-motion
/// enabled gets the content immediately with no transform.
class Reveal extends StatefulWidget {
  const Reveal({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.offset = 24,
  });

  final Widget child;

  /// Stagger offset when several reveals share a row or grid.
  final Duration delay;

  /// Vertical travel in logical pixels.
  final double offset;

  @override
  State<Reveal> createState() => _RevealState();
}

class _RevealState extends State<Reveal> with SingleTickerProviderStateMixin {
  /// The stagger is folded into the controller's duration and expressed as an
  /// [Interval] on the curve, rather than scheduling a `Future.delayed`.
  ///
  /// A raw timer would keep firing after the widget is gone — harmless here
  /// because of the `mounted` check, but it still leaves a pending timer that
  /// outlives the tree, which the test binding rightly flags.
  late final Duration _total = widget.delay + Motion.slow;

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: _total,
  );

  late final Animation<double> _animation = CurvedAnimation(
    parent: _controller,
    curve: Interval(
      _total.inMicroseconds == 0
          ? 0.0
          : widget.delay.inMicroseconds / _total.inMicroseconds,
      1.0,
      curve: Curves.easeOutCubic,
    ),
  );

  bool _triggered = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _trigger() {
    if (_triggered) return;
    _triggered = true;
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    // Reduced motion: render final state, skip the animation entirely.
    if (MediaQuery.disableAnimationsOf(context)) return widget.child;

    return _OnVisible(
      onVisible: _trigger,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          final t = _animation.value;
          return Opacity(
            opacity: t,
            child: Transform.translate(
              offset: Offset(0, widget.offset * (1 - t)),
              child: child,
            ),
          );
        },
        child: widget.child,
      ),
    );
  }
}

/// Fires [onVisible] once when any part of the subtree enters the viewport.
///
/// Deliberately geometry-based: it listens to the enclosing [ScrollPosition]
/// and compares its own paint bounds to the viewport, then unsubscribes. That
/// keeps the cost to one comparison per scroll frame per pending widget, and
/// zero once everything has revealed.
///
/// It listens to the position rather than to `ScrollNotification`, because
/// notifications bubble upwards from the `Scrollable` — a listener sitting
/// among its descendants, as this one does, would never receive one.
class _OnVisible extends StatefulWidget {
  const _OnVisible({required this.child, required this.onVisible});

  final Widget child;
  final VoidCallback onVisible;

  @override
  State<_OnVisible> createState() => _OnVisibleState();
}

class _OnVisibleState extends State<_OnVisible> {
  bool _done = false;
  bool _pending = false;
  ScrollPosition? _position;

  @override
  void initState() {
    super.initState();
    // Anything already on screen at first paint should reveal without
    // requiring the visitor to scroll.
    WidgetsBinding.instance.addPostFrameCallback((_) => _check());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _subscribe();
  }

  @override
  void dispose() {
    _unsubscribe();
    super.dispose();
  }

  void _subscribe() {
    if (_done) return;
    final position = Scrollable.maybeOf(context)?.position;
    if (identical(position, _position)) return;
    _unsubscribe();
    _position = position?..addListener(_onScrolled);
  }

  void _unsubscribe() {
    _position?.removeListener(_onScrolled);
    _position = null;
  }

  /// The position notifies from inside `setPixels`, before the frame is laid
  /// out at the new offset — reading geometry there would be one frame stale.
  /// Deferring to the post-frame callback reads the offset actually painted,
  /// and the flag coalesces a burst of notifications into one check.
  void _onScrolled() {
    if (_done || _pending) return;
    _pending = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _pending = false;
      _check();
    });
  }

  void _check() {
    if (_done || !mounted) return;

    final box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize || !box.attached) return;

    final screenHeight = MediaQuery.sizeOf(context).height;
    final top = box.localToGlobal(Offset.zero).dy;

    // Trigger slightly before the element is fully on screen so the animation
    // is already underway by the time it is comfortably readable.
    const preload = 80.0;
    final isVisible = top < screenHeight - preload && top + box.size.height > 0;

    if (isVisible) {
      _done = true;
      _unsubscribe();
      widget.onVisible();
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
