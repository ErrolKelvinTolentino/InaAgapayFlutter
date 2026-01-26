import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/vaccine_model.dart';
import '../services/vaccine_service.dart';

class AddImmunizationPage extends StatefulWidget {
  final int childId;

  const AddImmunizationPage({
    super.key,
    required this.childId,
  });

  @override
  State<AddImmunizationPage> createState() => _AddImmunizationPageState();
}

class _AddImmunizationPageState extends State<AddImmunizationPage> {
  List<VaccineModel> vaccines = [];
  VaccineModel? selectedVaccine;
  DateTime? selectedDate;

  final TextEditingController remarksController = TextEditingController();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadVaccines();
  }

  Future<void> _loadVaccines() async {
    try {
      final data = await VaccineService.fetchVaccines();
      setState(() => vaccines = data);
    } catch (e) {
      _showSnack('Failed to load vaccines');
    }
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Immunization'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Vaccine Dropdown
            DropdownButtonFormField<VaccineModel>(
              value: selectedVaccine,
              items: vaccines.map((v) {
                return DropdownMenuItem(
                  value: v,
                  child: Text(
                    '${v.vaccineName} (Dose ${v.doseNumber})',
                  ),
                );
              }).toList(),
              onChanged: (v) => setState(() => selectedVaccine = v),
              decoration: const InputDecoration(
                labelText: 'Select Vaccine',
                border: OutlineInputBorder(),
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
                      : DateFormat('yyyy-MM-dd')
                          .format(selectedDate!),
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
                    ? const CircularProgressIndicator(
                        color: Colors.white,
                      )
                    : const Text('Add Immunization'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
