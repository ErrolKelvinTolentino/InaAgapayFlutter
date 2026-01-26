import 'package:flutter/material.dart';
import 'add_child_step4.dart';

class AddChildStep3Child extends StatefulWidget {
  final int motherId;
  final bool isExistingMother;

  const AddChildStep3Child({
    super.key,
    required this.motherId,
    required this.isExistingMother,
  });

  @override
  State<AddChildStep3Child> createState() =>
      _AddChildStep3ChildState();
}

class _AddChildStep3ChildState extends State<AddChildStep3Child> {
  final _formKey = GlobalKey<FormState>();

  final firstNameCtrl = TextEditingController();
  final lastNameCtrl = TextEditingController();
  final middleNameCtrl = TextEditingController();
  final extensionCtrl = TextEditingController();

  String sex = 'male';

  @override
  void dispose() {
    firstNameCtrl.dispose();
    lastNameCtrl.dispose();
    middleNameCtrl.dispose();
    extensionCtrl.dispose();
    super.dispose();
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
                'Child Basic Information',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: firstNameCtrl,
                decoration:
                    const InputDecoration(labelText: 'First Name'),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Required' : null,
              ),

              TextFormField(
                controller: lastNameCtrl,
                decoration:
                    const InputDecoration(labelText: 'Last Name'),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Required' : null,
              ),

              TextFormField(
                controller: middleNameCtrl,
                decoration: const InputDecoration(
                    labelText: 'Middle Name (Optional)'),
              ),

              TextFormField(
                controller: extensionCtrl,
                decoration: const InputDecoration(
                    labelText: 'Extension Name (Optional)'),
              ),

              const SizedBox(height: 12),

              DropdownButtonFormField<String>(
                value: sex,
                decoration:
                    const InputDecoration(labelText: 'Sex'),
                items: const [
                  DropdownMenuItem(
                      value: 'male', child: Text('Male')),
                  DropdownMenuItem(
                      value: 'female', child: Text('Female')),
                ],
                onChanged: (v) => setState(() => sex = v!),
              ),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: () {
                  if (!_formKey.currentState!.validate()) return;

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AddChildStep4Birth(
                        motherId: widget.motherId,
                        firstName: firstNameCtrl.text.trim(),
                        lastName: lastNameCtrl.text.trim(),
                        middleName: middleNameCtrl.text.trim(),
                        extensionName: extensionCtrl.text.trim(),
                        sex: sex,
                      ),
                    ),
                  );
                },
                child: const Text('Next'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
