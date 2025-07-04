import 'package:get/get.dart';
import 'package:rahul_resume/widgets/hero_section.dart';
import '../pages/resume_page.dart';
import '../pages/about_me_page.dart';
import '../pages/contact_page.dart';
import '../pages/blog_page.dart';
import '../pages/portfolio_page.dart';

class AppRoutes {
  static const String resume = '/resume';
  static const String aboutMe = '/about-me';
  static const String contact = '/contact';
  static const String blog = '/blog';
  static const String portfolio = '/portfolio';
  static const String homeScreen = '/home-screen';

  static final routes = [
    GetPage(
      name: resume,
      page: () => const ResumePage(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: aboutMe,
      page: () => const AboutMePage(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: contact,
      page: () => const ContactPage(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: blog,
      page: () => const BlogPage(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: portfolio,
      page: () => const PortfolioPage(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: homeScreen,
      page: () => const HeroSection(),
      transition: Transition.fadeIn,
    ),
  ];
} 