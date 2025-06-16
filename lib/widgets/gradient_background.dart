import 'package:flutter/material.dart';

class GradientBackground extends StatelessWidget {
  final Widget child;

  const GradientBackground({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDarkMode
              ? [
                  const Color(0xFF0F172A),
                  const Color(0xFF1E293B),
                  const Color(0xFF1E293B).withOpacity(0.8),
                ]
              : [
                  const Color(0xFFF0F9FF),
                  const Color(0xFFE0F2FE),
                  const Color(0xFFBAE6FD),
                ],
        ),
      ),
      child: Stack(
        children: [
          // Subtle dot pattern overlay
          CustomPaint(
            painter: DotPatternPainter(
              color: isDarkMode 
                  ? Colors.white.withOpacity(0.03)
                  : Colors.black.withOpacity(0.05),
            ),
            child: Container(),
          ),
          // Content
          child,
        ],
      ),
    );
  }
}

class DotPatternPainter extends CustomPainter {
  final Color color;

  DotPatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    const spacing = 20.0;
    const dotRadius = 1.0;

    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), dotRadius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(DotPatternPainter oldDelegate) => color != oldDelegate.color;
} 