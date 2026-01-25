import 'package:flutter/material.dart';

class AddMotherStep6Pregnancy extends StatelessWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;

  const AddMotherStep6Pregnancy({
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
          'Step 6 – Pregnancy History',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),

        TextField(decoration: const InputDecoration(labelText: 'Times Pregnant')),
        TextField(decoration: const InputDecoration(labelText: 'Date of Delivery')),
        TextField(decoration: const InputDecoration(labelText: 'Place of Delivery')),
        TextField(decoration: const InputDecoration(labelText: 'Delivery Method')),

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
