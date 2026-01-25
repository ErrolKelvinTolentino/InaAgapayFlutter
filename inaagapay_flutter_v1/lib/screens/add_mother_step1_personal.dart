import 'package:flutter/material.dart';

class AddMotherStep1Personal extends StatelessWidget {
  final VoidCallback onNext;

  const AddMotherStep1Personal({
    super.key,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Step 1 – Personal Information',
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
        Align(
          alignment: Alignment.centerRight,
          child: ElevatedButton(
            onPressed: onNext,
            child: const Text('Next'),
          ),
        ),
      ],
    );
  }
}
