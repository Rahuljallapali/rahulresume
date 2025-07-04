import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:rahul_resume/routes/app_routes.dart';
import '../providers/theme_provider.dart';

class CustomBackButton extends StatefulWidget {
  const CustomBackButton({super.key});

  @override
  State<CustomBackButton> createState() => _CustomBackButtonState();
}

class _CustomBackButtonState extends State<CustomBackButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 32,
      left: 32,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: IconButton(
          tooltip: 'Go to Home',
          icon: Icon(
            Icons.home,
            color: _isHovered ? Colors.amber : Colors.white,
          ),
          onPressed: () {
            Get.toNamed(AppRoutes.homeScreen);
          },
        ),
      ),
    );
  }
} 