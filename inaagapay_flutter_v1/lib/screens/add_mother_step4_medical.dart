import 'package:flutter/material.dart';
import '../models/add_mother_form_data.dart';

class AddMotherStep4Medical extends StatefulWidget {
  final AddMotherFormData form;
  final VoidCallback onNext;
  final VoidCallback onBack;

  const AddMotherStep4Medical({
    super.key,
    required this.form,
    required this.onNext,
    required this.onBack,
  });

  @override
  State<AddMotherStep4Medical> createState() => _AddMotherStep4MedicalState();
}

class _AddMotherStep4MedicalState extends State<AddMotherStep4Medical> {
  final conditions = ['Anemia', 'Diabetes', 'Smoking', 'Alcohol'];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ...conditions.map((c) {
          final checked = widget.form.medicalConditions.contains(c);
          return CheckboxListTile(
            title: Text(c),
            value: checked,
            onChanged: (v) {
              setState(() {
                v == true
                    ? widget.form.medicalConditions.add(c)
                    : widget.form.medicalConditions.remove(c);
              });
            },
          );
        }),
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
