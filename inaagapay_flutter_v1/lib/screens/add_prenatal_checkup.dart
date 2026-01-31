import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/add_mother_form_data.dart';
import '../services/auth_storage.dart';
import '../theme/app_colors.dart';
import '../widgets/app_input_field.dart';
import '../widgets/progressive_step_indicator.dart';
import 'mother_profile_page.dart';

class AddPrenatalCheckupScreen extends StatefulWidget {
  const AddPrenatalCheckupScreen({
    super.key,
    required this.motherId,
    required this.pregnancyId,
    this.lmp,
    this.motherWeight,
  });

  final int motherId;
  final int pregnancyId;
  final DateTime? lmp;
  final double? motherWeight;

  @override
  State<AddPrenatalCheckupScreen> createState() =>
      _AddPrenatalCheckupScreenState();
}

class _AddPrenatalCheckupScreenState extends State<AddPrenatalCheckupScreen> {
  final PrenatalCheckInput prenatal = PrenatalCheckInput();

  final TextEditingController _weight = TextEditingController();
  final TextEditingController _sys = TextEditingController();
  final TextEditingController _dia = TextEditingController();
  final TextEditingController _fetalBeat = TextEditingController();
  final TextEditingController _fetalTone = TextEditingController();
  final TextEditingController _remarks = TextEditingController();

  int step = 0;
  static const int totalSteps = 5;
  bool submitting = false;
  double? aogWeeks;

  @override
  void initState() {
    super.initState();
    _prefill();
  }

  @override
  void dispose() {
    _weight.dispose();
    _sys.dispose();
    _dia.dispose();
    _fetalBeat.dispose();
    _fetalTone.dispose();
    _remarks.dispose();
    super.dispose();
  }

  void _prefill() {
    prenatal.checkupDate = DateTime.now();
    if (widget.motherWeight != null) {
      _weight.text = widget.motherWeight!.toStringAsFixed(1);
      prenatal.checkupWeight = widget.motherWeight;
    }
    _recomputeAog();
  }

  void _recomputeAog() {
    if (widget.lmp == null) return;
    final days = DateTime.now().difference(widget.lmp!).inDays;
    final weeks = double.parse((days / 7).toStringAsFixed(1));
    setState(() {
      aogWeeks = weeks;
      prenatal.ageOfGestationWeeks = weeks;
    });
  }

