import 'package:emailjs/emailjs.dart' as emailjs;
import 'package:flutter/foundation.dart';

import '../data/profile.dart';

/// Contact-form transport.
///
/// SECURITY — why there is no private key here:
/// This is a client-side web app. Anything compiled into it is readable by
/// anyone who opens devtools, so an EmailJS *private* key committed to this
/// file would let any visitor send mail through the account. The previous
/// implementation shipped one. It has been removed and should be treated as
/// compromised: rotate it in the EmailJS dashboard.
///
/// The public key is designed to be exposed, and is the only credential a
/// browser client needs. Abuse is contained at the service instead:
///   * Enable "Use Private Key" = OFF for this template, and turn ON the
///     allow-list of permitted domains in EmailJS → Account → Security.
///   * Leave the built-in rate limit on (configured below as well).
/// Both are dashboard settings, not code — they cannot be bypassed by editing
/// the bundle.
abstract final class EmailService {
  static const _serviceId = 'service_3wkd7gm';
  static const _templateId = 'template_4dlrq2o';

  /// Publishable by design. Not a secret.
  static const _publicKey = 'rDUz8SsNXHGEp1MtU';

  static bool _initialised = false;

  static void _ensureInit() {
    if (_initialised) return;
    emailjs.init(
      const emailjs.Options(
        publicKey: _publicKey,
        // Client-side throttle: one send per 10s per browser. Real enforcement
        // is server-side in the EmailJS dashboard; this only stops honest
        // double-submits.
        limitRate: emailjs.LimitRate(id: 'contact-form', throttle: 10000),
      ),
    );
    _initialised = true;
  }

  /// Returns null on success, or a human-readable reason on failure.
  static Future<String?> send({
    required String name,
    required String email,
    required String message,
  }) async {
    try {
      _ensureInit();
      await emailjs.send(
        _serviceId,
        _templateId,
        {
          'from_name': name,
          'from_email': email,
          'message': message,
          'to_email': Profile.email,
          'to_name': Profile.name,
        },
      );
      return null;
    } catch (e) {
      debugPrint('Contact form send failed: $e');
      // The raw SDK error is not useful to a visitor, and can leak template
      // ids — give them the fallback that always works instead.
      return 'Message could not be sent. Please email ${Profile.email} directly.';
    }
  }
}
