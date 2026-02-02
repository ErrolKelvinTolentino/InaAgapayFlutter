import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../widgets/secondary_header.dart';
import '../widgets/page_title.dart';
import '../widgets/app_input_field.dart';
import '../widgets/main_button.dart';
import '../widgets/secondary_button.dart';
import '../widgets/progressive_step_indicator.dart';
import '../models/add_child_form_data.dart';

class MidwifeAddParentStep1 extends StatefulWidget {
  const MidwifeAddParentStep1({super.key});

  @override
  State<MidwifeAddParentStep1> createState() => _MidwifeAddParentStep1State();
}

class _MidwifeAddParentStep1State extends State<MidwifeAddParentStep1> {
  final TextEditingController _searchController = TextEditingController();
  late AddChildFormData formData;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    formData =
        ModalRoute.of(context)?.settings.arguments as AddChildFormData? ??
            AddChildFormData();
  }

  void _useExistingParent() {
    /// 🔧 MOCK — backend later
    formData.motherId = 1;

    Navigator.pushNamed(
      context,
      '/midwife-add-child-address',
      arguments: formData,
    );
  }

  void _registerNewParent() {
    Navigator.pushNamed(
      context,
      '/midwife-add-parent-details',
      arguments: formData,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,

      /// 🔝 HEADER
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: SecondaryHeader(
          title: 'Add Child',
          onBack: () => Navigator.pop(context),
        ),
      ),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              /// 🧭 STEP INDICATOR
              

              /// 🧑‍🍼 TITLE
              const Center(
                child: PageTitle(
                  title: 'Find Parent',
                  leadingIcon: Icons.search,
                ),
              ),

              const SizedBox(height: 16),

              const ProgressiveStepIndicator(
                currentStep: 0,
                totalSteps: 3,
              ),

              const SizedBox(height: 24),

              /// 🔍 SEARCH FIELD
              AppInputField(
                hintText: 'Search mother name',
                controller: _searchController,
                leadingIcon: Icons.person_search,
              ),

              const SizedBox(height: 24),

              /// ✅ PRIMARY ACTION
              MainButton(
                label: 'Use Existing Parent',
                leadingIcon: Icons.check_circle_outline,
                onPressed: _useExistingParent,
              ),

              const SizedBox(height: 12),

              /// ➕ SECONDARY ACTION (NOW CORRECT)
              SecondaryButton(
                label: 'Register New Parent',
                leadingIcon: Icons.person_add_alt,
                onPressed: _registerNewParent,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
