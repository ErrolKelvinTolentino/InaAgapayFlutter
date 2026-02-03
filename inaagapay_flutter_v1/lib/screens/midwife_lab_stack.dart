import 'package:flutter/material.dart';
import 'midwife_lab_overview.dart';
import 'midwife_lab_details.dart';

class MidwifeLabStack extends StatefulWidget {
  const MidwifeLabStack({super.key});

  @override
  State<MidwifeLabStack> createState() => _MidwifeLabStackState();
}

class _MidwifeLabStackState extends State<MidwifeLabStack> {
  int _index = 0;

  void _goToDetails() {
    setState(() => _index = 1);
  }

  void _goBack() {
    setState(() => _index = 0);
  }

  @override
  Widget build(BuildContext context) {
    return IndexedStack(
      index: _index,
      children: [
        MidwifeLabOverview(
          onViewDetails: _goToDetails,
        ),
        MidwifeLabDetailsPage(
          onBack: _goBack,
        ),
      ],
    );
  }
}
