import 'package:flutter/material.dart';
import 'midwife_ultrasound_overview.dart';
import 'midwife_ultrasound_details.dart';

class MidwifeUltrasoundStack extends StatefulWidget {
  const MidwifeUltrasoundStack({super.key});

  @override
  State<MidwifeUltrasoundStack> createState() =>
      _MidwifeUltrasoundStackState();
}

class _MidwifeUltrasoundStackState extends State<MidwifeUltrasoundStack> {
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
        MidwifeUltrasoundOverview(
          onViewDetails: _goToDetails,
        ),
        MidwifeUltrasoundDetailsPage(
          onBack: _goBack,
        ),
      ],
    );
  }
}
