import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/headline.dart';
import '../widgets/app_input_field.dart';
import '../widgets/main_button.dart';
import '../widgets/calculation_dropdown.dart';
import '../widgets/aog_input.dart';
import '../models/due_date_basis.dart';
import 'congrats_page.dart';

enum DueDateMode { pregnant, supporting }

class DueDateSetterScreen extends StatefulWidget {
  final DueDateMode mode;

  const DueDateSetterScreen({super.key, required this.mode});

  @override
  State<DueDateSetterScreen> createState() => _DueDateSetterScreenState();
}

class _DueDateSetterScreenState extends State<DueDateSetterScreen> {
  DueDateBasis _basis = DueDateBasis.lmp;

  final _dateController = TextEditingController();
  final _weeksController = TextEditingController();
  final _daysController = TextEditingController();

  Future<void> _pickDateForBasis() async {
    final now = DateTime.now();

    final pickedDate = await showDatePicker(
      context: context,

      // sensible default
      initialDate: _basis == DueDateBasis.edd
          ? now.add(const Duration(days: 1))
          : now,

      // ✅ LMP → past allowed
      // ❌ EDD → past NOT allowed
      firstDate: _basis == DueDateBasis.edd ? now : DateTime(1900),

      // ✅ LMP → up to today
      // ✅ EDD → future allowed
      lastDate: _basis == DueDateBasis.edd ? DateTime(now.year + 2) : now,
    );

    if (pickedDate != null) {
      _dateController.text =
          '${pickedDate.month.toString().padLeft(2, '0')}/'
          '${pickedDate.day.toString().padLeft(2, '0')}/'
          '${pickedDate.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPregnant = widget.mode == DueDateMode.pregnant;

    return Scaffold(
      resizeToAvoidBottomInset: false, // ✅ IMPORTANT
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 24),

              Image.asset('assets/images/logo.png', height: 90),

              const SizedBox(height: 24),

              Headline(
                text: isPregnant ? 'Set Your Due Date' : 'Set Their Due Date',
              ),

              const SizedBox(height: 12),

              Text(
                isPregnant
                    ? 'This helps us give you weekly updates tailored to your pregnancy journey'
                    : 'This helps us give you weekly updates tailored to their pregnancy journey',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),

              const SizedBox(height: 32),

              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Calculate Based on:',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),

              const SizedBox(height: 8),

              CalculationDropdown(
                value: _basis,
                onChanged: (value) {
                  setState(() => _basis = value);
                },
              ),

              const SizedBox(height: 24),

              // ✅ CALENDAR INPUT (LMP & EDD)
              if (_basis == DueDateBasis.lmp || _basis == DueDateBasis.edd)
                AppInputField(
                  hintText: _basis == DueDateBasis.lmp
                      ? 'First day of last menstrual period'
                      : 'Estimated delivery date',
                  controller: _dateController,
                  readOnly: false,
                  leadingIcon: Icons.calendar_today,
                  onTap: _pickDateForBasis,
                ),
              if (_basis != DueDateBasis.aog) ...[
                const SizedBox(height: 12),

                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.brandPrimary.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.info_outline,
                        size: 24,
                        color: AppColors.brandPrimary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.mode == DueDateMode.pregnant
                              ? 'Not sure of the exact date?\nYour closest estimate works too!'
                              : 'Not sure of the exact date?\nTheir closest estimate works too!',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // ✅ AoG INPUT
              if (_basis == DueDateBasis.aog)
                AogInput(
                  weeksController: _weeksController,
                  daysController: _daysController,
                ),

              const Spacer(),

              MainButton(
                label: isPregnant
                    ? 'Calculate My Due Date'
                    : 'Calculate Their Due Date',
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    '/congrats',
                    arguments:
                        widget.mode, // DueDateMode.pregnant or supporting
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
