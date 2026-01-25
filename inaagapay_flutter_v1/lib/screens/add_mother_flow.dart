import 'package:flutter/material.dart';

import 'add_mother_step1_personal.dart';
import 'add_mother_step2_address.dart';
import 'add_mother_step3_husband.dart';
import 'add_mother_step4_medical.dart';
import 'add_mother_step5_allergies.dart';
import 'add_mother_step6_pregnancy.dart';
import 'add_mother_step7_gestational.dart';

class AddMotherFlow extends StatefulWidget {
  const AddMotherFlow({super.key});

  @override
  State<AddMotherFlow> createState() => _AddMotherFlowState();
}

class _AddMotherFlowState extends State<AddMotherFlow> {
  int currentStep = 0;

  void next() {
    if (currentStep < 6) {
      setState(() => currentStep++);
    }
  }

  void back() {
    if (currentStep > 0) {
      setState(() => currentStep--);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Mother – Step ${currentStep + 1} of 7'),
      ),
      body: IndexedStack(
        index: currentStep,
        children: [
          AddMotherStep1(onNext: next),
          AddMotherStep2Address(onNext: next, onBack: back),
          AddMotherStep3Husband(onNext: next, onBack: back),
          AddMotherStep4Medical(onNext: next, onBack: back),
          AddMotherStep5Allergies(onNext: next, onBack: back),
          AddMotherStep6Pregnancy(onNext: next, onBack: back),
          AddMotherStep7Gestational(onBack: back),
        ],
      ),
    );
  }
}
