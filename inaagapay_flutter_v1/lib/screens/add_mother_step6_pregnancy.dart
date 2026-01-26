import 'package:flutter/material.dart';
import '../models/add_mother_form_data.dart';

class AddMotherStep6Pregnancy extends StatefulWidget {
  final AddMotherFormData form;
  final VoidCallback onNext;
  final VoidCallback onBack;

  const AddMotherStep6Pregnancy({
    super.key,
    required this.form,
    required this.onNext,
    required this.onBack,
  });

  @override
  State<AddMotherStep6Pregnancy> createState() =>
      _AddMotherStep6PregnancyState();
}

class _AddMotherStep6PregnancyState extends State<AddMotherStep6Pregnancy> {
  Future<void> _pickLmp() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: widget.form.lastMenstrualPeriod ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: now.add(const Duration(days: 14)),
    );
    if (picked != null) {
      setState(() {
        widget.form.lastMenstrualPeriod = picked;
        widget.form.expectedDateOfDelivery = picked.add(
          const Duration(days: 280),
        );
      });
    }
  }

  Widget _historyList() {
    if (!widget.form.hadPastPregnancy || widget.form.pastPregnancyCount == 0) {
      return const SizedBox.shrink();
    }

    widget.form.normalizePregnancyHistory();
    return Column(
      children: List.generate(widget.form.pastPregnancyCount, (index) {
        final item = widget.form.pastPregnancies[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pregnancy ${index + 1}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                DropdownButtonFormField<String>(
                  value: item.outcome,
                  items: const [
                    DropdownMenuItem(
                      value: 'live_birth',
                      child: Text('Live birth'),
                    ),
                    DropdownMenuItem(
                      value: 'stillbirth',
                      child: Text('Stillbirth'),
                    ),
                    DropdownMenuItem(
                      value: 'miscarriage',
                      child: Text('Miscarriage'),
                    ),
                    DropdownMenuItem(value: 'ectopic', child: Text('Ectopic')),
                    DropdownMenuItem(
                      value: 'abortion',
                      child: Text('Abortion'),
                    ),
                  ],
                  onChanged: (v) =>
                      setState(() => item.outcome = v ?? item.outcome),
                  decoration: const InputDecoration(labelText: 'Outcome *'),
                ),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Outcome Date (YYYY-MM-DD)',
                  ),
                  initialValue: item.outcomeDate
                      ?.toIso8601String()
                      .split('T')
                      .first,
                  onChanged: (v) => item.outcomeDate = DateTime.tryParse(v),
                ),
                CheckboxListTile(
                  value: item.isOutcomeDateEstimated,
                  onChanged: (v) =>
                      setState(() => item.isOutcomeDateEstimated = v ?? false),
                  title: const Text('Outcome date is estimated'),
                  contentPadding: EdgeInsets.zero,
                ),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Place of delivery',
                  ),
                  initialValue: item.placeOfDelivery,
                  onChanged: (v) => item.placeOfDelivery = v,
                ),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Delivery method',
                  ),
                  initialValue: item.deliveryMethod,
                  onChanged: (v) => item.deliveryMethod = v,
                ),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Gestational age at end (weeks)',
                  ),
                  initialValue: item.gestationalAgeAtEnd?.toString(),
                  keyboardType: TextInputType.number,
                  onChanged: (v) =>
                      item.gestationalAgeAtEnd = double.tryParse(v),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final aog = widget.form.ageOfGestationWeeks();
    final edd = widget.form.expectedDateOfDelivery;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Step 6 – Pregnancy History & Gestation',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        SwitchListTile(
          title: const Text('Undergone past pregnancy'),
          value: widget.form.hadPastPregnancy,
          onChanged: (v) => setState(() {
            widget.form.hadPastPregnancy = v;
            if (!v) {
              widget.form.pastPregnancyCount = 0;
              widget.form.pastPregnancies.clear();
            }
          }),
        ),
        if (widget.form.hadPastPregnancy) ...[
          TextFormField(
            decoration: const InputDecoration(labelText: 'How many times?'),
            keyboardType: TextInputType.number,
            initialValue: widget.form.pastPregnancyCount.toString(),
            onChanged: (v) {
              final parsed = int.tryParse(v) ?? 0;
              setState(() {
                widget.form.pastPregnancyCount = parsed;
                widget.form.normalizePregnancyHistory();
              });
            },
          ),
          _historyList(),
        ],

        const SizedBox(height: 12),
        TextFormField(
          decoration: const InputDecoration(
            labelText: 'Last Menstrual Period (LMP)',
          ),
          controller: TextEditingController(
            text:
                widget.form.lastMenstrualPeriod
                    ?.toIso8601String()
                    .split('T')
                    .first ??
                '',
          ),
          readOnly: true,
          onTap: _pickLmp,
        ),
        TextButton.icon(
          onPressed: _pickLmp,
          icon: const Icon(Icons.date_range),
          label: const Text('Pick LMP'),
        ),
        if (aog != null)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text('Age of gestation: ${aog.toStringAsFixed(1)} weeks'),
          ),
        if (edd != null)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              'Expected date of delivery (EDD): ${edd.toIso8601String().split('T').first}',
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
