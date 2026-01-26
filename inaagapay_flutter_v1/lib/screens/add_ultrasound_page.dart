import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../services/auth_storage.dart';

class AddUltrasoundPage extends StatefulWidget {
  final int motherId;
  const AddUltrasoundPage({super.key, required this.motherId});

  @override
  State<AddUltrasoundPage> createState() => _AddUltrasoundPageState();
}

class _AddUltrasoundPageState extends State<AddUltrasoundPage> {
  DateTime? _date;
  int? _pregnancyId;
  bool _loading = true;

  final _locationCtrl = TextEditingController();
  final _remarksCtrl = TextEditingController();
  final _workerNameCtrl = TextEditingController();
  final _institutionCtrl = TextEditingController();
  final _professionCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadPregnancy();
  }

  Future<void> _loadPregnancy() async {
    final token = await AuthStorage.getToken();
    final res = await http.get(
      Uri.parse(
        'https://inaagapay.alwaysdata.net/api/midwife/get_active_pregnancy.php'
        '?mother_id=${widget.motherId}',
      ),
      headers: {'Authorization': 'Bearer $token'},
    );

    final decoded = jsonDecode(res.body);

    if (decoded['success'] == true) {
      _pregnancyId = decoded['pregnancy_id'];
    }

    setState(() => _loading = false);
  }

  Future<void> _submit() async {
    if (_pregnancyId == null || _date == null) return;

    final token = await AuthStorage.getToken();

    final res = await http.post(
      Uri.parse(
        'https://inaagapay.alwaysdata.net/api/midwife/add_ultrasound.php',
      ),
      headers: {'Authorization': 'Bearer $token'},
      body: {
        'pregnancy_id': _pregnancyId.toString(),
        'ultrasound_date': DateFormat('yyyy-MM-dd').format(_date!),
        'ultrasound_location': _locationCtrl.text,
        'remarks': _remarksCtrl.text,
        'health_worker_name': _workerNameCtrl.text,
        'health_worker_institution': _institutionCtrl.text,
        'health_worker_profession': _professionCtrl.text,
      },
    );

    final decoded = jsonDecode(res.body);

    if (decoded['success'] == true) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_pregnancyId == null) {
      return const Scaffold(
        body: Center(child: Text('No active pregnancy found')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Add Ultrasound')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ListTile(
              title: Text(
                _date == null
                    ? 'Select Ultrasound Date'
                    : DateFormat('MMMM d, yyyy').format(_date!),
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2035),
                  initialDate: DateTime.now(),
                );
                if (picked != null) {
                  setState(() => _date = picked);
                }
              },
            ),

            TextField(
              controller: _locationCtrl,
              decoration:
                  const InputDecoration(labelText: 'Location'),
            ),
            TextField(
              controller: _workerNameCtrl,
              decoration:
                  const InputDecoration(labelText: 'Health Worker'),
            ),
            TextField(
              controller: _institutionCtrl,
              decoration:
                  const InputDecoration(labelText: 'Institution'),
            ),
            TextField(
              controller: _professionCtrl,
              decoration:
                  const InputDecoration(labelText: 'Profession'),
            ),
            TextField(
              controller: _remarksCtrl,
              decoration:
                  const InputDecoration(labelText: 'Remarks'),
              maxLines: 3,
            ),

            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
                backgroundColor: Colors.pink,
              ),
              child: const Text('Save Ultrasound'),
            ),
          ],
        ),
      ),
    );
  }
}
