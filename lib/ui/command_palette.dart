import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app/theme/tokens.dart';

@immutable
class PaletteCommand {
  const PaletteCommand({
    required this.label,
    required this.icon,
    required this.onInvoke,
    this.group = 'Navigate',
    this.keywords = const [],
  });

  final String label;
  final IconData icon;
  final VoidCallback onInvoke;
  final String group;

  /// Extra search terms so "email"/"cv"/"work" find the right entry even when
  /// they do not appear in the visible label.
  final List<String> keywords;

  bool matches(String query) {
    if (query.isEmpty) return true;
    final q = query.toLowerCase();
    return label.toLowerCase().contains(q) ||
        group.toLowerCase().contains(q) ||
        keywords.any((k) => k.toLowerCase().contains(q));
  }
}

/// Ctrl/⌘K launcher.
///
/// Fully keyboard-driven: arrows move, Enter invokes, Escape dismisses. Search
/// is substring rather than fuzzy — with this few commands, fuzzy matching adds
/// false positives and no real speed.
class CommandPalette extends StatefulWidget {
  const CommandPalette({super.key, required this.commands});

  final List<PaletteCommand> commands;

  static Future<void> show(
    BuildContext context,
    List<PaletteCommand> commands,
  ) {
    return showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.55),
      builder: (_) => CommandPalette(commands: commands),
    );
  }

  @override
  State<CommandPalette> createState() => _CommandPaletteState();
}

class _CommandPaletteState extends State<CommandPalette> {
  final _controller = TextEditingController();
  final _focus = FocusNode();
  final _scroll = ScrollController();
  int _selected = 0;

  List<PaletteCommand> get _results =>
      widget.commands.where((c) => c.matches(_controller.text)).toList();

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _move(int delta) {
    final results = _results;
    if (results.isEmpty) return;
    setState(() {
      // Wraps at both ends, which is what every palette does.
      _selected = (_selected + delta) % results.length;
      if (_selected < 0) _selected += results.length;
    });
  }

  void _invoke() {
    final results = _results;
    if (results.isEmpty) return;
    final command = results[_selected.clamp(0, results.length - 1)];
    Navigator.of(context).pop();
    command.onInvoke();
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    switch (event.logicalKey) {
      case LogicalKeyboardKey.arrowDown:
        _move(1);
        return KeyEventResult.handled;
      case LogicalKeyboardKey.arrowUp:
        _move(-1);
        return KeyEventResult.handled;
      case LogicalKeyboardKey.enter:
      case LogicalKeyboardKey.numpadEnter:
        _invoke();
        return KeyEventResult.handled;
      case LogicalKeyboardKey.escape:
        Navigator.of(context).pop();
        return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final theme = Theme.of(context);
    final results = _results;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      alignment: Alignment.topCenter,
      insetPadding: EdgeInsets.symmetric(
        horizontal: 20,
        vertical: MediaQuery.sizeOf(context).height * 0.12,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(Radii.lg),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 560, maxHeight: 460),
            decoration: BoxDecoration(
              color: c.surface.withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(Radii.lg),
              border: Border.all(color: c.glassBorder),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.4),
                  blurRadius: 48,
                  offset: const Offset(0, 18),
                ),
              ],
            ),
            child: Focus(
              onKeyEvent: _onKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.fromLTRB(Space.md, 14, Space.md, 12),
                    child: Row(
                      children: [
                        Icon(Icons.search_rounded,
                            size: 17, color: c.textTertiary),
                        const SizedBox(width: 11),
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            focusNode: _focus,
                            autofocus: true,
                            style: theme.textTheme.bodyLarge
                                ?.copyWith(color: c.textPrimary, fontSize: 15),
                            decoration: InputDecoration(
                              isDense: true,
                              filled: false,
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                              hintText: 'Search sections and actions…',
                              hintStyle: theme.textTheme.bodyMedium
                                  ?.copyWith(color: c.textTertiary),
                            ),
                            onChanged: (_) => setState(() => _selected = 0),
                            onSubmitted: (_) => _invoke(),
                          ),
                        ),
                        const _Kbd('esc'),
                      ],
                    ),
                  ),
                  Divider(height: 1, color: c.hairline),
                  Flexible(
                    child: results.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.all(Space.xl),
                            child: Text('No matches',
                                style: theme.textTheme.bodyMedium),
                          )
                        : ListView.builder(
                            controller: _scroll,
                            shrinkWrap: true,
                            padding: const EdgeInsets.all(Space.sm),
                            itemCount: results.length,
                            itemBuilder: (context, i) {
                              final cmd = results[i];
                              final active = i == _selected;
                              return _PaletteRow(
                                command: cmd,
                                active: active,
                                onTap: () {
                                  setState(() => _selected = i);
                                  _invoke();
                                },
                              );
                            },
                          ),
                  ),
                  Divider(height: 1, color: c.hairline),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: Space.md, vertical: 10),
                    child: Row(
                      children: [
                        const _Kbd('↑↓'),
                        const SizedBox(width: 7),
                        Text('navigate', style: theme.textTheme.bodySmall),
                        const SizedBox(width: Space.md),
                        const _Kbd('↵'),
                        const SizedBox(width: 7),
                        Text('select', style: theme.textTheme.bodySmall),
                        const Spacer(),
                        Text('${results.length}',
                            style: theme.textTheme.bodySmall),
                      ],
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

class _PaletteRow extends StatelessWidget {
  const _PaletteRow({
    required this.command,
    required this.active,
    required this.onTap,
  });

  final PaletteCommand command;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(Radii.sm),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 10),
        decoration: BoxDecoration(
          color: active ? c.accentSoft : Colors.transparent,
          borderRadius: BorderRadius.circular(Radii.sm),
        ),
        child: Row(
          children: [
            Icon(command.icon,
                size: 15, color: active ? c.accent : c.textTertiary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                command.label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: active ? c.textPrimary : c.textSecondary,
                  fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
            Text(command.group, style: theme.textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _Kbd extends StatelessWidget {
  const _Kbd(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: c.glassFill,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: c.glassBorder),
      ),
      child: Text(
        label,
        style: Theme.of(context)
            .textTheme
            .bodySmall
            ?.copyWith(fontSize: 10.5, color: c.textTertiary),
      ),
    );
  }
}
