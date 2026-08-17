import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../app/theme/tokens.dart';

/// Editor-style window for the hero: two tabs, one Spring Boot controller and
/// one Flutter sync routine — the two halves of the work, backend tab first.
///
/// The code is illustrative but idiomatic; it is tokenised by hand below
/// rather than run through a highlighter, which keeps the payload at zero
/// dependencies. Lines reveal with a stagger on first build and a cursor
/// blinks at the end — both skipped under reduced motion.
class CodeShowcase extends StatefulWidget {
  const CodeShowcase({super.key});

  @override
  State<CodeShowcase> createState() => _CodeShowcaseState();
}

class _CodeShowcaseState extends State<CodeShowcase> {
  int _tab = 0;

  static const _tabs = ['WorkOrderController.java', 'sync_service.dart'];
  static const _captions = [
    '// tenant-scoped · stateless JWT · tokens signed in-service',
    '// offline-first · captures reconcile on reconnect',
  ];

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;

    // One palette per brightness; AA against the editor surface in both.
    final pal = _CodePalette(
      keyword: dark ? const Color(0xFFC792EA) : const Color(0xFF7C3AED),
      type: dark ? const Color(0xFF82AAFF) : const Color(0xFF2F5FE0),
      annotation: dark ? const Color(0xFFFFCB6B) : const Color(0xFFB45309),
      string: dark ? const Color(0xFFC3E88D) : const Color(0xFF15803D),
      plain: c.textSecondary,
      dim: c.textTertiary,
    );

