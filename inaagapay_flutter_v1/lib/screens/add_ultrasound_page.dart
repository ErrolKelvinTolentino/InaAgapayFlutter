import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../services/auth_storage.dart';
import '../theme/app_colors.dart';
import '../widgets/app_input_field.dart';
import '../widgets/progressive_step_indicator.dart';

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
  bool _submitting = false;
  int _step = 0;
  static const int _totalSteps = 3;

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

  @override
  void dispose() {
    _locationCtrl.dispose();
    _remarksCtrl.dispose();
    _workerNameCtrl.dispose();
    _institutionCtrl.dispose();
    _professionCtrl.dispose();
    super.dispose();
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
    setState(() => _submitting = true);

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

    if (!mounted) return;
    if (decoded['success'] == true) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(decoded['message'] ?? 'Save failed')),
      );
    }
    setState(() => _submitting = false);
  }

  bool _validateStep() {
    String? message;
    switch (_step) {
      case 0:
        if (_date == null) {
          message = 'Ultrasound date is required.';
        }
        break;
    }
    if (message != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
      return false;
    }
    return true;
  }

  void _next() {
    if (!_validateStep()) return;
    if (_step < _totalSteps - 1) {
      setState(() => _step++);
    }
  }

  void _back() {
    if (_step > 0) setState(() => _step--);
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      initialDate: _date ?? DateTime.now(),
    );
    if (picked != null) {
      setState(() => _date = picked);
    }
  }

  Widget _controls({bool showSubmit = false}) {
    return Row(
      children: [
        if (_step > 0)
          OutlinedButton(
            onPressed: _submitting ? null : _back,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.brandAccent,
            ),
            child: const Text('Back'),
          ),
        const Spacer(),
        if (showSubmit)
          ElevatedButton.icon(
            onPressed: _submitting ? null : _submit,
            icon: _submitting
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.check),
            label: Text(_submitting ? 'Saving...' : 'Save & Finish'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.brandPrimary,
              foregroundColor: Colors.white,
              minimumSize: const Size(200, 48),
            ),
          )
        else
          ElevatedButton(
            onPressed: _submitting ? null : _next,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.brandPrimary,
              foregroundColor: Colors.white,
              minimumSize: const Size(200, 48),
            ),
            child: const Text('Next'),
          ),
      ],
    );
  }

  Widget _stepContent() {
    switch (_step) {
      case 0:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                _date == null
                    ? 'Select Ultrasound Date'
                    : DateFormat('MMMM d, yyyy').format(_date!),
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: _pickDate,
            ),
            const SizedBox(height: 12),
            AppInputField(hintText: 'Location', controller: _locationCtrl),
            const SizedBox(height: 20),
            _controls(),
          ],
        );
      case 1:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppInputField(
              hintText: 'Health Worker',
              controller: _workerNameCtrl,
            ),
            const SizedBox(height: 12),
            AppInputField(
              hintText: 'Institution',
              controller: _institutionCtrl,
            ),
            const SizedBox(height: 12),
            AppInputField(hintText: 'Profession', controller: _professionCtrl),
            const SizedBox(height: 20),
            _controls(),
          ],
        );
      default:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _remarksCtrl,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Remarks (optional)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            _infoChip(
              'Date',
              _date == null ? '—' : DateFormat('yyyy-MM-dd').format(_date!),
            ),
            const SizedBox(height: 20),
            _controls(showSubmit: true),
          ],
        );
    }
  }

  Widget _infoChip(String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.bgSecondary,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.borderPrimary),
          ),
          child: Text('$label: $value'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_pregnancyId == null) {
      return const Scaffold(
        body: Center(child: Text('No active pregnancy found')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        title: Text('Ultrasound (${_step + 1} of $_totalSteps)'),
        backgroundColor: AppColors.bgPrimary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ProgressiveStepIndicator(
              currentStep: _step,
              totalSteps: _totalSteps,
            ),
            const SizedBox(height: 12),
            Text(
              [
                'Ultrasound Details',
                'Health Worker',
                'Remarks & Summary',
              ][_step],
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.brandText,
              ),
            ),
            const SizedBox(height: 16),
            _stepContent(),
          ],
        ),
      ),
    );
  }
}
