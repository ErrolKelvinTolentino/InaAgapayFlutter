import 'package:flutter/material.dart';

import '../models/add_mother_form_data.dart';

import 'add_mother_step1_personal.dart';
import 'add_mother_step2_address.dart';
import 'add_mother_step3_emergency.dart';
import 'add_mother_step4_medical.dart';
import 'add_mother_step5_allergies.dart';
import 'add_mother_step6_pregnancy.dart';
import 'add_mother_step7_submit.dart';

class AddMotherFlow extends StatefulWidget {
  const AddMotherFlow({super.key});

  @override
  State<AddMotherFlow> createState() => _AddMotherFlowState();
}

class _AddMotherFlowState extends State<AddMotherFlow> {
  final AddMotherFormData form = AddMotherFormData();
  int step = 0;

  void next() {
    if (step < 6) {
      setState(() => step++);
    }
  }

  void back() {
    if (step > 0) {
      setState(() => step--);
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      AddMotherStep1Personal(form: form, onNext: next),
      AddMotherStep2Address(form: form, onNext: next, onBack: back),
      AddMotherStep3Emergency(form: form, onNext: next, onBack: back),
      AddMotherStep4Medical(form: form, onNext: next, onBack: back),
      AddMotherStep5Allergies(form: form, onNext: next, onBack: back),
      AddMotherStep6Pregnancy(form: form, onNext: next, onBack: back),
      AddMotherStep7Submit(form: form, onBack: back),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Add Mother – Step ${step + 1} of 7'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: pages[step],
      ),
    );
  }
}
