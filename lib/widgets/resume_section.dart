import 'package:flutter/material.dart';
import 'animated_section_divider.dart';
import 'scroll_animated_widget.dart';

class ResumeSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget content;
  final Duration delay;
  final Color? color;

  const ResumeSection({
    super.key,
    required this.title,
    required this.icon,
    required this.content,
    this.delay = const Duration(milliseconds: 100),
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ScrollAnimatedWidget(
      delay: delay,
      child: Column(
        children: [
          AnimatedSectionDivider(
            icon: icon,
            title: title,
            color: color,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: content,
          ),
        ],
      ),
    );
  }
} 