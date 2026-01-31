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
import 'screens/welcome_screen.dart';
import 'screens/congrats_page.dart';
import 'screens/due_date_setter.dart'; // gives access to DueDateMode
import 'screens/mother_children_page.dart';
import 'screens/mother_child_stack.dart';
import 'screens/mother_prenatal_stack.dart';
import 'screens/mother_ultrasound_stack.dart';
import 'screens/mother_lab_stack.dart';
import 'screens/pregnancy_details.dart';
import 'screens/mother_records.dart';


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

      // 👇 initial screen
      initialRoute: '/login',

      // 👇 named routes
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const MotherRegistrationScreen(),
        '/verify-registration': (context) =>
            const AccountVerificationRegistration(),
        '/mother-dashboard': (context) => MotherDashboard(),
        '/mother-children': (context) => MotherChildrenPage(),
        '/mother-records': (context) => MotherRecordsPage(),
        '/mother-prenatal-stack': (context) => MotherPrenatalStack(),
        '/mother-ultrasound-stack': (context) => MotherUltrasoundStack(),
        '/mother-lab-stack': (context) => MotherLabStack(),
        '/mother-pregnancy': (context) => PregnancyDetailsPage(),
        '/midwife-dashboard': (context) => const MidwifeDashboard(),
        '/admin-dashboard': (context) => const AdminDashboard(),
        '/forgot-password': (context) => const ForgotPasswordScreen(),
        '/forgot-password-verify': (context) =>
            const ForgotPasswordVerificationScreen(),
        '/change-forgot-password': (context) =>
            const ChangeForgotPasswordScreen(),
        '/complete-profile': (context) => const CompleteProfileScreen(),
        '/welcome': (context) => const WelcomeScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/congrats') {
          final mode = settings.arguments as DueDateMode;

          return MaterialPageRoute(builder: (_) => CongratsPage(mode: mode));
        }
        return null;
      },
    );
  }
}
