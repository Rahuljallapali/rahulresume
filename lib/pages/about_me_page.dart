import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/back_button.dart';
import '../widgets/page_nav_bar.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class AboutMePage extends StatelessWidget {
  const AboutMePage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                _buildHeader(isDarkMode),
                Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.star,
                            color: theme.colorScheme.primary,
                            size: 28,
                          ),
                          const SizedBox(width: 16),
                          Text(
                            'About Me',
                            style: theme.textTheme.headlineLarge,
                          ),
                        ],
                      ),
                      const SizedBox(height: 48),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildParagraph(
                                  'I am a passionate Flutter developer with a strong foundation in mobile app development. My journey in software development started with native Android development, and I transitioned to Flutter to create beautiful, cross-platform applications.',
                                  theme,
                                ),
                                const SizedBox(height: 24),
                                _buildParagraph(
                                  'I believe in writing clean, maintainable code and following best practices. My experience includes working with various state management solutions, integrating RESTful APIs, and implementing real-time features using WebSocket and Firebase.',
                                  theme,
                                ),
                                const SizedBox(height: 24),
                                _buildParagraph(
                                  'When I\'m not coding, you can find me exploring new technologies, contributing to open-source projects, or enjoying nature through hiking and photography.',
                                  theme,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 48),
                          Expanded(
                            flex: 2,
                            child: Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: isDarkMode ? Colors.black12 : Colors.grey[100],
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isDarkMode ? Colors.grey[850]! : Colors.grey[300]!,
                                  width: 1,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildSectionTitle('Core Strengths', theme),
                                  const SizedBox(height: 16),
                                  _buildStrengthItem('Flutter & Dart', 'Cross-platform expertise', theme),
                                  _buildStrengthItem('Backend Integration', 'Spring Boot & AWS', theme),
                                  _buildStrengthItem('Real-time Features', 'WebSocket & Firebase', theme),
                                  _buildStrengthItem('Clean Architecture', 'SOLID principles', theme),
                                  const SizedBox(height: 32),
                                  _buildSectionTitle('Interests', theme),
                                  const SizedBox(height: 16),
                                  _buildInterestItem('UI/UX Design', theme),
                                  _buildInterestItem('Emerging Tech', theme),
                                  _buildInterestItem('AI Integration', theme),
                                  _buildInterestItem('Nature & Hiking', theme),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const CustomBackButton(),
          const PageNavBar(currentPage: 'About'),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isDarkMode) {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        color: Colors.black,
        image: DecorationImage(
          image: AssetImage(
            isDarkMode ? 'assets/homescreen.png' : 'assets/lightMode_homescreen.png'
          ),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            isDarkMode ? Colors.black.withOpacity(0.2) : Colors.white.withOpacity(0.2),
            isDarkMode ? BlendMode.darken : BlendMode.lighten,
          ),
        ),
      ),
      child: Center(
        child: Text(
          'About Me',
          style: GoogleFonts.inter(
            fontSize: 48,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }

  Widget _buildParagraph(String text, ThemeData theme) {
    return Text(
      text,
      style: theme.textTheme.bodyLarge,
    );
  }

  Widget _buildSectionTitle(String title, ThemeData theme) {
    return Text(
      title,
      style: theme.textTheme.titleLarge,
    );
  }

  Widget _buildStrengthItem(String title, String description, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildInterestItem(String text, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(
            Icons.arrow_right,
            color: theme.colorScheme.primary,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
} 