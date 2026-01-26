import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../services/auth_storage.dart';
import 'add_child_step3.dart';

class AddChildStep2 extends StatefulWidget {
  // ================= FROM STEP 1 =================
  final String motherFirstName;
  final String motherLastName;
  final String motherMiddleName;
  final String motherExtension;
  final String motherPhone;

  const AddChildStep2({
    super.key,
    required this.motherFirstName,
    required this.motherLastName,
    required this.motherMiddleName,
    required this.motherExtension,
    required this.motherPhone,
  });

  @override
  State<AddChildStep2> createState() => _AddChildStep2State();
}

class _AddChildStep2State extends State<AddChildStep2> {
  final _formKey = GlobalKey<FormState>();

  // ================= ADDRESS CONTROLLERS =================
  final houseCtrl = TextEditingController();
  final streetCtrl = TextEditingController();
  final barangayCtrl = TextEditingController();
  final cityCtrl = TextEditingController();
  final provinceCtrl = TextEditingController();

  bool isSaving = false;

  @override
  void dispose() {
    houseCtrl.dispose();
    streetCtrl.dispose();
    barangayCtrl.dispose();
    cityCtrl.dispose();
    provinceCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isSaving = true);

    final token = await AuthStorage.getToken();

    // 🔥🔥🔥 FIXED PAYLOAD (MATCHES add_mother.php EXACTLY) 🔥🔥🔥
    final payload = {
      "account": {
        "first_name": widget.motherFirstName,
        "middle_name": widget.motherMiddleName,
        "last_name": widget.motherLastName,
        "extension_name": widget.motherExtension,
        "phone_number": widget.motherPhone,
        // backend auto-generates if null
        "email_address": null,
      },
      "address": {
        "house_number": houseCtrl.text.trim(),
        "street": streetCtrl.text.trim(),
        "barangay": barangayCtrl.text.trim(),
        "city_municipality": cityCtrl.text.trim(),
        "province": provinceCtrl.text.trim(),
      }
    };

    final res = await http.post(
      Uri.parse(
        'https://inaagapay.alwaysdata.net/api/midwife/add_mother.php',
      ),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(payload),
    );

    final decoded = jsonDecode(res.body);
    setState(() => isSaving = false);

    if (decoded['success'] == true) {
      final int motherId = decoded['mother_id'];

      // ✅ PROCEED TO CHILD STEP 3 WITH REAL mother_id
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AddChildStep3Child(
            motherId: motherId,
            isExistingMother: false,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(decoded['message'] ?? 'Failed to add mother'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Child')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const Text(
                'Mother Address Information',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: houseCtrl,
                decoration:
                    const InputDecoration(labelText: 'House Number'),
              ),
              TextFormField(
                controller: streetCtrl,
                decoration: const InputDecoration(labelText: 'Street'),
              ),
              TextFormField(
                controller: barangayCtrl,
                decoration:
                    const InputDecoration(labelText: 'Barangay'),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: cityCtrl,
                decoration:
                    const InputDecoration(labelText: 'City / Municipality'),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: provinceCtrl,
                decoration:
                    const InputDecoration(labelText: 'Province'),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Required' : null,
              ),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: isSaving ? null : _submit,
                child: isSaving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Next'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
