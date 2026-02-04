import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../widgets/main_header.dart';
import '../widgets/main_bottom_navigation.dart';
import '../widgets/headline.dart';
import '../widgets/long_info_box.dart';
import '../widgets/main_button.dart';

class MotherMoreInfoPage extends StatelessWidget {
  MotherMoreInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,

      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(72),
        child: MainHeader(
          title: 'PREGNANCY CARE',
          onNotificationTap: () {},
          onAvatarTap: () {},
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Headline(
                text: 'Taking Care of Yourself 🌷',
                textAlign: TextAlign.left,
              ),

              const SizedBox(height: 12),

              const Text(
                'Pregnancy is a special journey. Here are simple tips to help keep you and your baby healthy.',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),

              const SizedBox(height: 24),

              LongInfoBox(
                icon: Icons.restaurant,
                text: const [
                  TextSpan(
                    text: 'Nutrition & Hydration\n',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  TextSpan(
                    text:
                        '• Eat balanced meals daily.\n'
                        '• Drink plenty of water.\n'
                        '• Take prenatal vitamins if prescribed.\n'
                        '• Avoid alcohol and smoking.',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              LongInfoBox(
                icon: Icons.favorite,
                text: const [
                  TextSpan(
                    text: 'Body Changes\n',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  TextSpan(
                    text:
                        '• Fatigue and nausea are normal.\n'
                        '• Back pain may occur.\n'
                        '• Get enough rest.\n'
                        '• Avoid heavy lifting.',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              LongInfoBox(
                icon: Icons.self_improvement,
                text: const [
                  TextSpan(
                    text: 'Mental Health\n',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  TextSpan(
                    text:
                        '• Mood changes are normal.\n'
                        '• Talk to loved ones.\n'
                        '• Do relaxing activities.\n'
                        '• Ask for help if needed.',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              LongInfoBox(
                icon: Icons.health_and_safety,
                text: const [
                  TextSpan(
                    text: 'Safety Tips\n',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  TextSpan(
                    text:
                        '• Avoid self-medication.\n'
                        '• Stay away from smoke.\n'
                        '• Wear comfortable footwear.\n'
                        '• Attend prenatal checkups.',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // ✅ EXIT BUTTON
              MainButton(
                label: 'Exit',
                showIcons: true,
                leadingIcon: Icons.arrow_back,
                onPressed: () {
                  Navigator.pop(context);
                },
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),

      bottomNavigationBar: const MainBottomNavigation(currentIndex: 0),
    );
  }
}