    final lines = _tab == 0 ? _javaLines(pal) : _dartLines(pal);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: dark
            ? const Color(0xFF0C0E14)
            : Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(Radii.md),
        border: Border.all(color: c.hairline),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: dark ? 0.4 : 0.10),
            blurRadius: 40,
            offset: const Offset(0, 18),
          ),
          BoxShadow(
            color: c.accent.withValues(alpha: 0.10),
            blurRadius: 64,
            spreadRadius: -12,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Window chrome: traffic lights + file tabs.
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
            child: Row(
              children: [
                for (final dot in const [
                  Color(0xFFFF5F57),
                  Color(0xFFFEBC2E),
                  Color(0xFF28C840),
                ]) ...[
                  Container(
                    width: 10,
                    height: 10,
                    decoration:
                        BoxDecoration(color: dot, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 6),
                ],
                const SizedBox(width: 8),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        for (var i = 0; i < _tabs.length; i++)
                          _FileTab(
                            label: _tabs[i],
                            active: _tab == i,
                            onTap: () => setState(() => _tab = i),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Divider(color: c.hairline, height: 1),
          ),
          // Code body. Fixed-ish height so switching tabs does not reflow the
          // hero; the taller snippet defines the box.
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 6),
            child: AnimatedSwitcher(
              duration: Motion.base,
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              child: Column(
                key: ValueKey(_tab),
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (var i = 0; i < lines.length; i++)
                    _CodeLine(spans: lines[i], index: i, dim: pal.dim),
                  const _BlinkingCursor(),
                ],
              ),
            ),
          ),
          Divider(color: c.hairline, height: 1),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 10, 18, 12),
            child: Text(
              _captions[_tab],
              style: GoogleFonts.jetBrainsMono(
                fontSize: 11,
                color: c.textTertiary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CodePalette {
  const _CodePalette({
    required this.keyword,
    required this.type,
    required this.annotation,
    required this.string,
    required this.plain,
    required this.dim,
  });

  final Color keyword;
  final Color type;
  final Color annotation;
  final Color string;
  final Color plain;
  final Color dim;
}

/// (text, colour) pairs for one line of code.
typedef _Toks = List<(String, Color)>;

List<_Toks> _javaLines(_CodePalette p) => [
      [('@RestController', p.annotation)],
      [('@RequestMapping', p.annotation), ('("/api/v1/workorders")', p.string)],
      [
        ('public class ', p.keyword),
        ('WorkOrderController', p.type),
        (' {', p.plain)
      ],
      [
        ('  private final ', p.keyword),
        ('WorkOrderService', p.type),
        (' service;', p.plain)
      ],
      [('', p.plain)],
      [('  @PostMapping', p.annotation), ('("/{id}/complete")', p.string)],
      [
        ('  public ', p.keyword),
        ('ResponseEntity', p.type),
        ('<', p.plain),
        ('WorkOrderDto', p.type),
        ('> complete(', p.plain)
      ],
      [
        ('      @PathVariable ', p.annotation),
        ('Long', p.type),
        (' id, ', p.plain),
        ('@AuthenticationPrincipal ', p.annotation),
        ('AppUser', p.type),
        (' user) {', p.plain)
      ],
      [
        ('    return ', p.keyword),
        ('ResponseEntity', p.type),
        ('.ok(', p.plain)
      ],
      [
        ('        service.complete(id, user.tenantId()));', p.plain),
      ],
      [('  }', p.plain)],
      [('}', p.plain)],
    ];

List<_Toks> _dartLines(_CodePalette p) => [
      [
        ('Future', p.type),
        ('<', p.plain),
        ('void', p.keyword),
        ('> reconcile() ', p.plain),
        ('async', p.keyword),
        (' {', p.plain)
      ],
      [
        ('  final ', p.keyword),
        ('pending = ', p.plain),
        ('await', p.keyword),
        (' db.pendingCaptures();', p.plain)
      ],
      [
        ('  for ', p.keyword),
        ('(', p.plain),
        ('final ', p.keyword),
        ('capture ', p.plain),
        ('in', p.keyword),
        (' pending) {', p.plain)
      ],
      [
        ('    final ', p.keyword),
        ('res = ', p.plain),
        ('await', p.keyword),
        (' api.upload(capture);', p.plain)
      ],
      [
        ('    if ', p.keyword),
        ('(res.ok) ', p.plain),
        ('await', p.keyword),
        (' db.markSynced(capture.id);', p.plain)
      ],
      [('  }', p.plain)],
      [('  ', p.plain), ('// nothing lost between basements.', p.dim)],
      [('}', p.plain)],
    ];

class _FileTab extends StatelessWidget {
  const _FileTab({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Semantics(
      button: true,
      selected: active,
      label: 'Show $label',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: AnimatedContainer(
          duration: Motion.fast,
          margin: const EdgeInsets.only(left: 4),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: active ? c.accentSoft : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            label,
            style: GoogleFonts.jetBrainsMono(
              fontSize: 11,
              fontWeight: active ? FontWeight.w600 : FontWeight.w400,
              color: active ? c.accent : c.textTertiary,
            ),
          ),
        ),
      ),
    );
  }
}

class _CodeLine extends StatelessWidget {
  const _CodeLine(
      {required this.spans, required this.index, required this.dim});

  final _Toks spans;
  final int index;
  final Color dim;

  @override
  Widget build(BuildContext context) {
    final still = MediaQuery.disableAnimationsOf(context);

    final line = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 22,
          child: Text(
            '${index + 1}',
            textAlign: TextAlign.right,
            style: GoogleFonts.jetBrainsMono(
              fontSize: 12,
              height: 1.7,
              color: dim.withValues(alpha: 0.55),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text.rich(
            TextSpan(
              children: [
                for (final (text, color) in spans)
                  TextSpan(text: text, style: TextStyle(color: color)),
              ],
            ),
            style: GoogleFonts.jetBrainsMono(fontSize: 12, height: 1.7),
            softWrap: false,
            overflow: TextOverflow.fade,
          ),
        ),
      ],
    );

    if (still) return line;

    // Staggered slide-in per line, ~40ms apart — reads as the file "typing"
    // itself in without the cost of per-character animation.
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 260 + 40 * index),
      curve: Curves.easeOutCubic,
      builder: (context, t, child) => Opacity(
        opacity: t,
        child:
            Transform.translate(offset: Offset(10 * (1 - t), 0), child: child),
      ),
      child: line,
    );
  }
}

class _BlinkingCursor extends StatefulWidget {
  const _BlinkingCursor();

  @override
  State<_BlinkingCursor> createState() => _BlinkingCursorState();
}

class _BlinkingCursorState extends State<_BlinkingCursor>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final block = Container(
      margin: const EdgeInsets.only(left: 34, top: 2),
      width: 7,
      height: 14,
      color: c.accent,
    );
    if (MediaQuery.disableAnimationsOf(context)) return block;
    return FadeTransition(
      opacity: CurvedAnimation(parent: _c, curve: Curves.easeInOut),
      child: block,
    );
  }
}