  bool _validateStep() {
    String? message;
    switch (step) {
      case 0:
        if (_weight.text.trim().isEmpty) {
          message = 'Weight is required.';
        }
        break;
      case 1:
        if (_sys.text.trim().isEmpty || _dia.text.trim().isEmpty) {
          message = 'Enter blood pressure (systolic/diastolic).';
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
    if (step < totalSteps - 1) {
      setState(() => step++);
    }
  }

  void _back() {
    if (step > 0) setState(() => step--);
  }

  Future<void> _submit() async {
    if (!_validateStep()) return;
    setState(() => submitting = true);
    try {
      final token = await AuthStorage.getToken();
      if (token == null) throw Exception('Not authenticated');

      final res = await http.post(
        Uri.parse(
          'https://inaagapay.alwaysdata.net/api/midwife/add_prenatal_checkup.php',
        ),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'pregnancy_id': widget.pregnancyId,
          'prenatal_checkup': prenatal.toJson(),
        }),
      );

      final decoded = jsonDecode(res.body);
      if (decoded['success'] == true) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Prenatal checkup saved. Redirecting to profile...'),
          ),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => MotherProfilePage(motherId: widget.motherId),
          ),
        );
      } else {
        throw Exception(decoded['message'] ?? 'Save failed');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => submitting = false);
    }
  }

  Widget _buildStepContent() {
    switch (step) {
      case 0:
        return _vitalsStep();
      case 1:
        return _fetalStep();
      case 2:
        return _edemaStep();
      case 3:
        return _medicationsStep();
      default:
        return _remarksStep();
    }
  }

  Widget _vitalsStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppInputField(
          hintText: 'Weight (kg)',
          controller: _weight,
          keyboardType: TextInputType.number,
          onChanged: (v) => prenatal.checkupWeight = double.tryParse(v),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: AppInputField(
                hintText: 'Systolic',
                controller: _sys,
                keyboardType: TextInputType.number,
                onChanged: (v) =>
                    prenatal.bloodPressureSystolic = int.tryParse(v),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Text('/'),
            ),
            Expanded(
              child: AppInputField(
                hintText: 'Diastolic',
                controller: _dia,
                keyboardType: TextInputType.number,
                onChanged: (v) =>
                    prenatal.bloodPressureDiastolic = int.tryParse(v),
              ),
            ),
            const SizedBox(width: 8),
            const Text('mmHg'),
          ],
        ),
        const SizedBox(height: 12),
        _infoChip(
          'Auto age of gestation',
          aogWeeks != null
              ? '${aogWeeks!.toStringAsFixed(1)} weeks'
              : 'Set once LMP is available',
        ),
        const SizedBox(height: 20),
        _controls(),
      ],
    );
  }

  Widget _fetalStep() {
    final positions = ['unknown', 'cephalic', 'vertex', 'breech', 'transverse'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<String>(
          value: prenatal.fetalPosition,
          decoration: const InputDecoration(labelText: 'Fetal Position'),
          items: positions
              .map((p) => DropdownMenuItem(value: p, child: Text(p)))
              .toList(),
          onChanged: (v) => setState(() {
            prenatal.fetalPosition = v;
            prenatal.abnormalFetalPosition =
                v != null && v != 'cephalic' && v != 'vertex' && v != 'unknown';
          }),
        ),
        const SizedBox(height: 12),
        AppInputField(
          hintText: 'Fetal heartbeat (bpm)',
          controller: _fetalBeat,
          keyboardType: TextInputType.number,
          onChanged: (v) {
            prenatal.fetalHeartBeat = int.tryParse(v);
            final val = prenatal.fetalHeartBeat;
            prenatal.abnormalFetalHeartBeat =
                val != null && (val < 110 || val > 160);
          },
        ),
        const SizedBox(height: 12),
        AppInputField(
          hintText: 'Fetal heart tone',
          controller: _fetalTone,
          onChanged: (v) => prenatal.fetalHeartTone = v.trim(),
        ),
        const SizedBox(height: 20),
        _controls(),
      ],
    );
  }

  Widget _edemaStep() {
    const options = ['none', 'mild', 'moderate', 'severe'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.bgSecondary,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderPrimary),
          ),
          child: const Text(
            'Edema guide: none (no swelling), mild (trace on ankles), moderate (pitting), severe (generalized).',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
        const SizedBox(height: 12),
        ...options.map(
          (o) => RadioListTile<String>(
            value: o,
            groupValue: prenatal.edema,
            onChanged: (v) => setState(() => prenatal.edema = v ?? 'none'),
            title: Text(o.toUpperCase()),
          ),
        ),
        const SizedBox(height: 20),
        _controls(),
      ],
    );
  }

  Widget _medicationsStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _listHeader(
          'Medication Plans',
          onAdd: () => _addMedication(plan: true),
        ),
        if (prenatal.motherMedications.isEmpty)
          const Text(
            'No planned medications yet.',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ...prenatal.motherMedications.asMap().entries.map((entry) {
          final idx = entry.key;
          final m = entry.value;
          return ListTile(
            title: Text(m.name),
            subtitle: Text(
              [
                if (m.frequency != null) 'Freq: ${m.frequency}',
                if (m.quantity != null) 'Qty: ${m.quantity}',
                if (m.startDate != null)
                  'Start: ${m.startDate!.toLocal().toString().split(' ').first}',
              ].join(' · '),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () =>
                  setState(() => prenatal.motherMedications.removeAt(idx)),
            ),
          );
        }),
        const Divider(),
        _listHeader(
          'Given Medications',
          onAdd: () => _addMedication(plan: false),
        ),
        if (prenatal.givenMedications.isEmpty)
          const Text(
            'No medications dispensed.',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ...prenatal.givenMedications.asMap().entries.map((entry) {
          final idx = entry.key;
          final g = entry.value;
          return ListTile(
            title: Text(g.name),
            subtitle: Text(
              [
                if (g.quantity != null) 'Qty: ${g.quantity}',
                if (g.dateGiven != null)
                  'Date: ${g.dateGiven!.toLocal().toString().split(' ').first}',
              ].join(' · '),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () =>
                  setState(() => prenatal.givenMedications.removeAt(idx)),
            ),
          );
        }),
        const SizedBox(height: 20),
        _controls(),
      ],
    );
  }

  Widget _remarksStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SwitchListTile(
          title: const Text('Missed scheduled checkups?'),
          value: prenatal.missedScheduledCheckups,
          onChanged: (v) =>
              setState(() => prenatal.missedScheduledCheckups = v),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _remarks,
          maxLines: 4,
          decoration: const InputDecoration(
            labelText: 'Remarks (optional)',
            border: OutlineInputBorder(),
          ),
          onChanged: (v) => prenatal.remarks = v.trim(),
        ),
        const SizedBox(height: 12),
        _infoChip(
          'Checkup date',
          prenatal.checkupDate.toIso8601String().split('T').first,
        ),
        _infoChip(
          'Age of gestation',
          aogWeeks != null
              ? '${aogWeeks!.toStringAsFixed(1)} weeks'
              : 'Not set',
        ),
        const SizedBox(height: 20),
        _controls(showSubmit: true),
      ],
    );
  }

  Widget _controls({bool showSubmit = false}) {
    return Row(
      children: [
        if (step > 0)
          OutlinedButton(
            onPressed: submitting ? null : _back,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.brandAccent,
            ),
            child: const Text('Back'),
          ),
        const Spacer(),
        if (showSubmit)
          ElevatedButton.icon(
            onPressed: submitting ? null : _submit,
            icon: submitting
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.check),
            label: Text(submitting ? 'Saving...' : 'Save & Finish'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.brandPrimary,
              foregroundColor: Colors.white,
              minimumSize: const Size(200, 48),
            ),
          )
        else
          ElevatedButton(
            onPressed: submitting ? null : _next,
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

  Widget _listHeader(String title, {required VoidCallback onAdd}) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        TextButton.icon(
          onPressed: onAdd,
          icon: const Icon(Icons.add),
          label: const Text('Add'),
          style: TextButton.styleFrom(foregroundColor: AppColors.brandAccent),
        ),
      ],
    );
  }

  Widget _infoChip(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
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
      ),
    );
  }

  Future<void> _addMedication({required bool plan}) async {
    final name = TextEditingController();
    final qty = TextEditingController();
    final freq = TextEditingController();
    DateTime? start;
    DateTime? end;
    DateTime? givenDate;

    final saved = await showDialog<bool>(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setModalState) {
          final isValid =
              name.text.trim().isNotEmpty &&
              (plan || qty.text.trim().isNotEmpty);
          return AlertDialog(
            title: Row(
              children: [
                Text(plan ? 'Add Medication Plan' : 'Add Given Medication'),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context, false),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: name,
                    decoration: const InputDecoration(labelText: 'Name *'),
                    onChanged: (_) => setModalState(() {}),
                  ),
                  TextField(
                    controller: qty,
                    decoration: const InputDecoration(labelText: 'Quantity *'),
                    keyboardType: TextInputType.number,
                    onChanged: (_) => setModalState(() {}),
                  ),
                  if (plan) ...[
                    TextField(
                      controller: freq,
                      decoration: const InputDecoration(labelText: 'Frequency'),
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        start == null
                            ? 'Start Date'
                            : 'Start: ${start!.toIso8601String().split('T').first}',
                      ),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: start ?? DateTime.now(),
                          firstDate: DateTime(1900),
                          lastDate: DateTime.now().add(
                            const Duration(days: 365),
                          ),
                        );
                        if (picked != null) setModalState(() => start = picked);
                      },
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        end == null
                            ? 'End Date'
                            : 'End: ${end!.toIso8601String().split('T').first}',
                      ),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: end ?? DateTime.now(),
                          firstDate: DateTime(1900),
                          lastDate: DateTime.now().add(
                            const Duration(days: 365),
                          ),
                        );
                        if (picked != null) setModalState(() => end = picked);
                      },
                    ),
                  ] else
                    ...[],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: isValid ? () => Navigator.pop(context, true) : null,
                child: const Text('Done'),
              ),
            ],
          );
        },
      ),
    );

    if (saved == true && name.text.trim().isNotEmpty) {
      setState(() {
        if (plan) {
          final entry = MotherMedicationEntry(name: name.text.trim())
            ..quantity = int.tryParse(qty.text.trim())
            ..frequency = freq.text.trim().isEmpty ? null : freq.text.trim()
            ..startDate = start
            ..endDate = end;
          prenatal.motherMedications.add(entry);
        } else {
          final entry = GivenMedicationEntry(name: name.text.trim())
            ..quantity = int.tryParse(qty.text.trim())
            ..dateGiven = givenDate ?? DateTime.now();
          prenatal.givenMedications.add(entry);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        title: Text('Prenatal Checkup (${step + 1} of $totalSteps)'),
        backgroundColor: AppColors.bgPrimary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ProgressiveStepIndicator(currentStep: step, totalSteps: totalSteps),
            const SizedBox(height: 12),
            Text(
              _title(step),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.brandText,
              ),
            ),
            const SizedBox(height: 16),
            _buildStepContent(),
          ],
        ),
      ),
    );
  }

  String _title(int s) {
    const titles = [
      'Vital Statistics',
      'Fetal Information',
      'Edema',
      'Medications',
      'Remarks & Summary',
    ];
    return titles[s];
  }
}
