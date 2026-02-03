import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../models/vaccine_model.dart';
import '../services/auth_storage.dart';
import '../services/vaccine_service.dart';

class AddImmunizationPage extends StatefulWidget {
  final int childId;

  const AddImmunizationPage({super.key, required this.childId});

  @override
  State<AddImmunizationPage> createState() => _AddImmunizationPageState();
}

class _AddImmunizationPageState extends State<AddImmunizationPage> {
  List<VaccineModel> vaccines = [];
  VaccineModel? selectedVaccine;
  DateTime? selectedDate;
  bool vaccinesLoading = true;
  Set<int> takenVaccineIds = {};
  Set<String> takenVaccineNames = {};

  final TextEditingController remarksController = TextEditingController();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadVaccines();
  }

  @override
  void dispose() {
    remarksController.dispose();
    super.dispose();
  }

  Future<void> _loadVaccines() async {
    try {
      final data = await VaccineService.fetchVaccines();
      final taken = await _fetchTakenVaccines();

      setState(() {
        vaccines = data;
        takenVaccineIds = taken.$1;
        takenVaccineNames = taken.$2;
        vaccinesLoading = false;

        if (selectedVaccine != null &&
            !_availableVaccines().contains(selectedVaccine)) {
          selectedVaccine = null;
        }
      });
    } catch (e) {
      _showSnack('Failed to load vaccines');
      setState(() => vaccinesLoading = false);
    }
  }

  Future<(Set<int>, Set<String>)> _fetchTakenVaccines() async {
    try {
      final token = await AuthStorage.getToken();
      final res = await http.get(
        Uri.parse(
          'https://inaagapay.alwaysdata.net/api/midwife/child_immunization_list.php?child_id=${widget.childId}',
        ),
        headers: {'Authorization': 'Bearer $token'},
      );

      final decoded = jsonDecode(res.body);
      final records = decoded['records'] is List ? decoded['records'] : [];

      final ids = <int>{};
      final names = <String>{};
      for (final r in records) {
        final id = int.tryParse(r['vaccine_id']?.toString() ?? '');
        if (id != null) ids.add(id);
        final name = r['vaccine_name']?.toString().trim();
        if (name != null && name.isNotEmpty) names.add(name);
      }

      return (ids, names);
    } catch (_) {
      return (<int>{}, <String>{});
    }
  }

  List<VaccineModel> _availableVaccines() {
    return vaccines.where((v) {
      final alreadyTaken =
          takenVaccineIds.contains(v.vaccineId) ||
          takenVaccineNames.contains(v.vaccineName);
      return !alreadyTaken;
    }).toList();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() => selectedDate = picked);
    }
  }

  Future<void> _submit() async {
    if (selectedVaccine == null || selectedDate == null) {
      _showSnack('Please select vaccine and date');
      return;
    }

    setState(() => isLoading = true);

    try {
      final success = await VaccineService.addImmunization(
        childId: widget.childId,
        vaccineId: selectedVaccine!.vaccineId,
        vaccinationDate: selectedDate!,
        remarks: remarksController.text,
      );

      if (success) {
        _showSnack('Immunization added successfully');
        Navigator.pop(context, true);
      } else {
        _showSnack('Failed to add immunization');
      }
    } catch (e) {
      _showSnack('Error: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final available = _availableVaccines();

    return Scaffold(
      appBar: AppBar(title: const Text('Add Immunization')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (vaccinesLoading) const LinearProgressIndicator(minHeight: 2),

            // Vaccine Dropdown
            DropdownButtonFormField<VaccineModel>(
              value: available.contains(selectedVaccine)
                  ? selectedVaccine
                  : null,
              items: available.map((v) {
                return DropdownMenuItem(
                  value: v,
                  child: Text('${v.vaccineName} (Dose ${v.doseNumber})'),
                );
              }).toList(),
              onChanged: (v) => setState(() => selectedVaccine = v),
              decoration: const InputDecoration(
                labelText: 'Select Vaccine',
                border: OutlineInputBorder(),
              ),
            ),

            if (!vaccinesLoading && available.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  'All recorded vaccines are already taken. No duplicates shown.',
                  style: TextStyle(color: Colors.black54),
                ),
              ),

            const SizedBox(height: 16),

            // Date Picker
            InkWell(
              onTap: _pickDate,
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Vaccination Date',
                  border: OutlineInputBorder(),
                ),
                child: Text(
                  selectedDate == null
                      ? 'Select date'
                      : DateFormat('yyyy-MM-dd').format(selectedDate!),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Remarks
            TextField(
              controller: remarksController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Remarks (optional)',
                border: OutlineInputBorder(),
              ),
            ),

            const Spacer(),

            // Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : _submit,
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Add Immunization'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
