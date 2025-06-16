import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'services/pdf_service.dart';
import 'widgets/animated_project_image.dart';
import 'widgets/project_image_carousel.dart';
import 'providers/theme_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'widgets/project_card.dart';
import 'widgets/gradient_background.dart';
import 'widgets/responsive_layout.dart';
import 'widgets/animated_section_divider.dart';
import 'widgets/scroll_animated_widget.dart';
import 'widgets/resume_header.dart';
import 'widgets/resume_section.dart';
import 'widgets/hero_section.dart';
import 'package:get/get.dart';
import 'routes/app_routes.dart';

void main() {
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
    final themeProvider = Provider.of<ThemeProvider>(context);
    final textTheme = themeProvider.currentTheme.textTheme;

    return GetMaterialApp(
      title: 'Rahul Jallapalli - Flutter Developer',
      debugShowCheckedModeBanner: false,
      theme: themeProvider.currentTheme.copyWith(
        textTheme: GoogleFonts.montserratTextTheme(textTheme).copyWith(
          displayLarge: GoogleFonts.playfairDisplay(textStyle: textTheme.displayLarge),
          displayMedium: GoogleFonts.playfairDisplay(textStyle: textTheme.displayMedium),
          displaySmall: GoogleFonts.playfairDisplay(textStyle: textTheme.displaySmall),
          headlineLarge: GoogleFonts.playfairDisplay(textStyle: textTheme.headlineLarge),
          headlineMedium: GoogleFonts.playfairDisplay(textStyle: textTheme.headlineMedium),
          headlineSmall: GoogleFonts.playfairDisplay(textStyle: textTheme.headlineSmall),
        ),
      ),
      getPages: AppRoutes.routes,
      home: const ResumeHomePage(),
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
