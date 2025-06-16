import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import '../routes/app_routes.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../widgets/back_button.dart';
import 'package:confetti/confetti.dart';

class BlogPage extends StatelessWidget {
  const BlogPage({super.key});

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
                      _buildIntroSection(),
                      const SizedBox(height: 48),
                      _buildBlogEntries(),
                      const SizedBox(height: 48),
                      _buildCallToAction(),
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
          "Learning & Experiments",
          style: GoogleFonts.inter(
            fontSize: 48,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildIntroSection() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.black12,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[850]!, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.rocket_launch,
                color: Color(0xFF0066FF),
                size: 32,
              ),
              const SizedBox(width: 16),
              Text(
                "Tech Explorer's Journal",
                style: GoogleFonts.inter(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            "I constantly explore new technologies and frameworks to sharpen my skills. Here's a quick look at what I've been learning, building, and experimenting with lately.",
            style: GoogleFonts.inter(
              fontSize: 16,
              color: Colors.grey[300],
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBlogEntries() {
    final entries = [
      {
        'icon': Icons.sync,
        'title': 'Integrated offline sync',
        'description': 'Learned how to sync local DB with API using background tasks.',
        'tags': ['Flutter', 'SQLite', 'API'],
        'date': 'March 2024',
      },
      {
        'icon': Icons.videocam,
        'title': 'Added video calling feature',
        'description': 'Used Agora to add live video and real-time chat.',
        'tags': ['Agora', 'WebRTC', 'Real-time'],
        'date': 'February 2024',
      },
      {
        'icon': Icons.speed,
        'title': 'Improved performance',
        'description': 'Reduced widget rebuilds using GetX Obx efficiently.',
        'tags': ['GetX', 'Performance', 'State Management'],
        'date': 'January 2024',
      },
      {
        'icon': Icons.storage,
        'title': 'Migrated from SQLite to Isar',
        'description': 'Gained hands-on with schema migration and reactive data.',
        'tags': ['Isar', 'Database', 'Migration'],
        'date': 'December 2023',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Explorations',
          style: GoogleFonts.inter(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 24),
        ...entries.map((entry) => _buildBlogCard(entry)),
      ],
    );
  }

  Widget _buildBlogCard(Map<String, dynamic> entry) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.grey[900]!,
            Colors.grey[850]!,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF0066FF).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF0066FF).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  entry['icon'] as IconData,
                  color: const Color(0xFF0066FF),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry['title'] as String,
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      entry['date'] as String,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.grey[400],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            entry['description'] as String,
            style: GoogleFonts.inter(
              fontSize: 16,
              color: Colors.grey[300],
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: (entry['tags'] as List<String>).map((tag) => _buildTag(tag)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String tag) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF0066FF).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.tag,
            color: Color(0xFF0066FF),
            size: 14,
          ),
          const SizedBox(width: 6),
          Text(
            tag,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCallToAction() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.black12,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[850]!, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.edit,
                color: Color(0xFF0066FF),
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                "✍️ I'll be sharing deep-dives into these topics soon. Stay tuned!",
                style: GoogleFonts.inter(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Get.toNamed(AppRoutes.contact),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0066FF),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.mail_outline, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  'Suggest a Topic or Connect',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 