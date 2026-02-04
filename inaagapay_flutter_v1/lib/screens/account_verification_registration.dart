import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/main_button.dart';
import '../widgets/otp_input_field.dart';
import '../widgets/validation_message.dart';
import '../widgets/clickable_text.dart';
import '../widgets/dialog_box.dart';
import '../widgets/page_title.dart';
import '../services/register_service.dart';

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
  String _errorMessage = 'Incorrect or expired code. Please try again.';
  bool _loading = false;

  String _email = '';
  bool _linkedExisting = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Extract email from route arguments
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map) {
      _email = (args['email'] as String?) ?? '';
      _linkedExisting = args['linkedExisting'] == true;
    } else if (args is String) {
      _email = args;
      _linkedExisting = false;
    }

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

  Future<void> _verifyCode() async {
    if (_email.isEmpty) {
      setState(() {
        _hasError = true;
        _errorMessage = 'Missing email. Please restart registration.';
      });
      return;
    }

    setState(() {
      _loading = true;
      _hasError = false;
      _errorMessage = 'Incorrect or expired code. Please try again.';
    });

    final result = await RegisterService.verifyCode(email: _email, code: _code);

    if (!mounted) return;

    if (!result.success) {
      setState(() {
        _loading = false;
        _hasError = true;
        _errorMessage = result.message;
      });
      return;
    }

    setState(() => _loading = false);

    // Choose dialog based on linking or new verification
    if (_linkedExisting) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => DialogBox(
          title: 'Account Linked',
          subtitle: 'You have existing data from a Barangay Health Center',
          buttonText: 'Continue',
          type: DialogType.success,
          onPressed: () {
            Navigator.pop(context);
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/mother-dashboard',
              (route) => false,
            );
          },
        ),
      );
    } else {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => DialogBox(
          title: 'Account Verified!',
          subtitle: result.message,
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
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: ValidationMessage(
                    message: _errorMessage,
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
