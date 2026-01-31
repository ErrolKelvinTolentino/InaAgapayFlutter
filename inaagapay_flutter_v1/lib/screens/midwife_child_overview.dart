import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../widgets/secondary_header.dart';
import '../widgets/midwife_bottom_navigation.dart';

import '../widgets/hero_card.dart';
import '../widgets/records_display_card.dart';
import '../widgets/status_indicator.dart';
import '../widgets/important_button.dart';
import 'midwife_child_growth.dart';
import 'midwife_child_vaccine.dart';

class MidwifeChildOverviewPage extends StatelessWidget {
  const MidwifeChildOverviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    // 🔧 TEMP DATA (backend later)
    const String childName = 'First Name MI. Last Name';
    const String childAge = 'XX Years Old';

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,

      /// 🔝 Header (BACK = Navigator.pop)
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: SecondaryHeader(
          title: 'Child Information',
          onBack: () {
            Navigator.pop(context); // ✅ CORRECT
          },
        ),
      ),

      /// 🔽 Body
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            children: [
              /// 👶 Child Hero
              HeroCard(
                image: const AssetImage('assets/images/baby.png'),
                title: childName,
                subtitle: childAge,
                showWeekBadge: false,
                showHeartRow: false,
              ),

              const SizedBox(height: 24),

              /// 👪 Parent Information
              const RecordsDisplayCard(
                title: 'Parent Information',
                headerIcon: Icons.family_restroom_outlined,
                items: [
                  RecordItem(
                    leadingIcon: Icons.person_outline,
                    label: 'Parent Name',
                    value: 'First name last name',
                  ),
                  RecordItem(
                    leadingIcon: Icons.phone_outlined,
                    label: 'Contact',
                    value: '09XXXXXXXXX',
                  ),
                  RecordItem(
                    leadingIcon: Icons.location_on_outlined,
                    label: 'Address',
                    value: 'Street, Barangay',
                  ),
                ],
              ),

              const SizedBox(height: 16),

              /// 🎂 Birth Details
              const RecordsDisplayCard(
                title: 'Birth Details',
                headerIcon: Icons.cake_outlined,
                items: [
                  RecordItem(
                    leadingIcon: Icons.calendar_month_rounded,
                    label: 'Birth Date',
                    value: 'Month Day, Year',
                  ),
                  RecordItem(
                    leadingIcon: Icons.schedule,
                    label: 'Time of Birth',
                    value: '10:00 AM',
                  ),
                  RecordItem(
                    leadingIcon: Icons.location_on_outlined,
                    label: 'Birthplace',
                    value: 'City',
                  ),
                ],
              ),

              const SizedBox(height: 16),

              /// 📈 Latest Growth Records
              RecordsDisplayCard(
                title: 'Latest Growth Records',
                headerIcon: Icons.bar_chart_rounded,
                items: [
                  RecordItem(
                    leadingIcon: Icons.height,
                    label: 'Height',
                    value: '__ cm',
                    trailingWidget: const Icon(
                      Icons.arrow_upward,
                      size: 14,
                      color: AppColors.success,
                    ),
                    onTap: () {
                      // TODO: view growth history
                    },
                  ),
                  RecordItem(
                    leadingIcon: Icons.monitor_weight,
                    label: 'Weight',
                    value: '__ kg',
                    trailingWidget: const Icon(
                      Icons.arrow_downward,
                      size: 14,
                      color: AppColors.error,
                    ),
                    onTap: () {
                      // TODO: view growth history
                    },
                  ),
                  const RecordItem(
                    leadingIcon: Icons.calculate,
                    label: 'BMI',
                    value: '__ kg/m²',
                    trailingWidget: StatusIndicator(
                      status: StatusIndicatorType.normal,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              /// 🔘 View Growth
              ImportantButton(
                label: 'View Growth Statistics',
                leadingIcon: Icons.bar_chart_rounded,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MidwifeChildGrowthPage(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 20),

              /// 💉 Latest Immunization
              const RecordsDisplayCard(
                title: 'Latest Immunization',
                headerIcon: Icons.vaccines_outlined,
                items: [
                  RecordItem(
                    leadingIcon: Icons.vaccines,
                    label: 'Vaccine Name',
                    value: 'Vaccine Name',
                  ),
                  RecordItem(
                    leadingIcon: Icons.calendar_month_rounded,
                    label: 'Taken',
                    value: 'MM/DD/YYYY',
                    trailingWidget: StatusIndicator(
                      status: StatusIndicatorType.onTime,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              /// 🔘 View Vaccines
              ImportantButton(
                label: 'View Vaccination Details',
                leadingIcon: Icons.vaccines_outlined,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MidwifeChildVaccinePage(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 20),

              /// ⏭ Next Immunization
              const RecordsDisplayCard(
                title: 'Next Immunization',
                headerIcon: Icons.schedule_outlined,
                items: [
                  RecordItem(
                    leadingIcon: Icons.vaccines,
                    label: 'Vaccine Name',
                    value: 'Vaccine Name',
                  ),
                  RecordItem(
                    leadingIcon: Icons.person_outline,
                    label: 'For Age',
                    value: 'XX Months',
                    trailingWidget: StatusIndicator(
                      status: StatusIndicatorType.overdue,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),

      /// 🔻 Bottom Nav
      bottomNavigationBar: const MidwifeBottomNavigation(currentIndex: 2),
    );
  }
}
