import 'package:flutter/material.dart';

import '../../presentation/features/auth/screens/login_screen.dart';
import '../../presentation/features/auth/screens/otp_screen.dart';

class AppRouter {
  static final navigatorKey = GlobalKey<NavigatorState>();

  static const login = '/login';
  static const otp = '/otp';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case otp:
        final phone = settings.arguments;
        return MaterialPageRoute(
          builder: (_) => phone is String
              ? OtpScreen(phoneNumber: phone)
              : const LoginScreen(),
        );
      default:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
    }
  }
}
