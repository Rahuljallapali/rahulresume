import 'package:flutter/material.dart';

import '../app/theme/tokens.dart';

/// Screen-size classes. Named by available space rather than device, so the
/// same rules apply to a narrow desktop window and a tablet.
enum ScreenSize { compact, medium, wide }

extension ScreenSizeContext on BuildContext {
  ScreenSize get screen {
    final w = MediaQuery.sizeOf(this).width;
    if (w < Breakpoints.compact) return ScreenSize.compact;
    if (w < Breakpoints.medium) return ScreenSize.medium;
    return ScreenSize.wide;
  }

  bool get isCompact => screen == ScreenSize.compact;
  bool get isWide => screen == ScreenSize.wide;

  /// Picks the value matching the current class, falling back down the scale.
  T responsive<T>({required T compact, T? medium, required T wide}) =>
      switch (screen) {
        ScreenSize.compact => compact,
        ScreenSize.medium => medium ?? wide,
        ScreenSize.wide => wide,
      };
}

/// Runs a section the full width of the viewport inside the page gutter, and
/// applies the vertical rhythm between sections.
///
/// Deliberately unclamped: the site reads as full-bleed. Individual blocks that
/// need a readable measure — headline, prose, project blurbs — set their own
/// `ConstrainedBox` at the point of use, where the right width is knowable.
class ContentShell extends StatelessWidget {
  const ContentShell({
    super.key,
    required this.child,
    this.vertical = Space.section,
  });

  final Widget child;
  final double vertical;

  @override
  Widget build(BuildContext context) {
    final v = context.isCompact ? vertical * 0.62 : vertical;

    return Padding(
      padding:
          EdgeInsets.symmetric(horizontal: pageGutter(context), vertical: v),
      child: child,
    );
  }
}

/// Horizontal page inset. Shared so the header's brand lines up with the left
/// edge of every section beneath it.
double pageGutter(BuildContext context) =>
    context.responsive(compact: 20.0, medium: 40.0, wide: 48.0);

/// A wrap-based grid that gives each child an equal share of the row.
///
/// Preferred over GridView here because the page is one long scroll view:
/// nesting a scrollable grid would need a fixed extent, and fixed-height cards
/// clip content when a visitor bumps their font size.
class AutoGrid extends StatelessWidget {
  const AutoGrid({
    super.key,
    required this.children,
    required this.columns,
    this.spacing = Space.lg,
    this.runSpacing = Space.lg,
    this.equalHeight = false,
  });

  final List<Widget> children;
  final int columns;
  final double spacing;
  final double runSpacing;

  /// Stretches every card in a row to the height of the tallest one.
  ///
  /// A [Wrap] sizes each child independently, so cards whose text runs a line
  /// longer end up taller than their neighbours — which reads as sloppy when
  /// the cards are peers. This lays each row out as a [Row] inside an
  /// [IntrinsicHeight] instead. That is a more expensive layout pass, so it is
  /// opt-in and only worth it for a handful of cards per row.
  final bool equalHeight;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final n = columns.clamp(1, children.isEmpty ? 1 : children.length);
        final width = (constraints.maxWidth - spacing * (n - 1)) / n;
        final cellWidth = width > 0 ? width : constraints.maxWidth;

        if (!equalHeight) {
          return Wrap(
            spacing: spacing,
            runSpacing: runSpacing,
            children: [
              for (final child in children)
                SizedBox(width: cellWidth, child: child),
            ],
          );
        }

        // Chunk into rows of n so the last, possibly short, row still aligns
        // its cards to the left rather than stretching them across the width.
        final rows = <List<Widget>>[];
        for (var i = 0; i < children.length; i += n) {
          rows.add(children.sublist(
              i, i + n > children.length ? children.length : i + n));
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var r = 0; r < rows.length; r++)
              Padding(
                padding: EdgeInsets.only(
                    bottom: r == rows.length - 1 ? 0 : runSpacing),
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (var i = 0; i < rows[r].length; i++) ...[
                        if (i != 0) SizedBox(width: spacing),
                        SizedBox(width: cellWidth, child: rows[r][i]),
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
