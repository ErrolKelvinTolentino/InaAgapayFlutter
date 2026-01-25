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
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Text('🏠 Address Information', style: TextStyle(fontSize: 18)),

          TextField(decoration: const InputDecoration(labelText: 'Province')),
          TextField(decoration: const InputDecoration(labelText: 'City / Municipality')),
          TextField(decoration: const InputDecoration(labelText: 'Barangay')),
          TextField(decoration: const InputDecoration(labelText: 'Street')),
          TextField(decoration: const InputDecoration(labelText: 'House Number')),

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
