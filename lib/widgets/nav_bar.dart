import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../routes/app_routes.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class NavBar extends StatelessWidget {
  const NavBar({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = Theme.of(context);
    final isDarkMode = themeProvider.isDarkMode;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor.withOpacity(0.8),
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.primary.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Rahul Jallapalli | Software Developer",
            style: theme.textTheme.headlineSmall,
          ),
          Row(
            children: [
              _buildNavItem(context, 'About', AppRoutes.aboutMe),
              const SizedBox(width: 32),
              _buildNavItem(context, 'Projects', AppRoutes.portfolio),
              const SizedBox(width: 32),
              _buildNavItem(context, 'Blog', AppRoutes.blog),
              const SizedBox(width: 32),
              _buildNavItem(context, 'Resume', AppRoutes.resume),
              const SizedBox(width: 32),
              _buildNavItem(context, 'Contact', AppRoutes.contact),
            ],
          ),
          IconButton(
            icon: Icon(
              isDarkMode ? Icons.light_mode : Icons.dark_mode,
              color: theme.colorScheme.onBackground,
            ),
            onPressed: () {
              final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
              themeProvider.toggleTheme();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, String label, String route) {
    final theme = Theme.of(context);
    final isCurrentRoute = Get.currentRoute == route;
    
    return InkWell(
      onTap: () => Get.toNamed(route),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Text(
          label,
          style: theme.textTheme.titleMedium?.copyWith(
            color: isCurrentRoute 
                ? theme.colorScheme.primary 
                : theme.colorScheme.onBackground,
            fontWeight: isCurrentRoute ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
} 