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
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Text('👨 Husband Information'),

          TextField(decoration: const InputDecoration(labelText: 'First Name')),
          TextField(decoration: const InputDecoration(labelText: 'Last Name')),
          TextField(decoration: const InputDecoration(labelText: 'Middle Name')),
          TextField(decoration: const InputDecoration(labelText: 'Extension Name')),
          TextField(decoration: const InputDecoration(labelText: 'Birthdate')),
          TextField(decoration: const InputDecoration(labelText: 'Phone Number')),
          TextField(decoration: const InputDecoration(labelText: 'Email Address')),

          const Spacer(),

          Row(
            children: [
              Expanded(child: OutlinedButton(onPressed: onBack, child: const Text('Back'))),
              const SizedBox(width: 8),
              Expanded(child: ElevatedButton(onPressed: onNext, child: const Text('Next'))),
            ],
          ),
        ],
      ),
    );
  }
}
