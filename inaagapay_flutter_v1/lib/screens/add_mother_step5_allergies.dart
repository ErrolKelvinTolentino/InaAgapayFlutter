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
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Text('🚫 Allergies'),

          TextField(decoration: const InputDecoration(labelText: 'Allergy Name')),
          TextField(decoration: const InputDecoration(labelText: 'Diagnosis Date')),
          TextField(decoration: const InputDecoration(labelText: 'Status')),
          TextField(decoration: const InputDecoration(labelText: 'Treatment')),

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
