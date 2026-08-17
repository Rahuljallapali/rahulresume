import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../app/theme/tokens.dart';
import '../data/profile.dart';
import '../ui/layout.dart';
import '../utils/link.dart';

class FooterSection extends StatelessWidget {
  const FooterSection({super.key});

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
        child: Column(
          children: [
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              runSpacing: Space.md,
              spacing: Space.lg,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  '© 2026 ${Profile.name}',
                  style: theme.textTheme.bodySmall,
                ),
                Wrap(
                  spacing: Space.lg,
                  children: [
                    for (final s in Profile.socials)
                      InkWell(
                        onTap: () => openLink(s.url),
                        child: Semantics(
                          link: true,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Text(
                              s.label,
                              style: theme.textTheme.bodySmall
                                  ?.copyWith(color: c.textSecondary),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: Space.md),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Built with Flutter Web. No template, no UI kit — the design '
                'system, the animations and the résumé generator are all in '
                'this repository.',
                style: theme.textTheme.bodySmall?.copyWith(fontSize: 11.5),
              ),
            ),
            const SizedBox(height: Space.md),
            const Align(
              alignment: Alignment.centerLeft,
              child: _StatusLine(),
            ),
          ],
        ),
      ),
    );
  }
}

/// A service-status line, because this page was built by someone who spends
/// their day looking at them. Everything in it is true: the status is the one
/// the page is currently rendering at, and the deploy date is stamped at
/// build time from [Profile.buildDate].
class _StatusLine extends StatelessWidget {
  const _StatusLine();

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);

    final mono = GoogleFonts.jetBrainsMono(
      fontSize: 10.5,
      height: 1.6,
      color: c.textTertiary,
    );

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Container(
          width: 6,
          height: 6,
          margin: const EdgeInsets.only(right: 9),
          decoration: BoxDecoration(color: c.success, shape: BoxShape.circle),
        ),
        Text('status: ', style: mono),
        Text(
          '200 OK',
          style: mono.copyWith(color: c.success, fontWeight: FontWeight.w700),
        ),
        Text(
          '  ·  region: ${Profile.timezone}'
          '  ·  deployed: ${Profile.buildDate}'
          '  ·  runtime: flutter-web',
          style: mono,
        ),
      ],
    );
  }
}
