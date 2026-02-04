import 'package:flutter/material.dart';

import 'mother_prenatal_overview.dart';
import 'mother_growth.dart';
import 'mother_checkup_details.dart';

class MotherPrenatalStack extends StatefulWidget {
  const MotherPrenatalStack({super.key});

  @override
  State<MotherPrenatalStack> createState() => _MotherPrenatalStackState();
}


class _MotherPrenatalStackState extends State<MotherPrenatalStack> {
  int _currentIndex = 0;

  void _goTo(int index) {
    setState(() => _currentIndex = index);
  }

  void _goBackToOverview() {
    setState(() => _currentIndex = 0);
  }

  @override
  Widget build(BuildContext context) {
    return IndexedStack(
      index: _currentIndex,
      children: [
        // 🟢 INDEX 0 — OVERVIEW
        MotherPrenatalOverview(
          onViewGrowth: () => _goTo(1),
          onViewCheckupDetails: () => _goTo(2),
        ),

        // 🟡 INDEX 1 — GROWTH
        MotherGrowthPage(
          onBack: _goBackToOverview,
        ),

        // 🔵 INDEX 2 — CHECKUP DETAILS
        MotherCheckupDetailsPage(
          onBack: _goBackToOverview,
        ),
      ],
    );
  }
}
