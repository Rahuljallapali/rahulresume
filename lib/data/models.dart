import 'package:flutter/widgets.dart';

/// Domain models for portfolio content.
///
/// Everything rendered by the site is built from these immutable models,
/// declared once in `profile.dart`. Keeping content out of widgets means a
/// factual correction is a one-line edit in one file, not a hunt through
/// the widget tree.

@immutable
class SocialLink {
  const SocialLink({
    required this.label,
    required this.url,
    required this.icon,
    this.handle,
  });

  final String label;
  final String url;
  final IconData icon;
  final String? handle;
}

@immutable
class Stat {
  const Stat({
    required this.value,
    required this.label,
    required this.detail,
    this.suffix = '',
    this.prefix = '',
  });

  /// Numeric target used to drive the count-up animation.
  final int value;
  final String label;

  /// The provenance of the number — shown on hover/below so the figure is
  /// auditable rather than decorative.
  final String detail;
  final String suffix;
  final String prefix;
}

enum ProjectKind { professional, personal }

@immutable
class ProjectHighlight {
  const ProjectHighlight({required this.title, required this.body});
  final String title;
  final String body;
}

@immutable
class Project {
  const Project({
    required this.slug,
    required this.name,
    required this.role,
    required this.summary,
    required this.kind,
    required this.tags,
    required this.stack,
    required this.highlights,
    this.metrics = const [],
    this.challenge,
    this.architecture,
    this.repoUrl,
    this.liveUrl,
    this.images = const [],
    this.isFlagship = false,
    this.privateNote,
  });

  /// URL segment for the deep-linkable case study: `/#/work/<slug>`.
  final String slug;
  final String name;
  final String role;
  final String summary;
  final ProjectKind kind;

  /// Filter facets — must intersect with [Profile.projectFilters].
  final List<String> tags;
  final List<String> stack;
  final List<ProjectHighlight> highlights;
  final List<Stat> metrics;
  final String? challenge;
  final String? architecture;
  final String? repoUrl;
  final String? liveUrl;
  final List<String> images;
  final bool isFlagship;

  /// Shown in place of a repo link when the source is not public.
  final String? privateNote;
}

@immutable
class Skill {
  const Skill({
    required this.name,
    required this.level,
    this.evidence,
  });

  final String name;

  /// 0.0–1.0. Deliberately coarse: 4 bands, not false precision.
  final double level;

  /// Where this was actually used. Null for tools where the claim is trivial.
  final String? evidence;
}

@immutable
class SkillGroup {
  const SkillGroup({
    required this.title,
    required this.icon,
    required this.skills,
  });

  final String title;
  final IconData icon;
  final List<Skill> skills;
}

/// Which illustration the stylised phone renders for an app.
///
/// Explicit rather than inferred from the other flags: how an app is
/// distributed says nothing about what its screen looks like.
enum AppMock { list, release, beacon }

/// A shipped application.
///
/// Kept separate from [Project]: shipping is proof of delivery, not a case
/// study. [role] states the honest boundary of the contribution — built it,
/// contributed to it, or carried it through release — and the distribution
/// flags decide what the card is allowed to claim. An app with no public
/// listing never renders a store badge.
@immutable
class StoreApp {
  const StoreApp({
    required this.name,
    required this.tagline,
    required this.description,
    required this.role,
    required this.accent,
    required this.stack,
    this.appStoreUrl,
    this.playStoreUrl,
    this.releaseOnly = false,
    this.enterprise = false,
    this.mock = AppMock.list,
    this.caseStudy,
  });

  /// Distributed inside an organisation rather than through a public store.
  /// Real, deployed, and deliberately unlinkable — so the card says that
  /// instead of implying a listing a reader could go and check.
  final bool enterprise;

  final AppMock mock;

  /// Slug of the [Project] that documents this app in depth, when one exists.
  /// Null for apps whose card text is already the whole honest story.
  final String? caseStudy;

  final String name;
  final String tagline;
  final String description;

  /// What was actually done on this app — never overstated.
  final String role;

  /// Hue used by the stylised phone mockup for this app.
  final Color accent;
  final List<String> stack;
  final String? appStoreUrl;
  final String? playStoreUrl;

  /// True when the contribution was the iOS release itself, not the code.
  final bool releaseOnly;
}

