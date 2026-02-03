import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../widgets/secondary_header.dart';
import '../widgets/hero_card.dart';
import '../widgets/records_display_card.dart';
import '../widgets/important_button.dart';
import '../widgets/status_indicator.dart';

class MotherPrenatalOverview extends StatelessWidget {
  final VoidCallback onViewGrowth;
  final VoidCallback onViewCheckupDetails;

  const MotherPrenatalOverview({
    super.key,
    required this.onViewGrowth,
    required this.onViewCheckupDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,

      // 🔝 HEADER
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: SecondaryHeader(
          title: 'Prenatal Check-ups',
          onBack: () {
            Navigator.pop(context); // 👈 goes back to mother_records_page
          },
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // 👩‍🍼 HERO
            HeroCard(
              image: const AssetImage('assets/images/prenatal.png'),
              title: 'First Name MI. Last Name',
              showHeartRow: false,
              showWeekBadge: false,
            ),

            const SizedBox(height: 20),

            // 🧠 OVERVIEW (GROUPED FORMAT)
            RecordsDisplayCard(
              title: 'Overview',
              headerIcon: Icons.info_outline_rounded,
              layout: RecordsCardLayout.grouped,
              items: const [
                RecordItem(
                  leadingIcon: Icons.medical_services_rounded,
                  label: 'Latest Health Center Visit',
                  value: 'Month Day, Year',
                  centerGroupTitle: true,
                ),
                RecordItem(
                  leadingIcon: Icons.calendar_today_rounded,
                  label: '(Recommended) Next Visit',
                  value: 'Month Day, Year',
                  centerGroupTitle: true,
                ),
              ],
            ),

            const SizedBox(height: 16),

            // 📈 LATEST GROWTH RECORDS
            RecordsDisplayCard(
              headerIcon: Icons.bar_chart_rounded,
              title: 'Latest Growth Records',
              items: const [
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
                  value: '__ kg/m²',
                  trailingWidget: StatusIndicator(
                    status: StatusIndicatorType.normal,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // 🔥 PRIMARY CTA (SEPARATE — NOT A RECORD ROW)
            ImportantButton(
              label: 'View Growth Statistics',
              leadingIcon: Icons.show_chart_rounded,
              onPressed: onViewGrowth,
            ),

            const SizedBox(height: 20),

            // 🕘 CHECKUP HISTORY
            RecordsDisplayCard(
              headerIcon: Icons.history,
              title: 'Checkup History',
              items: [
                RecordItem(
                  leadingIcon: Icons.calendar_today_outlined,
                  label: 'Month Day, Year',
                  value: '',
                  trailingWidget: _ViewDetailsPill(onTap: onViewCheckupDetails),
                ),
                RecordItem(
                  leadingIcon: Icons.calendar_today_outlined,
                  label: 'Month Day, Year',
                  value: '',
                  trailingWidget: _ViewDetailsPill(onTap: onViewCheckupDetails),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/* -------------------------------------------------------------------------- */
/*                          VIEW DETAILS PILL BUTTON                           */
/* -------------------------------------------------------------------------- */

class _ViewDetailsPill extends StatelessWidget {
  final VoidCallback onTap;

  const _ViewDetailsPill({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.brandPrimary),
        ),
        child: const Text(
          'View Details',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.brandPrimary,
          ),
        ),
      ),
    );
  }
}
