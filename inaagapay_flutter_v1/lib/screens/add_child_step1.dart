import 'package:flutter/material.dart';
import 'add_child_step2.dart';

class AddChildStep1Parent extends StatefulWidget {
  const AddChildStep1Parent({super.key});

  @override
  State<AddChildStep1Parent> createState() => _AddChildStep1ParentState();
}

class _AddChildStep1ParentState extends State<AddChildStep1Parent> {
  bool manualEntry = false;

  final motherFirstName = TextEditingController();
  final motherLastName = TextEditingController();
  final motherMiddleName = TextEditingController();
  final motherExtensionName = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Child')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            const Text(
              'Parent Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            if (!manualEntry) ...[
              TextFormField(
                decoration: const InputDecoration(
                  hintText: 'Search Mother',
                  prefixIcon: Icon(Icons.search),
                ),
              ),
              const SizedBox(height: 16),

              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AddChildStep2(),
                    ),
                  );
                },
                child: const Text('Next'),
              ),

              const SizedBox(height: 8),

              TextButton(
                onPressed: () {
                  setState(() => manualEntry = true);
                },
                child: const Text('Mother not registered'),
              ),
            ] else ...[
              TextFormField(
                controller: motherFirstName,
                decoration:
                    const InputDecoration(labelText: 'Mother First Name'),
              ),
              TextFormField(
                controller: motherLastName,
                decoration:
                    const InputDecoration(labelText: 'Mother Last Name'),
              ),
              TextFormField(
                controller: motherMiddleName,
                decoration: const InputDecoration(
                  labelText: 'Mother Middle Name (Optional)',
                ),
              ),
              TextFormField(
                controller: motherExtensionName,
                decoration: const InputDecoration(
                  labelText: 'Mother Extension Name (Optional)',
                ),
              ),
              const SizedBox(height: 16),

              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AddChildStep2(),
                    ),
                  );
                },
                child: const Text('Next'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
