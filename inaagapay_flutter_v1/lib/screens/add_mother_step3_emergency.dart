import 'package:flutter/material.dart';
import '../models/add_mother_form_data.dart';

class AddMotherStep3Emergency extends StatelessWidget {
  final AddMotherFormData form;
  final VoidCallback onNext;
  final VoidCallback onBack;

  const AddMotherStep3Emergency({
    super.key,
    required this.form,
    required this.onNext,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Step 3 – Emergency Contact',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),

        TextField(
          decoration: const InputDecoration(labelText: 'First Name'),
          onChanged: (v) => form.ecFirstName = v,
        ),
        TextField(
          decoration: const InputDecoration(labelText: 'Middle Name'),
          onChanged: (v) => form.ecMiddleName = v,
        ),
        TextField(
          decoration: const InputDecoration(labelText: 'Last Name'),
          onChanged: (v) => form.ecLastName = v,
        ),
        TextField(
          decoration: const InputDecoration(labelText: 'Extension Name'),
          onChanged: (v) => form.ecExtension = v,
        ),
        TextField(
          decoration: const InputDecoration(labelText: 'Phone Number'),
          onChanged: (v) => form.ecPhone = v,
        ),
        TextField(
          decoration: const InputDecoration(labelText: 'Email Address'),
          onChanged: (v) => form.ecEmail = v,
        ),

        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            OutlinedButton(onPressed: onBack, child: const Text('Back')),
            ElevatedButton(onPressed: onNext, child: const Text('Next')),
          ],
        ),
      ],
    );
  }
}
