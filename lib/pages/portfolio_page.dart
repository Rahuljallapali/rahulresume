import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/back_button.dart';
import 'dart:async';

class PortfolioPage extends StatefulWidget {
  const PortfolioPage({super.key});

  @override
  State<PortfolioPage> createState() => _PortfolioPageState();
}

class _PortfolioPageState extends State<PortfolioPage> {
  final PageController _pageController = PageController(
    viewportFraction: 0.85, // This will show part of prev/next images
    initialPage: 0,
  );
  int _currentPage = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startAutoSlide();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoSlide() {
    _timer = Timer.periodic(const Duration(seconds: 3), (Timer timer) {
      if (_pageController.hasClients) {
        if (_currentPage < 2) {
          _pageController.nextPage(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        } else {
          _pageController.animateToPage(
            0,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        }
      }
    });
  }

  void _stopAutoSlide() {
    _timer?.cancel();
    _timer = null;
  }

  void _restartAutoSlide() {
    _stopAutoSlide();
    _startAutoSlide();
  }

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
                          const Icon(
                            Icons.rocket_launch,
                            color: Color(0xFF0066FF),
                            size: 28,
                          ),
                          const SizedBox(width: 16),
                          Text(
                            'My Projects',
                            style: GoogleFonts.inter(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 48),
                      _buildProjectSection(),
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

  Widget _buildProjectSection() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return _buildProjectCard(
          width: constraints.maxWidth,
          title: 'ServeizApp',
          description:
              'A robust field service management solution enabling technicians to manage work orders, track inventory, and communicate with customers — all in real-time and offline.',
          role: 'Lead Flutter Developer',
          features: [
            'Real-time chat and video calls',
            'Offline-first data sync',
            'GPS tracking and route optimization',
            'Camera integration for work documentation',
            'Custom animations and transitions',
          ],
          techStack: [
            'Flutter',
            'GetX',
            'WebSocket',
            'SQLite',
            'Google Maps',
            'Firebase',
          ],
          images: [
            'assets/serveizMain.png',
            'assets/serveizlogin.jpg',
            'assets/serveizmenudrawer.jpg',
          ],
          badges: ['Live on Play Store', 'Offline-First', 'Real-time Video'],
          playStoreLink:
              'https://play.google.com/store/apps/details?id=com.serveiz.app',
        );
      },
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
          'Portfolio',
          style: GoogleFonts.inter(
            fontSize: 48,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildProjectCard({
    required double width,
    required String title,
    required String description,
    required String role,
    required List<String> features,
    required List<String> techStack,
    required List<String> images,
    required List<String> badges,
    String? playStoreLink,
    String? githubLink,
    String? liveDemoLink,
  }) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey[850]!,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left side - Project Images
              Expanded(
                flex: 3,
                child: Container(
                  height: 600,
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      bottomLeft: Radius.circular(16),
                    ),
                    color: Color(0xFF1A1A1A),
                  ),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          bottomLeft: Radius.circular(16),
                        ),
                        child: MouseRegion(
                            onEnter: (_) => _stopAutoSlide(),
                            onExit: (_) => _startAutoSlide(),
                            child: AnimatedBuilder(
                              animation: _pageController,
                              builder: (context, child) {
                                return PageView.builder(
                                  controller: _pageController,
                                  onPageChanged: (index) {
                                    setState(() {
                                      _currentPage = index;
                                    });
                                    _restartAutoSlide();
                                  },
                                  itemCount: images.length,
                                  itemBuilder: (context, index) {
                                    double currentPage = 0;
                                    try {
                                      currentPage = _pageController.page ??
                                          _pageController.initialPage
                                              .toDouble();
                                    } catch (_) {}

                                    double value = index - currentPage;
                                    value = (value * 0.5).clamp(-1, 1);

                                    return Transform.scale(
                                      scale: 1,
                                      child: Transform(
                                        transform: Matrix4.identity()
                                          ..setEntry(3, 2, 0.001)
                                          ..translate(value * width * 0.5)
                                          ..scale(1 - value.abs() * 0.2),
                                        alignment: value >= 0
                                            ? Alignment.centerLeft
                                            : Alignment.centerRight,
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 24.0, vertical: 16.0),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withOpacity(0.2),
                                                  blurRadius: 20,
                                                  offset: const Offset(0, 10),
                                                ),
                                              ],
                                            ),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              child: Image.asset(
                                                images[index],
                                                fit: BoxFit.contain,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            )),
                      ),
                      // Navigation arrows with improved styling
                      Positioned.fill(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              margin: const EdgeInsets.only(left: 8),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.3),
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.arrow_back_ios,
                                    color: Colors.white, size: 20),
                                onPressed: () {
                                  if (_currentPage > 0) {
                                    _pageController.previousPage(
                                      duration:
                                          const Duration(milliseconds: 500),
                                      curve: Curves.easeInOut,
                                    );
                                  }
                                },
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.3),
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.arrow_forward_ios,
                                    color: Colors.white, size: 20),
                                onPressed: () {
                                  if (_currentPage < images.length - 1) {
                                    _pageController.nextPage(
                                      duration:
                                          const Duration(milliseconds: 500),
                                      curve: Curves.easeInOut,
                                    );
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Page indicators with improved styling
                    ],
                  ),
                ),
              ),
              // Right side - Project Details
              Expanded(
                flex: 2,
                child: Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFF2A2A2A),
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title and Links
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                title,
                                style: GoogleFonts.inter(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            if (playStoreLink != null)
                              IconButton(
                                icon: const Icon(Icons.play_circle_outline),
                                color: const Color(0xFF0066FF),
                                onPressed: () => _launchURL(playStoreLink),
                              ),
                            if (githubLink != null)
                              IconButton(
                                icon: const Icon(Icons.code),
                                color: const Color(0xFF0066FF),
                                onPressed: () => _launchURL(githubLink),
                              ),
                            if (liveDemoLink != null)
                              IconButton(
                                icon: const Icon(Icons.launch),
                                color: const Color(0xFF0066FF),
                                onPressed: () => _launchURL(liveDemoLink),
                              ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Badges
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: badgeMeta
                              .map((b) => _buildBadge(b["text"].toString(),
                                  color: b["color"] as Color?,
                                  icon: b["icon"] as IconData?))
                              .toList(),
                        ),
                        const SizedBox(height: 24),
                        // Description
                        Text(
                          description,
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            color: Colors.grey[300],
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Role
                        Text(
                          'Role: $role',
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF0066FF),
                          ),
                        ),
                        const SizedBox(height: 32),
                        // Key Features
                        _buildSectionTitle('Key Features'),
                        const SizedBox(height: 16),
                        ...features
                            .map((feature) => _buildFeatureItem(feature)),
                        const SizedBox(height: 32),
                        // Tech Stack
                        _buildSectionTitle('Tech Stack'),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: techStack
                              .map((tech) => _buildTechChip(tech))
                              .toList(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  final badgeMeta = [
  {"text": "Live on Play Store", "color": Colors.green, "icon": Icons.play_arrow},
  {"text": "Offline-First", "color": Colors.deepPurple, "icon": Icons.offline_bolt},
  {"text": "Real-time Video", "color": Colors.redAccent, "icon": Icons.videocam},
];


  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }

  Widget _buildFeatureItem(String feature) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle_outline,
            color: Color(0xFF0066FF),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              feature,
              style: GoogleFonts.inter(
                fontSize: 16,
                color: Colors.grey[300],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTechChip(String tech) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF0066FF),
          width: 1,
        ),
      ),
      child: Text(
        tech,
        style: GoogleFonts.inter(
          fontSize: 14,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildBadge(String text, {Color? color, IconData? icon}) {
  final baseColor = color ?? const Color(0xFF0066FF);

  return MouseRegion(
    cursor: SystemMouseCursors.click,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: baseColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: baseColor, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null)
            Icon(icon, size: 14, color: baseColor),
          if (icon != null) const SizedBox(width: 6),
          Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: baseColor,
            ),
          ),
        ],
      ),
    ),
  );
}


  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    }
  }
}
