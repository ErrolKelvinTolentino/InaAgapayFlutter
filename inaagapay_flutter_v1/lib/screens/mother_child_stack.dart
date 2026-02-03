import 'package:flutter/material.dart';

import 'mother_view_child.dart';
import 'mother_child_growth.dart';
import 'mother_child_vaccine.dart';

class MotherChildStack extends StatefulWidget {
  const MotherChildStack({super.key});

  @override
  State<MotherChildStack> createState() => _MotherChildStackState();
}


class _MotherChildStackState extends State<MotherChildStack> {
  int _currentIndex = 0;

  void _goTo(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _goBackToOverview() {
    setState(() {
      _currentIndex = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return IndexedStack(
      index: _currentIndex,
      children: [
        // 🟢 INDEX 0 — OVERVIEW
        MotherViewChildPage(
          onBackToChildren: () => Navigator.pop(context),
          onViewGrowth: () => _goTo(1),
          onViewVaccines: () => _goTo(2),
        ),

        // 🟡 INDEX 1 — GROWTH
        MotherChildGrowthPage(
          onBack: _goBackToOverview,
        ),

        // 🔵 INDEX 2 — VACCINES
        MotherChildVaccinePage(
          onBack: _goBackToOverview,
        ),
      ],
    );
  }
}
