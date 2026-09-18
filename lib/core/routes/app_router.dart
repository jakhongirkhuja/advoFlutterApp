import 'package:flutter/material.dart';

import '../../presentation/features/auth/screens/login_screen.dart';
import '../../presentation/features/auth/screens/otp_screen.dart';
import '../../presentation/features/auth/screens/user_info_fill.dart';
import '../../presentation/features/home/screens/home_screen.dart';
import '../../presentation/features/home/screens/ai_chat_screen.dart';
import '../../presentation/features/profile/screens/profile_screen.dart';
import '../../presentation/features/profile/screens/profile_details_screen.dart';
import '../../presentation/features/profile/screens/profile_edit_screen.dart';
import '../../presentation/features/profile/screens/privacy_policy_screen.dart';
import '../../presentation/features/profile/screens/help_center_screen.dart';
import '../../presentation/features/profile/screens/trust_number_screen.dart';
import '../../presentation/features/profile/screens/partnership_screen.dart';
import '../../presentation/features/profile/screens/history_screen.dart';
import '../../presentation/features/profile/screens/active_devices_screen.dart';
import '../../presentation/features/profile/screens/suggestions_screen.dart';
import '../../presentation/features/appointments/screens/appointments_screen.dart';
import '../../presentation/features/services/screens/services_screen.dart';
import '../../presentation/features/services/screens/court_representation_screen.dart';
import '../../presentation/features/services/screens/lawyer_profile_screen.dart';
import '../../presentation/features/services/screens/appointment_create_screen.dart';
import '../../presentation/features/profile/screens/profile_templates_screen.dart';
import '../../presentation/features/profile/screens/profile_verification_screen.dart';
import '../../presentation/features/profile/screens/profile_contribution_screen.dart';
import '../../presentation/features/services/screens/templates_screen.dart';
import '../../presentation/features/services/screens/organizations_screen.dart';
import '../../presentation/features/services/screens/organization_profile_screen.dart';
import '../../presentation/features/services/screens/protokol_screen.dart';
import '../../presentation/features/services/screens/protokol_map_screen.dart';
import '../../presentation/features/common/screens/utility_screens.dart';
import '../../data/models/home/lawyer.dart';
import '../../data/models/auth/user_model.dart';
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
  static const userInfo = '/user-info';
  static const home = '/home';
  static const aiAssistant = '/ai-assistant';
  static const profile = '/profile';
  static const profileDetails = '/profile/details';
  static const profileEdit = '/profile/edit';
  static const profilePrivacy = '/profile/privacy';
  static const helpCenter = '/profile/help';
  static const trustNumber = '/profile/trust-number';
  static const partnership = '/profile/partnership';
  static const history = '/profile/history';
  static const activeDevices = '/profile/active-devices';
  static const suggestions = '/profile/suggestions';
  static const appointments = '/appointments';
  static const services = '/services';
  static const courtRepresentation = '/services/court-representation';
  static const lawyerProfile = '/lawyer-profile';
  static const appointmentCreate = '/appointments/create';
  static const templates = '/services/templates';
  static const profileTemplates = '/profile/templates';
  static const profileVerification = '/profile/verification';
  static const profileContribution = '/profile/contribution';
  static const organizations = '/services/organizations';
  static const organizationProfile = '/organization-profile';
  static const protokol = '/services/protokol';
  static const protokolProviders = '/services/protokol/providers';
  static const savedLawyers = '/saved-lawyers';
  static const lawyers = '/lawyers';
  static const notifications = '/notifications';
  static const search = '/search';
  static const filters = '/filters';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case aiAssistant:
        return MaterialPageRoute(builder: (_) => const AiChatScreen());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case profile:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());
      case profileDetails:
        final user = settings.arguments;
        return MaterialPageRoute(
          builder: (_) => user is UserModel
              ? ProfileDetailsRouteScreen(user: user)
              : const ProfileScreen(),
        );
      case profileEdit:
        final user = settings.arguments;
        return MaterialPageRoute(
          builder: (_) => user is UserModel
              ? ProfileEditRouteScreen(user: user)
              : const ProfileScreen(),
        );
      case profilePrivacy:
        return MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen());
      case helpCenter:
        return MaterialPageRoute(builder: (_) => const HelpCenterScreen());
      case trustNumber:
        return MaterialPageRoute(builder: (_) => const TrustNumberScreen());
      case partnership:
        return MaterialPageRoute(builder: (_) => const PartnershipScreen());
      case history:
        return MaterialPageRoute(builder: (_) => const HistoryScreen());
      case activeDevices:
        return MaterialPageRoute(builder: (_) => const ActiveDevicesScreen());
      case suggestions:
        return MaterialPageRoute(builder: (_) => const SuggestionsScreen());
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
      case profileTemplates:
        return MaterialPageRoute(builder: (_) => const ProfileTemplatesScreen());
      case profileVerification:
        return MaterialPageRoute(builder: (_) => const ProfileVerificationScreen());
      case profileContribution:
        return MaterialPageRoute(builder: (_) => const ProfileContributionScreen());
      case organizations:
        return MaterialPageRoute(builder: (_) => const OrganizationsScreen());
      case organizationProfile:
        final organization = settings.arguments;
        return MaterialPageRoute(
          builder: (_) => organization is Organization
              ? OrganizationProfileScreen(organization: organization)
              : const OrganizationsScreen(),
        );
      case protokol:
        return MaterialPageRoute(builder: (_) => const ProtokolMapScreen());
      case protokolProviders:
        return MaterialPageRoute(
          builder: (_) => const ProtokolScreen(title: 'Yevro pratakol'),
        );
      case savedLawyers:
        return MaterialPageRoute(builder: (_) => const SavedLawyersScreen());
      case lawyers:
        return MaterialPageRoute(builder: (_) => const LawyersScreen());
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
      case userInfo:
        final phone = settings.arguments;
        return MaterialPageRoute(
          builder: (_) => phone is String
              ? UserInfoFill(phoneNumber: phone)
              : const LoginScreen(),
        );
      default:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
    }
  }
}
