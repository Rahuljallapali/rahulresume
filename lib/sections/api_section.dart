import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../app/theme/tokens.dart';
import '../data/models.dart';
import '../data/profile.dart';
import '../ui/glass_card.dart';
import '../ui/json_view.dart';
import '../ui/layout.dart';
import '../ui/primitives.dart';
import '../ui/reveal.dart';

/// An interactive tour of the API surface.
///
/// Responses are canned and the latency is simulated — stated plainly in the
/// UI, because a demo that pretends to be live is a lie a technical reader
/// will catch in one devtools glance. What it does show honestly is the shape
/// of the endpoints and the reasoning behind each one.
class ApiSection extends StatefulWidget {
  const ApiSection({super.key});

  @override
  State<ApiSection> createState() => _ApiSectionState();
}

class _ApiSectionState extends State<ApiSection> {
  int _selected = 0;

  /// Bumped on every send so the response pane can key its transition.
  int _run = 0;
  bool _sending = false;
  bool _hasResponse = false;

  ApiEndpoint get _endpoint => Profile.apiEndpoints[_selected];

  Future<void> _send() async {
    if (_sending) return;
    setState(() {
      _sending = true;
      _hasResponse = false;
    });

    // Deliberate: the wait is what makes the status/timing readout meaningful.
    await Future<void>.delayed(Duration(milliseconds: _endpoint.latencyMs));

    if (!mounted) return;
    setState(() {
      _sending = false;
      _hasResponse = true;
      _run++;
    });
  }

  void _select(int index) {
    if (index == _selected) return;
    setState(() {
      _selected = index;
      _hasResponse = false;
      _sending = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final compact = context.isCompact;

    final list = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < Profile.apiEndpoints.length; i++)
          _EndpointTile(
            endpoint: Profile.apiEndpoints[i],
            selected: i == _selected,
            onTap: () => _select(i),
          ),
      ],
    );

    final console = _Console(
      endpoint: _endpoint,
      sending: _sending,
      hasResponse: _hasResponse,
      runKey: _run,
      onSend: _send,
    );

    return ContentShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Reveal(
            child: SectionHeader(
              eyebrow: 'The backend, hands-on',
              title: 'Try the API',
              lead: 'Five endpoints from the service, with the thinking behind '
                  'each one. Pick a request and send it — responses are '
                  'recorded rather than live, so this page never depends on a '
                  'server being up.',
            ),
          ),
          const SizedBox(height: Space.xl),
          Reveal(
            child: compact
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [list, const SizedBox(height: Space.lg), console],
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 4, child: list),
                      const SizedBox(width: Space.lg),
                      Expanded(flex: 6, child: console),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _EndpointTile extends StatelessWidget {
  const _EndpointTile({
    required this.endpoint,
    required this.selected,
    required this.onTap,
  });

  final ApiEndpoint endpoint;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: Space.sm),
      child: Semantics(
        button: true,
        selected: selected,
        label: '${endpoint.method} ${endpoint.path}',
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(Radii.md),
          child: AnimatedContainer(
            duration: Motion.fast,
            padding: const EdgeInsets.all(Space.md),
            decoration: BoxDecoration(
              color: selected ? c.accentSoft : c.glassFill,
              borderRadius: BorderRadius.circular(Radii.md),
              border: Border.all(
                color: selected ? c.accent.withValues(alpha: 0.55) : c.hairline,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _MethodBadge(method: endpoint.method),
                    const SizedBox(width: 9),
                    Expanded(
                      child: Text(
                        endpoint.path,
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 11.5,
                          height: 1.45,
                          fontWeight: FontWeight.w500,
                          color: selected ? c.textPrimary : c.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 7),
                Text(endpoint.summary, style: theme.textTheme.bodySmall),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MethodBadge extends StatelessWidget {
  const _MethodBadge({required this.method});
  final String method;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    // GET reads, POST writes — coloured the way every API console colours them.
    final color = method == 'GET' ? c.accentAlt : c.accent;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: color.withValues(alpha: 0.45)),
      ),
      child: Text(
        method,
        style: GoogleFonts.jetBrainsMono(
          fontSize: 9.5,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.6,
          color: color,
        ),
      ),
    );
  }
}

class _Console extends StatelessWidget {
  const _Console({
    required this.endpoint,
    required this.sending,
    required this.hasResponse,
    required this.runKey,
    required this.onSend,
  });

  final ApiEndpoint endpoint;
  final bool sending;
  final bool hasResponse;
  final int runKey;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;

    return GlassCard(
      interactive: false,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Request bar.
          Padding(
            padding: const EdgeInsets.all(Space.md),
            child: Row(
              children: [
                _MethodBadge(method: endpoint.method),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    endpoint.path,
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 11.5,
                      color: c.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: Space.sm),
                _SendButton(busy: sending, onPressed: onSend),
              ],
            ),
          ),
          Divider(color: c.hairline, height: 1),

          if (endpoint.requestBody != null) ...[
            const _PaneLabel(
              text: 'REQUEST BODY',
              trailing: 'application/json',
            ),
            Padding(
              padding:
                  const EdgeInsets.fromLTRB(Space.md, 0, Space.md, Space.md),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(Space.md),
                decoration: BoxDecoration(
                  color: dark
                      ? Colors.black.withValues(alpha: 0.30)
                      : Colors.black.withValues(alpha: 0.035),
                  borderRadius: BorderRadius.circular(Radii.sm),
                  border: Border.all(color: c.hairline),
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: JsonView(endpoint.requestBody!, fontSize: 11.5),
                ),
              ),
            ),
            Divider(color: c.hairline, height: 1),
          ],

          // Response pane.
          AnimatedSize(
            duration: Motion.base,
            curve: Motion.standard,
            alignment: Alignment.topCenter,
            child: sending
                ? const _Waiting()
                : hasResponse
                    ? _Response(key: ValueKey(runKey), endpoint: endpoint)
                    : const _Idle(),
          ),

          Divider(color: c.hairline, height: 1),
          Padding(
            padding: const EdgeInsets.all(Space.md),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.lightbulb_outline_rounded,
                    size: 14, color: c.accentAlt),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    endpoint.note,
                    style: theme.textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PaneLabel extends StatelessWidget {
  const _PaneLabel({required this.text, this.trailing});
  final String text;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding:
          const EdgeInsets.fromLTRB(Space.md, Space.md, Space.md, Space.sm),
      child: Row(
        children: [
          Text(text, style: theme.textTheme.labelSmall),
          const Spacer(),
          if (trailing != null)
            Text(
              trailing!,
              style: GoogleFonts.jetBrainsMono(
                fontSize: 10,
                color: AppColors.of(context).textTertiary,
              ),
            ),
        ],
      ),
    );
  }
}

