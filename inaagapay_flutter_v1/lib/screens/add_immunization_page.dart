import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../theme/app_colors.dart';
import '../services/auth_storage.dart';
import '../widgets/secondary_header.dart';
import '../widgets/page_title.dart';
import '../widgets/app_input_field.dart';
import '../widgets/main_button.dart';
import '../widgets/dialog_box.dart';
import '../widgets/confirmation_dialog_box.dart';
import '../widgets/validation_message.dart';

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
  final TextEditingController _vaccineController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _remarksController = TextEditingController();

  String? _selectedVaccineKey;
  int? _selectedVaccineId;
  DateTime? _selectedDate;
  bool _isLoading = false;
  List<Map<String, dynamic>> _vaccines = [];

  @override
  void initState() {
    super.initState();
    _loadVaccines();
  }

  /// --------------------------------------------------
  /// LOAD VACCINES FROM API
  /// --------------------------------------------------
  Future<void> _loadVaccines() async {
    try {
      final token = await AuthStorage.getToken();
      if (token == null) throw Exception('Not authenticated');

      final response = await http.get(
        Uri.parse('https://inaagapay.alwaysdata.net/api/midwife/vaccines.php'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded['success'] == true) {
          setState(() {
            _vaccines = List<Map<String, dynamic>>.from(decoded['data'] ?? []);
          });
        }
      }
    } catch (e) {
      // If API fails, use default vaccines
      _setDefaultVaccines();
    }
  }

  void _setDefaultVaccines() {
    _vaccines = [
      {
        'vaccine_id': 1,
        'vaccine_name': 'BCG',
        'dose_number': '1',
        'recommended_age_weeks': 0,
        'age_label': 'At Birth'
      },
      {
        'vaccine_id': 2,
        'vaccine_name': 'Hepatitis B',
        'dose_number': '1',
        'recommended_age_weeks': 0,
        'age_label': 'At Birth'
      },
      {
        'vaccine_id': 3,
        'vaccine_name': 'Pentavalent',
        'dose_number': '1',
        'recommended_age_weeks': 6,
        'age_label': '6 Weeks'
      },
      {
        'vaccine_id': 4,
        'vaccine_name': 'OPV',
        'dose_number': '1',
        'recommended_age_weeks': 6,
        'age_label': '6 Weeks'
      },
      {
        'vaccine_id': 5,
        'vaccine_name': 'PCV',
        'dose_number': '1',
        'recommended_age_weeks': 6,
        'age_label': '6 Weeks'
      },
      {
        'vaccine_id': 6,
        'vaccine_name': 'Rotavirus',
        'dose_number': '1',
        'recommended_age_weeks': 6,
        'age_label': '6 Weeks'
      },
      {
        'vaccine_id': 7,
        'vaccine_name': 'Pentavalent',
        'dose_number': '2',
        'recommended_age_weeks': 10,
        'age_label': '10 Weeks'
      },
      {
        'vaccine_id': 8,
        'vaccine_name': 'OPV',
        'dose_number': '2',
        'recommended_age_weeks': 10,
        'age_label': '10 Weeks'
      },
      {
        'vaccine_id': 9,
        'vaccine_name': 'PCV',
        'dose_number': '2',
        'recommended_age_weeks': 10,
        'age_label': '10 Weeks'
      },
      {
        'vaccine_id': 10,
        'vaccine_name': 'Rotavirus',
        'dose_number': '2',
        'recommended_age_weeks': 10,
        'age_label': '10 Weeks'
      },
    ];
  }

  /// --------------------------------------------------
  /// FORM VALIDATION
  /// --------------------------------------------------
  bool get _isFormValid =>
      _selectedVaccineKey != null && _selectedDate != null;

  /// --------------------------------------------------
  /// DATE PICKER
  /// --------------------------------------------------
  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormat('MM/dd/yyyy').format(picked);
      });
    }
  }

  /// --------------------------------------------------
  /// GROUP VACCINES BY AGE
  /// --------------------------------------------------
  Map<String, List<Map<String, dynamic>>> _groupVaccinesByAge() {
    final Map<String, List<Map<String, dynamic>>> grouped = {};
    
    for (final vaccine in _vaccines) {
      final ageLabel = vaccine['age_label']?.toString() ?? 'Other';
      grouped.putIfAbsent(ageLabel, () => []);
      grouped[ageLabel]!.add(vaccine);
    }
    
    return grouped;
  }

  /// --------------------------------------------------
  /// VACCINE DROPDOWN (CALCULATOR STYLE)
  /// --------------------------------------------------
  void _openVaccineDropdown() {
    final groupedVaccines = _groupVaccinesByAge();

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Column(
              children: groupedVaccines.entries.map((entry) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// AGE LABEL
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
                      child: Text(
                        entry.key,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),

                    /// VACCINES
                    ...entry.value.map((vaccine) {
                      final vaccineId = vaccine['vaccine_id']?.toString() ?? '';
                      final vaccineName = vaccine['vaccine_name']?.toString() ?? '';
                      final doseNumber = vaccine['dose_number']?.toString() ?? '';
                      final displayName = doseNumber.isNotEmpty
                          ? '$vaccineName (Dose $doseNumber)'
                          : vaccineName;

                      return InkWell(
                        onTap: () {
                          setState(() {
                            _selectedVaccineKey = vaccineId;
                            _selectedVaccineId = int.tryParse(vaccineId);
                            _vaccineController.text = displayName;
                          });
                          Navigator.pop(context);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.circle_outlined,
                                size: 18,
                                color: _selectedVaccineKey == vaccineId
                                    ? AppColors.brandPrimary
                                    : AppColors.textSecondary,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  displayName,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: _selectedVaccineKey == vaccineId
                                        ? AppColors.brandPrimary
                                        : AppColors.textPrimary,
                                  ),
                                ),
                              ),
                              if (_selectedVaccineKey == vaccineId)
                                const Icon(
                                  Icons.check,
                                  size: 18,
                                  color: AppColors.brandPrimary,
                                ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  /// --------------------------------------------------
  /// SUBMIT IMMUNIZATION
  /// --------------------------------------------------
  Future<bool> _submitImmunization() async {
    if (_selectedVaccineId == null || _selectedDate == null) {
      return false;
    }

    final token = await AuthStorage.getToken();
    if (token == null) return false;

    try {
      final response = await http.post(
        Uri.parse('https://inaagapay.alwaysdata.net/api/midwife/add_immunization.php'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'child_id': widget.childId,
          'vaccine_id': _selectedVaccineId,
          'vaccination_date': DateFormat('yyyy-MM-dd').format(_selectedDate!),
          'remarks': _remarksController.text.trim(),
        }),
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        return decoded['success'] == true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// --------------------------------------------------
  /// SUBMIT FLOW
  /// --------------------------------------------------
  void _submit() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => ConfirmationDialogBox(
        title: 'Confirm Immunization',
        subtitle: 'Please review the details carefully. Immunization records cannot be edited once added.',
        confirmText: 'Confirm',
        cancelText: 'Cancel',
        onCancel: () => Navigator.pop(context),
        onConfirm: () async {
          Navigator.pop(context);
          
          setState(() => _isLoading = true);
          
          final success = await _submitImmunization();
          
          setState(() => _isLoading = false);
          
          if (success) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (_) => DialogBox(
                type: DialogType.success,
                title: 'Immunization Added',
                subtitle: 'The immunization record has been successfully saved.',
                buttonText: 'OK',
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context, true); // Return true to refresh parent
                },
              ),
            );
          } else {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (_) => DialogBox(
                type: DialogType.error,
                title: 'Failed to Add',
                subtitle: 'There was an error saving the immunization record. Please try again.',
                buttonText: 'OK',
                onPressed: () => Navigator.pop(context),
              ),
            );
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,

      /// HEADER
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: SecondaryHeader(
          title: 'Add Immunization',
          onBack: () => Navigator.pop(context),
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: PageTitle(
                  title: 'Vaccine Details',
                  leadingIcon: Icons.vaccines_rounded,
                  trailingIcon: Icons.check_circle,
                ),
              ),

              const SizedBox(height: 16),

              /// SELECT VACCINE
              AppInputField(
                hintText: 'Select Vaccine',
                controller: _vaccineController,
                leadingIcon: Icons.vaccines_outlined,
                trailingIcon: Icons.keyboard_arrow_down_rounded,
                readOnly: false,
                onTap: _openVaccineDropdown,
                isRequired: true,
              ),

              const SizedBox(height: 16),

              /// DATE
              AppInputField(
                hintText: 'Vaccination Date',
                controller: _dateController,
                leadingIcon: Icons.calendar_month_rounded,
                readOnly: false,
                onTap: _selectDate,
                isRequired: true,
              ),

              const SizedBox(height: 16),

              /// REMARKS
              AppInputField(
                hintText: 'Remarks (optional)',
                controller: _remarksController,
                leadingIcon: Icons.notes_rounded,
              ),

              const SizedBox(height: 12),

              if (!_isFormValid)
                const ValidationMessage(
                  message: 'Please complete all required fields before submitting.',
                  type: ValidationType.info,
                ),

              const SizedBox(height: 28),

              /// SUBMIT BUTTON
              _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.brandPrimary,
                      ),
                    )
                  : MainButton(
                      label: 'Add Immunization Record',
                      onPressed: _isFormValid ? _submit : null,
                    ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}