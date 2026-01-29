import 'package:flutter/material.dart';
import '../models/add_mother_form_data.dart';

class AddMotherStep4Vitals extends StatefulWidget {
  const AddMotherStep4Vitals({
    super.key,
    required this.form,
    required this.onNext,
    required this.onBack,
  });

  final AddMotherFormData form;
  final VoidCallback onNext;
  final VoidCallback onBack;

  @override
  State<AddMotherStep4Vitals> createState() => _AddMotherStep4VitalsState();
}

class _AddMotherStep4VitalsState extends State<AddMotherStep4Vitals> {
  late final TextEditingController _height;
  late final TextEditingController _weight;
  late final TextEditingController _bloodType;

  @override
  void initState() {
    super.initState();
    _height = TextEditingController(
      text: widget.form.heightCm?.toString() ?? '',
    );
    _weight = TextEditingController(
      text: widget.form.weightKg?.toString() ?? '',
    );
    _bloodType = TextEditingController(text: widget.form.bloodType ?? '');
  }

  @override
  void dispose() {
    _height.dispose();
    _weight.dispose();
    _bloodType.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bmi = widget.form.bmi();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Step 4 – Vital Statistics',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _height,
          decoration: const InputDecoration(labelText: 'Height (cm)'),
          keyboardType: TextInputType.number,
          onChanged: (v) => widget.form.heightCm = double.tryParse(v),
        ),
        TextField(
          controller: _weight,
          decoration: const InputDecoration(labelText: 'Weight (kg)'),
          keyboardType: TextInputType.number,
          onChanged: (v) => widget.form.weightKg = double.tryParse(v),
        ),
        TextField(
          controller: _bloodType,
          decoration: const InputDecoration(labelText: 'Blood Type'),
          onChanged: (v) => widget.form.bloodType = v,
        ),
        if (bmi != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text('BMI: ${bmi.toStringAsFixed(1)} (auto-calculated)'),
          ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            OutlinedButton(onPressed: widget.onBack, child: const Text('Back')),
            ElevatedButton(onPressed: widget.onNext, child: const Text('Next')),
          ],
        ),
      ],
    );
  }
}
