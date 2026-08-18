import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app/router.dart';
import '../app/theme/tokens.dart';
import '../data/notes.dart';
import '../data/profile.dart';
import '../sections/activity_section.dart';
import '../sections/api_section.dart';
import '../sections/apps_section.dart';
import '../sections/architecture_section.dart';
import '../sections/contact_section.dart';
import '../sections/delivery_section.dart';
import '../sections/experience_section.dart';
import '../sections/footer_section.dart';
import '../sections/hero_section.dart';
import '../sections/notes_section.dart';
import '../sections/principles_section.dart';
import '../sections/projects_section.dart';
import '../sections/skills_section.dart';
import '../services/resume_download.dart';
import '../ui/command_palette.dart';
import '../ui/primitives.dart';
import '../ui/tech_ticker.dart';
import '../ui/top_nav.dart';
import '../utils/link.dart';

/// One section of the long scroll.
///
/// Declaring sections as data rather than inline widgets keeps the ordering,
/// the nav strip and the command palette in sync automatically — adding a
/// section is one entry, not four edits in three files.
class _SectionSpec {
  const _SectionSpec({
    required this.name,
    required this.keywords,
    required this.build,
    this.inNav = true,
  });

  final String name;
  final List<String> keywords;
  final Widget Function() build;

  /// The nav strip only has room for the primary path through the page.
  /// Everything else is one keystroke away in the palette.
  final bool inNav;
}

