import 'package:flutter/material.dart';
import '../models/add_mother_form_data.dart';

class AddMotherStep3Emergency extends StatefulWidget {
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
  State<AddMotherStep3Emergency> createState() =>
      _AddMotherStep3EmergencyState();
}

class _AddMotherStep3EmergencyState extends State<AddMotherStep3Emergency> {
  bool skip = false;

  void _handleSkip(bool value) {
    setState(() {
      skip = value;
      if (skip) {
        widget.form.ecFirstName = null;
        widget.form.ecMiddleName = null;
        widget.form.ecLastName = null;
        widget.form.ecExtension = null;
        widget.form.ecPhone = null;
        widget.form.ecEmail = null;
        widget.form.ecAffiliation = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Step 3 – Emergency Contact',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        CheckboxListTile(
          value: skip,
          onChanged: (v) => _handleSkip(v ?? false),
          title: const Text('Skip for now (no emergency contact)'),
          contentPadding: EdgeInsets.zero,
        ),
        if (!skip) ...[
          TextField(
            decoration: const InputDecoration(labelText: 'First Name *'),
            onChanged: (v) => widget.form.ecFirstName = v,
          ),
          TextField(
            decoration: const InputDecoration(labelText: 'Middle Name'),
            onChanged: (v) => widget.form.ecMiddleName = v,
          ),
          TextField(
            decoration: const InputDecoration(labelText: 'Last Name *'),
            onChanged: (v) => widget.form.ecLastName = v,
          ),
          TextField(
            decoration: const InputDecoration(labelText: 'Extension Name'),
            onChanged: (v) => widget.form.ecExtension = v,
          ),
          TextField(
            decoration: const InputDecoration(labelText: 'Affiliation'),
            onChanged: (v) => widget.form.ecAffiliation = v,
          ),
          TextField(
            decoration: const InputDecoration(labelText: 'Phone Number *'),
            keyboardType: TextInputType.phone,
            onChanged: (v) => widget.form.ecPhone = v,
          ),
          TextField(
            decoration: const InputDecoration(labelText: 'Email Address'),
            onChanged: (v) => widget.form.ecEmail = v,
          ),
          const SizedBox(height: 8),
          const Text('Contact Address (optional)'),
          TextField(
            decoration: const InputDecoration(labelText: 'House Number'),
            onChanged: (v) => widget.form.ecHouseNumber = v,
          ),
          TextField(
            decoration: const InputDecoration(labelText: 'Street'),
            onChanged: (v) => widget.form.ecStreet = v,
          ),
          TextField(
            decoration: const InputDecoration(labelText: 'Barangay'),
            onChanged: (v) => widget.form.ecBarangay = v,
          ),
          TextField(
            decoration: const InputDecoration(labelText: 'City / Municipality'),
            onChanged: (v) => widget.form.ecCityMunicipality = v,
          ),
          TextField(
            decoration: const InputDecoration(labelText: 'Province'),
            onChanged: (v) => widget.form.ecProvince = v,
          ),
        ],

        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            OutlinedButton(onPressed: widget.onBack, child: const Text('Back')),
            ElevatedButton(onPressed: widget.onNext, child: const Text('Next')),
          ],
        ),
      ],
    );
  }
}
