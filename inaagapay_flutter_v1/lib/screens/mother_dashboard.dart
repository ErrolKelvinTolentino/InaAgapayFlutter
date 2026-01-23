import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../widgets/main_header.dart';
import '../widgets/main_bottom_navigation.dart';
import '../widgets/headline.dart';
import '../widgets/small_description.dart';

import '../widgets/hero_card.dart';
import '../widgets/small_info_box.dart';
import '../widgets/long_info_box.dart';
import '../widgets/comparison_card.dart';

import '../widgets/main_button.dart';
import '../widgets/secondary_button.dart';

class MotherDashboard extends StatelessWidget {
  const MotherDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    // 🔧 TEMP HARD-CODED DATA (backend later)
    const int week = 10;
    const String trimester = 'First Trimester';

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,

      // 🔝 Header
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(72),
        child: MainHeader(
          title: 'HOME',
          onNotificationTap: () {
            // TODO: notifications
          },
          onAvatarTap: () {
            // TODO: profile
          },
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
              const Headline(
                text: 'Welcome, First Name! 🌸',
              ),

              const SizedBox(height: 8),

              SmallDescription(
                icon: Icons.calendar_today,
                text: 'Week $week • $trimester',
              ),

              const SizedBox(height: 20),

              // 🧸 HERO CARD
              const HeroCard(
                imagePath: 'assets/images/pregnant1.png',
                message: 'Your baby is growing beautifully!',
                week: week,
                showWeekBadge: true,
              ),

              const SizedBox(height: 20),

              // 📦 Baby stats
              Row(
                children: const [
                  SmallInfoBox(
                    icon: Icons.straighten,
                    title: 'Baby Size',
                    value: '0.1 – 0.2 cm',
                  ),
                  SizedBox(width: 12),
                  SmallInfoBox(
                    icon: Icons.monitor_weight,
                    title: 'Baby Weight',
                    value: '< 1 g',
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // 📅 Due date
              const LongInfoBox(
                icon: Icons.calendar_month,
                title: 'Due Date: Month Day, Year',
                subtitle: 'You are X weeks away from meeting!',
              ),

              const SizedBox(height: 16),

              // 🫐 Comparison
              const ComparisonCard(
                label: 'Your baby is now as big as',
                comparison: 'A Blueberry!',
                imagePath: 'assets/images/blueberry.png',
              ),

              const SizedBox(height: 20),

              // 🔔 Next check-up
              const LongInfoBox(
                icon: Icons.notifications,
                title: 'Next Check-up',
                subtitle: 'Month Day, Year – Day',
                borderColor: AppColors.borderPrimary,
              ),

              const SizedBox(height: 24),

              // 🔘 Actions (USING DESIGN SYSTEM BUTTONS)
              MainButton(
                label: 'More Info',
                showIcons: true,
                leadingIcon: Icons.info_outline,
                onPressed: () {
                  // TODO: navigate to more info
                },
              ),

              const SizedBox(height: 12),

              SecondaryButton(
  label: 'Conclude Pregnancy',
  showIcons: true,
  leadingIcon: Icons.check,
  onPressed: () {
    // TODO
  },
),


              const SizedBox(height: 40),
            ],
          ),
        ),
      ),

      // 🔻 Bottom Nav
      bottomNavigationBar: MainBottomNavigation(
        currentIndex: 0,
        onTap: (index) {
          // TODO: handle navigation
        },
      ),
    );
  }
}
