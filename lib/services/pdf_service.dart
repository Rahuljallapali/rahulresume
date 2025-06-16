import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:universal_html/html.dart' as html;

class PDFService {
  static Future<void> generateAndDownloadResume(BuildContext context) async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      final pdf = pw.Document();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          build: (context) => [
            _buildHeader(),
            _buildProfessionalSummary(),
            _buildExperience(),
            _buildSkills(),
            _buildProjects(),
            _buildEducation(),
          ],
        ),
      );

      final bytes = await pdf.save();

      // Close loading indicator
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      if (kIsWeb) {
        // Web platform handling with improved Chrome compatibility
        try {
          final blob = html.Blob([bytes], 'application/pdf');
          final url = html.Url.createObjectUrlFromBlob(blob);
          
          // Create a temporary link element
          final anchor = html.AnchorElement(href: url)
            ..setAttribute('download', 'Rahul_Jallapalli_Resume.pdf')
            ..style.display = 'none';
          
          // Append to document, click, and remove
          html.document.body?.append(anchor);
          anchor.click();
          anchor.remove();
          
          // Clean up
          html.Url.revokeObjectUrl(url);
          
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Resume downloaded successfully!'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error downloading PDF: ${e.toString()}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } else {
        // Mobile/Desktop platform handling
        try {
          final output = await getTemporaryDirectory();
          final file = File('${output.path}/Rahul_Jallapalli_Resume.pdf');
          await file.writeAsBytes(bytes);
          await Share.shareXFiles(
            [XFile(file.path)],
            text: 'My Professional Resume',
          );
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error sharing PDF: ${e.toString()}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    } catch (e) {
      // Close loading indicator if it's still showing
      if (context.mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error generating PDF: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  static Future<List<int>> generateResume() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          _buildHeader(),
          _buildProfessionalSummary(),
          _buildExperience(),
          _buildSkills(),
          _buildProjects(),
          _buildEducation(),
        ],
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildHeader() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Rahul Jallapalli',
          style: pw.TextStyle(
            fontSize: 28,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          'Senior Flutter Developer',
          style: pw.TextStyle(
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.blue700,
          ),
        ),
        pw.SizedBox(height: 8),
        pw.Row(
          children: [
            _buildContactInfo('Email', 'rahul.jallapalli@example.com'),
            _buildContactInfo('Phone', '+1 234 567 8900'),
            _buildContactInfo('Location', 'San Francisco, CA'),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildContactInfo(String label, String value) {
    return pw.Expanded(
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
              color: PdfColors.grey700,
              fontSize: 10,
            ),
          ),
          pw.Text(
            value,
            style: const pw.TextStyle(
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildProfessionalSummary() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Header(
          level: 1,
          text: 'Professional Summary',
        ),
        pw.SizedBox(height: 8),
        pw.Text(
          'Experienced Flutter developer with a proven track record of building production-ready mobile applications. '
          'Specialized in implementing complex features like camera integration, maps, and real-time video collaboration. '
          'Strong backend knowledge with Spring Boot and expertise in CI/CD using Jenkins, Docker, and AWS EC2.',
        ),
      ],
    );
  }

  static pw.Widget _buildExperience() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Header(
          level: 1,
          text: 'Experience',
        ),
        pw.SizedBox(height: 8),
        _buildExperienceItem(
          'Senior Flutter Developer',
          'Company Name',
          '2021 - Present',
          [
            'Led development of multiple production Flutter apps with features including camera integration, maps, and real-time video collaboration',
            'Implemented offline data synchronization using SQLite and Firebase',
            'Integrated REST APIs and WebSocket connections for real-time features',
            'Collaborated with backend team to design and implement API endpoints',
            'Mentored junior developers and conducted code reviews',
          ],
        ),
        pw.SizedBox(height: 16),
        _buildExperienceItem(
          'Flutter Developer',
          'Previous Company',
          '2019 - 2021',
          [
            'Developed and maintained multiple Flutter applications',
            'Implemented Firebase integration for authentication and real-time database',
            'Created custom UI components and animations',
            'Worked with REST APIs and state management solutions',
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildExperienceItem(
    String title,
    String company,
    String duration,
    List<String> points,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          title,
          style: pw.TextStyle(
            fontSize: 14,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.Text(
          '$company • $duration',
          style: const pw.TextStyle(
            fontSize: 12,
          ),
        ),
        pw.SizedBox(height: 8),
        ...points.map(
          (point) => pw.Padding(
            padding: const pw.EdgeInsets.only(left: 12, bottom: 4),
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('• '),
                pw.Expanded(
                  child: pw.Text(
                    point,
                    style: const pw.TextStyle(
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildSkills() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Header(
          level: 1,
          text: 'Technical Skills',
        ),
        pw.SizedBox(height: 8),
        _buildSkillCategory('Languages', ['Dart', 'Java', 'Kotlin', 'Swift', 'JavaScript']),
        pw.SizedBox(height: 8),
        _buildSkillCategory('Frameworks', ['Flutter', 'Spring Boot', 'React Native', 'Node.js']),
        pw.SizedBox(height: 8),
        _buildSkillCategory('Tools', ['Android Studio', 'VS Code', 'Git', 'Postman', 'Figma']),
        pw.SizedBox(height: 8),
        _buildSkillCategory('Cloud/DevOps', ['AWS EC2', 'Docker', 'Jenkins', 'Firebase', 'GitHub Actions']),
      ],
    );
  }

  static pw.Widget _buildSkillCategory(String category, List<String> skills) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          category,
          style: pw.TextStyle(
            fontSize: 12,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Wrap(
          spacing: 8,
          runSpacing: 4,
          children: skills.map(
            (skill) => pw.Container(
              padding: const pw.EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey200,
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
              ),
              child: pw.Text(
                skill,
                style: const pw.TextStyle(
                  fontSize: 10,
                ),
              ),
            ),
          ).toList(),
        ),
      ],
    );
  }

  static pw.Widget _buildProjects() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Header(
          level: 1,
          text: 'Key Projects',
        ),
        pw.SizedBox(height: 8),
        _buildProjectItem(
          'Serveiz for Enterprise',
          'An end-to-end field service management solution developed using Flutter. Enables enterprises to manage work orders, inventory, field staff, and customer interactions efficiently.',
          ['Flutter', 'Firebase', 'Google Maps', 'SQLite', 'REST APIs'],
        ),
        pw.SizedBox(height: 16),
        _buildProjectItem(
          'SMB (Small-Medium Business Toolkit)',
          'A Flutter-based business automation app designed for small and medium businesses to streamline operations from customer management to billing.',
          ['Flutter', 'Firebase', 'Google Maps API', 'Payment Gateway', 'WebRTC'],
        ),
      ],
    );
  }

  static pw.Widget _buildProjectItem(
    String title,
    String description,
    List<String> technologies,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          title,
          style: pw.TextStyle(
            fontSize: 14,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          description,
          style: const pw.TextStyle(
            fontSize: 10,
          ),
        ),
        pw.SizedBox(height: 8),
        pw.Wrap(
          spacing: 8,
          runSpacing: 4,
          children: technologies.map(
            (tech) => pw.Container(
              padding: const pw.EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey200,
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
              ),
              child: pw.Text(
                tech,
                style: const pw.TextStyle(
                  fontSize: 10,
                ),
              ),
            ),
          ).toList(),
        ),
      ],
    );
  }

  static pw.Widget _buildEducation() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Header(
          level: 1,
          text: 'Education',
        ),
        pw.SizedBox(height: 8),
        _buildEducationItem(
          'B.TECH (EEE)',
          'Bharat Institute of Engineering and Technology',
          '2020',
          '6.35 CGPA',
        ),
        pw.SizedBox(height: 12),
        _buildEducationItem(
          'Intermediate (M.P.C)',
          'Narayana Junior College',
          '2016',
          '61%',
        ),
        pw.SizedBox(height: 12),
        _buildEducationItem(
          'High School (SSC)',
          "ST. Anthony's High School",
          '2014',
          '7.3 GPA',
        ),
      ],
    );
  }

  static pw.Widget _buildEducationItem(
    String degree,
    String institution,
    String year,
    String score,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          degree,
          style: pw.TextStyle(
            fontSize: 12,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.Text(
          institution,
          style: const pw.TextStyle(
            fontSize: 10,
          ),
        ),
        pw.Row(
          children: [
            pw.Text(
              year,
              style: pw.TextStyle(
                fontSize: 10,
                color: PdfColors.grey700,
              ),
            ),
            pw.Text(
              ' • ',
              style: pw.TextStyle(
                fontSize: 10,
                color: PdfColors.grey700,
              ),
            ),
            pw.Text(
              score,
              style: pw.TextStyle(
                fontSize: 10,
                color: PdfColors.grey700,
              ),
            ),
          ],
        ),
      ],
    );
  }
} 