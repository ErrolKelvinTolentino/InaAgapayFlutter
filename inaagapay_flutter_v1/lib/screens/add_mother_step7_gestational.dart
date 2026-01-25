import 'package:flutter/material.dart';

class AddMotherStep7Gestational extends StatelessWidget {
  final VoidCallback onBack;

  const AddMotherStep7Gestational({
    super.key,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Text('🧠 Gestational Information'),

          TextField(decoration: const InputDecoration(labelText: 'Last Menstrual Date')),
          TextField(decoration: const InputDecoration(labelText: 'Expected Delivery Date')),
          TextField(decoration: const InputDecoration(labelText: 'Age of Gestation')),

          const Spacer(),

          Row(
            children: [
              Expanded(child: OutlinedButton(onPressed: onBack, child: const Text('Back'))),
              const SizedBox(width: 8),
              Expanded(child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Add Patient'),
              )),
            ],
          ),
        ],
      ),
    );
  }
}
