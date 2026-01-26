import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../services/auth_storage.dart';
import 'midwife_children_page.dart';

class AddChildStep4Birth extends StatefulWidget {
  final int motherId;

  // 🔥 CHILD DATA FROM STEP 3
  final String firstName;
  final String lastName;
  final String middleName;
  final String extensionName;
  final String sex;

  const AddChildStep4Birth({
    super.key,
    required this.motherId,
    required this.firstName,
    required this.lastName,
    required this.middleName,
    required this.extensionName,
    required this.sex,
  });

  @override
  State<AddChildStep4Birth> createState() =>
      _AddChildStep4BirthState();
}

class _AddChildStep4BirthState extends State<AddChildStep4Birth> {
  final _formKey = GlobalKey<FormState>();
  bool isSaving = false;

  final birthdateCtrl = TextEditingController();
  final birthWeightCtrl = TextEditingController();
  final birthLengthCtrl = TextEditingController();
  final headCtrl = TextEditingController();
  final provinceCtrl = TextEditingController();
  final cityCtrl = TextEditingController();
  final complicationsCtrl = TextEditingController();

  DateTime? selectedBirthdate;

  Future<void> _pickBirthdate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        selectedBirthdate = picked;
        birthdateCtrl.text =
            "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isSaving = true);

    final token = await AuthStorage.getToken();

    final payload = {
      "mother_id": widget.motherId,
      "child": {
        "first_name": widget.firstName,
        "last_name": widget.lastName,
        "middle_name": widget.middleName,
        "extension_name": widget.extensionName,
        "sex": widget.sex
      },
      "birth": {
        "birthdate": birthdateCtrl.text,
        "birth_weight": double.parse(birthWeightCtrl.text),
        "birth_length": double.parse(birthLengthCtrl.text),
        "head_circumference":
            headCtrl.text.isEmpty ? null : double.parse(headCtrl.text),
        "birthplace_city_municipality": cityCtrl.text,
        "birthplace_province": provinceCtrl.text,
        "birth_complications": complicationsCtrl.text
      }
    };

    final res = await http.post(
      Uri.parse(
        'https://inaagapay.alwaysdata.net/api/midwife/add_child.php',
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
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => const MidwifeChildrenPage(),
        ),
        (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(decoded['message'] ?? 'Failed')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Birth Information')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: birthdateCtrl,
                readOnly: true,
                onTap: _pickBirthdate,
                decoration: const InputDecoration(
                  labelText: 'Birthdate',
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Required' : null,
              ),

              TextFormField(
                controller: birthWeightCtrl,
                decoration:
                    const InputDecoration(labelText: 'Birth Weight (kg)'),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Required' : null,
              ),

              TextFormField(
                controller: birthLengthCtrl,
                decoration:
                    const InputDecoration(labelText: 'Birth Length (cm)'),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Required' : null,
              ),

              TextFormField(
                controller: headCtrl,
                decoration: const InputDecoration(
                    labelText: 'Head Circumference (cm)'),
              ),

              TextFormField(
                controller: provinceCtrl,
                decoration:
                    const InputDecoration(labelText: 'Birthplace Province'),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Required' : null,
              ),

              TextFormField(
                controller: cityCtrl,
                decoration: const InputDecoration(
                    labelText: 'Birthplace City / Municipality'),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Required' : null,
              ),

              TextFormField(
                controller: complicationsCtrl,
                maxLines: 3,
                decoration:
                    const InputDecoration(labelText: 'Birth Complications'),
              ),

              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: isSaving ? null : _submit,
                child: isSaving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Add Child'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
