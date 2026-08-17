import 'package:flutter/material.dart';

import '../app/theme/tokens.dart';
import '../data/models.dart';
import '../data/profile.dart';
import '../services/resume_download.dart';
import '../ui/code_card.dart';
import '../ui/layout.dart';
import '../ui/primitives.dart';
import '../ui/reveal.dart';
import '../utils/link.dart';

/// Landing section. Everything a recruiter needs to decide to keep reading is
/// above the fold: who, what, proof, and three actions — and on wide screens,
/// an editor window showing both halves of the stack, Spring Boot tab first.
class HeroSection extends StatelessWidget {
  const HeroSection(
      {super.key, required this.onViewWork, required this.onContact});

  final VoidCallback onViewWork;
  final VoidCallback onContact;

  @override
  Widget build(BuildContext context) {
    final compact = context.isCompact;
    // The code window needs real width next to an 800px copy column; below
    // the wide breakpoint it would crush the headline, so it is dropped
    // rather than squeezed.
    final showCode = context.isWide;

    final copy = _HeroCopy(onViewWork: onViewWork, onContact: onContact);

    return ContentShell(
      child: ConstrainedBox(
        // Reserve close to a viewport height so the hero reads as a full
        // panel, but never force it — tall content must still fit.
        constraints: BoxConstraints(
          minHeight:
              MediaQuery.sizeOf(context).height * (compact ? 0.72 : 0.78),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showCode)
              Row(
                children: [
                  Expanded(child: copy),
                  const SizedBox(width: Space.xxl),
                  const SizedBox(
                    width: 470,
                    child: Reveal(
                      delay: Duration(milliseconds: 200),
                      offset: 32,
                      child: CodeShowcase(),
                    ),
                  ),
                ],
              )
            else
              copy,
            const SizedBox(height: Space.xxl),
            const Reveal(
              delay: Duration(milliseconds: 360),
              child: _StatStrip(),
            ),
          ],
        ),
      ),
    );
  }
}

/// The text column of the hero: pill, name, headline, actions, socials.
class _HeroCopy extends StatelessWidget {
  const _HeroCopy({required this.onViewWork, required this.onContact});

  final VoidCallback onViewWork;
  final VoidCallback onContact;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final theme = Theme.of(context);
    final compact = context.isCompact;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Reveal(child: _AvailabilityPill()),
        const SizedBox(height: Space.lg),

        // Face, name, one human line. The single non-evidential element on
        // the page — people hire people, and a portfolio with no person on
        // it reads as a spec sheet.
        Reveal(
          delay: const Duration(milliseconds: 60),
          child: Row(
            children: [
              const _Avatar(),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${Profile.firstName} ${Profile.lastName}',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: c.textTertiary,
                        letterSpacing: 1.6,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      Profile.bio,
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: c.textTertiary),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: Space.md),

        // The headline is the single most important string on the site.
        Reveal(
          delay: const Duration(milliseconds: 120),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Text(
              Profile.headline,
              style: (compact
                      ? theme.textTheme.displaySmall
                      : theme.textTheme.displayMedium)
                  ?.copyWith(height: 1.08),
            ),
          ),
        ),
        const SizedBox(height: Space.lg),

        Reveal(
          delay: const Duration(milliseconds: 180),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 660),
            child: Text(
              Profile.subheadline,
              style: theme.textTheme.bodyLarge,
            ),
          ),
        ),
        const SizedBox(height: Space.xl),

        Reveal(
          delay: const Duration(milliseconds: 240),
          child: Wrap(
            spacing: Space.md,
            runSpacing: Space.md,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              MagneticButton(
                label: 'View my work',
                icon: Icons.arrow_downward_rounded,
                onPressed: onViewWork,
              ),
              const _ResumeButton(),
              MagneticButton(
                label: 'Get in touch',
                icon: Icons.mail_outline_rounded,
                filled: false,
                onPressed: onContact,
              ),
            ],
          ),
        ),
        const SizedBox(height: Space.xl),

        Reveal(
          delay: const Duration(milliseconds: 300),
          child: Wrap(
            spacing: Space.sm,
            runSpacing: Space.sm,
            children: [
              for (final s in Profile.socials) _SocialLinkButton(link: s),
            ],
          ),
        ),
      ],
    );
  }
}

