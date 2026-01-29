import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../services/auth_storage.dart';

class AddPrenatalCheckupPage extends StatefulWidget {
  const AddPrenatalCheckupPage({
    super.key,
    required this.motherId,
    required this.pregnancyId,
    this.lmp,
    this.initialWeight,
  });

  final int motherId;
  final int pregnancyId;
  final DateTime? lmp;
  final double? initialWeight;

  @override
  State<AddPrenatalCheckupPage> createState() => _AddPrenatalCheckupPageState();
}

class _AddPrenatalCheckupPageState extends State<AddPrenatalCheckupPage> {
  final TextEditingController weightCtrl = TextEditingController();
  final TextEditingController sysCtrl = TextEditingController();
  final TextEditingController diaCtrl = TextEditingController();
  final TextEditingController fetalHeartBeatCtrl = TextEditingController();
  final TextEditingController fetalHeartToneCtrl = TextEditingController();
  final TextEditingController remarksCtrl = TextEditingController();
  final TextEditingController nextScheduleCtrl = TextEditingController();

  String fetalPosition = 'unknown';
  String edema = 'none';

  final List<Map<String, String>> medications = [];
  final List<Map<String, String>> givenMeds = [];

  @override
  void initState() {
    super.initState();
    if (widget.initialWeight != null) {
      weightCtrl.text = widget.initialWeight!.toString();
    }
  }

  double? _aogWeeks() {
    if (widget.lmp == null) return null;
    final days = DateTime.now().difference(widget.lmp!).inDays;
    return days / 7.0;
  }

