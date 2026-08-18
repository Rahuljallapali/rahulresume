import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app/lens.dart';
import '../app/theme/tokens.dart';
import 'layout.dart';

/// Segmented control that asks the visitor which role they are hiring for.
///
/// It is a question, not decoration: a recruiter arriving with one specialism
/// in mind can say so in one click and get a page argued for them. The label
/// above it says as much, because an unexplained three-way switch invites
/// people to ignore it.
class LensToggle extends StatelessWidget {
  const LensToggle({super.key});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final theme = Theme.of(context);
    final controller = context.watch<LensController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          controller.lens == Lens.freelance ? 'LOOKING FOR' : 'HIRING FOR',
          style: theme.textTheme.labelSmall?.copyWith(color: c.textTertiary),
        ),
        const SizedBox(height: Space.sm),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: c.glassFill,
            borderRadius: BorderRadius.circular(Radii.pill),
            border: Border.all(color: c.glassBorder),
          ),
          // Wrap, not Row: label widths depend on the font that actually
          // loads, so a fixed row eventually clips on someone's phone. This
          // stays one line wherever it fits and folds to two where it cannot.
          child: Wrap(
            spacing: 2,
            runSpacing: 2,
            children: [
              // The hidden freelance lens is not offered — a recruiter who
              // spots a "Freelance" tab reads divided attention. It appears
              // only when a `?role=` link has already selected it, so the
              // visitor can see which version they are looking at.
              for (final lens in [
                ...Lens.offered,
                if (controller.lens.isHidden) controller.lens,
              ])
                _Segment(
                  lens: lens,
                  selected: controller.lens == lens,
                  onTap: () => controller.select(lens),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({
    required this.lens,
    required this.selected,
    required this.onTap,
  });

  final Lens lens;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final theme = Theme.of(context);
    final onAccent = theme.brightness == Brightness.dark
        ? const Color(0xFF06070A)
        : Colors.white;

    return Semantics(
      button: true,
      selected: selected,
      label: 'Show the ${lens.label} version of this page',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Radii.pill),
        child: AnimatedContainer(
          duration: Motion.fast,
          curve: Motion.standard,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
          decoration: BoxDecoration(
            gradient: selected
                ? LinearGradient(colors: [c.accent, c.accentAlt])
                : null,
            borderRadius: BorderRadius.circular(Radii.pill),
          ),
          child: Text(
            context.isCompact ? lens.shortLabel : lens.label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: selected ? onAccent : c.textSecondary,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
