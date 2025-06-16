import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/back_button.dart';
import '../utils/download_helper.dart';

class ResumePage extends StatelessWidget {
  const ResumePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(32, 100, 32, 32),
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
                            style: GoogleFonts.inter(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'Jallapalli',
                            style: GoogleFonts.inter(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF0066FF),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Flutter Developer',
                            style: GoogleFonts.inter(
                              fontSize: 24,
                              color: Colors.grey[400],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed diam nonummy nibh euismod tincidunt ut laoreet dolore magna aliquam erat volutpat.',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      color: Colors.grey[300],
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 32),
                  _buildContactInfo(),
                  const SizedBox(height: 48),
                  // Work Experience Section
                  _buildSection(
                    'Work Experience',
                    [
                      _buildExperienceItem(
                        'Flutter Developer',
                        'Company Name',
                        '2021 - Present',
                        'Developed and maintained multiple Flutter applications with clean architecture and state management using GetX.',
                      ),
                      _buildExperienceItem(
                        'Mobile Developer',
                        'Previous Company',
                        '2019 - 2021',
                        'Worked on cross-platform mobile applications using Flutter and React Native.',
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  // Education Section
                  _buildSection(
                    'Education',
                    [
                      _buildEducationItem(
                        'Bachelor of Technology',
                        'University Name',
                        '2015 - 2019',
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  // Skills Section
                  _buildSkillsSection(),
                ],
              ),
            ),
          ),
          const CustomBackButton(),
        ],
      ),
    );
  }

  Widget _buildContactInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Contact',
          style: GoogleFonts.inter(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        _buildContactItem(Icons.phone, '123-456-7890'),
        _buildContactItem(Icons.email, 'rahul@example.com'),
        _buildContactItem(Icons.location_on, 'City, Country'),
      ],
    );
  }

  Widget _buildContactItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF0066FF), size: 20),
          const SizedBox(width: 12),
          Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 16,
              color: Colors.grey[300],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        ...items,
      ],
    );
  }

  Widget _buildExperienceItem(
    String title,
    String company,
    String period,
    String description,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                company,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: const Color(0xFF0066FF),
                ),
              ),
              const SizedBox(width: 16),
              Text(
                period,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: Colors.grey[400],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: GoogleFonts.inter(
              fontSize: 16,
              color: Colors.grey[300],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEducationItem(
    String degree,
    String university,
    String period,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            degree,
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                university,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: const Color(0xFF0066FF),
                ),
              ),
              const SizedBox(width: 16),
              Text(
                period,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: Colors.grey[400],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSkillsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Skills',
          style: GoogleFonts.inter(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        _buildSkillBar('Flutter', 0.9),
        _buildSkillBar('Dart', 0.85),
        _buildSkillBar('Firebase', 0.8),
        _buildSkillBar('GetX', 0.85),
        _buildSkillBar('REST APIs', 0.8),
        _buildSkillBar('Git', 0.75),
      ],
    );
  }

  Widget _buildSkillBar(String skill, double progress) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            skill,
            style: GoogleFonts.inter(
              fontSize: 16,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Stack(
            children: [
              Container(
                height: 4,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Container(
                height: 4,
                width: 300 * progress,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0066FF), Color(0xFF2196F3)],
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
