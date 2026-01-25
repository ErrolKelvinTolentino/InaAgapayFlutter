import 'package:flutter/material.dart';

class AddMotherStep3Husband extends StatelessWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;

  const AddMotherStep3Husband({
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
          'Step 3 – Husband Information',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),

        TextField(decoration: const InputDecoration(labelText: 'First Name')),
        TextField(decoration: const InputDecoration(labelText: 'Last Name')),
        TextField(decoration: const InputDecoration(labelText: 'Middle Name')),
        TextField(decoration: const InputDecoration(labelText: 'Extension Name')),
        TextField(decoration: const InputDecoration(labelText: 'Birthdate')),
        TextField(decoration: const InputDecoration(labelText: 'Phone Number')),
        TextField(decoration: const InputDecoration(labelText: 'Email Address')),

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
