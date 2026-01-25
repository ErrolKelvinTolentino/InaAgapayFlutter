import 'package:flutter/material.dart';
import '../models/vaccine_model.dart';
import '../services/vaccine_service.dart';
import '../theme/app_colors.dart';

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
  late Future<List<VaccineModel>> _vaccinesFuture;
  VaccineModel? selectedVaccine;
  DateTime? vaccinationDate;

  @override
  void initState() {
    super.initState();
    _vaccinesFuture = fetchVaccines();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Immunization')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: FutureBuilder<List<VaccineModel>>(
          future: _vaccinesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Failed to load vaccines',
                  style: TextStyle(color: Colors.red),
                ),
              );
            }

            final vaccines = snapshot.data!;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🔽 Vaccine Dropdown
                DropdownButtonFormField<VaccineModel>(
                  value: selectedVaccine,
                  items: vaccines
                      .map(
                        (v) => DropdownMenuItem(
                          value: v,
                          child: Text(v.displayLabel),
                        ),
                      )
                      .toList(),
                  onChanged: (v) {
                    setState(() => selectedVaccine = v);
                  },
                  decoration: const InputDecoration(
                    labelText: 'Vaccine',
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 16),

                // 📅 Date Picker
                ListTile(
                  title: Text(
                    vaccinationDate == null
                        ? 'Select Vaccination Date'
                        : vaccinationDate!
                            .toLocal()
                            .toString()
                            .split(' ')[0],
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final d = await showDatePicker(
                      context: context,
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now(),
                      initialDate: DateTime.now(),
                    );
                    if (d != null) {
                      setState(() => vaccinationDate = d);
                    }
                  },
                ),

                const Spacer(),

                // ✅ Save Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.brandPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: selectedVaccine == null ||
                            vaccinationDate == null
                        ? null
                        : () {
                            // SAVE TO immunization_record TABLE
                            // child_id = widget.childId
                            // vaccine_id = selectedVaccine!.vaccineId
                            // vaccination_date = vaccinationDate
                          },
                    child: const Text('Save Immunization'),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
