import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/login.dart';
import 'screens/mother_registration.dart';

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
      },
    );
  }
}
