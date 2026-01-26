import 'package:flutter/material.dart';
import '../models/add_mother_form_data.dart';

class AddMotherStep1Personal extends StatefulWidget {
  final AddMotherFormData form;
  final VoidCallback onNext;

  const AddMotherStep1Personal({
    super.key,
    required this.form,
    required this.onNext,
  });

  @override
  State<AddMotherStep1Personal> createState() => _AddMotherStep1PersonalState();
}

class _AddMotherStep1PersonalState extends State<AddMotherStep1Personal> {
  late final TextEditingController _firstName;
  late final TextEditingController _middleName;
  late final TextEditingController _lastName;
  late final TextEditingController _extensionName;
  late final TextEditingController _email;
  late final TextEditingController _phone;
  late final TextEditingController _birthdate;

  @override
  void initState() {
    super.initState();
    _firstName = TextEditingController(text: widget.form.firstName ?? '');
    _middleName = TextEditingController(text: widget.form.middleName ?? '');
    _lastName = TextEditingController(text: widget.form.lastName ?? '');
    _extensionName = TextEditingController(
      text: widget.form.extensionName ?? '',
    );
    _email = TextEditingController(text: widget.form.email ?? '');
    _phone = TextEditingController(text: widget.form.phone ?? '');
    _birthdate = TextEditingController(
      text: widget.form.birthdate != null
          ? widget.form.birthdate!.toIso8601String().split('T').first
          : '',
    );
  }

  @override
  void dispose() {
    _firstName.dispose();
    _middleName.dispose();
    _lastName.dispose();
    _extensionName.dispose();
    _email.dispose();
    _phone.dispose();
    _birthdate.dispose();
    super.dispose();
  }

  Future<void> _pickBirthdate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate:
          widget.form.birthdate ?? DateTime(now.year - 20, now.month, now.day),
      firstDate: DateTime(now.year - 60),
      lastDate: now,
    );
    if (picked != null) {
      setState(() {
        widget.form.birthdate = picked;
        _birthdate.text = picked.toIso8601String().split('T').first;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final age = widget.form.ageInYears();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _firstName,
          decoration: const InputDecoration(labelText: 'First Name *'),
          onChanged: (v) => widget.form.firstName = v,
        ),
        TextField(
          controller: _middleName,
          decoration: const InputDecoration(labelText: 'Middle Name'),
          onChanged: (v) => widget.form.middleName = v,
        ),
        TextField(
          controller: _lastName,
          decoration: const InputDecoration(labelText: 'Last Name *'),
          onChanged: (v) => widget.form.lastName = v,
        ),
        TextField(
          controller: _extensionName,
          decoration: const InputDecoration(labelText: 'Extension Name'),
          onChanged: (v) => widget.form.extensionName = v,
        ),
        TextField(
          controller: _birthdate,
          decoration: InputDecoration(
            labelText: 'Birthdate * (YYYY-MM-DD)',
            suffixIcon: IconButton(
              icon: const Icon(Icons.calendar_today_outlined),
              onPressed: _pickBirthdate,
            ),
          ),
          readOnly: true,
          onTap: _pickBirthdate,
        ),
        if (age != null)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text('Age: $age years old'),
          ),
        TextField(
          controller: _email,
          decoration: const InputDecoration(labelText: 'Email'),
          onChanged: (v) => widget.form.email = v,
        ),
        TextField(
          controller: _phone,
          decoration: const InputDecoration(labelText: 'Phone Number *'),
          keyboardType: TextInputType.phone,
          onChanged: (v) => widget.form.phone = v,
        ),
        const SizedBox(height: 20),
        ElevatedButton(onPressed: widget.onNext, child: const Text('Next')),
      ],
    );
  }
}
