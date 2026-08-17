import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app/theme/theme_controller.dart';
import '../app/theme/tokens.dart';
import '../data/profile.dart';
import 'layout.dart';
import 'primitives.dart';

/// Sticky header: brand, section links, scroll progress, palette trigger and
/// theme toggle.
///
/// Rebuilt only when [progress] or [activeIndex] change — it sits above a long
/// scroll view, so anything expensive here is paid on every frame of a scroll.
class TopNav extends StatelessWidget {
  const TopNav({
    super.key,
    required this.sections,
    required this.activeIndex,
    required this.progress,
    required this.scrolled,
    required this.onSelect,
    required this.onOpenPalette,
  });

  final List<String> sections;
  final int activeIndex;
  final double progress;
  final bool scrolled;
  final void Function(int index) onSelect;
  final VoidCallback onOpenPalette;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final showLinks = MediaQuery.sizeOf(context).width >= Breakpoints.medium;

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: AnimatedContainer(
          duration: Motion.base,
          decoration: BoxDecoration(
            // Transparent at the top of the page so the hero reads full-bleed;
            // gains a surface and a hairline once content scrolls beneath it.
            color: scrolled
                ? c.canvas.withValues(alpha: 0.72)
                : Colors.transparent,
            border: Border(
              bottom: BorderSide(
                color: scrolled ? c.hairline : Colors.transparent,
              ),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SafeArea(
                bottom: false,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: pageGutter(context),
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      _Brand(onTap: () => onSelect(0)),
                      // The link strip is the only flexible element, and it
                      // scrolls rather than overflows. Nav labels come from
                      // data and font metrics vary by platform, so a fixed
                      // layout here would eventually clip on someone's
                      // machine — this cannot.
                      Expanded(
                        child: showLinks
                            ? SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                // Keeps the strip pinned right when it fits,
                                // and reveals the tail first when it does not.
                                reverse: true,
                                child: Row(
                                  children: [
                                    for (var i = 0; i < sections.length; i++)
                                      _NavLink(
                                        label: sections[i],
                                        active: activeIndex == i,
                                        onTap: () => onSelect(i),
                                      ),
                                    const SizedBox(width: Space.sm),
                                  ],
                                ),
                              )
                            : const SizedBox.shrink(),
                      ),
                      _PaletteButton(onTap: onOpenPalette),
                      const SizedBox(width: Space.sm),
                      const _ThemeToggle(),
                    ],
                  ),
                ),
              ),
              ScrollProgressBar(progress: progress),
            ],
          ),
        ),
      ),
    );
  }
}

class _Brand extends StatelessWidget {
  const _Brand({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final theme = Theme.of(context);

    return Semantics(
      button: true,
      label: 'Back to top',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Radii.sm),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 27,
                height: 27,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [c.accent, c.accentAlt]),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'R',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              // On a phone the mark alone carries the brand; the name would
              // crowd out the palette and theme controls.
              if (MediaQuery.sizeOf(context).width >= Breakpoints.compact) ...[
                const SizedBox(width: 10),
                Text(
                  Profile.name,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: c.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _NavLink extends StatefulWidget {
  const _NavLink({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  State<_NavLink> createState() => _NavLinkState();
}

class _NavLinkState extends State<_NavLink> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final theme = Theme.of(context);

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: Semantics(
        button: true,
        selected: widget.active,
        child: GestureDetector(
          onTap: widget.onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedDefaultTextStyle(
                  duration: Motion.fast,
                  style: theme.textTheme.bodySmall!.copyWith(
                    color: widget.active
                        ? c.textPrimary
                        : (_hovered ? c.textSecondary : c.textTertiary),
                    fontWeight:
                        widget.active ? FontWeight.w600 : FontWeight.w500,
                    fontSize: 13,
                  ),
                  child: Text(widget.label),
                ),
                const SizedBox(height: 4),
                AnimatedContainer(
                  duration: Motion.fast,
                  height: 2,
                  width: widget.active ? 14 : 0,
                  decoration: BoxDecoration(
                    color: c.accent,
                    borderRadius: BorderRadius.circular(Radii.pill),
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

class _PaletteButton extends StatelessWidget {
  const _PaletteButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final theme = Theme.of(context);
    final wide = MediaQuery.sizeOf(context).width >= Breakpoints.compact;

    return Tooltip(
      message: 'Search — Ctrl K',
      child: Semantics(
        button: true,
        label: 'Open command palette',
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(Radii.pill),
          child: Container(
            padding:
                EdgeInsets.symmetric(horizontal: wide ? 12 : 9, vertical: 8),
            decoration: BoxDecoration(
              color: c.glassFill,
              borderRadius: BorderRadius.circular(Radii.pill),
              border: Border.all(color: c.glassBorder),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.search_rounded, size: 14, color: c.textTertiary),
                if (wide) ...[
                  const SizedBox(width: 8),
                  Text(
                    'Ctrl K',
                    style: theme.textTheme.bodySmall
                        ?.copyWith(fontSize: 11.5, color: c.textTertiary),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ThemeToggle extends StatelessWidget {
  const _ThemeToggle();

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ThemeController>();
    final c = AppColors.of(context);
    final isDark = controller.isDark(context);

    return Tooltip(
      message: isDark ? 'Switch to light' : 'Switch to dark',
      child: Semantics(
        button: true,
        label: isDark ? 'Switch to light theme' : 'Switch to dark theme',
        child: InkWell(
          onTap: () => controller.toggle(context),
          borderRadius: BorderRadius.circular(Radii.pill),
          child: Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: c.glassFill,
              borderRadius: BorderRadius.circular(Radii.pill),
              border: Border.all(color: c.glassBorder),
            ),
            // Rotate + fade between the two glyphs so the change reads as one
            // object turning over rather than two icons swapping.
            child: AnimatedSwitcher(
              duration: Motion.base,
              transitionBuilder: (child, animation) => RotationTransition(
                turns: Tween(begin: 0.6, end: 1.0).animate(animation),
                child: FadeTransition(opacity: animation, child: child),
              ),
              child: Icon(
                isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                key: ValueKey(isDark),
                size: 15,
                color: c.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
