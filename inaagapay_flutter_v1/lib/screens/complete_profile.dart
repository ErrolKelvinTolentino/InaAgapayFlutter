import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/secondary_header.dart';
import '../widgets/app_input_field.dart';
import '../widgets/main_button.dart';
import '../widgets/progressive_step_indicator.dart';
import '../widgets/page_title.dart';

class CompleteProfileScreen extends StatefulWidget {
  const CompleteProfileScreen({super.key});

  @override
  State<CompleteProfileScreen> createState() =>
      _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  int _currentStep = 0;

  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _middleName = TextEditingController();
  final _extensionName = TextEditingController();
  final _birthDate = TextEditingController();
  final _contactNumber = TextEditingController();

  final _province = TextEditingController();
  final _city = TextEditingController();
  final _barangay = TextEditingController();
  final _street = TextEditingController();
  final _houseNo = TextEditingController();


  void _nextStep() {
    if (_currentStep < 2) setState(() => _currentStep++);
  }

  void _previousStep() {
    if (_currentStep > 0) setState(() => _currentStep--);
  }

  void _jumpToStep(int step) {
    setState(() => _currentStep = step);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),

            SecondaryHeader(
              title: 'Complete Your Profile',
              onBack: _currentStep == 0 ? null : _previousStep,
            ),

            const SizedBox(height: 24),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _stepHeader(),
            ),

            const SizedBox(height: 16),

            ProgressiveStepIndicator(
              currentStep: _currentStep,
              totalSteps: 3,
            ),

            const SizedBox(height: 24),

            Expanded(
              child: IndexedStack(
                index: _currentStep,
                children: [
                  _personalInfoStep(),
                  _addressStep(),
                  _reviewStep(),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(24),
              child: MainButton(
                label: _currentStep == 2 ? 'Save Profile' : 'Next',
                showIcons: false,
                onPressed: _nextStep,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _stepHeader() {
    switch (_currentStep) {
      case 0:
        return const PageTitle(
          title: 'Personal Details',
          leadingIcon: Icons.person,
          trailingIcon: Icons.check,
        );
      case 1:
        return const PageTitle(
          title: 'Address (Optional)',
          leadingIcon: Icons.home,
          trailingIcon: Icons.check,
        );
      default:
        return const PageTitle(
          title: 'Review Information',
          leadingIcon: Icons.edit,
          trailingIcon: Icons.check,
        );
    }
  }

  Widget _personalInfoStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          AppInputField(hintText: 'First Name', controller: _firstName, isRequired: true),
          const SizedBox(height: 12),
          AppInputField(hintText: 'Last Name', controller: _lastName, isRequired: true),
          const SizedBox(height: 12),
          AppInputField(hintText: 'Middle Name', controller: _middleName),
          const SizedBox(height: 12),
          AppInputField(hintText: 'Extension Name', controller: _extensionName),
          const SizedBox(height: 12),
          AppInputField(
            hintText: 'Birthdate',
            controller: _birthDate,
            isRequired: true,
            leadingIcon: Icons.calendar_today,
            readOnly: true,
            onTap: () async {
              final pickedDate = await showDatePicker(
                context: context,
                initialDate: DateTime(2000),
                firstDate: DateTime(1900),
                lastDate: DateTime.now(),
              );
              if (pickedDate != null) {
                _birthDate.text =
                    '${pickedDate.month.toString().padLeft(2, '0')}/'
                    '${pickedDate.day.toString().padLeft(2, '0')}/'
                    '${pickedDate.year}';
              }
            },
          ),
          const SizedBox(height: 12),
          AppInputField(
            hintText: '+63 Contact Number',
            controller: _contactNumber,
            isRequired: true,
            keyboardType: TextInputType.phone,
            leadingIcon: Icons.phone,
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _addressStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          AppInputField(hintText: 'Province', controller: _province),
          const SizedBox(height: 12),
          AppInputField(hintText: 'City / Municipality', controller: _city),
          const SizedBox(height: 12),
          AppInputField(hintText: 'Barangay', controller: _barangay),
          const SizedBox(height: 12),
          AppInputField(hintText: 'Street Name', controller: _street),
          const SizedBox(height: 12),
          AppInputField(hintText: 'House No.', controller: _houseNo),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _reviewStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          AppInputField(
            hintText: 'First Name',
            controller: _firstName,
            readOnly: true,
            trailingIcon: Icons.edit,
            onTrailingTap: () => _jumpToStep(0),
          ),
          const SizedBox(height: 12),

          AppInputField(
            hintText: 'Middle Name',
            controller: _middleName,
            readOnly: true,
            trailingIcon: Icons.edit,
            onTrailingTap: () => _jumpToStep(0),
          ),
          const SizedBox(height: 12),

          AppInputField(
            hintText: 'Last Name',
            controller: _lastName,
            readOnly: true,
            trailingIcon: Icons.edit,
            onTrailingTap: () => _jumpToStep(0),
          ),
          const SizedBox(height: 12),

          AppInputField(
            hintText: 'Birthdate',
            controller: _birthDate,
            readOnly: true,
            leadingIcon: Icons.calendar_today,
            trailingIcon: Icons.edit,
            onTrailingTap: () => _jumpToStep(0),
          ),
          const SizedBox(height: 12),

          AppInputField(
            hintText: '+63 Contact Number',
            controller: _contactNumber,
            readOnly: true,
            leadingIcon: Icons.phone,
            trailingIcon: Icons.edit,
            onTrailingTap: () => _jumpToStep(0),
          ),
          const SizedBox(height: 12),

          AppInputField(
            hintText: 'Address',
            controller: TextEditingController(
              text: '${_province.text}, ${_city.text}, ${_barangay.text}',
            ),
            readOnly: true,
            trailingIcon: Icons.edit,
            onTrailingTap: () => _jumpToStep(1),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
