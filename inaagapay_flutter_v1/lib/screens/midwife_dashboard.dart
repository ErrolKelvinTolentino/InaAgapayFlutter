import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

// layout
import '../widgets/main_header.dart';
import '../widgets/midwife_bottom_navigation.dart';

// reusable widgets
import '../widgets/main_button.dart';
import '../widgets/hero_card.dart';

// dashboard widgets
import '../widgets/overview_info.dart';
import '../widgets/midwife_statistics_card.dart';
import '../widgets/midwife_history_card.dart';

import '../models/add_child_form_data.dart';

class MidwifeDashboard extends StatelessWidget {
  const MidwifeDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,

      bottomNavigationBar: const MidwifeBottomNavigation(currentIndex: 0),

      body: Column(
        children: [
          MainHeader(
            title: 'Home',
            onNotificationTap: () {},
            onAvatarTap: () {},
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  const SizedBox(height: 16),

                  HeroCard(
                    image: const AssetImage('assets/images/midwife.png'),
                    title: 'Welcome, [First Name]! 🌸',
                    subtitle: 'Barangay Sta. Barbara Midwife',
                    showWeekBadge: false,
                    showHeartRow: false,
                  ),

                  const SizedBox(height: 20),

                  Row(
                    children: const [
                      Expanded(
                        child: OverviewInfo(
                          value: 12,
                          label: 'Registered\nChildren',
                          icon: Icons.child_care_rounded,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: OverviewInfo(
                          value: 24,
                          label: 'Registered\nMothers',
                          icon: Icons.pregnant_woman,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: OverviewInfo(
                          value: 12,
                          label: 'RHU Visits\nThis week',
                          icon: Icons.local_hospital,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  const MidwifeStatisticsCard(
                    totalPregnancies: 13,
                    firstTrimester: 4,
                    secondTrimester: 5,
                    thirdTrimester: 4,
                  ),

                  const SizedBox(height: 20),

                  MidwifeHistoryCard(
                    visits: const [
                      MidwifeVisitItem(
                        fullName: 'First Name Last Name',
                        visitType: 'Visit Type',
                        timeLabel: 'Today',
                      ),
                      MidwifeVisitItem(
                        fullName: 'First Name Last Name',
                        visitType: 'Visit Type',
                        timeLabel: 'Yesterday',
                      ),
                      MidwifeVisitItem(
                        fullName: 'First Name Last Name',
                        visitType: 'Visit Type',
                        timeLabel: '2 days ago',
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  MainButton(
                    label: 'Register Mother',
                    showIcons: true,
                    leadingIcon: Icons.person_add,
                    onPressed: () {},
                  ),

                  const SizedBox(height: 12),

                  MainButton(
                    label: 'Register Child',
                    showIcons: true,
                    leadingIcon: Icons.add,
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        '/midwife-add-parent',
                        arguments: AddChildFormData(),
                      );
                    },
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
