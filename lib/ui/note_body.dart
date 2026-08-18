import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../app/theme/tokens.dart';
import '../data/models.dart';

/// Renders a [Note]'s block list.
///
/// A deliberately small vocabulary — heading, paragraph, code, bullets,
/// callout — rather than a Markdown parser. Five block types cover everything
/// these notes need, and keeping them as typed data means a malformed post is
/// a compile error rather than a rendering surprise.
class NoteBody extends StatelessWidget {
  const NoteBody({super.key, required this.blocks, this.maxWidth = 680});

  final List<NoteBlock> blocks;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final block in blocks) _Block(block: block),
        ],
      ),
    );
  }
}

class _Block extends StatelessWidget {
  const _Block({required this.block});
  final NoteBlock block;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final theme = Theme.of(context);

    switch (block.kind) {
      case NoteBlockKind.heading:
        return Padding(
          padding: const EdgeInsets.only(top: Space.lg, bottom: Space.sm),
          child: Semantics(
            header: true,
            child: Text(block.text, style: theme.textTheme.headlineSmall),
          ),
        );

      case NoteBlockKind.paragraph:
        return Padding(
          padding: const EdgeInsets.only(bottom: Space.md),
          child: Text(
            block.text,
            style: theme.textTheme.bodyLarge?.copyWith(height: 1.75),
          ),
        );

      case NoteBlockKind.bullets:
        return Padding(
          padding: const EdgeInsets.only(bottom: Space.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final item in block.items)
                Padding(
                  padding: const EdgeInsets.only(bottom: Space.sm),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 10, right: 12),
                        width: 5,
                        height: 5,
                        decoration: BoxDecoration(
                          color: c.accentAlt,
                          shape: BoxShape.circle,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          item,
                          style:
                              theme.textTheme.bodyMedium?.copyWith(height: 1.7),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );

      case NoteBlockKind.code:
        final dark = theme.brightness == Brightness.dark;
        return Padding(
          padding: const EdgeInsets.only(bottom: Space.lg),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: dark
                  ? const Color(0xFF0C0E14)
                  : Colors.black.withValues(alpha: 0.035),
              borderRadius: BorderRadius.circular(Radii.md),
              border: Border.all(color: c.hairline),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (block.language != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                        Space.md, Space.sm, Space.md, 0),
                    child: Text(
                      block.language!.toUpperCase(),
                      style: theme.textTheme.labelSmall,
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.all(Space.md),
                  // Code scrolls sideways rather than wrapping: a wrapped line
                  // of Java reads as a different program.
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SelectionArea(
                      child: Text(
                        block.text,
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 12,
                          height: 1.7,
                          color: c.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );

      case NoteBlockKind.callout:
        // The accent edge is a sibling strip, not a thick left BorderSide:
        // Flutter forbids borderRadius on a border whose sides differ in
        // colour, and that combination threw on every note page.
        return Padding(
          padding: const EdgeInsets.only(top: Space.sm, bottom: Space.lg),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(Radii.md),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: c.accentSoft,
                border: Border.all(color: c.accent.withValues(alpha: 0.18)),
              ),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(width: 3, color: c.accent),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(Space.lg),
                        child: Text(
                          block.text,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: c.textPrimary,
                            height: 1.7,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
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
}
