import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:confetti/confetti.dart';
import 'package:get/get.dart';
import '../routes/app_routes.dart';
import '../widgets/back_button.dart';
import '../utils/download_helper.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/page_nav_bar.dart';

class ContactPage extends StatefulWidget {
  const ContactPage({super.key});

  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  final _formKey = GlobalKey<FormState>();
  late ConfettiController _confettiController;
  bool _showSuccess = false;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void _showConfetti() {
    _confettiController.play();
    setState(() {
      _showSuccess = true;
    });
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _showSuccess = false;
        });
      }
    });
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
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildPurposeSection(theme, isDarkMode),
                      const SizedBox(height: 48),
                      _buildContactOptions(theme, isDarkMode),
                      const SizedBox(height: 48),
                      _buildSocialLinks(theme, isDarkMode),
                      const SizedBox(height: 48),
                      _buildLocationAvailability(theme, isDarkMode),
                      const SizedBox(height: 48),
                      _buildContactForm(theme, isDarkMode),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const CustomBackButton(),
          const PageNavBar(currentPage: 'Contact'),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirection: pi / 2,
              maxBlastForce: 5,
              minBlastForce: 2,
              emissionFrequency: 0.05,
              numberOfParticles: 50,
              gravity: 0.1,
              colors: const [
                Colors.pink,
                Colors.purple,
                Colors.blue,
                Colors.green,
                Colors.orange,
                Colors.red,
              ],
            ),
          ),
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
          "Let's Work Together!",
          style: GoogleFonts.inter(
            fontSize: 48,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }

  Widget _buildPurposeSection(ThemeData theme, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.black12 : Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDarkMode ? Colors.grey[850]! : Colors.grey[300]!,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            "I'm actively seeking Flutter development roles",
            style: theme.textTheme.headlineMedium,
          ),
          const SizedBox(height: 16),
          Text(
            "Feel free to reach out for job opportunities, collaborations, or freelance work.",
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }

  Widget _buildContactOptions(ThemeData theme, bool isDarkMode) {
    return Column(
      children: [
        Text(
          'Primary Contact Options',
          style: theme.textTheme.headlineSmall,
        ),
        const SizedBox(height: 32),
        Wrap(
          spacing: 24,
          runSpacing: 24,
          alignment: WrapAlignment.center,
          children: [
            _buildContactCard(
              icon: Icons.email,
              title: 'Email',
              content: 'rahul.jallapalli.dev@gmail.com',
              onTap: () => _launchURL('mailto:rahul.jallapalli.dev@gmail.com'),
              theme: theme,
              isDarkMode: isDarkMode,
            ),
            _buildContactCard(
              icon: Icons.phone,
              title: 'Phone',
              content: '+91-98765-43210',
              onTap: () => _launchURL('tel:+919876543210'),
              theme: theme,
              isDarkMode: isDarkMode,
            ),
            _buildContactCard(
              icon: Icons.description,
              title: 'Resume',
              content: 'Download PDF',
              onTap: () => DownloadHelper.downloadFile(
                'assets/resume.pdf',
                'Rahul_Jallapalli_Resume.pdf',
              ),
              theme: theme,
              isDarkMode: isDarkMode,
              isButton: true,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildContactCard({
    required IconData icon,
    required String title,
    required String content,
    required VoidCallback onTap,
    required ThemeData theme,
    required bool isDarkMode,
    bool isButton = false,
  }) {
    return Container(
      width: 300,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDarkMode ? [
            Colors.grey[900]!,
            Colors.grey[850]!,
          ] : [
            Colors.white,
            Colors.grey[50]!,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            if (isButton)
              ElevatedButton(
                onPressed: onTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  content,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onPrimary,
                  ),
                ),
              )
            else
              Text(
                content,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: theme.colorScheme.primary,
                ),
                textAlign: TextAlign.center,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialLinks(ThemeData theme, bool isDarkMode) {
    return Column(
      children: [
        Text(
          'Professional Social Links',
          style: theme.textTheme.headlineSmall,
        ),
        const SizedBox(height: 32),
        Wrap(
          spacing: 24,
          runSpacing: 24,
          alignment: WrapAlignment.center,
          children: [
            _buildSocialButton(
              icon: FontAwesomeIcons.linkedin,
              label: 'LinkedIn',
              url: 'https://linkedin.com/in/rahul-jallapalli',
              theme: theme,
              isDarkMode: isDarkMode,
            ),
            _buildSocialButton(
              icon: FontAwesomeIcons.github,
              label: 'GitHub',
              url: 'https://github.com/rahul-jallapalli',
              theme: theme,
              isDarkMode: isDarkMode,
            ),
            _buildSocialButton(
              icon: FontAwesomeIcons.globe,
              label: 'Portfolio',
              url: '#portfolio',
              theme: theme,
              isDarkMode: isDarkMode,
            ),
            _buildSocialButton(
              icon: FontAwesomeIcons.stackOverflow,
              label: 'Stack Overflow',
              url: 'https://stackoverflow.com/users/rahul-jallapalli',
              theme: theme,
              isDarkMode: isDarkMode,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required String label,
    required String url,
    required ThemeData theme,
    required bool isDarkMode,
  }) {
    return Tooltip(
      message: label,
      child: InkWell(
        onTap: () => _launchURL(url),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.black12 : Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.colorScheme.primary.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              FaIcon(
                icon,
                color: theme.colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: theme.textTheme.bodyLarge,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLocationAvailability(ThemeData theme, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.black12 : Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDarkMode ? Colors.grey[850]! : Colors.grey[300]!,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.location_on,
                color: Color(0xFF0066FF),
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Hyderabad, India',
                style: theme.textTheme.bodyLarge,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Open to On-site, Hybrid, or Remote roles',
                style: theme.textTheme.bodyLarge,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContactForm(ThemeData theme, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.black12 : Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDarkMode ? Colors.grey[850]! : Colors.grey[300]!,
          width: 1,
        ),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Send me a message',
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: 24),
            _buildTextField(
              label: 'Name',
              theme: theme,
              isDarkMode: isDarkMode,
              validator: (value) =>
                  value?.isEmpty ?? true ? 'Please enter your name' : null,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              label: 'Email',
              theme: theme,
              isDarkMode: isDarkMode,
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'Please enter your email';
                }
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                    .hasMatch(value!)) {
                  return 'Please enter a valid email';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildTextField(
              label: 'Message',
              theme: theme,
              isDarkMode: isDarkMode,
              maxLines: 5,
              validator: (value) =>
                  value?.isEmpty ?? true ? 'Please enter your message' : null,
            ),
            const SizedBox(height: 24),
            Center(
              child: _showSuccess
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Message sent successfully!',
                          style: theme.textTheme.bodyLarge,
                        ),
                      ],
                    )
                  : ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState?.validate() ?? false) {
                          _showConfetti();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 48,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.send,
                            color: theme.colorScheme.onPrimary,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Send Message',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: theme.colorScheme.onPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required ThemeData theme,
    required bool isDarkMode,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      maxLines: maxLines,
      validator: validator,
      style: theme.textTheme.bodyLarge,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: theme.textTheme.bodyMedium,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: theme.colorScheme.primary),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: theme.colorScheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: theme.colorScheme.error),
        ),
        filled: true,
        fillColor: isDarkMode ? Colors.black12 : Colors.white,
      ),
    );
  }

  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    }
  }
} 