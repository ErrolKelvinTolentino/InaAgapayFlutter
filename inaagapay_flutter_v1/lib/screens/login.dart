import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/app_input_field.dart';
import '../widgets/main_button.dart';
import '../widgets/clickable_text.dart';
import '../services/auth_service.dart';
import '../services/auth_storage.dart'; // ✅ ADD THIS

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final response = await AuthService.login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (response.success) {
      // 🔐 SAVE TOKEN (NEW)
      if (response.token != null) {
        await AuthStorage.saveToken(response.token!);
      }

      final user = response.user;

      // ✅ ROLE-BASED NAVIGATION (UNCHANGED)
      if (user?['role'] == 'mother') {
        Navigator.pushReplacementNamed(context, '/mother_dashboard');
      } else if (user?['role'] == 'midwife') {
        Navigator.pushReplacementNamed(context, '/midwife_dashboard');
      } else if (user?['role'] == 'admin') {
        Navigator.pushReplacementNamed(context, '/admin_dashboard');
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Unknown user role')));
      }
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(response.message)));
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

              Image.asset('assets/images/inaagapay_name.png', width: 282),

              const SizedBox(height: 8),

              const Text(
                'Supporting you through every step',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
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
                label: _isLoading ? 'Signing in...' : 'Sign in',
                showIcons: false,
                onPressed: _isLoading ? null : _handleLogin,
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
