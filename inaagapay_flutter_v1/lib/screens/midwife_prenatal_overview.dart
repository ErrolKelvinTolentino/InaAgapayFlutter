import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

import '../widgets/secondary_header.dart';
import '../widgets/hero_card.dart';
import '../widgets/records_display_card.dart';
import '../widgets/important_button.dart';
import '../widgets/status_indicator.dart';

class MidwifePrenatalOverview extends StatelessWidget {
  final VoidCallback onViewGrowth;
  final VoidCallback onViewCheckupDetails;

  const MidwifePrenatalOverview({
    super.key,
    required this.onViewGrowth,
    required this.onViewCheckupDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,

      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: SecondaryHeader(
          title: 'Prenatal Check-ups',
          onBack: () => Navigator.pop(context),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            HeroCard(
              image: const AssetImage('assets/images/prenatal.png'),
              title: 'Patient Name',
              showHeartRow: false,
              showWeekBadge: false,
            ),

            const SizedBox(height: 20),

            RecordsDisplayCard(
              title: 'Overview',
              headerIcon: Icons.info_outline,
              layout: RecordsCardLayout.grouped,
              items: const [
                RecordItem(
                  label: 'Latest Visit',
                  value: 'Month Day, Year',
                  centerGroupTitle: true,
                ),
                RecordItem(
                  label: 'Next Recommended Visit',
                  value: 'Month Day, Year',
                  centerGroupTitle: true,
                ),
              ],
            ),

            const SizedBox(height: 16),

            RecordsDisplayCard(
              title: 'Latest Growth Records',
              headerIcon: Icons.bar_chart,
              items: const [
                RecordItem(label: 'Height', value: '__ cm'),
                RecordItem(label: 'Weight', value: '__ kg'),
                RecordItem(
                  label: 'BMI',
                  value: '__',
                  trailingWidget: StatusIndicator(
                    status: StatusIndicatorType.normal,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            ImportantButton(
              label: 'View Growth Statistics',
              leadingIcon: Icons.show_chart,
              onPressed: onViewGrowth,
            ),

            const SizedBox(height: 20),

            RecordsDisplayCard(
              title: 'Checkup History',
              headerIcon: Icons.history,
              items: [
                RecordItem(
                  label: 'Month Day, Year',
                  value: '',
                  trailingWidget: _ViewDetails(onTap: onViewCheckupDetails),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ViewDetails extends StatelessWidget {
  final VoidCallback onTap;
  const _ViewDetails({required this.onTap});

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
