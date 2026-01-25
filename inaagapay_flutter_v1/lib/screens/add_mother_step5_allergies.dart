import 'package:flutter/material.dart';

class AddMotherStep5Allergies extends StatelessWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;

  const AddMotherStep5Allergies({
    super.key,
    required this.onNext,
    required this.onBack,
  });

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

        TextField(decoration: const InputDecoration(labelText: 'Allergy Name')),
        TextField(decoration: const InputDecoration(labelText: 'Diagnosis Date')),
        TextField(decoration: const InputDecoration(labelText: 'Treatment')),

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
