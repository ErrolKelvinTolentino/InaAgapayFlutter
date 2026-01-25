import 'package:flutter/material.dart';

class AddMotherStep7Gestational extends StatelessWidget {
  final VoidCallback onBack;

  const AddMotherStep7Gestational({
    super.key,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Step 7 – Gestational Information',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),

        TextField(decoration: const InputDecoration(labelText: 'Last Menstrual Date')),
        TextField(decoration: const InputDecoration(labelText: 'Expected Delivery Date')),
        TextField(decoration: const InputDecoration(labelText: 'Age of Gestation')),

        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            OutlinedButton(onPressed: onBack, child: const Text('Back')),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Add Patient'),
            ),
          ],
        ),
      ],
    );
  }
}
