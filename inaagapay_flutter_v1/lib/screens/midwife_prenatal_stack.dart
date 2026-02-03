import 'package:flutter/material.dart';

import 'midwife_prenatal_overview.dart';
import 'midwife_growth_page.dart';
import 'midwife_checkup_details_page.dart';

class MidwifePrenatalStack extends StatefulWidget {
  const MidwifePrenatalStack({super.key});

  @override
  State<MidwifePrenatalStack> createState() => _MidwifePrenatalStackState();
}

class _MidwifePrenatalStackState extends State<MidwifePrenatalStack> {
  int _index = 0;

  void _goTo(int index) => setState(() => _index = index);
  void _goBack() => setState(() => _index = 0);

  @override
  Widget build(BuildContext context) {
    return IndexedStack(
      index: _index,
      children: [
        MidwifePrenatalOverview(
          onViewGrowth: () => _goTo(1),
          onViewCheckupDetails: () => _goTo(2),
        ),
        MidwifeGrowthPage(onBack: _goBack),
        MidwifeCheckupDetailsPage(onBack: _goBack),
      ],
    );
  }
}
