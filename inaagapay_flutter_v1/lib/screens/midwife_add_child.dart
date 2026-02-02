import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../widgets/secondary_header.dart';
import '../widgets/page_title.dart';
import '../widgets/app_input_field.dart';
import '../widgets/main_button.dart';
import '../widgets/dialog_box.dart';
import '../widgets/confirmation_dialog_box.dart';
import '../widgets/progressive_step_indicator.dart';
import '../models/add_child_form_data.dart';

class MidwifeAddChildPage extends StatefulWidget {
  const MidwifeAddChildPage({super.key});

  @override
  State<MidwifeAddChildPage> createState() => _MidwifeAddChildPageState();
}

class _MidwifeAddChildPageState extends State<MidwifeAddChildPage> {
  late AddChildFormData formData;

  final firstName = TextEditingController();
  final lastName = TextEditingController();
  final middleName = TextEditingController();
  final extensionName = TextEditingController();
  final birthDate = TextEditingController();
  final birthProvince = TextEditingController();
  final birthCity = TextEditingController();

  bool get _isFormValid =>
      firstName.text.isNotEmpty &&
      lastName.text.isNotEmpty &&
      birthDate.text.isNotEmpty &&
      birthProvince.text.isNotEmpty &&
      birthCity.text.isNotEmpty;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    formData = ModalRoute.of(context)!.settings.arguments as AddChildFormData;
  }

  void _submit() {
    formData.child = {
      'firstName': firstName.text,
      'lastName': lastName.text,
      'middleName': middleName.text,
      'extension': extensionName.text,
      'birthDate': birthDate.text,
      'birthProvince': birthProvince.text,
      'birthCity': birthCity.text,
    };

    showDialog(
      context: context,
      builder: (_) => ConfirmationDialogBox(
        title: 'Confirm Registration',
        subtitle:
            'Please make sure all child details are correct. This cannot be edited later.',
        confirmText: 'Confirm',
        cancelText: 'Cancel',
        onCancel: () => Navigator.pop(context),
        onConfirm: () {
          Navigator.pop(context);

          showDialog(
            context: context,
            builder: (_) => DialogBox(
              type: DialogType.success,
              title: 'Child Registered',
              subtitle: 'The child has been successfully added.',
              buttonText: 'OK',
              onPressed: () {
                Navigator.pop(context);
                Navigator.popUntil(
                  context,
                  ModalRoute.withName('/midwife-dashboard'),
                );
              },
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,

      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: SecondaryHeader(
          title: 'Add Child',
          onBack: () => Navigator.pop(context),
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const PageTitle(
                title: 'Child Information',
                leadingIcon: Icons.child_care,
              ),

              const SizedBox(height: 12),

              const ProgressiveStepIndicator(
                currentStep: 2,
                totalSteps: 3,
              ),

              const SizedBox(height: 24),

              AppInputField(
                hintText: 'First Name',
                controller: firstName,
                isRequired: true,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 12),

              AppInputField(
                hintText: 'Last Name',
                controller: lastName,
                isRequired: true,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 12),

              AppInputField(
                hintText: 'Middle Name (Optional)',
                controller: middleName,
              ),
              const SizedBox(height: 12),

              AppInputField(
                hintText: 'Extension Name (Optional)',
                controller: extensionName,
              ),
              const SizedBox(height: 12),

              AppInputField(
                hintText: 'Birth Date',
                controller: birthDate,
                isRequired: true,
                leadingIcon: Icons.calendar_month,
                readOnly: false,
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) {
                    birthDate.text =
                        '${date.month}/${date.day}/${date.year}';
                    setState(() {});
                  }
                },
              ),
              const SizedBox(height: 12),

              AppInputField(
                hintText: 'Birth Place Province',
                controller: birthProvince,
                isRequired: true,
                trailingIcon: Icons.keyboard_arrow_down,
                readOnly: false,
                onTap: () {
                  // TODO: province dropdown
                },
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 12),

              AppInputField(
                hintText: 'Birth Place Municipality',
                controller: birthCity,
                isRequired: true,
                trailingIcon: Icons.keyboard_arrow_down,
                readOnly: false,
                onTap: () {
                  // TODO: city dropdown
                },
                onChanged: (_) => setState(() {}),
              ),

              const SizedBox(height: 24),

              MainButton(
                label: 'Add Child',
                onPressed: _isFormValid ? _submit : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
