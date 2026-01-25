import 'package:flutter/material.dart';

class AddMotherStep4Medical extends StatelessWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;

  const AddMotherStep4Medical({
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
          const Text('🩺 Medical History'),

          CheckboxListTile(value: false, onChanged: (_) {}, title: const Text('Anemia')),
          CheckboxListTile(value: false, onChanged: (_) {}, title: const Text('Diabetes')),
          CheckboxListTile(value: false, onChanged: (_) {}, title: const Text('Smoking')),

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
