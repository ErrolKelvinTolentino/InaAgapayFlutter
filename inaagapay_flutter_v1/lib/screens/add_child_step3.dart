import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AddChildStep3 extends StatefulWidget {
  final Map<String, dynamic> payload;

  const AddChildStep3({
    super.key,
    required this.payload,
  });

  @override
  State<AddChildStep3> createState() => _AddChildStep3State();
}

class _AddChildStep3State extends State<AddChildStep3> {
  final _formKey = GlobalKey<FormState>();

  final firstNameCtrl = TextEditingController();
  final lastNameCtrl = TextEditingController();
  final middleNameCtrl = TextEditingController();
  final extensionNameCtrl = TextEditingController();
  final birthdateCtrl = TextEditingController();
  final birthPlaceCtrl = TextEditingController();

  String sex = 'male';
  bool isSubmitting = false;

  // ================= SUBMIT =================
  Future<void> submitChild() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isSubmitting = true);

    final payload = {
      ...widget.payload,

      // CHILD INFO
      'child_first_name': firstNameCtrl.text.trim(),
      'child_last_name': lastNameCtrl.text.trim(),
      'child_middle_name': middleNameCtrl.text.trim(),
      'child_extension_name': extensionNameCtrl.text.trim(),
      'sex': sex,

      // BIRTH DETAILS
      'birthdate': birthdateCtrl.text.trim(), // yyyy-mm-dd
      'birth_place': birthPlaceCtrl.text.trim(),
    };

    try {
      final res = await http.post(
        Uri.parse(
          'https://inaagapay.alwaysdata.net/api/midwife/add_child.php',
        ),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      final data = jsonDecode(res.body);

      if (data['success'] == true) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Child added successfully')),
        );

        // Go back to children list
        Navigator.popUntil(context, (route) => route.isFirst);
      } else {
        throw Exception(data['message'] ?? 'Failed to add child');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) setState(() => isSubmitting = false);
    }
  }

  // ================= DATE PICKER =================
  Future<void> pickBirthdate() async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      initialDate: DateTime.now(),
    );

    if (picked != null) {
      birthdateCtrl.text =
          picked.toIso8601String().split('T').first; // yyyy-mm-dd
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
                'Child Information',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: firstNameCtrl,
                decoration:
                    const InputDecoration(labelText: 'Child First Name'),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: lastNameCtrl,
                decoration:
                    const InputDecoration(labelText: 'Child Last Name'),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: middleNameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Child Middle Name (Optional)',
                ),
              ),
              TextFormField(
                controller: extensionNameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Child Extension Name (Optional)',
                ),
              ),

              const SizedBox(height: 12),

              DropdownButtonFormField<String>(
                value: sex,
                decoration: const InputDecoration(labelText: 'Sex'),
                items: const [
                  DropdownMenuItem(value: 'male', child: Text('Male')),
                  DropdownMenuItem(value: 'female', child: Text('Female')),
                ],
                onChanged: (v) => setState(() => sex = v!),
              ),

              const SizedBox(height: 12),

              TextFormField(
                controller: birthdateCtrl,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Birthdate',
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                onTap: pickBirthdate,
                validator: (v) =>
                    v == null || v.isEmpty ? 'Required' : null,
              ),

              TextFormField(
                controller: birthPlaceCtrl,
                decoration:
                    const InputDecoration(labelText: 'Place of Birth'),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Required' : null,
              ),

              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed:
                          isSubmitting ? null : () => Navigator.pop(context),
                      child: const Text('Back'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: isSubmitting ? null : submitChild,
                      child: isSubmitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Add Child'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
