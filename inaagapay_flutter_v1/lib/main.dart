import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/login.dart';
import 'screens/mother_registration.dart';
import 'screens/account_verification_registration.dart';
import 'screens/mother_dashboard.dart';
import 'screens/midwife_dashboard.dart';
import 'screens/midwife_children_page.dart';
import 'screens/midwife_child_overview.dart';
import 'screens/midwife_child_growth.dart';
import 'screens/midwife_child_vaccine.dart';
import 'screens/midwife_add_child_growth.dart';
import 'screens/midwife_add_immunization.dart';
import 'screens/midwife_add_parent_1.dart';
import 'screens/midwife_add_parent_2.dart';
import 'screens/midwife_add_child_address.dart';
import 'screens/midwife_add_child.dart';
import 'screens/midwife_mother_overview.dart';
import 'screens/midwife_mothers_page.dart';
import 'screens/midwife_mother_records.dart';
import 'screens/midwife_prenatal_stack.dart';
import 'screens/midwife_ultrasound_stack.dart';
import 'screens/midwife_lab_stack.dart';


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
        '/mother-children-stack': (context) => MotherChildStack(),
        '/mother-children': (context) => MotherChildrenPage(),
        '/mother-records': (context) => MotherRecordsPage(),
        '/mother-prenatal-stack': (context) => MotherPrenatalStack(),
        '/mother-ultrasound-stack': (context) => MotherUltrasoundStack(),
        '/mother-lab-stack': (context) => MotherLabStack(),
        '/mother-pregnancy': (context) => PregnancyDetailsPage(),

        '/midwife-dashboard': (context) => const MidwifeDashboard(),
        '/midwife-children': (context) => const MidwifeChildrenPage(),
        '/midwife-child-overview': (context) =>
            const MidwifeChildOverviewPage(),
        '/midwife-child-growth': (context) => const MidwifeChildGrowthPage(),
        '/midwife-child-vaccine': (context) => const MidwifeChildVaccinePage(),
        '/midwife-add-child-growth': (context) =>
            const MidwifeAddChildGrowthPage(),
        '/midwife-add-immunization': (context) =>
            const MidwifeAddImmunizationPage(),
        '/midwife-add-parent': (_) => const MidwifeAddParentStep1(),
        '/midwife-add-parent-details': (_) =>
            const MidwifeAddParentStep2(), // next
        '/midwife-add-child-address': (_) => const MidwifeAddChildAddressPage(),
        '/midwife-add-child': (_) => const MidwifeAddChildPage(),
        '/midwife-mothers': (context) => const MidwifeMothersPage(),
        '/midwife-mother-overview': (context) =>
            const MidwifeMotherOverviewPage(),

        '/midwife-mother-records': (context) => MidwifeMotherRecordsPage(),
        '/midwife-prenatal-stack': (context) => MidwifePrenatalStack(),
        '/midwife-ultrasound-stack': (context) => MidwifeUltrasoundStack(),
        '/midwife-lab-stack': (context) => MidwifeLabStack(),


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
