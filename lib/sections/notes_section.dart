import 'package:flutter/material.dart';

import '../app/router.dart';
import '../app/theme/tokens.dart';
import '../data/models.dart';
import '../data/notes.dart';
import '../ui/glass_card.dart';
import '../ui/layout.dart';
import '../ui/primitives.dart';
import '../ui/reveal.dart';

/// Index of the written notes. Each card opens a deep-linkable page.
class NotesSection extends StatelessWidget {
  const NotesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return ContentShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Reveal(
            child: SectionHeader(
              eyebrow: 'Writing',
              title: 'Notes from production',
              lead: 'Decisions made on the systems described above, written up '
                  'while the reasoning was still fresh. Short, specific, and '
                  'about trade-offs rather than tutorials.',
            ),
          ),
          const SizedBox(height: Space.xl),
          AutoGrid(
            columns: context.responsive(compact: 1, medium: 2, wide: 3),
            children: [
              for (var i = 0; i < Notes.all.length; i++)
                Reveal(
                  delay: Duration(milliseconds: 80 * i),
                  child: NoteCard(note: Notes.all[i]),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Shared between the index and the "read next" strip on a note page.
class NoteCard extends StatelessWidget {
  const NoteCard({super.key, required this.note});
  final Note note;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final theme = Theme.of(context);

    return GlassCard(
      onTap: () => AppRouter.openNote(context, note.slug),
      semanticLabel: '${note.title}. ${note.dek}',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(note.date, style: theme.textTheme.labelSmall),
              const SizedBox(width: Space.sm),
              Container(
                  width: 3,
                  height: 3,
                  decoration: BoxDecoration(
                    color: c.textTertiary,
                    shape: BoxShape.circle,
                  )),
              const SizedBox(width: Space.sm),
              Text(
                '${note.readingMinutes} min read',
                style: theme.textTheme.labelSmall,
              ),
            ],
          ),
          const SizedBox(height: Space.md),
          Text(note.title, style: theme.textTheme.headlineSmall),
          const SizedBox(height: Space.sm),
          Text(
            note.dek,
            style: theme.textTheme.bodyMedium,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: Space.md),
          Wrap(
            spacing: Space.sm,
            runSpacing: Space.sm,
            children: [for (final t in note.tags) TagChip(t)],
          ),
          const SizedBox(height: Space.md),
          Row(
            children: [
              Text(
                'Read',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: c.accent,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 5),
              Icon(Icons.arrow_forward_rounded, size: 15, color: c.accent),
            ],
          ),
        ],
      ),
    );
  }
}
