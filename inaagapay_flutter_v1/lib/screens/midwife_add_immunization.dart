import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../widgets/secondary_header.dart';
import '../widgets/page_title.dart';
import '../widgets/app_input_field.dart';
import '../widgets/main_button.dart';
import '../widgets/dialog_box.dart';
import '../widgets/confirmation_dialog_box.dart';
import '../widgets/validation_message.dart';
import '../models/vaccine_schedule.dart';

/// --------------------------------------------------
/// TEMP CHILD DATA (BACKEND WILL REPLACE THIS)
/// --------------------------------------------------
const int childAgeInWeeks = 6;

const Set<String> givenVaccines = {
  'bcg',
  'opv0',
  'opv1',
  'penta1',
  'pcv1',
  // ❌ rota1 not given yet
};

/// --------------------------------------------------
/// UI MODEL
/// --------------------------------------------------
class VaccineOption {
  final String key;
  final String name;
  final String ageLabel;
  final int week;
  final bool isGiven;
  final bool isLocked;

  const VaccineOption({
    required this.key,
    required this.name,
    required this.ageLabel,
    required this.week,
    required this.isGiven,
    required this.isLocked,
  });
}

class MidwifeAddImmunizationPage extends StatefulWidget {
  const MidwifeAddImmunizationPage({super.key});

  @override
  State<MidwifeAddImmunizationPage> createState() =>
      _MidwifeAddImmunizationPageState();
}

class _MidwifeAddImmunizationPageState
    extends State<MidwifeAddImmunizationPage> {
  final TextEditingController _vaccineController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _remarksController = TextEditingController();

  String? _selectedVaccineKey;

  /// --------------------------------------------------
  /// FORM VALIDATION
  /// --------------------------------------------------
  bool get _isFormValid =>
      _selectedVaccineKey != null && _dateController.text.isNotEmpty;

  /// --------------------------------------------------
  /// BUILD VACCINE OPTIONS (BACKEND READY)
  /// --------------------------------------------------
  List<VaccineOption> _buildOptions() {
    final List<VaccineOption> list = [];

    for (final group in vaccineSchedule) {
      for (final vaccine in group.vaccines) {
        list.add(
          VaccineOption(
            key: vaccine.key,
            name: vaccine.name,
            ageLabel: group.label,
            week: group.week,
            isGiven: givenVaccines.contains(vaccine.key),
            isLocked: childAgeInWeeks < group.week,
          ),
        );
      }
    }
    return list;
  }

  Map<String, List<VaccineOption>> _groupByAge(
      List<VaccineOption> options) {
    final Map<String, List<VaccineOption>> grouped = {};
    for (final option in options) {
      grouped.putIfAbsent(option.ageLabel, () => []);
      grouped[option.ageLabel]!.add(option);
    }
    return grouped;
  }

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
        _dateController.text =
            '${picked.month}/${picked.day}/${picked.year}';
      });
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
        subtitle:
            'Please review the details carefully. Immunization records cannot be edited once added.',
        confirmText: 'Confirm',
        cancelText: 'Cancel',
        onCancel: () => Navigator.pop(context),
        onConfirm: () {
          Navigator.pop(context);

          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => DialogBox(
              type: DialogType.success,
              title: 'Immunization Added',
              subtitle:
                  'The immunization record has been successfully saved.',
              buttonText: 'OK',
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
            ),
          );
        },
      ),
    );
  }

  /// --------------------------------------------------
  /// VACCINE DROPDOWN (CALCULATOR STYLE)
  /// --------------------------------------------------
  void _openVaccineDropdown() {
    final options = _groupByAge(_buildOptions());

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
              children: options.entries.map((entry) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// AGE LABEL
                    Padding(
                      padding:
                          const EdgeInsets.fromLTRB(16, 14, 16, 6),
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
                      final bool disabled =
                          vaccine.isGiven || vaccine.isLocked;

                      return InkWell(
                        onTap: disabled
                            ? null
                            : () {
                                setState(() {
                                  _selectedVaccineKey = vaccine.key;
                                  _vaccineController.text =
                                      vaccine.name;
                                });
                                Navigator.pop(context);
                              },
                        child: Opacity(
                          opacity: disabled ? 0.45 : 1,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  vaccine.isGiven
                                      ? Icons.check_circle
                                      : vaccine.isLocked
                                          ? Icons.lock
                                          : Icons.circle_outlined,
                                  size: 18,
                                  color: vaccine.isGiven
                                      ? AppColors.success
                                      : vaccine.isLocked
                                          ? AppColors.textSecondary
                                          : AppColors.brandPrimary,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    vaccine.name,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: vaccine.isGiven
                                          ? AppColors.success
                                          : vaccine.isLocked
                                              ? AppColors.textSecondary
                                              : AppColors.brandPrimary,
                                    ),
                                  ),
                                ),
                                if (vaccine.isGiven)
                                  const Text(
                                    'Given',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.success,
                                    ),
                                  ),
                              ],
                            ),
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
          padding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
                hintText: 'Remarks',
                controller: _remarksController,
                leadingIcon: Icons.notes_rounded,
              ),

              const SizedBox(height: 12),

              if (!_isFormValid)
                const ValidationMessage(
                  message:
                      'Please complete all required fields before submitting.',
                  type: ValidationType.info,
                ),

              const SizedBox(height: 28),

              /// SUBMIT
              MainButton(
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