@immutable
class Experience {
  const Experience({
    required this.role,
    required this.company,
    required this.period,
    required this.location,
    required this.summary,
    required this.achievements,
    required this.stack,
    this.isCurrent = false,
  });

  final String role;
  final String company;
  final String period;
  final String location;
  final String summary;
  final List<String> achievements;
  final List<String> stack;
  final bool isCurrent;
}

@immutable
class Principle {
  const Principle({
    required this.title,
    required this.body,
    required this.evidence,
    required this.icon,
  });

  final String title;
  final String body;

  /// A concrete thing that was shipped — keeps the section from being buzzwords.
  final String evidence;
  final IconData icon;
}

@immutable
class PipelineStage {
  const PipelineStage({
    required this.label,
    required this.detail,
    required this.icon,
  });

  final String label;
  final String detail;
  final IconData icon;
}

// -----------------------------------------------------------------------------
// Architecture diagram
// -----------------------------------------------------------------------------

/// One box in the request-flow diagram.
@immutable
class ArchNode {
  const ArchNode({required this.label, required this.detail, this.badge});

  final String label;

  /// One short line explaining what this stage actually does.
  final String detail;

  /// Optional count or version rendered in mono beside the label.
  final String? badge;
}

/// A vertical column of the diagram — one hop in the request path.
@immutable
class ArchLayer {
  const ArchLayer({
    required this.title,
    required this.icon,
    required this.nodes,
  });

  final String title;
  final IconData icon;
  final List<ArchNode> nodes;
}

// -----------------------------------------------------------------------------
// API playground
// -----------------------------------------------------------------------------

/// A canned request/response pair for the interactive endpoint demo.
///
/// Deliberately not wired to a live server: the point is to show the shape of
/// the API surface and the thinking behind it, and a portfolio must not depend
/// on a backend that could be down when a recruiter opens it. [note] states
/// what each endpoint is meant to demonstrate.
@immutable
class ApiEndpoint {
  const ApiEndpoint({
    required this.method,
    required this.path,
    required this.summary,
    required this.note,
    required this.status,
    required this.latencyMs,
    required this.response,
    this.requestBody,
  });

  final String method;
  final String path;
  final String summary;

  /// The engineering point this endpoint illustrates.
  final String note;
  final int status;

  /// Simulated round-trip, used for the timing readout and the fake wait.
  final int latencyMs;

  /// Pretty-printed JSON, rendered through the tokeniser in `json_view.dart`.
  final String response;
  final String? requestBody;
}

// -----------------------------------------------------------------------------
// Notes (writing)
// -----------------------------------------------------------------------------

enum NoteBlockKind { heading, paragraph, code, bullets, callout }

@immutable
class NoteBlock {
  const NoteBlock.heading(this.text)
      : kind = NoteBlockKind.heading,
        items = const [],
        language = null;

  const NoteBlock.paragraph(this.text)
      : kind = NoteBlockKind.paragraph,
        items = const [],
        language = null;

  const NoteBlock.code(this.text, {this.language})
      : kind = NoteBlockKind.code,
        items = const [];

  const NoteBlock.bullets(this.items)
      : kind = NoteBlockKind.bullets,
        text = '',
        language = null;

  const NoteBlock.callout(this.text)
      : kind = NoteBlockKind.callout,
        items = const [],
        language = null;

  final NoteBlockKind kind;
  final String text;
  final List<String> items;
  final String? language;
}

/// A shape of work a client can actually buy.
///
/// Only rendered under the hidden freelance lens — see `lens.dart`. The
/// default site is recruiter-facing, where engagement pricing reads as
/// divided attention.
@immutable
class Engagement {
  const Engagement({
    required this.title,
    required this.pitch,
    required this.deliverables,
    required this.icon,
    this.typicalLength,
  });

  final String title;
  final String pitch;
  final List<String> deliverables;
  final IconData icon;
  final String? typicalLength;
}

/// A short technical write-up, deep-linkable at `/#/notes/<slug>`.
@immutable
class Note {
  const Note({
    required this.slug,
    required this.title,
    required this.dek,
    required this.date,
    required this.readingMinutes,
    required this.tags,
    required this.body,
  });

  final String slug;
  final String title;

  /// Standfirst — the one-sentence reason to read on.
  final String dek;

  /// Display date, already formatted. Absolute, never "2 months ago".
  final String date;
  final int readingMinutes;
  final List<String> tags;
  final List<NoteBlock> body;
}
