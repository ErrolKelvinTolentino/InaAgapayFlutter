import 'package:flutter/material.dart';
import '../models/add_mother_form_data.dart';

class AddMotherStep1Personal extends StatelessWidget {
  final AddMotherFormData form;
  final VoidCallback onNext;

  const AddMotherStep1Personal({
    super.key,
    required this.form,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          decoration: const InputDecoration(labelText: 'First Name'),
          onChanged: (v) => form.firstName = v,
        ),
        TextField(
          decoration: const InputDecoration(labelText: 'Middle Name'),
          onChanged: (v) => form.middleName = v,
        ),
        TextField(
          decoration: const InputDecoration(labelText: 'Last Name'),
          onChanged: (v) => form.lastName = v,
        ),
        TextField(
          decoration: const InputDecoration(labelText: 'Extension Name'),
          onChanged: (v) => form.extensionName = v,
        ),
        TextField(
          decoration: const InputDecoration(labelText: 'Email'),
          onChanged: (v) => form.email = v,
        ),
        TextField(
          decoration: const InputDecoration(labelText: 'Phone Number'),
          onChanged: (v) => form.phone = v,
        ),
        const SizedBox(height: 20),
        ElevatedButton(onPressed: onNext, child: const Text('Next')),
      ],
    );
  }
}
