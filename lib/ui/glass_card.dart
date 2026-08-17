import 'dart:ui';

import 'package:flutter/material.dart';

import '../app/theme/tokens.dart';

/// Frosted panel used for every card on the site.
///
/// The blur is real ([BackdropFilter]) but applied once per card and clipped to
/// the card bounds, so the ambient background gradient shows through without
/// the cost of blurring the whole page. On hover the card lifts, its border
/// picks up the accent, and a soft accent glow fades in — all driven by one
/// [AnimatedContainer], not a controller per card.
class GlassCard extends StatefulWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(Space.lg),
    this.radius = Radii.lg,
    this.interactive = true,
    this.onTap,
    this.semanticLabel,
    this.blur = 18,
    this.accentBorder = false,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;

  /// When false the card never responds to hover — used for static panels.
  final bool interactive;
  final VoidCallback? onTap;
  final String? semanticLabel;
  final double blur;

  /// Draws the accent border at rest instead of only on hover.
  final bool accentBorder;

  @override
  State<GlassCard> createState() => _GlassCardState();
}

class _GlassCardState extends State<GlassCard> {
  bool _hovered = false;
  bool _focused = false;

  bool get _active => (_hovered || _focused) && widget.interactive;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final radius = BorderRadius.circular(widget.radius);

    Widget card = AnimatedContainer(
      duration: Motion.base,
      curve: Motion.standard,
      transform: Matrix4.translationValues(0, _active ? -4 : 0, 0),
      decoration: BoxDecoration(
        color: _active ? c.surfaceElevated : c.glassFill,
        borderRadius: radius,
        border: Border.all(
          color: _active || widget.accentBorder
              ? c.accent.withValues(alpha: _active ? 0.5 : 0.28)
              : c.glassBorder,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: _active ? 0.28 : 0.14),
            blurRadius: _active ? 36 : 20,
            offset: Offset(0, _active ? 14 : 8),
          ),
          if (_active)
            BoxShadow(
              color: c.accent.withValues(alpha: 0.16),
              blurRadius: 44,
              spreadRadius: -6,
            ),
        ],
      ),
      padding: widget.padding,
      child: widget.child,
    );

    card = ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: widget.blur, sigmaY: widget.blur),
        child: card,
      ),
    );

    if (widget.onTap == null && !widget.interactive) {
      return Semantics(label: widget.semanticLabel, child: card);
    }

    return FocusableActionDetector(
      // Focus tracking mirrors hover so keyboard users get the same affordance
      // mouse users get, which is the whole point of a visible focus state.
      onShowHoverHighlight: (v) => setState(() => _hovered = v),
      onShowFocusHighlight: (v) => setState(() => _focused = v),
      mouseCursor:
          widget.onTap != null ? SystemMouseCursors.click : MouseCursor.defer,
      actions: {
        if (widget.onTap != null)
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (_) {
              widget.onTap!.call();
              return null;
            },
          ),
      },
      child: Semantics(
        label: widget.semanticLabel,
        button: widget.onTap != null,
        child: GestureDetector(onTap: widget.onTap, child: card),
      ),
    );
  }
}
