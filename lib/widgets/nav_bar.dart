import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../routes/app_routes.dart';

class NavBar extends StatelessWidget {
  const NavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Rahul's Portfolio",
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Row(
            children: [
              _buildNavItem('Resume', AppRoutes.resume),
              const SizedBox(width: 32),
              _buildNavItem('About Me', AppRoutes.aboutMe),
              const SizedBox(width: 32),
              _buildNavItem('Portfolio', AppRoutes.portfolio),
              const SizedBox(width: 32),
              _buildNavItem('Blog', AppRoutes.blog),
              const SizedBox(width: 32),
              _buildNavItem('Contact', AppRoutes.contact),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(String title, String route) {
    return InkWell(
      onTap: () => Get.toNamed(route),
      child: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 16,
          color: Get.currentRoute == route ? const Color(0xFF0066FF) : Colors.white,
          fontWeight: Get.currentRoute == route ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
} 