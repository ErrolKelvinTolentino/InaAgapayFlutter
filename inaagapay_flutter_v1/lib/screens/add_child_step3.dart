import 'package:flutter/material.dart';

class AddChildStep3 extends StatelessWidget {
  const AddChildStep3({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Child')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            const Text(
              'Birth Details',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            TextFormField(decoration: const InputDecoration(labelText: 'Birthdate *')),
            TextFormField(decoration: const InputDecoration(labelText: 'Birth Time *')),
            const Text('Child Age: Auto-calculated'),

            TextFormField(decoration: const InputDecoration(labelText: 'Birth Weight *')),
            TextFormField(decoration: const InputDecoration(labelText: 'Birth Height *')),
            TextFormField(decoration: const InputDecoration(labelText: 'City Place of Birth *')),
            TextFormField(decoration: const InputDecoration(labelText: 'Institution Place of Birth *')),
            TextFormField(decoration: const InputDecoration(labelText: 'Head Circumference *')),
            TextFormField(decoration: const InputDecoration(labelText: 'Birth Complications *')),

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
                      // TODO: submit to API
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
