import 'package:flutter/material.dart';
import 'add_child_step3.dart';

class AddChildStep2 extends StatefulWidget {
  final Map<String, dynamic> payload;

  const AddChildStep2({
    super.key,
    required this.payload,
  });

  @override
  State<AddChildStep2> createState() => _AddChildStep2State();
}

class _AddChildStep2State extends State<AddChildStep2> {
  final provinceCtrl = TextEditingController();
  final cityCtrl = TextEditingController();
  final barangayCtrl = TextEditingController();
  final streetCtrl = TextEditingController();
  final houseCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Child')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            const Text(
              'Address Details',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: provinceCtrl,
              decoration: const InputDecoration(labelText: 'Province'),
            ),
            TextField(
              controller: cityCtrl,
              decoration:
                  const InputDecoration(labelText: 'City / Municipality'),
            ),
            TextField(
              controller: barangayCtrl,
              decoration: const InputDecoration(labelText: 'Barangay'),
            ),
            TextField(
              controller: streetCtrl,
              decoration: const InputDecoration(labelText: 'Street Name'),
            ),
            TextField(
              controller: houseCtrl,
              decoration: const InputDecoration(labelText: 'House Number'),
            ),

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
                      // ✅ BUILD PAYLOAD HERE
                      final payload = {
                        ...widget.payload,
                        'province': provinceCtrl.text.trim(),
                        'city_municipality': cityCtrl.text.trim(),
                        'barangay': barangayCtrl.text.trim(),
                        'street': streetCtrl.text.trim(),
                        'house_number': houseCtrl.text.trim(),
                      };

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AddChildStep3(
                            payload: payload, // ✅ NOW EXISTS
                          ),
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
