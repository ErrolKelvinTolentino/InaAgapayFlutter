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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Step 4 – Medical History',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),

        CheckboxListTile(title: const Text('Anemia'), value: false, onChanged: (_) {}),
        CheckboxListTile(title: const Text('Diabetes'), value: false, onChanged: (_) {}),
        CheckboxListTile(title: const Text('Smoking'), value: false, onChanged: (_) {}),
        CheckboxListTile(title: const Text('Alcohol'), value: false, onChanged: (_) {}),

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
