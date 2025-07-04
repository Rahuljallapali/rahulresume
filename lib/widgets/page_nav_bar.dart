import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../routes/app_routes.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class PageNavBar extends StatelessWidget {
  final String currentPage;
  
  const PageNavBar({
    super.key,
    required this.currentPage,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return Positioned(
      top: 24,
      right: 24,
      child: Row(
        children: [
          if (currentPage != 'About')
            _buildNavItem('About', () => Get.toNamed(AppRoutes.aboutMe)),
          if (currentPage != 'Projects')
            _buildNavItem('Projects', () => Get.toNamed(AppRoutes.portfolio)),
          if (currentPage != 'Blog')
            _buildNavItem('Blog', () => Get.toNamed(AppRoutes.blog)),
          if (currentPage != 'Resume')
            _buildNavItem('Resume', () => Get.toNamed(AppRoutes.resume)),
          if (currentPage != 'Contact')
            _buildNavItem('Contact', () => Get.toNamed(AppRoutes.contact)),
        ],
      ),
    );
  }

  Widget _buildNavItem(String text, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(left: 16),
      child: TextButton(
        onPressed: onTap,
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.white,
            decoration: TextDecoration.none,
          ),
        ),
      ),
    );
  }
} 