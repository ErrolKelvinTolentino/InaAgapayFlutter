import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/app_input_field.dart';
import '../widgets/main_button.dart';
import '../widgets/secondary_button.dart';
import '../widgets/validation_message.dart';
import '../widgets/page_title.dart';
import '../widgets/dialog_box.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  bool _hasError = false;

  Future<void> _sendResetCode() async {
    setState(() {
      // 🔧 mock validation (replace later)
      _hasError = _emailController.text != 'test@email.com';
    });

    if (_hasError) return;

    // ✅ Email found → show dialog
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => DialogBox(
        title: 'Verification Code Sent',
        buttonText: 'Continue',
        type: DialogType.info, // 🩷 pink / brand
        onPressed: () {
          Navigator.of(context).pop();
        },
      ),
    );

    if (!mounted) return;

    Navigator.pushNamed(
      context,
      '/forgot-password-verify',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 32),

              Image.asset('assets/images/logo.png', height: 100),
              const SizedBox(height: 12),
              Image.asset('assets/images/inaagapay_name.png', height: 34),

              const SizedBox(height: 32),

              const PageTitle(
                title: 'Forgot Password',
                leadingIcon: Icons.key,
                trailingIcon: Icons.check,
              ),

              const SizedBox(height: 12),

              const Text(
                'Enter your email to reset your password',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),

              const SizedBox(height: 24),

              AppInputField(
                hintText: 'Email Address',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                leadingIcon: Icons.email_outlined,
              ),

              if (_hasError) ...[
                const SizedBox(height: 12),
                const ValidationMessage(
                  message: 'Email not found',
                  type: ValidationType.error,
                ),
              ],

              const SizedBox(height: 28),

              MainButton(
                label: 'Send Reset Code',
                showIcons: false,
                onPressed: _sendResetCode,
              ),

              const SizedBox(height: 16),

              SecondaryButton(
                label: 'Back to Login',
                showIcons: false,
                onPressed: () {
                  Navigator.pop(context);
                },
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
