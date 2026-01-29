import 'package:flutter/material.dart';
import '../models/add_mother_form_data.dart';

class AddMotherStep4Medical extends StatefulWidget {
  final AddMotherFormData form;
  final VoidCallback onNext;
  final VoidCallback onBack;

  const AddMotherStep4Medical({
    super.key,
    required this.form,
    required this.onNext,
    required this.onBack,
  });

  @override
  State<AddMotherStep4Medical> createState() => _AddMotherStep4MedicalState();
}

class _AddMotherStep4MedicalState extends State<AddMotherStep4Medical> {
  final List<String> conditions = [
    'Anemia',
    'Diabetes',
    'Hypertension',
    'Asthma',
    'Smoking',
    'Alcohol',
    'Domestic Violence',
    'Other',
  ];

  Future<void> _openConditionModal(String initialName) async {
    final nameController = TextEditingController(text: initialName);
    final dateController = TextEditingController();
    String status = 'active';
    final remarksController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Medical Condition'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Condition'),
                  readOnly: initialName.toLowerCase() != 'other',
                ),
                TextField(
                  controller: dateController,
                  decoration: const InputDecoration(
                    labelText: 'Diagnosis Date (YYYY-MM-DD)',
                  ),
                ),
                DropdownButtonFormField<String>(
                  value: status,
                  items: const [
                    DropdownMenuItem(value: 'active', child: Text('Active')),
                    DropdownMenuItem(
                      value: 'resolved',
                      child: Text('Resolved'),
                    ),
                  ],
                  onChanged: (v) => status = v ?? 'active',
                  decoration: const InputDecoration(labelText: 'Status'),
                ),
                TextField(
                  controller: remarksController,
                  decoration: const InputDecoration(labelText: 'Remarks'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: nameController.text.trim().isEmpty
                  ? null
                  : () => Navigator.pop(context, true),
              child: const Text('Done'),
            ),
          ],
        );
      },
    );

    if (result == true) {
      final entry = MedicalConditionInput(
        conditionName: nameController.text.trim(),
        diagnosisDate: dateController.text.isEmpty
            ? null
            : DateTime.tryParse(dateController.text),
        status: status,
        remarks: remarksController.text.isEmpty ? null : remarksController.text,
      );

      setState(() {
        // replace existing condition with same name
        widget.form.medicalConditions.removeWhere(
          (c) =>
              c.conditionName.toLowerCase() ==
              entry.conditionName.toLowerCase(),
        );
        widget.form.medicalConditions.add(entry);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: conditions
              .map(
                (c) => ChoiceChip(
                  label: Text(c),
                  selected: false,
                  onSelected: (_) => _openConditionModal(c),
                ),
              )
              .toList(),
        ),

        const SizedBox(height: 12),
        if (widget.form.medicalConditions.isNotEmpty)
          Align(
            alignment: Alignment.centerLeft,
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
              children: widget.form.medicalConditions
                  .map(
                    (c) => InputChip(
                      label: Text(c.conditionName),
                      onDeleted: () => setState(
                        () => widget.form.medicalConditions.remove(c),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
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
