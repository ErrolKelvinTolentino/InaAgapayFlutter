import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/page_title.dart';

class MidwifeDashboard extends StatelessWidget {
  const MidwifeDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              PageTitle(
                title: 'Midwife Dashboard',
                leadingIcon: Icons.medical_services,
                trailingIcon: Icons.check_circle,
              ),
              SizedBox(height: 12),
              Text(
                'Logged in as: Midwife',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
