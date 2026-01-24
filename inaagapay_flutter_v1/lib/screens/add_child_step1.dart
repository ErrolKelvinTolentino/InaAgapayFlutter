import 'package:flutter/material.dart';
import 'add_child_step2.dart';

class AddChildStep1 extends StatefulWidget {
  const AddChildStep1({super.key});

  @override
  State<AddChildStep1> createState() => _AddChildStep1State();
}

class _AddChildStep1State extends State<AddChildStep1> {
  bool manualEntry = false;

  // Existing mother (future: search)
  int? selectedMotherId;

  // Manual mother fields
  final firstNameCtrl = TextEditingController();
  final lastNameCtrl = TextEditingController();
  final middleNameCtrl = TextEditingController();
  final extensionNameCtrl = TextEditingController();

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

            // ================= SEARCH MODE =================
            if (!manualEntry) ...[
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Search Mother',
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: (value) {
                  // TODO: hook real search later
                },
              ),

              const SizedBox(height: 16),

              ElevatedButton(
                onPressed: () {
                  if (selectedMotherId == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please select a mother'),
                      ),
                    );
                    return;
                  }

                  // ✅ CREATE PAYLOAD HERE
                  final payload = {
                    'existing_mother_id': selectedMotherId,
                  };

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AddChildStep2(payload: payload),
                    ),
                  );
                },
                child: const Text('Next'),
              ),

              TextButton(
                onPressed: () => setState(() => manualEntry = true),
                child: const Text('Mother not registered'),
              ),
            ],

            // ================= MANUAL MODE =================
            if (manualEntry) ...[
              TextField(
                controller: firstNameCtrl,
                decoration:
                    const InputDecoration(labelText: 'Mother First Name'),
              ),
              TextField(
                controller: lastNameCtrl,
                decoration:
                    const InputDecoration(labelText: 'Mother Last Name'),
              ),
              TextField(
                controller: middleNameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Mother Middle Name (Optional)',
                ),
              ),
              TextField(
                controller: extensionNameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Mother Extension Name (Optional)',
                ),
              ),

              const SizedBox(height: 16),

              ElevatedButton(
                onPressed: () {
                  if (firstNameCtrl.text.isEmpty ||
                      lastNameCtrl.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('First and last name are required'),
                      ),
                    );
                    return;
                  }

                  // ✅ CREATE PAYLOAD HERE
                  final payload = {
                    'mother_first_name': firstNameCtrl.text.trim(),
                    'mother_middle_name': middleNameCtrl.text.trim(),
                    'mother_last_name': lastNameCtrl.text.trim(),
                    'mother_extension_name': extensionNameCtrl.text.trim(),
                  };

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AddChildStep2(payload: payload),
                    ),
                  );
                },
                child: const Text('Next'),
              ),

              TextButton(
                onPressed: () => setState(() => manualEntry = false),
                child: const Text('Back to search'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
