import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../widgets/secondary_header.dart';
import '../widgets/page_title.dart';
import '../widgets/app_input_field.dart';
import '../widgets/main_button.dart';
import '../widgets/progressive_step_indicator.dart';
import '../models/add_child_form_data.dart';

class MidwifeAddChildAddressPage extends StatefulWidget {
  const MidwifeAddChildAddressPage({super.key});

  @override
  State<MidwifeAddChildAddressPage> createState() =>
      _MidwifeAddChildAddressPageState();
}

class _MidwifeAddChildAddressPageState
    extends State<MidwifeAddChildAddressPage> {
  late AddChildFormData formData;

  final province = TextEditingController();
  final city = TextEditingController();
  final barangay = TextEditingController();
  final street = TextEditingController();
  final houseNo = TextEditingController();

  bool get _isFormValid =>
      province.text.isNotEmpty &&
      city.text.isNotEmpty &&
      barangay.text.isNotEmpty;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    formData = ModalRoute.of(context)!.settings.arguments as AddChildFormData;
  }

  void _next() {
    formData.address = {
      'province': province.text,
      'city': city.text,
      'barangay': barangay.text,
      'street': street.text,
      'houseNo': houseNo.text,
    };

    Navigator.pushNamed(
      context,
      '/midwife-add-child',
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
                title: 'Address Details',
                leadingIcon: Icons.location_on,
                trailingIcon: Icons.check_circle,
              ),

              const SizedBox(height: 12),

              const ProgressiveStepIndicator(
                currentStep: 1,
                totalSteps: 3,
              ),

              const SizedBox(height: 24),

              /// 🔽 PROVINCE (DROPDOWN LATER)
              AppInputField(
                hintText: 'Province',
                controller: province,
                isRequired: true,
                trailingIcon: Icons.keyboard_arrow_down,
                readOnly: false,
                onTap: () {
                  // TODO: open province dropdown (PSGC backend)
                },
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 12),

              /// 🔽 CITY / MUNICIPALITY
              AppInputField(
                hintText: 'City / Municipality',
                controller: city,
                isRequired: true,
                trailingIcon: Icons.keyboard_arrow_down,
                readOnly: false,
                onTap: () {
                  // TODO: open city dropdown
                },
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 12),

              /// 🔽 BARANGAY
              AppInputField(
                hintText: 'Barangay',
                controller: barangay,
                isRequired: true,
                trailingIcon: Icons.keyboard_arrow_down,
                readOnly: false,
                onTap: () {
                  // TODO: open barangay dropdown
                },
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 12),

              /// OPTIONAL
              AppInputField(
                hintText: 'Street Name',
                controller: street,
              ),
              const SizedBox(height: 12),

              /// OPTIONAL
              AppInputField(
                hintText: 'House No.',
                controller: houseNo,
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
