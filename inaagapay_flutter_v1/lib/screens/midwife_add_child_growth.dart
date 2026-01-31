import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../widgets/secondary_header.dart';
import '../widgets/app_input_field.dart';
import '../widgets/status_indicator.dart';
import '../widgets/main_button.dart';
import '../widgets/page_title.dart';
import '../widgets/dialog_box.dart';
import '../widgets/confirmation_dialog_box.dart';
import '../widgets/validation_message.dart';

class MidwifeAddChildGrowthPage extends StatefulWidget {
  const MidwifeAddChildGrowthPage({super.key});

  @override
  State<MidwifeAddChildGrowthPage> createState() =>
      _MidwifeAddChildGrowthPageState();
}

class _MidwifeAddChildGrowthPageState extends State<MidwifeAddChildGrowthPage> {
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _bmiController = TextEditingController();
  final TextEditingController _remarksController = TextEditingController();

  StatusIndicatorType _bmiStatus = StatusIndicatorType.normal;

  bool _isFormValid = false;
  String? _validationMessage;

  /// --------------------------------------------------
  /// BMI CALCULATION
  /// --------------------------------------------------
  void _recalculateBMI() {
    final double? heightCm = double.tryParse(_heightController.text);
    final double? weightKg = double.tryParse(_weightController.text);

    if (heightCm == null || weightKg == null || heightCm == 0) {
      setState(() {
        _bmiController.text = '';
        _isFormValid = false;
        _validationMessage = 'Please enter valid height and weight.';
      });
      return;
    }

    final double heightM = heightCm / 100;
    final double bmi = weightKg / (heightM * heightM);

    setState(() {
      _bmiController.text = bmi.toStringAsFixed(1);
      _bmiStatus = _getBmiStatus(bmi);
    });

    _validateForm();
  }

  StatusIndicatorType _getBmiStatus(double bmi) {
    if (bmi < 18.5) return StatusIndicatorType.underweight;
    if (bmi < 25) return StatusIndicatorType.normal;
    if (bmi < 30) return StatusIndicatorType.overweight;
    return StatusIndicatorType.obese;
  }

  /// --------------------------------------------------
  /// FORM VALIDATION
  /// --------------------------------------------------
  void _validateForm() {
    if (_heightController.text.isEmpty ||
        _weightController.text.isEmpty) {
      setState(() {
        _isFormValid = false;
        _validationMessage = 'Height and weight are required.';
      });
      return;
    }

    if (_bmiController.text.isEmpty) {
      setState(() {
        _isFormValid = false;
        _validationMessage = 'BMI could not be calculated.';
      });
      return;
    }

    setState(() {
      _isFormValid = true;
      _validationMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,

      /// 🔝 SECONDARY HEADER
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: SecondaryHeader(
          title: 'Add Growth Record',
          onBack: () => Navigator.pop(context),
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// 🧬 SECTION TITLE
              Center(
                child: PageTitle(
                  title: 'Growth Details',
                  leadingIcon: Icons.edit_rounded,
                  trailingIcon: Icons.check_circle,
                ),
              ),

              const SizedBox(height: 16),

              /// 📏 HEIGHT
              AppInputField(
                hintText: 'Height (cm)',
                controller: _heightController,
                leadingIcon: Icons.height,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                onChanged: (_) => _recalculateBMI(),
                isRequired: true,
              ),

              const SizedBox(height: 16),

              /// ⚖️ WEIGHT
              AppInputField(
                hintText: 'Weight (kg)',
                controller: _weightController,
                leadingIcon: Icons.monitor_weight,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                onChanged: (_) => _recalculateBMI(),
                isRequired: true,
              ),

              const SizedBox(height: 16),

              /// 🧮 BMI (READ ONLY)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.bgSecondary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calculate,
                        color: AppColors.brandAccent),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _bmiController.text.isEmpty
                            ? 'BMI: ---'
                            : 'BMI: ${_bmiController.text}',
                        style: const TextStyle(
                          fontSize: 15,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    StatusIndicator(status: _bmiStatus),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              /// 📝 REMARKS
              AppInputField(
                hintText: 'Remarks',
                controller: _remarksController,
                leadingIcon: Icons.notes_rounded,
              ),

              /// ⚠️ VALIDATION MESSAGE
              if (_validationMessage != null) ...[
                const SizedBox(height: 12),
                ValidationMessage(
                  message: _validationMessage!,
                  type: ValidationType.error,
                ),
              ],

              const SizedBox(height: 28),

              /// ➕ SUBMIT
              MainButton(
                label: 'Add Growth Record',
                onPressed: _isFormValid
                    ? () {
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (context) {
                            return ConfirmationDialogBox(
                              title: 'Confirm Growth Record',
                              subtitle:
                                  'Please make sure the details are correct. Growth records cannot be edited once added.',
                              confirmText: 'Confirm',
                              cancelText: 'Cancel',
                              onCancel: () => Navigator.pop(context),
                              onConfirm: () {
                                Navigator.pop(context);

                                showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (context) {
                                    return DialogBox(
                                      type: DialogType.success,
                                      title: 'Growth Record Added',
                                      subtitle:
                                          'The child’s growth information has been successfully recorded.',
                                      buttonText: 'OK',
                                      onPressed: () {
                                        Navigator.pop(context);
                                        Navigator.pop(context);
                                      },
                                    );
                                  },
                                );
                              },
                            );
                          },
                        );
                      }
                    : null, // 🚫 disabled when invalid
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
