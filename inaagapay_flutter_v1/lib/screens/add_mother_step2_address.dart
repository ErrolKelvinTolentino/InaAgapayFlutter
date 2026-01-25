import 'package:flutter/material.dart';

class AddMotherStep2Address extends StatelessWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;

  const AddMotherStep2Address({
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
          'Step 2 – Address Information',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),

        TextField(decoration: const InputDecoration(labelText: 'Province')),
        TextField(decoration: const InputDecoration(labelText: 'City / Municipality')),
        TextField(decoration: const InputDecoration(labelText: 'Barangay')),
        TextField(decoration: const InputDecoration(labelText: 'Street')),
        TextField(decoration: const InputDecoration(labelText: 'House Number')),

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