class _SendButton extends StatelessWidget {
  const _SendButton({required this.busy, required this.onPressed});
  final bool busy;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final fg = Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF06070A)
        : Colors.white;

    return Semantics(
      button: true,
      label: 'Send request',
      child: InkWell(
        onTap: busy ? null : onPressed,
        borderRadius: BorderRadius.circular(Radii.pill),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [c.accent, c.accentAlt]),
            borderRadius: BorderRadius.circular(Radii.pill),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (busy)
                SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(fg),
                  ),
                )
              else
                Icon(Icons.play_arrow_rounded, size: 15, color: fg),
              const SizedBox(width: 7),
              Text(
                busy ? 'Sending' : 'Send',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: fg,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Idle extends StatelessWidget {
  const _Idle();

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Padding(
      padding: const EdgeInsets.all(Space.lg),
      child: Row(
        children: [
          Icon(Icons.terminal_rounded, size: 15, color: c.textTertiary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Press Send to run this request.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}

class _Waiting extends StatelessWidget {
  const _Waiting();

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Padding(
      padding: const EdgeInsets.all(Space.lg),
      child: Row(
        children: [
          SizedBox(
            width: 13,
            height: 13,
            child: CircularProgressIndicator(strokeWidth: 2, color: c.accent),
          ),
          const SizedBox(width: 12),
          Text(
            'Awaiting response…',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _Response extends StatelessWidget {
  const _Response({super.key, required this.endpoint});
  final ApiEndpoint endpoint;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;
    final ok = endpoint.status < 300;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding:
              const EdgeInsets.fromLTRB(Space.md, Space.md, Space.md, Space.sm),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: (ok ? c.success : theme.colorScheme.error)
                      .withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  '${endpoint.status} ${_statusText(endpoint.status)}',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: ok ? c.success : theme.colorScheme.error,
                  ),
                ),
              ),
              const SizedBox(width: Space.sm),
              Text(
                '${endpoint.latencyMs} ms',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 10.5,
                  color: c.textTertiary,
                ),
              ),
              const Spacer(),
              Text('RESPONSE', style: theme.textTheme.labelSmall),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(Space.md, 0, Space.md, Space.md),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(Space.md),
            decoration: BoxDecoration(
              color: dark
                  ? Colors.black.withValues(alpha: 0.30)
                  : Colors.black.withValues(alpha: 0.035),
              borderRadius: BorderRadius.circular(Radii.sm),
              border: Border.all(color: c.hairline),
            ),
            // Long JSON scrolls sideways rather than wrapping mid-token, which
            // is what a console does and what a reader expects.
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: JsonView(endpoint.response, fontSize: 11.5),
            ),
          ),
        ),
      ],
    );
  }
}

String _statusText(int status) => switch (status) {
      200 => 'OK',
      201 => 'Created',
      204 => 'No Content',
      400 => 'Bad Request',
      401 => 'Unauthorized',
      403 => 'Forbidden',
      404 => 'Not Found',
      _ => '',
    };
