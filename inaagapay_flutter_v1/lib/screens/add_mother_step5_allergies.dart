import 'package:flutter/material.dart';
import '../models/add_mother_form_data.dart';

class AddMotherStep5Allergies extends StatefulWidget {
  final AddMotherFormData form;
  final VoidCallback onNext;
  final VoidCallback onBack;

  const AddMotherStep5Allergies({
    super.key,
    required this.form,
    required this.onNext,
    required this.onBack,
  });

  @override
  State<AddMotherStep5Allergies> createState() =>
      _AddMotherStep5AllergiesState();
}

class _AddMotherStep5AllergiesState extends State<AddMotherStep5Allergies> {
  Future<void> _openAllergyModal() async {
    final allergenCtrl = TextEditingController();
    final dateCtrl = TextEditingController();
    final treatmentCtrl = TextEditingController();
    final remarksCtrl = TextEditingController();
    String status = 'active';

    final result = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add Allergy'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: allergenCtrl,
                decoration: const InputDecoration(labelText: 'Allergen *'),
              ),
              TextField(
                controller: dateCtrl,
                decoration: const InputDecoration(
                  labelText: 'Diagnosis Date (YYYY-MM-DD)',
                ),
              ),
              DropdownButtonFormField<String>(
                value: status,
                items: const [
                  DropdownMenuItem(value: 'active', child: Text('Active')),
                  DropdownMenuItem(value: 'resolved', child: Text('Resolved')),
                ],
                onChanged: (v) => status = v ?? 'active',
                decoration: const InputDecoration(labelText: 'Status'),
              ),
              TextField(
                controller: treatmentCtrl,
                decoration: const InputDecoration(labelText: 'Treatment'),
              ),
              TextField(
                controller: remarksCtrl,
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
            onPressed: allergenCtrl.text.trim().isEmpty
                ? null
                : () => Navigator.pop(context, true),
            child: const Text('Done'),
          ),
        ],
      ),
    );

    if (result == true) {
      setState(() {
        widget.form.allergies.add(
          AllergyInput(
            allergen: allergenCtrl.text.trim(),
            diagnosisDate: dateCtrl.text.isEmpty
                ? null
                : DateTime.tryParse(dateCtrl.text),
            status: status,
            treatment: treatmentCtrl.text,
            remarks: remarksCtrl.text,
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Step 5 – Allergies',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: _openAllergyModal,
          icon: const Icon(Icons.add),
          label: const Text('Add Allergy'),
        ),

        const SizedBox(height: 16),
        ...widget.form.allergies.map(
          (a) => ListTile(
            title: Text(a.allergen),
            subtitle: Text(
              [
                if (a.diagnosisDate != null)
                  'Dx: ${a.diagnosisDate!.toIso8601String().split('T').first}',
                'Status: ${a.status}',
                if (a.treatment != null && a.treatment!.isNotEmpty)
                  'Tx: ${a.treatment}',
              ].join(' · '),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => setState(() => widget.form.allergies.remove(a)),
            ),
          ),
        ),

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
