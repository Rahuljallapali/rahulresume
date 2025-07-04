import 'package:flutter/material.dart';
import '../widgets/back_button.dart';
import '../widgets/page_nav_bar.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/pdf_service.dart';

class ResumePage extends StatelessWidget {
  const ResumePage({super.key});

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
          'Resume',
          style: GoogleFonts.inter(
            fontSize: 48,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }

  Widget _buildContactInfo(ThemeData theme) {
    return Row(
      children: [
        Icon(Icons.email, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          'rahul.jallapalli@example.com',
          style: theme.textTheme.bodyLarge,
        ),
        const SizedBox(width: 24),
        Icon(Icons.phone, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          '+1 234 567 8900',
          style: theme.textTheme.bodyLarge,
        ),
      ],
    );
  }

  Widget _buildSection(String title, List<Widget> items, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 24),
        ...items,
      ],
    );
  }

  Widget _buildExperienceItem(
    String title,
    String company,
    String duration,
    String description,
    ThemeData theme,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                company,
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(width: 16),
              Text(
                duration,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: theme.textTheme.bodyLarge?.copyWith(
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEducationItem(
    String degree,
    String institution,
    String duration,
    ThemeData theme,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            degree,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                institution,
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(width: 16),
              Text(
                duration,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSkillsSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Skills',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 24),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildSkillChip('Flutter', theme),
            _buildSkillChip('Dart', theme),
            _buildSkillChip('Firebase', theme),
            _buildSkillChip('REST APIs', theme),
            _buildSkillChip('Git', theme),
            _buildSkillChip('UI/UX Design', theme),
            _buildSkillChip('State Management', theme),
            _buildSkillChip('Clean Architecture', theme),
          ],
        ),
      ],
    );
  }

  Widget _buildSkillChip(String label, ThemeData theme) {
    return Chip(
      label: Text(label),
      backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
      labelStyle: TextStyle(color: theme.colorScheme.primary),
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Rahul',
                                style: theme.textTheme.displayMedium,
                              ),
                              Text(
                                'Jallapalli',
                                style: theme.textTheme.displayMedium?.copyWith(
                                  color: theme.colorScheme.primary.withOpacity(0.5),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Flutter Developer',
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  color: theme.colorScheme.onBackground.withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Experienced Flutter developer with a passion for creating beautiful and functional mobile applications. Skilled in developing cross-platform applications with clean architecture and modern state management solutions.',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 32),
                      _buildContactInfo(theme),
                      const SizedBox(height: 48),
                      // Work Experience Section
                      _buildSection(
                        'Work Experience',
                        [
                          _buildExperienceItem(
                            'Senior Flutter Developer',
                            'Tech Solutions Inc.',
                            '2021 - Present',
                            'Led the development of multiple Flutter applications with clean architecture and state management using GetX. Mentored junior developers and implemented best practices.',
                            theme,
                          ),
                          _buildExperienceItem(
                            'Mobile Developer',
                            'Mobile Innovations Ltd.',
                            '2019 - 2021',
                            'Developed cross-platform mobile applications using Flutter and React Native. Collaborated with design team to implement pixel-perfect UI/UX.',
                            theme,
                          ),
                        ],
                        theme,
                      ),
                      const SizedBox(height: 32),
                      // Education Section
                      _buildSection(
                        'Education',
                        [
                          _buildEducationItem(
                            'Bachelor of Technology in Computer Science',
                            'University of Technology',
                            '2015 - 2019',
                            theme,
                          ),
                        ],
                        theme,
                      ),
                      const SizedBox(height: 32),
                      // Skills Section
                      _buildSkillsSection(theme),
                      const SizedBox(height: 48),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const CustomBackButton(),
          const PageNavBar(currentPage: 'Resume'),
        ],
      ),
    );
  }
}
