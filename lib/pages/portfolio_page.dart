import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/back_button.dart';
import '../widgets/page_nav_bar.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class PortfolioPage extends StatelessWidget {
  const PortfolioPage({super.key});

  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    }
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
                        'Projects',
                        style: theme.textTheme.displayLarge?.copyWith(
                          fontSize: 64,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'A selection of my favorite projects, showcasing my skills and experience in Flutter development.',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontSize: 18,
                          color: theme.colorScheme.onBackground.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: 80),
                      // Projects Grid
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _buildProjectCard(
                              context,
                              'Mobile App for Fitness Tracking',
                              'A fitness tracking app built with Flutter, featuring real-time data synchronization, workout logging, and progress tracking.',
                              'assets/serveizlogin.jpg',
                              const Color(0xFF7DD3C0),
                              theme,
                            ),
                          ),
                          const SizedBox(width: 32),
                          Expanded(
                            child: _buildProjectCard(
                              context,
                              'E-commerce App with Payment Integration',
                              'An e-commerce application developed using Flutter, with secure payment processing and real-time inventory management.',
                              'assets/serveizmenudrawer.jpg',
                              const Color(0xFFFFB5A7),
                              theme,
                            ),
                          ),
                          const SizedBox(width: 32),
                          Expanded(
                            child: _buildProjectCard(
                              context,
                              'Social Media App with User Authentication',
                              'A social media application developed in Flutter, with Firebase authentication and real-time data updates.',
                              'assets/serveizMain.png',
                              const Color(0xFFE5E5E5),
                              theme,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),
                      MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: () => _launchURL('https://github.com/rahul-jallapalli'),
                          child: Text(
                            'For more projects, visit my GitHub profile.',
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
          const PageNavBar(currentPage: 'Projects'),
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
          'Projects',
          style: GoogleFonts.inter(
            fontSize: 48,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }

  Widget _buildProjectCard(
    BuildContext context,
    String title,
    String description,
    String imagePath,
    Color backgroundColor,
    ThemeData theme,
  ) {
    return Container(
      height: 400,
      decoration: BoxDecoration(
        color: const Color(0xFF1B2028),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // Project image
          Expanded(
            flex: 2,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Center(
                child: SizedBox(
                  height: double.infinity,
                  width: 280,
                  child: Image.asset(
                    imagePath,
                    fit: BoxFit.fitHeight,
                  ),
                ),
              ),
            ),
          ),
          // Content section
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: Text(
                      description,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withOpacity(0.7),
                        height: 1.4,
                      ),
                      maxLines: 3,
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