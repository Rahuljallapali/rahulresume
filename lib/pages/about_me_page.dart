import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/back_button.dart';

class AboutMePage extends StatelessWidget {
  const AboutMePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                _buildHeader(),
                Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.star,
                            color: const Color(0xFF0066FF),
                            size: 28,
                          ),
                          const SizedBox(width: 16),
                          Text(
                            'About Me',
                            style: GoogleFonts.inter(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 48),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Left side - Content
                          Expanded(
                            flex: 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildParagraph(
                                  'Hi, I\'m Rahul Jallapalli, a passionate Flutter Developer with over 3 years of experience building scalable, production-ready mobile apps. I specialize in creating cross-platform applications using Flutter with features like camera integration, Google Maps, real-time video collaboration, and offline-first data handling.',
                                ),
                                const SizedBox(height: 24),
                                _buildParagraph(
                                  'With a strong foundation in Spring Boot for backend systems and hands-on expertise in CI/CD pipelines using Jenkins, Docker, and AWS EC2, I bridge the gap between mobile frontends and scalable backend services.',
                                ),
                                const SizedBox(height: 24),
                                _buildParagraph(
                                  'What sets me apart is my experience working in field-service applications where performance, offline access, and real-time capabilities are crucial. I take pride in writing clean, maintainable code and delivering polished user experiences under tight deadlines.',
                                ),
                                const SizedBox(height: 24),
                                _buildParagraph(
                                  'Currently, I\'m focused on improving real-time features, integrating LLMs (AI), and collaborating on impactful Flutter projects. When I\'m not coding, I enjoy sketching UI ideas, exploring new tech trends, and hiking in nature.',
                                ),
                                const SizedBox(height: 32),
                                Text(
                                  'Let\'s build something awesome together!',
                                  style: GoogleFonts.inter(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF0066FF),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 48),
                          // Right side - Skills and Interests
                          Expanded(
                            flex: 2,
                            child: Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: Colors.black12,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.grey[850]!,
                                  width: 1,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildSectionTitle('Core Strengths'),
                                  const SizedBox(height: 16),
                                  _buildStrengthItem('Flutter & Dart', 'Cross-platform expertise'),
                                  _buildStrengthItem('Backend Integration', 'Spring Boot & AWS'),
                                  _buildStrengthItem('Real-time Features', 'WebSocket & Firebase'),
                                  _buildStrengthItem('Clean Architecture', 'SOLID principles'),
                                  const SizedBox(height: 32),
                                  _buildSectionTitle('Interests'),
                                  const SizedBox(height: 16),
                                  _buildInterestItem('UI/UX Design'),
                                  _buildInterestItem('Emerging Tech'),
                                  _buildInterestItem('AI Integration'),
                                  _buildInterestItem('Nature & Hiking'),
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
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        color: Colors.black,
        image: DecorationImage(
          image: const AssetImage('assets/homescreen.png'),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Colors.black.withOpacity(0.7),
            BlendMode.darken,
          ),
        ),
      ),
      child: Center(
        child: Text(
          'About Me',
          style: GoogleFonts.inter(
            fontSize: 48,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildParagraph(String text) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 16,
        height: 1.8,
        color: Colors.grey[300],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }

  Widget _buildStrengthItem(String title, String description) {
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
              color: const Color(0xFF0066FF),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.grey[400],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInterestItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(
            Icons.arrow_right,
            color: const Color(0xFF0066FF),
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.grey[300],
            ),
          ),
        ],
      ),
    );
  }
} 