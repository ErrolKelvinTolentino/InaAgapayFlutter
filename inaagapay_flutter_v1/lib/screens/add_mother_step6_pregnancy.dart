import 'package:flutter/material.dart';
import '../models/add_mother_form_data.dart';

class AddMotherStep6Pregnancy extends StatelessWidget {
  final AddMotherFormData form;
  final VoidCallback onNext;
  final VoidCallback onBack;

  const AddMotherStep6Pregnancy({
    super.key,
    required this.form,
    required this.onNext,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Step 6 – Pregnancy',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),

        DropdownButtonFormField<String>(
          value: form.riskLevel,
          items: const [
            DropdownMenuItem(value: 'low', child: Text('Low Risk')),
            DropdownMenuItem(value: 'medium', child: Text('Medium Risk')),
            DropdownMenuItem(value: 'high', child: Text('High Risk')),
          ],
          onChanged: (v) => form.riskLevel = v ?? 'low',
          decoration: const InputDecoration(labelText: 'Risk Level'),
        ),

        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            OutlinedButton(onPressed: onBack, child: const Text('Back')),
            ElevatedButton(onPressed: onNext, child: const Text('Next')),
          ],
        ),
      ],
    );
  }
}
