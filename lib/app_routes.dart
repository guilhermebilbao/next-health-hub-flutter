import 'package:flutter/material.dart';
import 'auth/presentation/onboarding_screen.dart';
import 'auth/presentation/login_screen.dart';
import 'dashboard/presentation/dashboard_screen.dart';

class AppRoutes {
  static const String onboarding = '/';
  static const String login = '/login';
  static const String home = '/home';

  static Map<String, WidgetBuilder> get routes => {
    onboarding: (context) => const OnboardingScreen(),
    login: (context) => const LoginPatientScreen(),
    home: (context) => const DashboardScreen(),
  };
}
