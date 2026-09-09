import 'package:flutter/material.dart';

import '../../presentation/features/auth/screens/login_screen.dart';
import '../../presentation/features/auth/screens/otp_screen.dart';
import '../../presentation/features/home/screens/home_screen.dart';
import '../../presentation/features/profile/screens/profile_screen.dart';
import '../../presentation/features/appointments/screens/appointments_screen.dart';
import '../../presentation/features/services/screens/services_screen.dart';
import '../../presentation/features/services/screens/court_representation_screen.dart';
import '../../presentation/features/services/screens/lawyer_profile_screen.dart';
import '../../presentation/features/services/screens/appointment_create_screen.dart';
import '../../presentation/features/services/screens/templates_screen.dart';
import '../../presentation/features/services/screens/organizations_screen.dart';
import '../../presentation/features/services/screens/organization_profile_screen.dart';
import '../../presentation/features/common/screens/utility_screens.dart';
import '../../data/models/home/lawyer.dart';
import '../../data/models/services/organization.dart';
class CourtRepresentationArgs {
  final String title;
  final String about;
  final String description;

  CourtRepresentationArgs({
    required this.title,
    required this.about,
    required this.description,
  });
}
class AppRouter {
  static final navigatorKey = GlobalKey<NavigatorState>();

  static const login = '/login';
  static const otp = '/otp';
  static const home = '/home';
  static const profile = '/profile';
  static const appointments = '/appointments';
  static const services = '/services';
  static const courtRepresentation = '/services/court-representation';
  static const lawyerProfile = '/lawyer-profile';
  static const appointmentCreate = '/appointments/create';
  static const templates = '/services/templates';
  static const organizations = '/services/organizations';
  static const organizationProfile = '/organization-profile';
  static const savedLawyers = '/saved-lawyers';
  static const notifications = '/notifications';
  static const search = '/search';
  static const filters = '/filters';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case profile:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());
      case appointments:
        return MaterialPageRoute(builder: (_) => const AppointmentsScreen());
      case services:
        return MaterialPageRoute(builder: (_) => const ServicesScreen());
      case AppRouter.courtRepresentation:
        final args = settings.arguments as CourtRepresentationArgs;
        return MaterialPageRoute(
          builder: (_) => CourtRepresentationScreen(
            title: args.title,
            about: args.about,
            description: args.description,
          ),
        );
      case lawyerProfile:
        final lawyer = settings.arguments;
        return MaterialPageRoute(
          builder: (_) => lawyer is Lawyer ? LawyerProfileScreen(lawyer: lawyer) : const ServicesScreen(),
        );
      case appointmentCreate:
        final lawyer = settings.arguments;
        return MaterialPageRoute(
          builder: (_) => lawyer is Lawyer ? AppointmentCreateScreen(lawyer: lawyer) : const ServicesScreen(),
        );
      case templates:
        return MaterialPageRoute(builder: (_) => const TemplatesScreen());
      case organizations:
        return MaterialPageRoute(builder: (_) => const OrganizationsScreen());
      case organizationProfile:
        final organization = settings.arguments;
        return MaterialPageRoute(
          builder: (_) => organization is Organization
              ? OrganizationProfileScreen(organization: organization)
              : const OrganizationsScreen(),
        );
      case savedLawyers:
        return MaterialPageRoute(builder: (_) => const SavedLawyersScreen());
      case notifications:
        return MaterialPageRoute(builder: (_) => const NotificationsScreen());
      case search:
        return MaterialPageRoute(builder: (_) => const SearchScreen());
      case filters:
        return MaterialPageRoute(builder: (_) => const FilterScreen());
      case otp:
        final phone = settings.arguments;
        return MaterialPageRoute(
          builder: (_) => phone is String
              ? OtpScreen(phoneNumber: phone)
              : const LoginScreen(),
        );
      default:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
    }
  }
}
