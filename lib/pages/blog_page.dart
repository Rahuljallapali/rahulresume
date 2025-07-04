import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import '../routes/app_routes.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../widgets/back_button.dart';
import 'package:confetti/confetti.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/page_nav_bar.dart';

class BlogPage extends StatelessWidget {
  const BlogPage({super.key});

  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    }
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
          'Blog',
          style: GoogleFonts.inter(
            fontSize: 48,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }

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
                  padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 48.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Blog',
                        style: theme.textTheme.displayLarge?.copyWith(
                          fontSize: 64,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Thoughts, insights, and experiences from my journey in software development.',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontSize: 18,
                          color: theme.colorScheme.onBackground.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: 80),
                      // Blog Posts Grid
                      SizedBox(
                        height: 400, // Fixed height for the row of cards
                        child: Row(
                          children: [
                            Flexible(
                              flex: 1,
                              child: _buildBlogCard(
                                context,
                                'Flutter State Management Deep Dive',
                                'An in-depth exploration of different state management solutions in Flutter, comparing Provider, Riverpod, and GetX.',
                                const Color(0xFF7DD3C0),
                                'March 15, 2024',
                                theme,
                              ),
                            ),
                            const SizedBox(width: 32),
                            Flexible(
                              flex: 1,
                              child: _buildBlogCard(
                                context,
                                'Building Responsive UIs in Flutter',
                                'Best practices and techniques for creating responsive and adaptive user interfaces that work seamlessly across different screen sizes.',
                                const Color(0xFFFFB5A7),
                                'March 10, 2024',
                                theme,
                              ),
                            ),
                            const SizedBox(width: 32),
                            Flexible(
                              flex: 1,
                              child: _buildBlogCard(
                                context,
                                'Flutter Web: A Comprehensive Guide',
                                'Everything you need to know about developing and deploying Flutter web applications, including performance optimization tips.',
                                const Color(0xFFE5E5E5),
                                'March 5, 2024',
                                theme,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),
                      MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: () => _launchURL('https://dev.to'),
                          child: Text(
                            'Read more articles on my blog.',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              decoration: TextDecoration.underline,
                              color: theme.colorScheme.onBackground.withOpacity(0.7),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const CustomBackButton(),
          const PageNavBar(currentPage: 'Blog'),
        ],
      ),
    );
  }

  Widget _buildBlogCard(
    BuildContext context,
    String title,
    String description,
    Color backgroundColor,
    String date,
    ThemeData theme,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  date,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Flutter',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: Text(
                      description,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                        height: 1.4,
                        fontSize: 16,
                      ),
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
} 