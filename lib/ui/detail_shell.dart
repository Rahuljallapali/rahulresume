import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app/router.dart';
import '../app/theme/theme_controller.dart';
import '../app/theme/tokens.dart';
import '../data/profile.dart';
import 'layout.dart';
import 'primitives.dart';

/// Chrome shared by the case-study and note pages.
///
/// A slimmer header than the home page's: a back affordance, the brand, and
/// the theme toggle. No section links, because on a detail page there are no
/// sections to link to — the visitor's next move is back, or contact.
class DetailShell extends StatelessWidget {
  const DetailShell({
    super.key,
    required this.backLabel,
    required this.children,
  });

  final String backLabel;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AmbientBackground(
        child: Stack(
          children: [
            Positioned.fill(
              child: Scrollbar(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Clears the fixed header.
                      const SizedBox(height: 92),
                      ...children,
                      const _DetailFooter(),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: _DetailNav(backLabel: backLabel),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailNav extends StatelessWidget {
  const _DetailNav({required this.backLabel});
  final String backLabel;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final theme = Theme.of(context);
    final controller = context.watch<ThemeController>();
    final isDark = controller.isDark(context);

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: c.canvas.withValues(alpha: 0.72),
            border: Border(bottom: BorderSide(color: c.hairline)),
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: pageGutter(context),
                vertical: 12,
              ),
              child: Row(
                children: [
                  Semantics(
                    button: true,
                    label: backLabel,
                    child: InkWell(
                      onTap: () => AppRouter.goHome(context),
                      borderRadius: BorderRadius.circular(Radii.pill),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 13, vertical: 8),
                        decoration: BoxDecoration(
                          color: c.glassFill,
                          borderRadius: BorderRadius.circular(Radii.pill),
                          border: Border.all(color: c.glassBorder),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.arrow_back_rounded,
                                size: 15, color: c.textSecondary),
                            const SizedBox(width: 8),
                            Text(
                              backLabel,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: c.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (MediaQuery.sizeOf(context).width >= Breakpoints.compact)
                    Text(
                      Profile.name,
                      style: theme.textTheme.titleSmall
                          ?.copyWith(color: c.textPrimary),
                    ),
                  const SizedBox(width: Space.md),
                  Tooltip(
                    message: isDark ? 'Switch to light' : 'Switch to dark',
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
                        child: Icon(
                          isDark
                              ? Icons.light_mode_rounded
                              : Icons.dark_mode_rounded,
                          size: 15,
                          color: c.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Closing call to action. A detail page is often the first page a visitor
/// lands on from a shared link, so it cannot be a dead end.
class _DetailFooter extends StatelessWidget {
  const _DetailFooter();

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: c.hairline)),
      ),
      child: ContentShell(
        vertical: Space.xl,
        child: Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: Space.lg,
          runSpacing: Space.md,
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Want the rest?', style: theme.textTheme.headlineSmall),
                  const SizedBox(height: 6),
                  Text(
                    'The full portfolio has the systems, the stack and a way '
                    'to reach me.',
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            MagneticButton(
              label: 'Back to the portfolio',
              icon: Icons.arrow_forward_rounded,
              onPressed: () => AppRouter.goHome(context),
            ),
          ],
        ),
      ),
    );
  }
}
