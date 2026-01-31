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

import '../models/baby_growth_model.dart';
import '../services/api_service.dart';
import '../utils/session.dart';

class MotherDashboard extends StatelessWidget {
  const MotherDashboard({super.key});

  Future<Map<String, dynamic>> _loadDashboard() async {
    final res = await ApiService.get(
      'mother/dashboard.php',
      token: Session.token,
    );

    if (res == null || res['success'] != true) {
      throw Exception('Failed to load dashboard');
    }

    return res;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,

      // 🔝 Header
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(72),
        child: MainHeader(
          title: 'HOME',
          onNotificationTap: () {},
          onAvatarTap: () {},
        ),
      ),

      // 🔽 Body
      body: SafeArea(
        child: FutureBuilder<Map<String, dynamic>>(
          future: _loadDashboard(),
          builder: (context, snapshot) {
            // ⏳ Loading
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            // ❌ Error
            if (snapshot.hasError || !snapshot.hasData) {
              return const Center(
                child: Text(
                  'Unable to load dashboard',
                  style: TextStyle(color: AppColors.error),
                ),
              );
            }

            final data = snapshot.data!;

            // 🛡 NULL-SAFE EXTRACTION
            final int week = (data['week'] ?? 0) as int;
            final int weeksLeft = (data['weeks_left'] ?? 0) as int;
            final String trimester = data['trimester'] ?? '—';
            final String dueDate = data['due_date'] ?? '—';
            final String firstName = data['first_name'] ?? '';

            final babyGrowth = BabyGrowthData.getForWeek(week);

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 👋 Welcome
                  Center(
                    child: Column(
                      children: [
                        Headline(
                          text: 'Welcome, $firstName! 🌸',
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 8),

                        SmallDescription(
                          icon: Icons.calendar_today,
                          text: week > 0
                              ? 'Week $week • $trimester'
                              : 'Pregnancy not yet set',
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 🧸 HERO CARD
                  HeroCard(
                    image: const AssetImage('assets/images/pregnant1.png'),
                    week: week,
                    showWeekBadge: week > 0,
                    showHeartRow: week > 0,
                  ),

                  const SizedBox(height: 20),

                  // 📦 Baby stats
                  Row(
                    children: [
                      SmallInfoBox(
                        icon: Icons.straighten,
                        title: 'Ideal Baby Size',
                        value: babyGrowth.size,
                      ),
                      const SizedBox(width: 12),
                      SmallInfoBox(
                        icon: Icons.monitor_weight,
                        title: 'Ideal Baby Weight',
                        value: babyGrowth.weight,
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // 📅 Due date
                  LongInfoBox(
                    icon: Icons.calendar_month,
                    text: [
                      const TextSpan(
                        text: 'Due Date: ',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      TextSpan(
                        text: '$dueDate\n',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const TextSpan(
                        text: 'You are ',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      TextSpan(
                        text: week > 0
                            ? '$weeksLeft weeks away'
                            : '—',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.brandPrimary,
                        ),
                      ),
                      const TextSpan(
                        text: ' from meeting!',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // 🫐 Comparison
                  if (week > 0) ComparisonCard(week: week),

                  const SizedBox(height: 20),

                  // 🔔 Next check-up (future feature)
                  const LongInfoBox(
                    icon: Icons.notifications,
                    borderColor: AppColors.borderPrimary,
                    iconColor: AppColors.brandPrimary,
                    text: [
                      TextSpan(
                        text: 'Next Check-up\n',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      TextSpan(
                        text: 'No scheduled visit yet',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // 🔘 Actions
                  MainButton(
                    label: 'More Info',
                    showIcons: true,
                    leadingIcon: Icons.info_outline,
                    onPressed: () {},
                  ),

                  const SizedBox(height: 12),

                  SecondaryButton(
                    label: 'Conclude Pregnancy',
                    showIcons: true,
                    leadingIcon: Icons.check,
                    onPressed: () {},
                  ),

                  const SizedBox(height: 10),
                ],
              ),
            );
          },
        ),
      ),

      // 🔻 Bottom Nav
      bottomNavigationBar: const MainBottomNavigation(
        currentIndex: 0,
      ),
    );
  }
}
