import 'package:flutter/material.dart';
import 'theme/app_theme.dart';

import 'screens/login.dart';
import 'screens/mother_registration.dart';
import 'screens/account_verification_registration.dart';
import 'screens/mother_dashboard.dart';
import 'screens/midwife_dashboard.dart';
import 'screens/admin_dashboard.dart';
import 'screens/forgot_password.dart';
import 'screens/forgot_password_verification.dart';
import 'screens/change_forgot_password.dart';
import 'screens/complete_profile.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,

      initialRoute: '/login',

      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const MotherRegistrationScreen(),
        '/verify-registration': (context) =>
            const AccountVerificationRegistration(),

        // ✅ DASHBOARDS (USE UNDERSCORES)
        '/mother_dashboard': (context) => const MotherDashboard(),
        '/midwife_dashboard': (context) => const MidwifeDashboard(),
        '/admin_dashboard': (context) => const AdminDashboard(),

        // 🔐 FORGOT PASSWORD FLOW
        '/forgot-password': (context) => const ForgotPasswordScreen(),
        '/forgot-password-verify': (context) =>
            const ForgotPasswordVerificationScreen(),
        '/change-forgot-password': (context) =>
            const ChangeForgotPasswordScreen(),

        '/complete-profile': (context) =>
            const CompleteProfileScreen(),
      },
    );
  }
}
