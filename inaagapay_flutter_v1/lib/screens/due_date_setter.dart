import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/headline.dart';
import '../widgets/app_input_field.dart';
import '../widgets/main_button.dart';

enum DueDateMode { pregnant, supporting }

class DueDateSetterScreen extends StatefulWidget {
  final DueDateMode mode;

  const DueDateSetterScreen({
    super.key,
    required this.mode,
  });

  @override
  State<DueDateSetterScreen> createState() => _DueDateSetterScreenState();
}

class _DueDateSetterScreenState extends State<DueDateSetterScreen> {
  final TextEditingController _dateController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final isPregnant = widget.mode == DueDateMode.pregnant;

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 32),

              Image.asset(
                'assets/images/logo.png',
                height: 90,
              ),

              const SizedBox(height: 24),

              Headline(
                text: isPregnant
                    ? 'Set Your Due Date'
                    : 'Set Their Due Date',
              ),

              const SizedBox(height: 8),

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

              AppInputField(
                hintText: isPregnant
                    ? 'First day of last menstrual period'
                    : 'First day of their last menstrual period',
                controller: _dateController,
                readOnly: true,
                leadingIcon: Icons.calendar_today,
                onTap: () async {
                  final pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                  );

                  if (pickedDate != null) {
                    _dateController.text =
                        '${pickedDate.month.toString().padLeft(2, '0')}/'
                        '${pickedDate.day.toString().padLeft(2, '0')}/'
                        '${pickedDate.year}';
                  }
                },
              ),

              const SizedBox(height: 16),

              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.brandPrimary.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      size: 18,
                      color: AppColors.brandPrimary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        isPregnant
                            ? 'Not sure of the exact date? Your closest estimate works too!'
                            : 'Not sure of the exact date? Their closest estimate works too!',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              MainButton(
                label: isPregnant
                    ? 'Calculate My Due Date'
                    : 'Calculate Their Due Date',
                onPressed: () {
                  // TODO: calculate + save due date
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
