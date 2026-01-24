import 'package:flutter/material.dart';

class AddChildStep3Child extends StatelessWidget {
  const AddChildStep3Child({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Child')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            const Text(
              'Child Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            TextFormField(
                decoration:
                    const InputDecoration(labelText: 'Child First Name')),
            TextFormField(
                decoration:
                    const InputDecoration(labelText: 'Child Last Name')),
            TextFormField(
                decoration: const InputDecoration(
                    labelText: 'Child Middle Name (Optional)')),
            TextFormField(
                decoration: const InputDecoration(
                    labelText: 'Child Extension Name (Optional)')),
            TextFormField(
              decoration:
                  const InputDecoration(labelText: 'Birthdate (MM/DD/YYYY)'),
              readOnly: true,
            ),
            TextFormField(
                decoration:
                    const InputDecoration(labelText: 'Place of Birth')),

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
                      // TODO: Submit to API
                      Navigator.pop(context);
                    },
                    child: const Text('Add Child'),
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
