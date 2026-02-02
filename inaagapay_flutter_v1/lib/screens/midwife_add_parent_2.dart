import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../widgets/secondary_header.dart';
import '../widgets/page_title.dart';
import '../widgets/app_input_field.dart';
import '../widgets/main_button.dart';
import '../widgets/progressive_step_indicator.dart';
import '../models/add_child_form_data.dart';

class MidwifeAddParentStep2 extends StatefulWidget {
  const MidwifeAddParentStep2({super.key});

  @override
  State<MidwifeAddParentStep2> createState() => _MidwifeAddParentStep2State();
}

class _MidwifeAddParentStep2State extends State<MidwifeAddParentStep2> {
  late AddChildFormData formData;

  final firstName = TextEditingController();
  final lastName = TextEditingController();
  final birthDate = TextEditingController();

  bool get _isFormValid =>
      firstName.text.isNotEmpty &&
      lastName.text.isNotEmpty &&
      birthDate.text.isNotEmpty;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    formData = ModalRoute.of(context)!.settings.arguments as AddChildFormData;
  }

  void _next() {
    formData.motherDetails = {
      'firstName': firstName.text,
      'lastName': lastName.text,
      'birthDate': birthDate.text,
    };

    Navigator.pushNamed(
      context,
      '/midwife-add-child-address',
      arguments: formData,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,

      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: SecondaryHeader(
          title: 'Register Parent',
          onBack: () => Navigator.pop(context),
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              

              const PageTitle(
                title: 'Parent Details',
                leadingIcon: Icons.person,
              ),

              const SizedBox(height: 16),

              const ProgressiveStepIndicator(
                currentStep: 0,
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
                hintText: 'Birth Date',
                controller: birthDate,
                isRequired: true,
                leadingIcon: Icons.calendar_month,
                readOnly: false,
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(1950),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) {
                    birthDate.text =
                        '${date.month}/${date.day}/${date.year}';
                    setState(() {});
                  }
                },
              ),

              const SizedBox(height: 24),

              MainButton(
                label: 'Next',
                onPressed: _isFormValid ? _next : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
