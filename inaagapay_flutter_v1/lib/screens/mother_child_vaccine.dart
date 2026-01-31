import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../widgets/secondary_header.dart';
import '../widgets/small_description.dart';
import '../widgets/vaccine_list.dart';
import '../widgets/hero_card.dart';
import '../widgets/records_display_card.dart';
import '../widgets/status_indicator.dart';
import '../models/vaccine_schedule.dart';

import '../services/api_service.dart';
import '../utils/session.dart';

class MotherChildVaccinePage extends StatefulWidget {
  final VoidCallback onBack;
  final int childId;
  final String childName;
  final String childAge;

  const MotherChildVaccinePage({
    super.key,
    required this.onBack,
    required this.childId,
    required this.childName,
    required this.childAge,
  });

  @override
  State<MotherChildVaccinePage> createState() =>
      _MotherChildVaccinePageState();
}

class _MotherChildVaccinePageState extends State<MotherChildVaccinePage> {
  Future<Map<String, dynamic>> _fetchVaccines() async {
    return await ApiService.get(
      'mother/child_vaccines.php?child_id=${widget.childId}',
      token: Session.token,
    );
  }

  // ✅ SAFE ENUM PARSER (CRITICAL FIX)
  VaccineStatus _parseStatus(String? value) {
    switch (value) {
      case 'done':
        return VaccineStatus.done;
      case 'pending':
        return VaccineStatus.pending;
      case 'locked':
      default:
        return VaccineStatus.locked;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,

      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(72),
        child: SecondaryHeader(
          title: 'Vaccination Details',
          onBack: widget.onBack,
        ),
      ),

      body: FutureBuilder<Map<String, dynamic>>(
        future: _fetchVaccines(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!['success'] != true) {
            return const Center(
              child: Text(
                'Failed to load vaccination data',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            );
          }

          final data = snapshot.data!;
          final Map<String, VaccineStatus> statuses = {};

          (data['statuses'] as Map<String, dynamic>).forEach((key, value) {
            statuses[key] = _parseStatus(value);
          });

          return SafeArea(
            child: SingleChildScrollView(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  HeroCard(
                    image: const AssetImage('assets/images/baby.png'),
                    title: widget.childName,
                    subtitle: widget.childAge,
                    showWeekBadge: false,
                    showHeartRow: false,
                  ),

                  const SizedBox(height: 16),
                  const SmallDescription(
                    text:
                        'Track completed, pending, and upcoming vaccines',
                  ),

                  const SizedBox(height: 16),

                  RecordsDisplayCard(
                    title: 'Overview',
                    headerIcon: Icons.info_outline,
                    items: [
                      RecordItem(
                        leadingIcon: Icons.verified,
                        label: 'Protection Status',
                        value: '',
                        trailingWidget: const StatusIndicator(
                          status: StatusIndicatorType.ongoing,
                        ),
                      ),
                      RecordItem(
                        leadingIcon: Icons.schedule,
                        label: 'Next due',
                        value: data['next_due'] ?? '—',
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  VaccineList(
                    statuses: statuses,
                    childAgeInWeeks: data['child_age_weeks'] ?? 0,
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
