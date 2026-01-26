import 'package:flutter/material.dart';
import '../models/add_mother_form_data.dart';

class AddMotherStep5Allergies extends StatefulWidget {
  final AddMotherFormData form;
  final VoidCallback onNext;
  final VoidCallback onBack;

  const AddMotherStep5Allergies({
    super.key,
    required this.form,
    required this.onNext,
    required this.onBack,
  });

  @override
  State<AddMotherStep5Allergies> createState() =>
      _AddMotherStep5AllergiesState();
}

class _AddMotherStep5AllergiesState
    extends State<AddMotherStep5Allergies> {
  final allergenCtrl = TextEditingController();
  final dateCtrl = TextEditingController();
  final treatmentCtrl = TextEditingController();

  void addAllergy() {
    if (allergenCtrl.text.isEmpty) return;

    widget.form.allergies.add({
      'allergen': allergenCtrl.text,
      'diagnosis_date': dateCtrl.text.isEmpty ? null : dateCtrl.text,
      'treatment': treatmentCtrl.text,
    });

    allergenCtrl.clear();
    dateCtrl.clear();
    treatmentCtrl.clear();

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Step 5 – Allergies',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),

        TextField(
          controller: allergenCtrl,
          decoration: const InputDecoration(labelText: 'Allergen'),
        ),
        TextField(
          controller: dateCtrl,
          decoration: const InputDecoration(labelText: 'Diagnosis Date (YYYY-MM-DD)'),
        ),
        TextField(
          controller: treatmentCtrl,
          decoration: const InputDecoration(labelText: 'Treatment'),
        ),

        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: addAllergy,
          child: const Text('Add Allergy'),
        ),

        const SizedBox(height: 16),
        ...widget.form.allergies.map(
          (a) => ListTile(
            title: Text(a['allergen']),
            subtitle: Text(a['treatment'] ?? ''),
          ),
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
