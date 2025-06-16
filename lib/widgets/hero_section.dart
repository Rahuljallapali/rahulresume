import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rahul_resume/utils/download_helper.dart';
import '../routes/app_routes.dart';

class HeroSection extends StatelessWidget {
  const HeroSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.height,
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        image: DecorationImage(
          image: const AssetImage('assets/homescreen.png'),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Colors.black.withOpacity(0.5),
            BlendMode.darken,
          ),
        ),
      ),
      child: Stack(
        children: [
          // Pink accent line
          Positioned(
            left: 0,
            top: MediaQuery.of(context).size.height * 0.3,
            child: Container(
              width: 4,
              height: 100,
              color: const Color(0xFF0066FF),
            ),
          ),
          // Main content
          Padding(
            padding: EdgeInsets.only(
              left: MediaQuery.of(context).size.width * 0.1,
              top: MediaQuery.of(context).size.height * 0.3,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hello! I\'m a',
                  style: GoogleFonts.inter(
                    fontSize: 42,
                    fontWeight: FontWeight.w300,
                    color: Colors.white.withOpacity(0.9),
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: [
                      const Color(0xFF0066FF),
                      const Color(0xFF0066FF).withOpacity(0.8),
                      Colors.white,
                    ],
                  ).createShader(bounds),
                  child: Text(
                    'Flutter Developer',
                    style: GoogleFonts.inter(
                      fontSize: 56,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -1,
                      height: 1.1,
                    ),
                  ),
                ),
                Text(
                  'Code. Create. Iterate.',
                  style: GoogleFonts.inter(
                    fontSize: 52,
                    fontWeight: FontWeight.w400,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () {
                    DownloadHelper.downloadFile(
                      'assets/resume.pdf',
                      'Rahul_Jallapalli_Resume.pdf',
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0066FF),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.download_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Download Resume',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Let's Rock text
          Positioned(
            right: MediaQuery.of(context).size.width * 0.1,
            top: MediaQuery.of(context).size.height * 0.3,
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 24,
                  color: const Color(0xFF0066FF),
                  margin: const EdgeInsets.only(right: 8),
                ),
                const Text(
                  'Let\'s Rock!',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          // Navigation bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 48,
                vertical: 24,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Rahul Jallapalli',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Row(
                    children: [
                      _buildNavItem('Resume', onTap: () => Get.toNamed(AppRoutes.resume)),
                      _buildNavItem('About Me', onTap: () => Get.toNamed(AppRoutes.aboutMe)),
                      _buildNavItem('Portfolio', onTap: () => Get.toNamed(AppRoutes.portfolio)),
                      _buildNavItem('Blog', onTap: () => Get.toNamed(AppRoutes.blog)),
                      _buildNavItem('Contact', onTap: () => Get.toNamed(AppRoutes.contact)),
                    ],
                  ),
                  Row(
                    children: [
                      _buildSocialIcon(Icons.public),
                      _buildSocialIcon(Icons.alternate_email),
                      _buildSocialIcon(Icons.business_center),
                      _buildSocialIcon(Icons.photo_camera),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(String text, {VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextButton(
        onPressed: onTap,
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildSocialIcon(IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: IconButton(
        onPressed: () {
          // TODO: Implement social media links
        },
        icon: Icon(
          icon,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }
} 