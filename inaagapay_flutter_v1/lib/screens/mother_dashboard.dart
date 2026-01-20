import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/page_title.dart';

class MotherDashboard extends StatelessWidget {
  const MotherDashboard({super.key});

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
                title: 'Mother Dashboard',
                leadingIcon: Icons.pregnant_woman,
                trailingIcon: Icons.favorite,
              ),
              SizedBox(height: 12),
              Text(
                'Logged in as: Mother',
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
