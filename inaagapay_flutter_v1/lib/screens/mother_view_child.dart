import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../widgets/secondary_header.dart';
import '../widgets/main_bottom_navigation.dart';

import '../widgets/hero_card.dart';
import '../widgets/records_display_card.dart';
import '../widgets/status_indicator.dart';
import '../widgets/important_button.dart';

class MotherViewChildPage extends StatelessWidget {
  final VoidCallback onBackToChildren;
  final VoidCallback onViewGrowth;
  final VoidCallback onViewVaccines;

  const MotherViewChildPage({
    super.key,
    required this.onBackToChildren,
    required this.onViewGrowth,
    required this.onViewVaccines,
  });



  @override
  Widget build(BuildContext context) {
    // 🔧 TEMP DATA (backend later)
    const String childName = 'First Name MI. Last Name';
    const String childAge = 'XX Years Old';

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,

      // 🔝 Header
      appBar: PreferredSize(
  preferredSize: const Size.fromHeight(56),
  child: SecondaryHeader(
    title: 'Child Information',
    onBack: onBackToChildren,
  ),
),


      // 🔽 Body
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            children: [
              // 👶 Child Hero
              HeroCard(
                image: const AssetImage('assets/images/baby.png'),
                title: childName,
                subtitle: childAge,
                showWeekBadge: false,
                showHeartRow: false,
              ),

              const SizedBox(height: 24),

              // 🎂 Birth Details
              RecordsDisplayCard(
                title: 'Birth Details',
                headerIcon: Icons.cake_outlined,
                items: const [
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

              // 📈 Latest Growth Records
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
                      // TODO: open height history
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
                      // TODO: open weight history
                    },
                  ),
                  RecordItem(
                    leadingIcon: Icons.calculate,
                    label: 'BMI',
                    value: '__ kg/m²',
                    trailingWidget: const StatusIndicator(
                      status: StatusIndicatorType.obese,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              ImportantButton(
  label: 'View Growth Statistics',
  leadingIcon: Icons.bar_chart_rounded,
  onPressed: onViewGrowth, // ✅ THIS is the fix
),


              const SizedBox(height: 20),
              // 💉 Latest Immunization
              RecordsDisplayCard(
                title: 'Latest Immunization',
                headerIcon: Icons.vaccines_outlined,
                items: const [
                  RecordItem(
                    leadingIcon: Icons.vaccines,
                    label: 'Name',
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

              // 🔘 Important Action
              ImportantButton(
  label: 'View Vaccination Details',
  leadingIcon: Icons.vaccines_outlined,
  onPressed: onViewVaccines,
),


              const SizedBox(height: 20),

              // ⏭ Next Immunization
              RecordsDisplayCard(
                title: 'Next Immunization',
                headerIcon: Icons.schedule_outlined,
                items: const [
                  RecordItem(
                    leadingIcon: Icons.vaccines,
                    label: 'Name',
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

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),

      // 🔻 Bottom Navigation
      bottomNavigationBar: MainBottomNavigation(
        currentIndex: 2, // Children tab
      ),
    );
  }
}
