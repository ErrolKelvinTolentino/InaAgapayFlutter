import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
//screens
import 'screens/login.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      // 🌞 Light + 🌙 Dark themes
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,

      // 🚀 Start here
      home: const LoginScreen(),
    );
  }
}
