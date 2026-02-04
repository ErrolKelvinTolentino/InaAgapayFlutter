import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/main_button.dart';
import '../widgets/otp_input_field.dart';
import '../widgets/validation_message.dart';
import '../widgets/clickable_text.dart';
import '../widgets/dialog_box.dart';
import '../widgets/page_title.dart';

class AccountVerificationRegistration extends StatefulWidget {
  const AccountVerificationRegistration({super.key});

  @override
  State<AccountVerificationRegistration> createState() =>
      _AccountVerificationRegistrationState();
}

class _AccountVerificationRegistrationState
    extends State<AccountVerificationRegistration> {
  static const int _initialSeconds = 300;

  int _secondsRemaining = _initialSeconds;
  Timer? _timer;

  String _code = '';
  bool _hasError = false;
  bool _loading = false;

  late String _email;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Extract email from route arguments
    _email = ModalRoute.of(context)!.settings.arguments as String;

    // Start the countdown timer
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
    final minutes = _secondsRemaining ~/ 60;
    final seconds = (_secondsRemaining % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  void _verifyCode() {
    // ❌ Invalid code
    if (_code != '123456' && _code != '654321') {
      setState(() {
        _hasError = true;
      });
      return;
    }

    // 🧪 Existing account linked
    if (_code == '654321') {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => DialogBox(
          title: 'Account Linked',
          subtitle: 'You have existing data from a Barangay Health Center',
          buttonText: 'Continue',
          type: DialogType.success,
          onPressed: () {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/mother-dashboard',
              (route) => false,
            );
          },
        ),
      );
      return;
    }

    // ✅ New account verified
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => DialogBox(
        title: 'Account Verified!',
        buttonText: 'Continue',
        type: DialogType.success,
        onPressed: () {
          Navigator.pop(context);
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/login',
            (route) => false,
          );
        },
      ),
    );
  }

  void _resendCode() {
    _startTimer();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => DialogBox(
        title: 'Verification code sent',
        buttonText: 'Okay',
        type: DialogType.info,
        onPressed: () => Navigator.pop(context),
      ),
    );

    // NOTE:
    // You already generate OTP in register.php.
    // If later you want resend support, we add another endpoint.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            children: [
              const SizedBox(height: 32),
              Image.asset('assets/images/logo.png', height: 110),
              const SizedBox(height: 16),
              Image.asset('assets/images/inaagapay_name.png', width: 240),
              const SizedBox(height: 32),

              const PageTitle(
                title: 'CODE SENT',
                leadingIcon: Icons.mail,
                trailingIcon: Icons.check,
              ),

              const SizedBox(height: 16),

              // Show the email address that received the code
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                  children: [
                    const TextSpan(text: 'Enter the 6-digit code sent to\n'),
                    TextSpan(
                      text: _email,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              OtpInputField(
                onChanged: (value) {
                  setState(() {
                    _code = value;
                    _hasError = false;
                  });
                },
                showError: _hasError,
              ),

              if (_hasError)
                const Padding(
                  padding: EdgeInsets.only(top: 12),
                  child: ValidationMessage(
                    message: 'Incorrect or expired code. Please try again.',
                    type: ValidationType.error,
                  ),
                ),

              const SizedBox(height: 32),

              MainButton(
                label: _loading ? 'Verifying...' : 'Verify',
                showIcons: false,
                onPressed: _code.length == 6 && !_loading ? _verifyCode : null,
              ),

              const SizedBox(height: 32),

              _secondsRemaining == 0
                  ? ClickableText(text: 'Resend Code', onTap: _resendCode)
                  : Text(
                      'Resend Code in $_formattedTime',
                      style: const TextStyle(color: AppColors.textSecondary),
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
