import 'dart:convert';

import 'package:http/http.dart' as http;

import '../data/profile.dart';

/// One day in the contribution graph.
class ContributionDay {
  const ContributionDay({
    required this.date,
    required this.count,
    required this.level,
  });

  final DateTime date;
  final int count;

  /// 0–4, matching GitHub's own intensity buckets.
  final int level;
}

class ContributionYear {
  const ContributionYear({required this.total, required this.days});

  final int total;
  final List<ContributionDay> days;
}

/// Fetches the public contribution graph.
///
/// Uses a CORS-enabled community mirror of the profile graph rather than the
/// GitHub API directly: the official contributions endpoint is GraphQL-only
/// and requires a token, and a portfolio must not ship a credential to every
/// visitor's browser.
///
/// Failure is a first-class outcome, not an exception to swallow — the widget
/// renders an honest "could not load" state with a link to the profile, which
/// is strictly better than an empty grid a visitor would read as "no work".
abstract final class GitHubService {
  static const _base = 'https://github-contributions-api.jogruber.de/v4';

  /// Cached for the session: the graph does not change while someone reads the
  /// page, and a re-fetch on every rebuild would burn the shared rate limit.
  static Future<ContributionYear?>? _inFlight;

  static Future<ContributionYear?> contributions() =>
      _inFlight ??= _fetch().catchError((_) => null);

  static Future<ContributionYear?> _fetch() async {
    final uri = Uri.parse('$_base/${Profile.githubUser}?y=last');

    final response = await http.get(uri).timeout(const Duration(seconds: 8));

    if (response.statusCode != 200) return null;

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) return null;

    final raw = decoded['contributions'];
    if (raw is! List) return null;

    final days = <ContributionDay>[];
    for (final entry in raw) {
      if (entry is! Map) continue;
      final date = DateTime.tryParse('${entry['date']}');
      if (date == null) continue;
      final count = (entry['count'] as num?)?.toInt() ?? 0;
      final level = (entry['level'] as num?)?.toInt() ?? 0;
      days.add(
        ContributionDay(date: date, count: count, level: level.clamp(0, 4)),
      );
    }
    if (days.isEmpty) return null;

    // `total` is keyed by year, plus a "lastYear" rollup on the ?y=last query.
    final totals = decoded['total'];
    var total = 0;
    if (totals is Map) {
      final last = totals['lastYear'];
      if (last is num) {
        total = last.toInt();
      } else {
        for (final v in totals.values) {
          if (v is num) total += v.toInt();
        }
      }
    }
    if (total == 0) {
      total = days.fold(0, (sum, d) => sum + d.count);
    }

    return ContributionYear(total: total, days: days);
  }
}
