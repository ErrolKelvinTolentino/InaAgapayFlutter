import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

// layout
import '../widgets/secondary_header.dart';
import '../widgets/midwife_bottom_navigation.dart';

// reusable widgets
import '../widgets/hero_card.dart';
import '../widgets/records_display_card.dart';
import '../widgets/status_indicator.dart';
import '../widgets/important_button.dart';

// history widget
import '../widgets/midwife_history_card.dart';

class MidwifeMotherOverviewPage extends StatelessWidget {
  const MidwifeMotherOverviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    // 🔧 TEMP MOCK DATA (backend later)
    const String motherName = 'First Name MI. Last Name';
    const String pregnancyWeeks = 'XX Weeks Pregnant';

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,

      /// 🔝 HEADER
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: SecondaryHeader(
          title: 'Mother Information',
          onBack: () => Navigator.pop(context),
        ),
      ),

      /// 🔽 BODY
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            children: [
              /// 🤰 HERO CARD
              HeroCard(
                image: const AssetImage('assets/images/pregnant1.png'),
                title: motherName,
                subtitle: pregnancyWeeks,
                showWeekBadge: false,
                showHeartRow: false,
              ),

              const SizedBox(height: 24),

              /// 👤 PATIENT INFORMATION
              const RecordsDisplayCard(
                title: 'Patient Information',
                headerIcon: Icons.person_outline,
                items: [
                  RecordItem(
                    leadingIcon: Icons.calendar_month_rounded,
                    label: 'Birth date',
                    value: 'Month Day, Year',
                  ),
                  RecordItem(
                    leadingIcon: Icons.phone_outlined,
                    label: 'Contact',
                    value: 'XXXXXXXXXX',
                  ),
                  RecordItem(
                    leadingIcon: Icons.location_on_outlined,
                    label: 'Address',
                    value: 'Street, Barangay',
                  ),
                ],
              ),

              const SizedBox(height: 16),

              /// 🤰 LATEST PREGNANCY DETAILS
              const RecordsDisplayCard(
                title: 'Latest Pregnancy Details',
                headerIcon: Icons.pregnant_woman,
                items: [
                  RecordItem(
                    leadingIcon: Icons.calendar_today_rounded,
                    label: 'EDD',
                    value: 'Month Day, Year',
                  ),
                  RecordItem(
                    leadingIcon: Icons.date_range,
                    label: 'LMP',
                    value: 'Month Day, Year',
                  ),
                  RecordItem(
                    leadingIcon: Icons.timeline,
                    label: 'AOG',
                    value: 'XX weeks',
                  ),
                ],
              ),

              const SizedBox(height: 16),

              /// 🗂️ RECENT VISITS (✅ USING YOUR WIDGET)
              MidwifeHistoryCard(
                visits: const [
                  MidwifeVisitItem(
                    fullName: 'First Name Last Name',
                    visitType: 'Prenatal Checkup',
                    timeLabel: 'Today',
                  ),
                  MidwifeVisitItem(
                    fullName: 'First Name Last Name',
                    visitType: 'Ultrasound',
                    timeLabel: 'Yesterday',
                  ),
                  MidwifeVisitItem(
                    fullName: 'First Name Last Name',
                    visitType: 'Lab Test',
                    timeLabel: '2 days ago',
                  ),
                ],
                onTapItem: () {
                  // TODO: navigate to visit details
                },
              ),

              const SizedBox(height: 20),

              /// 🔘 VIEW PREGNANCY RECORDS
              ImportantButton(
                label: 'View Pregnancy Records',
                leadingIcon: Icons.favorite,
                onPressed: () {
                  // TODO: navigate to pregnancy records stack
                },
              ),

              const SizedBox(height: 20),

              /// 📈 LATEST GROWTH RECORDS
              const RecordsDisplayCard(
                title: 'Latest Growth Records',
                headerIcon: Icons.bar_chart_rounded,
                items: [
                  RecordItem(
                    leadingIcon: Icons.height,
                    label: 'Height',
                    value: '__ cm',
                  ),
                  RecordItem(
                    leadingIcon: Icons.monitor_weight,
                    label: 'Weight',
                    value: '__ kg',
                  ),
                  RecordItem(
                    leadingIcon: Icons.calculate,
                    label: 'BMI',
                    value: '---',
                    trailingWidget: StatusIndicator(
                      status: StatusIndicatorType.normal,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),

      /// 🔻 BOTTOM NAV
      bottomNavigationBar: const MidwifeBottomNavigation(
        currentIndex: 1, // ✅ Mothers tab active
      ),
    );
  }
}
