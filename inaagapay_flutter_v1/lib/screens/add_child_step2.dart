import 'package:flutter/material.dart';
import 'add_child_step3.dart';

class AddChildStep2 extends StatelessWidget {
  const AddChildStep2({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Child')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            const Text(
              'Parent Address Info',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            TextFormField(decoration: const InputDecoration(labelText: 'Province *')),
            TextFormField(decoration: const InputDecoration(labelText: 'City / Municipality *')),
            TextFormField(decoration: const InputDecoration(labelText: 'Barangay *')),
            TextFormField(decoration: const InputDecoration(labelText: 'Street *')),
            TextFormField(decoration: const InputDecoration(labelText: 'House Number *')),

            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Back'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AddChildStep3(),
                        ),
                      );
                    },
                    child: const Text('Next'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
