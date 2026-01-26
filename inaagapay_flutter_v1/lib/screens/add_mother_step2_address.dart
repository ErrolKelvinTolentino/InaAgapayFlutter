import 'package:flutter/material.dart';
import '../models/add_mother_form_data.dart';

class AddMotherStep2Address extends StatelessWidget {
  final AddMotherFormData form;
  final VoidCallback onNext;
  final VoidCallback onBack;

  const AddMotherStep2Address({
    super.key,
    required this.form,
    required this.onNext,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          decoration: const InputDecoration(labelText: 'House Number'),
          onChanged: (v) => form.houseNumber = v,
        ),
        TextField(
          decoration: const InputDecoration(labelText: 'Street'),
          onChanged: (v) => form.street = v,
        ),
        TextField(
          decoration: const InputDecoration(labelText: 'Barangay'),
          onChanged: (v) => form.barangay = v,
        ),
        TextField(
          decoration: const InputDecoration(labelText: 'City / Municipality'),
          onChanged: (v) => form.city = v,
        ),
        TextField(
          decoration: const InputDecoration(labelText: 'Province'),
          onChanged: (v) => form.province = v,
        ),
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
