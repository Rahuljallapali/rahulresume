import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app/lens.dart';
import 'app/router.dart';
import 'app/theme/app_theme.dart';
import 'app/theme/theme_controller.dart';
import 'data/profile.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const PortfolioApp());
}

class PortfolioApp extends StatelessWidget {
  const PortfolioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeController()),
        // Which specialism the page leads with. Resolved from ?role= in the
        // URL, then from storage — see lens.dart.
        ChangeNotifierProvider(create: (_) => LensController()),
      ],
      child: Consumer<ThemeController>(
        builder: (context, controller, _) {
          return MaterialApp(
            title: '${Profile.name} — ${Profile.title}',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: controller.mode,
            // Cross-fades the entire tree on theme change instead of snapping.
            themeAnimationDuration: const Duration(milliseconds: 340),
            themeAnimationCurve: Curves.easeOutCubic,
            // Named routes so case studies and notes are shareable URLs.
            // Hash-based on web, which is what GitHub Pages can serve.
            initialRoute: AppRouter.home,
            onGenerateRoute: AppRouter.generate,
            builder: (context, child) {
              // Clamp text scaling: the layout adapts well up to 1.3x, beyond
              // which headings start colliding. Below 1.0 we never shrink,
              // since that would undo an accessibility preference.
              final scale = MediaQuery.textScalerOf(context).scale(1.0);
              return _ErrorBoundary(
                child: MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                    textScaler: TextScaler.linear(scale.clamp(1.0, 1.3)),
                  ),
                  child: child!,
                ),
              );
            },
          );
        },
      ),
    );
  }
}

/// Replaces the red-screen-of-death with something a visitor can act on.
///
/// A portfolio that crashes in front of a recruiter is worse than one that
/// degrades — this keeps a working email address on screen no matter what.
class _ErrorBoundary extends StatefulWidget {
  const _ErrorBoundary({required this.child});
  final Widget child;

  @override
  State<_ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<_ErrorBoundary> {
  /// `ErrorWidget.builder` is process-global. Capturing the previous value and
  /// restoring it on dispose keeps this widget from leaking its override into
  /// anything else that mounts later — which is exactly what the test binding
  /// checks for, and would otherwise be a real bug in a host app.
  late final ErrorWidgetBuilder _previousBuilder;

  @override
  void initState() {
    super.initState();
    _previousBuilder = ErrorWidget.builder;
    ErrorWidget.builder = (details) {
      // Keep the real error in the console for debugging; show the visitor
      // something useful instead of a stack trace.
      debugPrint('Render error: ${details.exceptionAsString()}');
      return const _FallbackScreen();
    };
  }

  @override
  void dispose() {
    ErrorWidget.builder = _previousBuilder;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class _FallbackScreen extends StatelessWidget {
  const _FallbackScreen();

  @override
  Widget build(BuildContext context) {
    // Deliberately theme-independent: this renders when something has already
    // gone wrong, so it must not depend on an inherited widget that may be the
    // thing that failed.
    return const Material(
      color: Color(0xFF08090C),
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Something went wrong rendering this section.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFFF5F6F8),
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'The rest of the page should still work. You can also reach '
                'me directly:',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFFA7ADBB), fontSize: 14),
              ),
              SizedBox(height: 6),
              SelectableText(
                Profile.email,
                style: TextStyle(color: Color(0xFF6E8BFF), fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
