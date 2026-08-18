import 'package:flutter/material.dart';

import '../app/theme/tokens.dart';
import '../data/profile.dart';
import '../services/email_service.dart';
import '../ui/glass_card.dart';
import '../ui/layout.dart';
import '../ui/primitives.dart';
import '../ui/reveal.dart';
import '../utils/link.dart';

class ContactSection extends StatefulWidget {
  const ContactSection({super.key});

  @override
  State<ContactSection> createState() => _ContactSectionState();
}

class _ContactSectionState extends State<ContactSection> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _message = TextEditingController();

  bool _sending = false;
  bool _sent = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _message.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    // Dismiss the keyboard before the async gap so the success state is
    // actually visible on a phone.
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _sending = true;
      _error = null;
    });

    final failure = await EmailService.send(
      name: _name.text.trim(),
      email: _email.text.trim(),
      message: _message.text.trim(),
    );

    if (!mounted) return;
    setState(() {
      _sending = false;
      _error = failure;
      _sent = failure == null;
    });

    if (failure == null) {
      _name.clear();
      _email.clear();
      _message.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final theme = Theme.of(context);
    final compact = context.isCompact;

    final intro = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          eyebrow: 'Contact',
          title: 'Let us talk',
          lead: 'Open to senior Spring Boot & Flutter roles. The fastest '
              'route is email — I reply to everything that is not a mass '
              'mailing.',
        ),
        const SizedBox(height: Space.xl),
        for (final s in Profile.socials)
          Padding(
            padding: const EdgeInsets.only(bottom: Space.sm),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: c.glassFill,
                    borderRadius: BorderRadius.circular(Radii.sm),
                    border: Border.all(color: c.glassBorder),
                  ),
                  child: Icon(s.icon, size: 15, color: c.textSecondary),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(s.label, style: theme.textTheme.bodySmall),
                      InkWell(
                        onTap: () => openLink(s.url),
                        child: Text(
                          s.handle ?? s.url,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: c.textPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (s.handle != null)
                  CopyButton(value: s.handle!, label: s.label),
              ],
            ),
          ),
        const SizedBox(height: Space.lg),
        const _ScreeningFacts(),
      ],
    );

    final form = GlassCard(
      interactive: false,
      padding: EdgeInsets.all(compact ? Space.lg : Space.xl),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Send a message', style: theme.textTheme.titleLarge),
            const SizedBox(height: Space.lg),
            _Field(
              controller: _name,
              label: 'Name',
              hint: 'Your name',
              textInputAction: TextInputAction.next,
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Please add your name'
                  : null,
            ),
            _Field(
              controller: _email,
              label: 'Email',
              hint: 'you@company.com',
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              validator: (v) {
                final value = v?.trim() ?? '';
                if (value.isEmpty) return 'Please add your email';
                // Intentionally permissive: the only real validation of an
                // address is whether mail to it arrives. This catches typos,
                // not exotic-but-valid addresses.
                if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value)) {
                  return 'That does not look like an email address';
                }
                return null;
              },
            ),
            _Field(
              controller: _message,
              label: 'Message',
              hint: 'What are you working on?',
              maxLines: 5,
              validator: (v) => (v == null || v.trim().length < 10)
                  ? 'A sentence or two is plenty'
                  : null,
            ),
            const SizedBox(height: Space.sm),
            MagneticButton(
              label: _sending ? 'Sending…' : 'Send message',
              icon: Icons.send_rounded,
              expand: true,
              busy: _sending,
              onPressed: _submit,
            ),
            // Status is announced via a live region so a screen-reader user
            // learns the result without hunting for it.
            if (_sent || _error != null) ...[
              const SizedBox(height: Space.md),
              Semantics(
                liveRegion: true,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      _sent
                          ? Icons.check_circle_rounded
                          : Icons.error_outline_rounded,
                      size: 16,
                      color: _sent ? c.success : theme.colorScheme.error,
                    ),
                    const SizedBox(width: 9),
                    Expanded(
                      child: Text(
                        _sent
                            ? 'Message sent — I will get back to you shortly.'
                            : _error!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: _sent ? c.success : theme.colorScheme.error,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );

    return ContentShell(
      child: Reveal(
        child: compact
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [intro, const SizedBox(height: Space.xl), form],
              )
            : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 5, child: intro),
                  const SizedBox(width: Space.xxl),
                  Expanded(flex: 6, child: form),
                ],
              ),
      ),
    );
  }
}

/// The handful of facts a recruiter checks before writing to anyone.
///
/// Answering them here removes a round-trip email from the process. Rows with
/// no value are skipped entirely rather than shown blank — see the notes on
/// [Profile.phone] and [Profile.noticePeriod].
class _ScreeningFacts extends StatelessWidget {
  const _ScreeningFacts();

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final theme = Theme.of(context);

    final facts = <(IconData, String, String)>[
      (Icons.badge_outlined, 'Experience', Profile.experience),
      (Icons.place_outlined, 'Based in', Profile.location),
      (Icons.schedule_rounded, 'Working hours', Profile.timezone),
      if (Profile.noticePeriod.isNotEmpty)
        (Icons.event_available_rounded, 'Notice period', Profile.noticePeriod),
      if (Profile.phone.isNotEmpty)
        (Icons.call_outlined, 'Phone', Profile.phone),
      (Icons.flight_takeoff_rounded, 'Mobility', Profile.openToRelocation),
    ];

    return Container(
      padding: const EdgeInsets.all(Space.md),
      decoration: BoxDecoration(
        color: c.glassFill,
        borderRadius: BorderRadius.circular(Radii.md),
        border: Border.all(color: c.glassBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final (icon, label, value) in facts)
            Padding(
              padding: const EdgeInsets.only(bottom: Space.sm),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(icon, size: 14, color: c.textTertiary),
                  const SizedBox(width: 11),
                  SizedBox(
                    width: 108,
                    child: Text(label, style: theme.textTheme.bodySmall),
                  ),
                  Expanded(
                    child: Text(
                      value,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: c.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
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

class _Field extends StatelessWidget {
  const _Field({
    required this.controller,
    required this.label,
    required this.hint,
    this.validator,
    this.maxLines = 1,
    this.keyboardType,
    this.textInputAction,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final String? Function(String?)? validator;
  final int maxLines;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: Space.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.titleSmall),
          const SizedBox(height: 7),
          TextFormField(
            controller: controller,
            validator: validator,
            maxLines: maxLines,
            keyboardType: keyboardType,
            textInputAction: textInputAction,
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: AppColors.of(context).textPrimary),
            decoration: InputDecoration(hintText: hint),
          ),
        ],
      ),
    );
  }
}
