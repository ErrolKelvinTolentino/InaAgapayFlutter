import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../services/auth_storage.dart'; // 👈 IMPORTANT
import 'add_child_step2.dart';
import 'add_child_step3.dart';

class AddChildStep1Parent extends StatefulWidget {
  const AddChildStep1Parent({super.key});

  @override
  State<AddChildStep1Parent> createState() => _AddChildStep1ParentState();
}

class _AddChildStep1ParentState extends State<AddChildStep1Parent> {
  bool manualEntry = false;
  Map<String, dynamic>? selectedMother;

  bool mothersLoaded = false;
  List<Map<String, dynamic>> mothers = [];

  // ================= NON-REGISTERED MOTHER CONTROLLERS =================
  final motherFirstNameCtrl = TextEditingController();
  final motherLastNameCtrl = TextEditingController();
  final motherMiddleNameCtrl = TextEditingController();
  final motherExtensionCtrl = TextEditingController();
  final motherPhoneCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchMothers();
  }

  Future<void> fetchMothers() async {
    try {
      final token = await AuthStorage.getToken(); // 👈 REQUIRED

      final res = await http.get(
        Uri.parse(
          'https://inaagapay.alwaysdata.net/api/midwife/search_mothers.php',
        ),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      final decoded = jsonDecode(res.body);

      if (decoded['success'] == true) {
        setState(() {
          mothers = List<Map<String, dynamic>>.from(decoded['data']);
          mothersLoaded = true;
        });
      } else {
        // API responded but denied
        setState(() => mothersLoaded = true);
      }
    } catch (e) {
      // Network / parsing error
      setState(() => mothersLoaded = true);
    }
  }

  @override
  void dispose() {
    motherFirstNameCtrl.dispose();
    motherLastNameCtrl.dispose();
    motherMiddleNameCtrl.dispose();
    motherExtensionCtrl.dispose();
    motherPhoneCtrl.dispose();
    super.dispose();
  }

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
            const SizedBox(height: 16),

            // ================= REGISTERED MOTHER =================
            if (!manualEntry) ...[
              if (!mothersLoaded)
                const Center(child: CircularProgressIndicator())
              else
                Autocomplete<Map<String, dynamic>>(
                  displayStringForOption: (o) => o['name'],
                  optionsBuilder: (value) {
                    if (value.text.isEmpty) return mothers;
                    return mothers.where(
                      (m) => m['name']
                          .toLowerCase()
                          .contains(value.text.toLowerCase()),
                    );
                  },
                  onSelected: (mother) {
                    setState(() => selectedMother = mother);
                  },
                  fieldViewBuilder:
                      (context, controller, focusNode, _) {
                    return TextField(
                      controller: controller,
                      focusNode: focusNode,
                      decoration: const InputDecoration(
                        hintText: 'Search Mother',
                        prefixIcon: Icon(Icons.search),
                      ),
                    );
                  },
                ),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: selectedMother == null
                    ? null
                    : () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AddChildStep3Child(
                              motherId: selectedMother!['mother_id'],
                              isExistingMother: true,
                            ),
                          ),
                        );
                      },
                child: const Text('Next'),
              ),

              TextButton(
                onPressed: () {
                  setState(() {
                    manualEntry = true;
                    selectedMother = null;
                  });
                },
                child: const Text('Mother not registered'),
              ),
            ]

            // ================= NON-REGISTERED MOTHER =================
            else ...[
              TextFormField(
                controller: motherFirstNameCtrl,
                decoration:
                    const InputDecoration(labelText: 'Mother First Name'),
              ),
              TextFormField(
                controller: motherLastNameCtrl,
                decoration:
                    const InputDecoration(labelText: 'Mother Last Name'),
              ),
              TextFormField(
                controller: motherMiddleNameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Mother Middle Name (Optional)',
                ),
              ),
              TextFormField(
                controller: motherExtensionCtrl,
                decoration: const InputDecoration(
                  labelText: 'Mother Extension Name (Optional)',
                ),
              ),
              TextFormField(
                controller: motherPhoneCtrl,
                decoration:
                    const InputDecoration(labelText: 'Phone Number'),
              ),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AddChildStep2(
                        motherFirstName:
                            motherFirstNameCtrl.text.trim(),
                        motherLastName:
                            motherLastNameCtrl.text.trim(),
                        motherMiddleName:
                            motherMiddleNameCtrl.text.trim(),
                        motherExtension:
                            motherExtensionCtrl.text.trim(),
                        motherPhone:
                            motherPhoneCtrl.text.trim(),
                      ),
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
