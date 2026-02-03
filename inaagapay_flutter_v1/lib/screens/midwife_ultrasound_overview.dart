import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/secondary_header.dart';
import '../widgets/hero_card.dart';
import '../widgets/records_display_card.dart';

class MidwifeUltrasoundOverview extends StatelessWidget {
  final VoidCallback onViewDetails;

  const MidwifeUltrasoundOverview({
    super.key,
    required this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,

      /// 🔝 HEADER
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: SecondaryHeader(
          title: 'Ultrasound Records',
          onBack: () => Navigator.pop(context),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            /// 🤰 HERO
            HeroCard(
              image: const AssetImage('assets/images/prenatal.png'),
              title: 'First Name MI. Last Name',
              subtitle: 'XX Weeks Pregnant',
              showHeartRow: false,
              showWeekBadge: false,
            ),

            const SizedBox(height: 20),

            /// 🧠 OVERVIEW
            RecordsDisplayCard(
              title: 'Overview',
              headerIcon: Icons.info_outline_rounded,
              layout: RecordsCardLayout.grouped,
              items: const [
                RecordItem(
                  leadingIcon: Icons.monitor_heart_rounded,
                  label: 'Latest Ultrasound Record',
                  value: 'Month Day, Year',
                  centerGroupTitle: true,
                ),
              ],
            ),

            const SizedBox(height: 16),

            /// 🩻 ULTRASOUND HISTORY
            RecordsDisplayCard(
              title: 'Ultrasound History',
              headerIcon: Icons.history_rounded,
              items: [
                RecordItem(
                  leadingIcon: Icons.calendar_today_rounded,
                  label: 'Month Day, Year',
                  value: '',
                  trailingWidget: _ViewDetailsPill(onTap: onViewDetails),
                ),
                RecordItem(
                  leadingIcon: Icons.calendar_today_rounded,
                  label: 'Month Day, Year',
                  value: '',
                  trailingWidget: _ViewDetailsPill(onTap: onViewDetails),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

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
