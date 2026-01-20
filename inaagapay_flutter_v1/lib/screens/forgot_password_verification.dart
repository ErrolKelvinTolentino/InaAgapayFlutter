import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/main_button.dart';
import '../widgets/secondary_button.dart';
import '../widgets/otp_input_field.dart';
import '../widgets/validation_message.dart';
import '../widgets/clickable_text.dart';
import '../widgets/dialog_box.dart';
import '../widgets/page_title.dart';

class ForgotPasswordVerificationScreen extends StatefulWidget {
  const ForgotPasswordVerificationScreen({super.key});

  @override
  State<ForgotPasswordVerificationScreen> createState() =>
      _ForgotPasswordVerificationScreenState();
}

class _ForgotPasswordVerificationScreenState
    extends State<ForgotPasswordVerificationScreen> {
  static const int _initialSeconds = 300;

  int _secondsRemaining = _initialSeconds;
  Timer? _timer;

  String _code = '';
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _secondsRemaining = _initialSeconds;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining == 0) {
        timer.cancel();
      } else {
        setState(() => _secondsRemaining--);
      }
    });
  }

  String get _formattedTime {
    final minutes = (_secondsRemaining ~/ 60);
    final seconds = (_secondsRemaining % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  void _verifyCode() {
  if (_code != '123456') {
    setState(() {
      _hasError = true;
    });
    return;
  }

  final parentContext = context; // 👈 save parent context

  showDialog(
    context: parentContext,
    barrierDismissible: false,
    builder: (_) => DialogBox(
      title: 'Account Verified!',
      buttonText: 'Continue',
      type: DialogType.success,
      onPressed: () {
        Navigator.of(parentContext, rootNavigator: true).pop();

        Navigator.pushReplacementNamed(
          parentContext,
          '/change-forgot-password',
        );
      },
    ),
  );
}


  void _resendCode() {
    _startTimer();
    // TODO: resend OTP backend call
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
                title: 'CODE SENT',
                leadingIcon: Icons.mail,
                trailingIcon: Icons.check,
              ),

              const SizedBox(height: 16),

              const Text(
                'Enter the 6-digit code sent to your email',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),

              const SizedBox(height: 28),

              OtpInputField(
                onChanged: (value) {
                  setState(() {
                    _code = value;
                    _hasError = false;
                  });
                },
                showError: _hasError,
              ),

              if (_hasError) ...[
                const SizedBox(height: 12),
                const Padding(
                  padding: EdgeInsets.only(left: 20),
                  child: ValidationMessage(
                    message: 'Incorrect code. Please try again.',
                    type: ValidationType.error,
                  ),
                ),
              ],

              const SizedBox(height: 32),

              MainButton(
                label: 'Verify',
                showIcons: false,
                onPressed:
                    _code.length == 6 ? () => _verifyCode() : null,
              ),

              const SizedBox(height: 16),

              SecondaryButton(
                label: 'Back to Login',
                showIcons: false,
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/login',
                    (route) => false,
                  );
                },
              ),

              const SizedBox(height: 16),

              _secondsRemaining == 0
                  ? ClickableText(
                      text: 'Resend Code',
                      onTap: _resendCode,
                    )
                  : Text(
                      'Resend Code in $_formattedTime',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
