import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'project_image_carousel.dart';

class ProjectCard extends StatelessWidget {
  final String title;
  final String description;
  final List<String> technologies;
  final String? teamSize;
  final String? duration;
  final String? role;
  final List<String>? keyFeatures;
  final List<String>? imagePaths;

  const ProjectCard({
    super.key,
    required this.title,
    required this.description,
    required this.technologies,
    this.teamSize,
    this.duration,
    this.role,
    this.keyFeatures,
    this.imagePaths,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (imagePaths != null && imagePaths!.isNotEmpty)
                Expanded(
                  flex: 4,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Stack(
                        children: [
                          ProjectImageCarousel(
                            images: imagePaths!,
                            // height: 400, 
                            // width: double.infinity,
                          ),
                          // Phone frame overlay
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
                                  width: 12,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              const SizedBox(width: 24),
              Expanded(
                flex: 6,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.rocket_launch_outlined, size: 24),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              title,
                              style: GoogleFonts.poppins(
                                textStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 24,
                                    ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            if (teamSize != null) _buildInfoChip(context, '👥 Team Size: $teamSize'),
                            if (duration != null) ...[
                              const SizedBox(width: 8),
                              _buildInfoChip(context, '📅 Duration: $duration'),
                            ],
                            if (role != null) ...[
                              const SizedBox(width: 8),
                              _buildInfoChip(context, '👨‍💻 Role: $role'),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        description,
                        style: GoogleFonts.inter(
                          textStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                height: 1.6,
                                fontSize: 15,
                              ),
                        ),
                      ),
                      if (keyFeatures != null && keyFeatures!.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        Text(
                          '🔹 Key Features',
                          style: GoogleFonts.poppins(
                            textStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...keyFeatures!.map((feature) => Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('✅ ', style: TextStyle(fontSize: 16)),
                                  Expanded(
                                    child: Text(
                                      feature,
                                      style: GoogleFonts.inter(
                                        textStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                              height: 1.6,
                                              fontSize: 14,
                                            ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )),
                      ],
                      const SizedBox(height: 24),
                      Text(
                        '🔧 Tech Stack',
                        style: GoogleFonts.poppins(
                          textStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: technologies.map((tech) => _buildTechChip(context, tech)).toList(),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(BuildContext context, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          textStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
        ),
      ),
    );
  }

  Widget _buildTechChip(BuildContext context, String tech) {
    final color = _getTechColor(tech, context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _getTechIcon(tech, color),
          const SizedBox(width: 6),
          Text(
            tech,
            style: GoogleFonts.inter(
              textStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getTechColor(String tech, BuildContext context) {
    switch (tech.toLowerCase()) {
      case 'flutter':
        return const Color(0xFF02569B);
      case 'firebase':
        return const Color(0xFFFFA000);
      case 'google maps':
        return const Color(0xFF4285F4);
      case 'sqlite':
        return const Color(0xFF003B57);
      case 'rest apis':
        return const Color(0xFF009688);
      case 'spring boot':
        return const Color(0xFF6DB33F);
      case 'postgresql':
        return const Color(0xFF336791);
      case 'websocket':
        return const Color(0xFF2196F3);
      case 'aws':
        return const Color(0xFFFF9900);
      default:
        return Theme.of(context).colorScheme.primary;
    }
  }

  Widget _getTechIcon(String tech, Color color) {
    switch (tech.toLowerCase()) {
      case 'flutter':
        return Icon(Icons.flutter_dash, size: 16, color: color);
      case 'firebase':
        return Icon(Icons.local_fire_department, size: 16, color: color);
      case 'google maps':
        return Icon(Icons.map, size: 16, color: color);
      case 'sqlite':
        return Icon(Icons.storage, size: 16, color: color);
      case 'rest apis':
        return Icon(Icons.api, size: 16, color: color);
      case 'spring boot':
        return Icon(Icons.settings, size: 16, color: color);
      case 'postgresql':
        return Icon(Icons.data_array, size: 16, color: color);
      case 'websocket':
        return Icon(Icons.sync, size: 16, color: color);
      case 'aws':
        return Icon(Icons.cloud, size: 16, color: color);
      default:
        return Icon(Icons.code, size: 16, color: color);
    }
  }
} 