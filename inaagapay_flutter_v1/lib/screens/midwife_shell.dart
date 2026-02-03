import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../widgets/midwife_bottom_navigation.dart';

import 'midwife_dashboard.dart';
import 'midwife_mothers_page.dart';
import 'midwife_children_page.dart';
import 'midwife_schedules_page.dart';

class MidwifeShell extends StatefulWidget {
  const MidwifeShell({super.key});

  @override
  State<MidwifeShell> createState() => _MidwifeShellState();
}

class _MidwifeShellState extends State<MidwifeShell> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const MidwifeDashboard(),
    const MidwifeMothersPage(),
    const MidwifeChildrenPage(),
    const MidwifeSchedulesPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,

      body: SafeArea(
        child: IndexedStack(
          index: _currentIndex,
          children: _pages,
        ),
      ),

      // 🔻 Bottom Nav - Remove onTap parameter
      bottomNavigationBar: const MidwifeBottomNavigation(
        currentIndex: 0,
        // Remove onTap parameter
      ),
    );
  }
}