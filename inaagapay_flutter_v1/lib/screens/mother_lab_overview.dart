import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/secondary_header.dart';
import '../widgets/hero_card.dart';
import '../widgets/records_display_card.dart';

import '../services/api_service.dart';
import '../utils/session.dart';

class MotherLabOverview extends StatelessWidget {
  final VoidCallback onViewDetails;

  const MotherLabOverview({super.key, required this.onViewDetails});

  Future<Map<String, dynamic>> _fetchLabs() async {
    return await ApiService.get(
      'mother/lab_records.php',
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
          title: 'Laboratory Test Results',
          onBack: () => Navigator.pop(context),
        ),
      ),

      body: FutureBuilder<Map<String, dynamic>>(
        future: _fetchLabs(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final records = snapshot.data!['records'] as List;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                HeroCard(
                  image: const AssetImage('assets/images/lab.png'),
                  title: 'Laboratory Records',
                  showHeartRow: false,
                  showWeekBadge: false,
                ),

                const SizedBox(height: 20),

                RecordsDisplayCard(
                  title: 'Laboratory Test History',
                  headerIcon: Icons.history,
                  items: records.map((l) {
                    return RecordItem(
                      leadingIcon: Icons.calendar_today,
                      label: l['lab_test_date'],
                      value: l['lab_test_type'],
                      trailingWidget:
                          _ViewDetailsPill(onTap: onViewDetails),
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