/// The whole site.
///
/// Single-page scroll rather than routes: a recruiter's first visit is a
/// top-to-bottom skim, and every extra navigation is a chance to leave. Case
/// studies and notes do get their own URLs — those are documents people share.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _scroll = ScrollController();

  static final _sections = <_SectionSpec>[
    _SectionSpec(
      name: 'Apps',
      keywords: ['store', 'app store', 'play', 'serveiz', 'midc', 'dimms'],
      build: () => const AppsSection(),
    ),
    _SectionSpec(
      name: 'Work',
      keywords: ['projects', 'portfolio', 'case study'],
      build: () => const ProjectsSection(),
    ),
    _SectionSpec(
      name: 'Architecture',
      keywords: ['diagram', 'system', 'request', 'design', 'flow'],
      build: () => const ArchitectureSection(),
    ),
    _SectionSpec(
      name: 'API',
      keywords: ['endpoint', 'rest', 'json', 'playground', 'spring', 'try'],
      build: () => const ApiSection(),
    ),
    _SectionSpec(
      name: 'Experience',
      keywords: ['job', 'career', 'swensa', 'timeline'],
      build: () => const ExperienceSection(),
    ),
    _SectionSpec(
      name: 'Skills',
      keywords: ['tech', 'stack', 'tools', 'languages'],
      build: () => const SkillsSection(),
    ),
    _SectionSpec(
      name: 'Delivery',
      keywords: ['devops', 'docker', 'aws', 'deploy', 'ci'],
      inNav: false,
      build: () => const DeliverySection(),
    ),
    _SectionSpec(
      name: 'Activity',
      keywords: ['github', 'commits', 'contributions', 'graph'],
      inNav: false,
      build: () => const ActivitySection(),
    ),
    _SectionSpec(
      name: 'Approach',
      keywords: ['principles', 'philosophy', 'how i work'],
      inNav: false,
      build: () => const PrinciplesSection(),
    ),
    _SectionSpec(
      name: 'Notes',
      keywords: ['blog', 'writing', 'articles', 'posts'],
      build: () => const NotesSection(),
    ),
    _SectionSpec(
      name: 'Contact',
      keywords: ['email', 'reach', 'message'],
      build: () => const ContactSection(),
    ),
  ];

  /// One key per section, used both for scroll-to and for computing which nav
  /// link is active. Keys are cheaper than maintaining an offset table that
  /// would go stale on every resize or font-size change.
  final _keys = List.generate(_sections.length, (_) => GlobalKey());

  /// Indices of the sections that appear in the header strip.
  static final _navIndices = [
    for (var i = 0; i < _sections.length; i++)
      if (_sections[i].inNav) i,
  ];

  double _progress = 0;
  int _active = 0;
  bool _scrolled = false;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scroll.removeListener(_onScroll);
    _scroll.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scroll.hasClients) return;
    final position = _scroll.position;
    final max = position.maxScrollExtent;
    final offset = position.pixels;

    final progress = max <= 0 ? 0.0 : (offset / max).clamp(0.0, 1.0);
    final scrolled = offset > 8;
    final active = _activeSection();

    // setState only when something the header actually renders has changed —
    // otherwise every scroll frame rebuilds the nav for nothing.
    if (progress != _progress || scrolled != _scrolled || active != _active) {
      setState(() {
        _progress = progress;
        _scrolled = scrolled;
        _active = active;
      });
    }
  }

  /// Index into [_navIndices] of the nav link to highlight.
  int _activeSection() {
    // The section whose top is closest to just under the header wins.
    const anchor = 140.0;
    var best = _active;
    var bestDistance = double.infinity;

    for (var n = 0; n < _navIndices.length; n++) {
      final ctx = _keys[_navIndices[n]].currentContext;
      if (ctx == null) continue;
      final box = ctx.findRenderObject() as RenderBox?;
      if (box == null || !box.hasSize || !box.attached) continue;

      final top = box.localToGlobal(Offset.zero).dy;
      if (top > MediaQuery.sizeOf(context).height) continue;

      final distance = (top - anchor).abs();
      if (distance < bestDistance) {
        bestDistance = distance;
        best = n;
      }
    }
    return best;
  }

  Future<void> _scrollTo(int index) async {
    if (index < 0) {
      await _scroll.animateTo(0, duration: Motion.slow, curve: Motion.standard);
      return;
    }
    final ctx = _keys[index].currentContext;
    if (ctx == null) return;
    await Scrollable.ensureVisible(
      ctx,
      duration: Motion.slow,
      curve: Motion.standard,
      // Leave room for the sticky header.
      alignment: 0.06,
    );
  }

  List<PaletteCommand> _commands() => [
        for (var i = 0; i < _sections.length; i++)
          PaletteCommand(
            label: 'Go to ${_sections[i].name}',
            icon: Icons.arrow_forward_rounded,
            onInvoke: () => _scrollTo(i),
            keywords: _sections[i].keywords,
          ),
        for (final p in Profile.projects)
          PaletteCommand(
            label: 'Case study: ${p.name}',
            icon: Icons.article_outlined,
            group: 'Read',
            keywords: ['project', 'detail', ...p.tags],
            onInvoke: () => AppRouter.openCaseStudy(context, p.slug),
          ),
        for (final n in Notes.all)
          PaletteCommand(
            label: 'Note: ${n.title}',
            icon: Icons.edit_note_rounded,
            group: 'Read',
            keywords: ['blog', 'writing', ...n.tags],
            onInvoke: () => AppRouter.openNote(context, n.slug),
          ),
        PaletteCommand(
          label: 'Download resume (PDF)',
          icon: Icons.file_download_outlined,
          group: 'Action',
          keywords: const ['cv', 'resume', 'pdf'],
          onInvoke: () => ResumeDownload.generateAndDownload(),
        ),
        PaletteCommand(
          label: 'Open GitHub',
          icon: Icons.code_rounded,
          group: 'Link',
          keywords: const ['repo', 'source', 'code'],
          onInvoke: () => openLink(Profile.githubUrl),
        ),
        PaletteCommand(
          label: 'Open LinkedIn',
          icon: Icons.work_outline_rounded,
          group: 'Link',
          keywords: const ['profile', 'network'],
          onInvoke: () => openLink(Profile.linkedInUrl),
        ),
        PaletteCommand(
          label: 'Email ${Profile.email}',
          icon: Icons.alternate_email_rounded,
          group: 'Link',
          keywords: const ['contact', 'mail', 'hire'],
          onInvoke: () => openLink('mailto:${Profile.email}'),
        ),
      ];

  void _openPalette() => CommandPalette.show(context, _commands());

  /// Index of the section with this name, for the hero's jump targets.
  int _indexOf(String name) => _sections.indexWhere((s) => s.name == name);

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: const {
        SingleActivator(LogicalKeyboardKey.keyK, control: true):
            _OpenPaletteIntent(),
        SingleActivator(LogicalKeyboardKey.keyK, meta: true):
            _OpenPaletteIntent(),
        SingleActivator(LogicalKeyboardKey.slash): _OpenPaletteIntent(),
      },
      child: Actions(
        actions: {
          _OpenPaletteIntent: CallbackAction<_OpenPaletteIntent>(
            onInvoke: (_) {
              _openPalette();
              return null;
            },
          ),
        },
        child: Focus(
          autofocus: true,
          child: Scaffold(
            body: AmbientBackground(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Scrollbar(
                      controller: _scroll,
                      child: SingleChildScrollView(
                        controller: _scroll,
                        // Keeps the whole page in one semantics tree so
                        // assistive tech and browser find-in-page see all of
                        // it, which matters more here than lazy building.
                        child: Column(
                          children: [
                            HeroSection(
                              onViewWork: () => _scrollTo(_indexOf('Apps')),
                              onContact: () => _scrollTo(_indexOf('Contact')),
                            ),
                            const TechTicker(),
                            for (var i = 0; i < _sections.length; i++)
                              KeyedSubtree(
                                key: _keys[i],
                                child: _sections[i].build(),
                              ),
                            const FooterSection(),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: TopNav(
                      sections: [
                        for (final i in _navIndices) _sections[i].name,
                      ],
                      activeIndex: _active,
                      progress: _progress,
                      scrolled: _scrolled,
                      onSelect: (n) => _scrollTo(
                        n == 0 && !_scrolled ? -1 : _navIndices[n],
                      ),
                      onOpenPalette: _openPalette,
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

class _OpenPaletteIntent extends Intent {
  const _OpenPaletteIntent();
}
