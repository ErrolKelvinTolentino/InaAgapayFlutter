import 'package:flutter/material.dart';
import 'theme/app_theme.dart';

// 🔐 AUTH STORAGE
import 'services/auth_storage.dart';

// ================= AUTH & COMMON SCREENS =================
import 'screens/login.dart';
import 'screens/mother_registration.dart';
import 'screens/account_verification_registration.dart';
import 'screens/forgot_password.dart';
import 'screens/forgot_password_verification.dart';
import 'screens/change_forgot_password.dart';
import 'screens/complete_profile.dart';
import 'screens/welcome_screen.dart';
import 'screens/congrats_page.dart';
import 'screens/due_date_setter.dart';

// ================= DASHBOARDS / SHELLS ===================
import 'screens/mother_dashboard.dart';
import 'screens/admin_dashboard.dart';
import 'screens/midwife_shell.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<Widget> _determineStartScreen() async {
    final isLoggedIn = await AuthStorage.isLoggedIn();

    if (!isLoggedIn) {
      return const LoginScreen();
    }

    // ⚠️ TEMP DEFAULT (role-based routing later)
    return const MidwifeShell();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Widget>(
      future: _determineStartScreen(),
      builder: (context, snapshot) {
        // ⏳ Loading while checking token
        if (snapshot.connectionState != ConnectionState.done) {
          return const MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(body: Center(child: CircularProgressIndicator())),
          );
        }

        return MaterialApp(
          debugShowCheckedModeBanner: false,

          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.system,

          // ✅ SAFE AUTH ENTRY POINT
          home: snapshot.data,

          routes: {
            // ================= AUTH =================
            '/login': (context) => const LoginScreen(),
            '/register': (context) => const MotherRegistrationScreen(),
            '/verify-registration': (context) =>
                const AccountVerificationRegistration(),

            // ============== PASSWORD RESET ==========
            '/forgot-password': (context) => const ForgotPasswordScreen(),
            '/forgot-password-verify': (context) =>
                const ForgotPasswordVerificationScreen(),
            '/change-forgot-password': (context) =>
                const ChangeForgotPasswordScreen(),

            // ============== ONBOARDING ==============
            '/complete-profile': (context) => const CompleteProfileScreen(),
            '/welcome': (context) => const WelcomeScreen(),

            // ============== DASHBOARDS ===============
            '/mother_dashboard': (context) => const MotherDashboard(),
            '/midwife_dashboard': (context) => const MidwifeShell(),
            '/admin_dashboard': (context) => const AdminDashboard(),
          },

          onGenerateRoute: (settings) {
            if (settings.name == '/congrats') {
              final mode = settings.arguments as DueDateMode;
              return MaterialPageRoute(
                builder: (_) => CongratsPage(mode: mode),
              );
            }
            return null;
          },
        );
      },
    );
  }
}
