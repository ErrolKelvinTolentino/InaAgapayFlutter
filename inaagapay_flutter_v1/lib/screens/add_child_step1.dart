import 'package:flutter/material.dart';
import 'add_child_step2.dart';

class AddChildStep1 extends StatefulWidget {
  const AddChildStep1({super.key});

  @override
  State<AddChildStep1> createState() => _AddChildStep1State();
}

class _AddChildStep1State extends State<AddChildStep1> {
  final _formKey = GlobalKey<FormState>();

  String? selectedMother;
  String gender = 'male';

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
                'Basic Information',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              DropdownButtonFormField(
                decoration: const InputDecoration(
                  labelText: 'Select Mother / Patient *',
                ),
                items: const [
                  DropdownMenuItem(value: '1', child: Text('Sample Mother')),
                ],
                onChanged: (v) => selectedMother = v.toString(),
              ),

              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.upload),
                label: const Text('Upload Birth Certificate'),
              ),

              const SizedBox(height: 12),
              TextFormField(decoration: const InputDecoration(labelText: 'First Name *')),
              TextFormField(decoration: const InputDecoration(labelText: 'Last Name *')),
              TextFormField(decoration: const InputDecoration(labelText: 'Middle Name')),
              TextFormField(decoration: const InputDecoration(labelText: 'Extension Name')),

              const SizedBox(height: 12),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Birthdate *'),
                readOnly: true,
              ),

              DropdownButtonFormField(
                value: gender,
                decoration: const InputDecoration(labelText: 'Gender *'),
                items: const [
                  DropdownMenuItem(value: 'male', child: Text('Male')),
                  DropdownMenuItem(value: 'female', child: Text('Female')),
                ],
                onChanged: (v) => gender = v.toString(),
              ),

              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AddChildStep2()),
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
