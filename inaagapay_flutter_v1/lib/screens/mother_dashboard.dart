import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/main_header.dart';
import '../widgets/main_bottom_navigation.dart';

class MotherDashboard extends StatelessWidget {
  const MotherDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,

      // 🔝 Header
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(72),
        child: MainHeader(
          title: 'HOME',
          onNotificationTap: () {
            // TODO: open notifications
          },
          onAvatarTap: () {
            // TODO: open profile
          },
          // avatarImage: AssetImage('assets/images/avatar.png'), // optional
        ),
      ),

      // 🔽 Body
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 👋 Welcome
              const Text(
                'Welcome, First Name! 🌸',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.brandPrimary,
                ),
              ),

              const SizedBox(height: 8),

              Row(
                children: const [
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  SizedBox(width: 6),
                  Text(
                    'Week X • First Trimester',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // 🧸 Main Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.bgSecondary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.topRight,
                      children: [
                        Center(
                          child: Container(
                            padding: const EdgeInsets.all(24),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.faintWhite,
                            ),
                            child: Image.asset(
                              'assets/images/pregnant1.png',
                              height: 140,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.brandPrimary,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'Week X',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textOnColor,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(
                          Icons.favorite,
                          size: 16,
                          color: AppColors.brandPrimary,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'Your baby is growing beautifully!',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // 📦 Baby stats
              Row(
                children: [
                  _infoBox(
                    icon: Icons.straighten,
                    title: 'Baby Size',
                    value: '0.1 – 0.2 cm',
                  ),
                  const SizedBox(width: 12),
                  _infoBox(
                    icon: Icons.monitor_weight,
                    title: 'Baby Weight',
                    value: '< 1 g',
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // 📅 Due date
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.brandPrimary),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.calendar_month, color: AppColors.brandPrimary),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Due Date: Month Day, Year\n'
                        'You are X weeks away from meeting!',
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.4,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // 🫐 Fruit comparison
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.brandPrimary.withOpacity(0.15),
                      AppColors.brandPrimary.withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: RichText(
                        text: const TextSpan(
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                          children: [
                            TextSpan(text: 'Your baby is now as big as\n'),
                            TextSpan(
                              text: 'A Blueberry!',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: AppColors.brandPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Image.asset('assets/images/blueberry.png', height: 60),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // 🔔 Next check-up
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.borderPrimary),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.notifications, color: AppColors.brandPrimary),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Next Check-up:\nMonth Day, Year – Day',
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.4,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // 🔘 Buttons
              _actionButton(
                text: 'More Info',
                icon: Icons.info_outline,
                filled: true,
              ),
              const SizedBox(height: 12),
              _actionButton(
                text: 'Conclude Pregnancy',
                icon: Icons.check,
                filled: false,
              ),

              const SizedBox(height: 80),
            ],
          ),
        ),
      ),

      // 🔻 Bottom Nav
      bottomNavigationBar: MainBottomNavigation(
        currentIndex: 0,
        onTap: (index) {
          // TODO: handle navigation later
          // example:
          // if (index == 0) Navigator.pushNamed(context, '/home');
        },
      ),
    );
  }

  // 🔹 Info box
  Widget _infoBox({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.brandPrimary),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.brandPrimary),
            const SizedBox(height: 6),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🔹 Action button
  Widget _actionButton({
    required String text,
    required IconData icon,
    required bool filled,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {},
        icon: Icon(
          icon,
          color: filled ? AppColors.textOnColor : AppColors.brandPrimary,
        ),
        label: Text(text),
        style: ElevatedButton.styleFrom(
          backgroundColor: filled ? AppColors.brandPrimary : Colors.transparent,
          foregroundColor: filled
              ? AppColors.textOnColor
              : AppColors.brandPrimary,
          side: filled ? null : const BorderSide(color: AppColors.brandPrimary),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          elevation: filled ? 2 : 0,
        ),
      ),
    );
  }
}