/// Photo with a graceful fallback: if the asset is ever missing, a monogram
/// renders instead of a broken-image box.
class _Avatar extends StatelessWidget {
  const _Avatar();

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);

    return Container(
      width: 54,
      height: 54,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: c.accent.withValues(alpha: 0.45), width: 1.5),
      ),
      child: ClipOval(
        child: Image.asset(
          'assets/avatar.jpg',
          fit: BoxFit.cover,
          // Decode at display size, not the full 512px asset.
          cacheWidth: 108,
          semanticLabel: 'Photo of ${Profile.name}',
          errorBuilder: (context, _, __) => Container(
            color: c.accentSoft,
            alignment: Alignment.center,
            child: Text(
              Profile.firstName.characters.first,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: c.accent,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AvailabilityPill extends StatelessWidget {
  const _AvailabilityPill();

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: c.glassFill,
        borderRadius: BorderRadius.circular(Radii.pill),
        border: Border.all(color: c.glassBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _PulsingDot(color: c.success),
          const SizedBox(width: 9),
          // Flexible, not a bare Text: the label is a full sentence and the
          // narrowest phones leave it less than one line of room. Wrapping to
          // a second line beats overflowing the pill.
          Flexible(
            child: Text(
              Profile.availability,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: c.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Slow breathing dot. The only always-on animation in the hero.
class _PulsingDot extends StatefulWidget {
  const _PulsingDot({required this.color});
  final Color color;

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dot = Container(
      width: 7,
      height: 7,
      decoration: BoxDecoration(color: widget.color, shape: BoxShape.circle),
    );

    if (MediaQuery.disableAnimationsOf(context)) return dot;

    return AnimatedBuilder(
      animation: _c,
      builder: (context, child) => DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: widget.color.withValues(alpha: 0.55 * (1 - _c.value)),
              blurRadius: 4,
              spreadRadius: 3 * _c.value,
            ),
          ],
        ),
        child: child,
      ),
      child: dot,
    );
  }
}

/// Download button that reflects generation state, since building the PDF
/// takes a beat and a dead-looking button invites a second click.
class _ResumeButton extends StatefulWidget {
  const _ResumeButton();

  @override
  State<_ResumeButton> createState() => _ResumeButtonState();
}

class _ResumeButtonState extends State<_ResumeButton> {
  bool _busy = false;

  Future<void> _download() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await ResumeDownload.generateAndDownload();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not generate the résumé: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MagneticButton(
      label: _busy ? 'Preparing…' : 'Download résumé',
      icon: Icons.file_download_outlined,
      filled: false,
      busy: _busy,
      onPressed: _download,
    );
  }
}

class _SocialLinkButton extends StatelessWidget {
  const _SocialLinkButton({required this.link});
  final SocialLink link;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Tooltip(
      message: link.handle ?? link.label,
      child: InkWell(
        onTap: () => openLink(link.url),
        borderRadius: BorderRadius.circular(Radii.pill),
        child: Semantics(
          link: true,
          label: '${link.label}: ${link.handle ?? link.url}',
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: c.glassFill,
              borderRadius: BorderRadius.circular(Radii.pill),
              border: Border.all(color: c.glassBorder),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(link.icon, size: 15, color: c.textSecondary),
                const SizedBox(width: 8),
                Text(
                  link.label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: c.textSecondary,
                        fontWeight: FontWeight.w500,
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

/// The four headline numbers, each with its provenance printed underneath —
/// a metric a reader cannot audit is just decoration.
class _StatStrip extends StatelessWidget {
  const _StatStrip();

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final theme = Theme.of(context);

    return AutoGrid(
      columns: context.responsive(compact: 2, medium: 2, wide: 4),
      spacing: Space.md,
      runSpacing: Space.md,
      children: [
        for (final stat in Profile.stats)
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: Space.md,
              vertical: Space.md,
            ),
            decoration: BoxDecoration(
              border: Border(left: BorderSide(color: c.accent, width: 2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimatedCounter(
                  value: stat.value,
                  prefix: stat.prefix,
                  suffix: stat.suffix,
                  style: theme.textTheme.headlineMedium
                      ?.copyWith(color: c.textPrimary),
                ),
                const SizedBox(height: 4),
                Text(
                  stat.label,
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: c.textSecondary, fontSize: 12.5),
                ),
                const SizedBox(height: 3),
                Text(
                  stat.detail,
                  style: theme.textTheme.bodySmall?.copyWith(fontSize: 11.5),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
