import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/app_input_field.dart';
import '../widgets/main_button.dart';
import '../widgets/clickable_text.dart';
import '../services/api_service.dart';
import '../utils/session.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _loading = false;
  bool _error = false;

  Future<void> _handleLogin() async {
    if (_loading) return;

    setState(() {
      _loading = true;
      _error = false;
    });

    final res = await ApiService.post(
      'auth/login.php',
      {
        'email': _emailController.text.trim(),
        'password': _passwordController.text,
      },
    );

    setState(() => _loading = false);

    if (!res['success']) {
      setState(() => _error = true);
      return;
    }

    // ✅ Save token
    Session.token = res['token'];

    final bool profileComplete =
        res['user']['profile_complete'] == true;

    if (!mounted) return;

    if (profileComplete) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/mother-dashboard',
        (route) => false,
      );
    } else {
      Navigator.pushNamed(context, '/complete-profile');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),

              Image.asset('assets/images/logo.png', height: 146),

              const SizedBox(height: 20),
              Image.asset(
                'assets/images/inaagapay_name.png',
                width: 282,
                fit: BoxFit.contain,
              ),

              const SizedBox(height: 8),
              const Text(
                'Supporting you through every step',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w400,
                ),
              ),

              const SizedBox(height: 56),

              AppInputField(
                hintText: 'Email Address',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                leadingIcon: Icons.email_outlined,
              ),

              const SizedBox(height: 20),

              AppInputField(
                hintText: 'Password',
                controller: _passwordController,
                obscureText: _obscurePassword,
                leadingIcon: Icons.lock_outline,
                trailingIcon: _obscurePassword
                    ? Icons.visibility_off
                    : Icons.visibility,
                onTrailingTap: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),

              if (_error) ...[
                const SizedBox(height: 12),
                const Text(
                  'Invalid email or password',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.error,
                  ),
                ),
              ],

              const SizedBox(height: 20),

              Align(
                alignment: Alignment.centerRight,
                child: ClickableText(
                  text: 'Forgot Password?',
                  onTap: () {
                    Navigator.pushNamed(context, '/forgot-password');
                  },
                ),
              ),

              const SizedBox(height: 56),

              MainButton(
                label: _loading ? 'Signing in...' : 'Sign in',
                showIcons: false,
                onPressed: _loading ? null : _handleLogin,
              ),

              const SizedBox(height: 32),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'No account yet? ',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  ClickableText(
                    text: 'Register Here',
                    onTap: () {
                      Navigator.pushNamed(context, '/register');
                    },
                  ),
                ],
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
