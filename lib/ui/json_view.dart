import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../app/theme/tokens.dart';

/// Syntax-coloured JSON.
///
/// Hand-tokenised rather than pulled from a highlighting package: the input is
/// always pretty-printed JSON authored in this repository, so a full grammar
/// would be weight for no benefit. The scanner walks the string once and never
/// throws — worst case a fragment renders in the plain colour.
class JsonView extends StatelessWidget {
  const JsonView(this.source, {super.key, this.fontSize = 12});

  final String source;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final dark = Theme.of(context).brightness == Brightness.dark;

    final key = dark ? const Color(0xFF82AAFF) : const Color(0xFF2F5FE0);
    final str = dark ? const Color(0xFFC3E88D) : const Color(0xFF15803D);
    final num_ = dark ? const Color(0xFFF78C6C) : const Color(0xFFB45309);
    final lit = dark ? const Color(0xFFC792EA) : const Color(0xFF7C3AED);

    return SelectionArea(
      child: Text.rich(
        TextSpan(children: _scan(source, key, str, num_, lit, c.textSecondary)),
        style: GoogleFonts.jetBrainsMono(fontSize: fontSize, height: 1.65),
      ),
    );
  }
}

List<TextSpan> _scan(
  String src,
  Color keyColor,
  Color stringColor,
  Color numberColor,
  Color literalColor,
  Color plain,
) {
  final spans = <TextSpan>[];
  final buffer = StringBuffer();

  void flush() {
    if (buffer.isEmpty) return;
    spans
        .add(TextSpan(text: buffer.toString(), style: TextStyle(color: plain)));
    buffer.clear();
  }

  var i = 0;
  while (i < src.length) {
    final ch = src[i];

    if (ch == '"') {
      // Consume the whole literal, honouring backslash escapes.
      final start = i;
      i++;
      while (i < src.length) {
        if (src[i] == r'\') {
          i += 2;
          continue;
        }
        if (src[i] == '"') {
          i++;
          break;
        }
        i++;
      }
      final text = src.substring(start, i.clamp(0, src.length));

      // A string followed by a colon is an object key, not a value.
      var j = i;
      while (j < src.length && (src[j] == ' ' || src[j] == '\t')) {
        j++;
      }
      final isKey = j < src.length && src[j] == ':';

      flush();
      spans.add(
        TextSpan(
          text: text,
          style: TextStyle(color: isKey ? keyColor : stringColor),
        ),
      );
      continue;
    }

    if (_isDigit(ch) ||
        (ch == '-' && i + 1 < src.length && _isDigit(src[i + 1]))) {
      final start = i;
      i++;
      while (i < src.length && (_isDigit(src[i]) || src[i] == '.')) {
        i++;
      }
      flush();
      spans.add(
        TextSpan(
          text: src.substring(start, i),
          style: TextStyle(color: numberColor),
        ),
      );
      continue;
    }

    var matchedLiteral = false;
    for (final word in const ['true', 'false', 'null']) {
      if (src.startsWith(word, i)) {
        flush();
        spans.add(TextSpan(text: word, style: TextStyle(color: literalColor)));
        i += word.length;
        matchedLiteral = true;
        break;
      }
    }
    if (matchedLiteral) continue;

    // Punctuation and whitespace accumulate until the next coloured token.
    buffer.write(ch);
    i++;
  }

  flush();
  return spans;
}

bool _isDigit(String c) => c.codeUnitAt(0) >= 0x30 && c.codeUnitAt(0) <= 0x39;
