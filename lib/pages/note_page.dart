import 'package:flutter/material.dart';

import '../app/theme/tokens.dart';
import '../data/models.dart';
import '../data/notes.dart';
import '../sections/notes_section.dart';
import '../ui/detail_shell.dart';
import '../ui/layout.dart';
import '../ui/note_body.dart';
import '../ui/primitives.dart';
import '../ui/reveal.dart';

/// One written note, at `/#/notes/<slug>`.
class NotePage extends StatelessWidget {
  const NotePage({super.key, required this.note});

  final Note note;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final theme = Theme.of(context);

    final more = Notes.all.where((n) => n.slug != note.slug).toList();

    return DetailShell(
      backLabel: 'All notes',
      children: [
        ContentShell(
          vertical: Space.xl,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Wrap, not Row: the date and reading time are mono uppercase
              // with wide tracking and do not fit one line on a 320px phone.
              Wrap(
                spacing: Space.sm,
                runSpacing: 4,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(note.date, style: theme.textTheme.labelMedium),
                  Container(
                    width: 3,
                    height: 3,
                    decoration: BoxDecoration(
                      color: c.textTertiary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Text(
                    '${note.readingMinutes} MIN READ',
                    style: theme.textTheme.labelMedium,
                  ),
                ],
              ),
              const SizedBox(height: Space.lg),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 820),
                child: Text(
                  note.title,
                  style: context.isCompact
                      ? theme.textTheme.displaySmall
                      : theme.textTheme.displayMedium,
                ),
              ),
              const SizedBox(height: Space.lg),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 680),
                child: Text(
                  note.dek,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontSize: 19,
                    height: 1.6,
                    color: c.textSecondary,
                  ),
                ),
              ),
              const SizedBox(height: Space.lg),
              Wrap(
                spacing: Space.sm,
                runSpacing: Space.sm,
                children: [for (final t in note.tags) TagChip(t)],
              ),
              const SizedBox(height: Space.lg),
              SizedBox(
                width: 60,
                child: Divider(color: c.accent, thickness: 2),
              ),
            ],
          ),
        ),
        ContentShell(
          vertical: Space.md,
          child: NoteBody(blocks: note.body),
        ),
        if (more.isNotEmpty)
          Reveal(
            child: ContentShell(
              vertical: Space.xl,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Read next', style: theme.textTheme.headlineSmall),
                  const SizedBox(height: Space.lg),
                  AutoGrid(
                    columns: context.responsive(compact: 1, medium: 2, wide: 2),
                    children: [for (final n in more) NoteCard(note: n)],
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
