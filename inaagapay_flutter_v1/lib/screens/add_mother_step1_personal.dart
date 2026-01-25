import 'package:flutter/material.dart';

class AddMotherStep1 extends StatelessWidget {
  final VoidCallback onNext;

  const AddMotherStep1({super.key, required this.onNext});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Text('👩‍🦰 Personal Information', style: TextStyle(fontSize: 18)),

          const SizedBox(height: 16),

          TextField(decoration: const InputDecoration(labelText: 'First Name')),
          TextField(decoration: const InputDecoration(labelText: 'Last Name')),
          TextField(decoration: const InputDecoration(labelText: 'Middle Name')),
          TextField(decoration: const InputDecoration(labelText: 'Extension Name')),
          TextField(decoration: const InputDecoration(labelText: 'Birthdate')),
          TextField(decoration: const InputDecoration(labelText: 'Phone Number')),
          TextField(decoration: const InputDecoration(labelText: 'Email Address')),

          const Spacer(),

          ElevatedButton(
            onPressed: onNext,
            child: const Text('Next'),
          ),
        ],
      ),
    );
  }
}
