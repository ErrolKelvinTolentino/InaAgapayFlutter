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
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Text('🤰 Pregnancy History'),

          TextField(decoration: const InputDecoration(labelText: 'Times Pregnant')),
          TextField(decoration: const InputDecoration(labelText: 'Delivery Date')),
          TextField(decoration: const InputDecoration(labelText: 'Place of Delivery')),
          TextField(decoration: const InputDecoration(labelText: 'Delivery Method')),

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