  Future<void> _addMedicationDialog() async {
    final nameCtrl = TextEditingController();
    final qtyCtrl = TextEditingController();
    final freqCtrl = TextEditingController();
    final startCtrl = TextEditingController();
    final endCtrl = TextEditingController();

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add Medication'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Medication *'),
              ),
              TextField(
                controller: qtyCtrl,
                decoration: const InputDecoration(labelText: 'Quantity'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: freqCtrl,
                decoration: const InputDecoration(labelText: 'Frequency'),
              ),
              TextField(
                controller: startCtrl,
                decoration: const InputDecoration(
                  labelText: 'Start date (YYYY-MM-DD)',
                ),
              ),
              TextField(
                controller: endCtrl,
                decoration: const InputDecoration(
                  labelText: 'End date (YYYY-MM-DD)',
                ),
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
            onPressed: nameCtrl.text.trim().isEmpty
                ? null
                : () => Navigator.pop(context, true),
            child: const Text('Add'),
          ),
        ],
      ),
    );

    if (ok == true) {
      setState(() {
        medications.add({
          'name': nameCtrl.text.trim(),
          'quantity': qtyCtrl.text.trim(),
          'frequency': freqCtrl.text.trim(),
          'start_date': startCtrl.text.trim(),
          'end_date': endCtrl.text.trim(),
        });
      });
    }
  }

  Future<void> _addGivenMedicationDialog() async {
    final nameCtrl = TextEditingController();
    final qtyCtrl = TextEditingController();

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Give Medication'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Medication *'),
            ),
            TextField(
              controller: qtyCtrl,
              decoration: const InputDecoration(labelText: 'Quantity'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: nameCtrl.text.trim().isEmpty
                ? null
                : () => Navigator.pop(context, true),
            child: const Text('Add'),
          ),
        ],
      ),
    );

    if (ok == true) {
      setState(() {
        givenMeds.add({
          'name': nameCtrl.text.trim(),
          'quantity': qtyCtrl.text.trim(),
        });
      });
    }
  }

  Future<void> _submit() async {
    final token = await AuthStorage.getToken();
    if (token == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Not authenticated')));
      return;
    }

    final aog = _aogWeeks();
    final payload = {
      'pregnancy_id': widget.pregnancyId,
      'age_of_gestation': aog,
      'checkup_weight': double.tryParse(weightCtrl.text),
      'blood_pressure_systolic': int.tryParse(sysCtrl.text),
      'blood_pressure_diastolic': int.tryParse(diaCtrl.text),
      'fetal_position': fetalPosition,
      'fetal_heart_beat': int.tryParse(fetalHeartBeatCtrl.text),
      'fetal_heart_tone': fetalHeartToneCtrl.text.trim().isEmpty
          ? null
          : fetalHeartToneCtrl.text.trim(),
      'edema': edema,
      'remarks': remarksCtrl.text.trim().isEmpty
          ? null
          : remarksCtrl.text.trim(),
      'next_schedule': nextScheduleCtrl.text.trim().isEmpty
          ? null
          : nextScheduleCtrl.text.trim(),
      'medications': medications
          .map(
            (m) => {
              'name': m['name'],
              'quantity': int.tryParse(m['quantity'] ?? ''),
              'frequency': m['frequency'],
              'start_date': m['start_date']?.isEmpty == true
                  ? null
                  : m['start_date'],
              'end_date': m['end_date']?.isEmpty == true ? null : m['end_date'],
            },
          )
          .toList(),
      'given_medications': givenMeds
          .map(
            (g) => {
              'name': g['name'],
              'quantity': int.tryParse(g['quantity'] ?? ''),
            },
          )
          .toList(),
      'update_mother_weight': true,
    };

    final res = await http.post(
      Uri.parse(
        'https://inaagapay.alwaysdata.net/api/midwife/add_prenatal_checkup.php',
      ),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(payload),
    );

    final body = res.body.trim();
    if (!body.startsWith('{')) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Server error. Please try again.')),
      );
      return;
    }
    final decoded = jsonDecode(body);
    if (decoded['success'] == true) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Prenatal checkup saved')));
      Navigator.pop(context, true);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(decoded['message'] ?? 'Failed to save')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final aog = _aogWeeks();

    return Scaffold(
      appBar: AppBar(title: const Text('First Prenatal Checkup')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (aog != null)
              Text('Age of gestation: ${aog.toStringAsFixed(1)} weeks'),
            const SizedBox(height: 12),
            TextField(
              controller: weightCtrl,
              decoration: const InputDecoration(labelText: 'Weight (kg)'),
              keyboardType: TextInputType.number,
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: sysCtrl,
                    decoration: const InputDecoration(labelText: 'BP Systolic'),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: diaCtrl,
                    decoration: const InputDecoration(
                      labelText: 'BP Diastolic',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: fetalPosition,
              decoration: const InputDecoration(labelText: 'Fetal position'),
              items: const [
                DropdownMenuItem(value: 'unknown', child: Text('Unknown')),
                DropdownMenuItem(value: 'vertex', child: Text('Vertex')),
                DropdownMenuItem(value: 'breech', child: Text('Breech')),
                DropdownMenuItem(
                  value: 'transverse',
                  child: Text('Transverse'),
                ),
              ],
              onChanged: (v) => setState(() => fetalPosition = v ?? 'unknown'),
            ),
            TextField(
              controller: fetalHeartBeatCtrl,
              decoration: const InputDecoration(labelText: 'Fetal heartbeat'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: fetalHeartToneCtrl,
              decoration: const InputDecoration(labelText: 'Fetal heart tone'),
            ),
            DropdownButtonFormField<String>(
              value: edema,
              decoration: const InputDecoration(labelText: 'Edema'),
              items: const [
                DropdownMenuItem(value: 'none', child: Text('None')),
                DropdownMenuItem(value: 'mild', child: Text('Mild')),
                DropdownMenuItem(value: 'moderate', child: Text('Moderate')),
                DropdownMenuItem(value: 'severe', child: Text('Severe')),
              ],
              onChanged: (v) => setState(() => edema = v ?? 'none'),
            ),
            TextField(
              controller: remarksCtrl,
              decoration: const InputDecoration(labelText: 'Remarks'),
              maxLines: 3,
            ),
            TextField(
              controller: nextScheduleCtrl,
              decoration: const InputDecoration(
                labelText: 'Next schedule (YYYY-MM-DD)',
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _addMedicationDialog,
                  icon: const Icon(Icons.medication),
                  label: const Text('Add Medication'),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: _addGivenMedicationDialog,
                  icon: const Icon(Icons.local_pharmacy),
                  label: const Text('Give Medication'),
                ),
              ],
            ),
            if (medications.isNotEmpty) ...[
              const SizedBox(height: 8),
              const Text('Planned medications:'),
              ...medications.map(
                (m) => ListTile(
                  dense: true,
                  title: Text(m['name'] ?? ''),
                  subtitle: Text(
                    [
                      if ((m['quantity'] ?? '').isNotEmpty)
                        'Qty ${m['quantity']}',
                      if ((m['frequency'] ?? '').isNotEmpty) m['frequency'],
                    ].where((e) => e != null && e.isNotEmpty).join(' · '),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => setState(() => medications.remove(m)),
                  ),
                ),
              ),
            ],
            if (givenMeds.isNotEmpty) ...[
              const SizedBox(height: 8),
              const Text('Given medications:'),
              ...givenMeds.map(
                (m) => ListTile(
                  dense: true,
                  title: Text(m['name'] ?? ''),
                  subtitle: Text(
                    (m['quantity'] ?? '').isNotEmpty
                        ? 'Qty ${m['quantity']}'
                        : '',
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => setState(() => givenMeds.remove(m)),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submit,
                child: const Text('Save Checkup'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
