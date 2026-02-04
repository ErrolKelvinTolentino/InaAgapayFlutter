import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../widgets/secondary_header.dart';
import '../widgets/hero_card.dart';
import '../widgets/records_display_card.dart';
import '../widgets/important_button.dart';
import '../widgets/status_indicator.dart';

import '../services/api_service.dart';
import '../utils/session.dart';

class MotherPrenatalOverview extends StatelessWidget {
  final VoidCallback onViewGrowth;
  final VoidCallback onViewCheckupDetails;

  const MotherPrenatalOverview({
    super.key,
    required this.onViewGrowth,
    required this.onViewCheckupDetails,
  });

  Future<Map<String, dynamic>> _fetchPrenatal() async {
    return await ApiService.get(
      'mother/prenatal_overview.php',
      token: Session.token,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,

      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: SecondaryHeader(
          title: 'Prenatal Check-ups',
          onBack: () => Navigator.pop(context),
        ),
      ),

      body: FutureBuilder<Map<String, dynamic>>(
        future: _fetchPrenatal(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!;
          final latest = data['latest'];
          final history = (data['history'] ?? []) as List;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                HeroCard(
                  image: const AssetImage('assets/images/prenatal.png'),
                  title: 'Prenatal Records',
                  showHeartRow: false,
                  showWeekBadge: false,
                ),

                const SizedBox(height: 20),

                RecordsDisplayCard(
                  title: 'Overview',
                  headerIcon: Icons.info_outline_rounded,
                  layout: RecordsCardLayout.grouped,
                  items: [
                    RecordItem(
                      leadingIcon: Icons.medical_services,
                      label: 'Latest Health Center Visit',
                      value: latest?['checkup_date'] ?? '--',
                      centerGroupTitle: true,
                    ),
                    RecordItem(
                      leadingIcon: Icons.calendar_today,
                      label: '(Recommended) Next Visit',
                      value: latest?['next_schedule'] ?? '--',
                      centerGroupTitle: true,
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                RecordsDisplayCard(
                  title: 'Latest Growth Records',
                  headerIcon: Icons.bar_chart,
                  items: [
                    RecordItem(
                      leadingIcon: Icons.monitor_weight,
                      label: 'Weight',
                      value: latest?['checkup_weight'] != null
                          ? '${latest['checkup_weight']} kg'
                          : '-- kg',
                    ),
                    RecordItem(
                      leadingIcon: Icons.favorite,
                      label: 'Blood Pressure',
                      value: latest != null
                          ? '${latest['blood_pressure_systolic']}/${latest['blood_pressure_diastolic']}'
                          : '--',
                      trailingWidget: const StatusIndicator(
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
                  items: history.map((c) {
                    return RecordItem(
                      leadingIcon: Icons.calendar_today,
                      label: c['checkup_date'],
                      value: '',
                      trailingWidget:
                          _ViewDetailsPill(onTap: onViewCheckupDetails),
                    );
                  }).toList(),
                ),
              ],
            ),
          );
        },
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
