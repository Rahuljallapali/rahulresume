import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'providers/theme_provider.dart';
import 'widgets/hero_section.dart';
import 'package:get/get.dart';
import 'routes/app_routes.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const ResumeApp(),
    ),
  );
}

class ResumeApp extends StatelessWidget {
  const ResumeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final currentTheme = themeProvider.currentTheme;
        final textTheme = currentTheme.textTheme;
        
        return GetMaterialApp(
          title: 'Rahul Jallapalli | Software Developer',
          debugShowCheckedModeBanner: false,
          theme: currentTheme.copyWith(
            textTheme: GoogleFonts.montserratTextTheme(textTheme).copyWith(
              displayLarge: GoogleFonts.playfairDisplay(textStyle: textTheme.displayLarge),
              displayMedium: GoogleFonts.playfairDisplay(textStyle: textTheme.displayMedium),
              displaySmall: GoogleFonts.playfairDisplay(textStyle: textTheme.displaySmall),
              headlineLarge: GoogleFonts.playfairDisplay(textStyle: textTheme.headlineLarge),
              headlineMedium: GoogleFonts.playfairDisplay(textStyle: textTheme.headlineMedium),
              headlineSmall: GoogleFonts.playfairDisplay(textStyle: textTheme.headlineSmall),
            ),
          ),
          initialRoute: '/',
          getPages: AppRoutes.routes,
          home: const ResumeHomePage(),
          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
              child: child!,
            );
          },
        );
      },
    );
  }
}

class ResumeHomePage extends StatelessWidget {
  const ResumeHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            HeroSection(),
            // TODO: Add other sections
          ],
        ),
      ),
    );
  }
}
