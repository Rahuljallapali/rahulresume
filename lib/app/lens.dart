import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Which specialism the page leads with.
///
/// The same body of work reads differently to a Spring Boot hiring manager and
/// a Flutter one. Rather than average the two into a page that convinces
/// neither, the site reorders itself: the headline, the metric strip, the
/// project order and the skill order all follow the selected lens.
///
/// Crucially, no lens hides the other half — a backend recruiter looking at
/// the backend lens still sees the shipped apps, because "and he ships the
/// clients too" is an argument *for* hiring him, not a distraction.
enum Lens {
  both('both', 'Full stack', 'Both'),
  backend('backend', 'Spring Boot', 'Spring'),
  mobile('mobile', 'Flutter', 'Flutter'),

  /// Reachable only by `?role=freelance`, never offered in the toggle.
  ///
  /// A hiring manager who spots a "Freelance" tab reads divided attention,
  /// which is the exact impression this site is built to avoid — so the link
  /// is something to hand to a client, not something a recruiter can wander
  /// into. It is also never remembered between visits: see
  /// [LensController._set].
  freelance('freelance', 'Freelance', 'Freelance');

  const Lens(this.slug, this.label, this.shortLabel);

  final String slug;
  final String label;

  /// Used where three full labels will not fit on one line — a phone.
  final String shortLabel;

  /// The lenses the on-page switcher offers.
  static const offered = [Lens.both, Lens.backend, Lens.mobile];

  bool get isHidden => !offered.contains(this);

  static Lens fromSlug(String? slug) {
    if (slug == null) return Lens.both;
    final normalised = slug.toLowerCase().trim();
    for (final lens in Lens.values) {
      if (lens.slug == normalised) return lens;
    }
    // Friendly aliases, so a link written from memory still lands correctly.
    return switch (normalised) {
      'java' || 'spring' || 'springboot' || 'spring-boot' => Lens.backend,
      'flutter' || 'dart' || 'app' || 'android' || 'ios' => Lens.mobile,
      'client' || 'hire' || 'contract' || 'consulting' => Lens.freelance,
      _ => Lens.both,
    };
  }
}

/// Holds the active [Lens] and remembers it between visits.
///
/// Resolution order is deliberate: an explicit `?role=` in the URL always
/// wins, because that link was written for a specific reader and must show
/// them what it promised regardless of what this browser saw last time.
class LensController extends ChangeNotifier {
  LensController() {
    _resolveInitial();
  }

  static const _prefsKey = 'lens';

  Lens _lens = Lens.both;
  Lens get lens => _lens;

  bool get isBackend => _lens == Lens.backend;
  bool get isMobile => _lens == Lens.mobile;

  /// True when the reader has not asked for a specialism, so the page should
  /// argue both sides at once.
  bool get isBoth => _lens == Lens.both;

  Future<void> _resolveInitial() async {
    final fromUrl = Uri.base.queryParameters['role'];
    if (fromUrl != null && fromUrl.isNotEmpty) {
      _set(Lens.fromSlug(fromUrl), persist: false);
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final stored = prefs.getString(_prefsKey);
      if (stored != null) _set(Lens.fromSlug(stored), persist: false);
    } catch (_) {
      // Storage denied (private mode, blocked cookies) — the default lens is
      // a perfectly good page, so this is not worth surfacing.
    }
  }

  void select(Lens lens) => _set(lens, persist: true);

  void _set(Lens lens, {required bool persist}) {
    if (_lens == lens) return;
    _lens = lens;
    notifyListeners();

    // Hidden lenses are never remembered. Otherwise opening the freelance
    // link once would leave this browser showing freelance content on every
    // later visit — including the visit where the owner checks what a
    // recruiter is about to see.
    if (!persist || lens.isHidden) return;
    SharedPreferences.getInstance()
        .then((prefs) => prefs.setString(_prefsKey, lens.slug))
        .catchError((_) => false);
  }
}
