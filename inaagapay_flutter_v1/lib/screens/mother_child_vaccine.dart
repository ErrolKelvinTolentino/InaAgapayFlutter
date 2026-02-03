import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../widgets/secondary_header.dart';
import '../widgets/small_description.dart';
import '../widgets/vaccine_list.dart';
import '../widgets/hero_card.dart';
import '../widgets/records_display_card.dart';
import '../widgets/status_indicator.dart';
import '../models/vaccine_schedule.dart';

class MotherChildVaccinePage extends StatelessWidget {
  final VoidCallback onBack;

  const MotherChildVaccinePage({super.key, required this.onBack});

  @override
  Widget build(BuildContext context) {
    // 🔧 TEMP MOCK DATA (backend later)
    const int childAgeInWeeks = 8;
    const String childName = 'First Name MI. Last Name';
    const String childAge = 'XX Years Old';

    final Map<String, VaccineStatus> vaccineStatuses = {
      // ✅ DONE
      'bcg': VaccineStatus.done,
      'opv0': VaccineStatus.done,

      // 🟡 SOME DONE, SOME PENDING
      'opv1': VaccineStatus.done,
      'penta1': VaccineStatus.done,
      'pcv1': VaccineStatus.done,
      'rota1': VaccineStatus.pending,

      // 🔒 NOT YET REACHED
      'opv2': VaccineStatus.locked,
      'penta2': VaccineStatus.locked,
      'pcv2': VaccineStatus.locked,
      'rota2': VaccineStatus.locked,
      'opv3': VaccineStatus.locked,
      'penta3': VaccineStatus.locked,
      'pcv3': VaccineStatus.locked,
      'ipv': VaccineStatus.locked,
    };

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,

      // 🔝 Header with back
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(72),
        child: SecondaryHeader(title: 'Vaccination Details', onBack: onBack),
      ),

      // 🔽 Body
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HeroCard(
                image: const AssetImage('assets/images/baby.png'),
                title: childName,
                subtitle: childAge,
                showWeekBadge: false,
                showHeartRow: false,
              ),

              const SizedBox(height: 16),
              const SmallDescription(
                text: 'Track completed, pending, and upcoming vaccines',
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
      value: 'Week 6 vaccines',
    ),
  ],
),


              const SizedBox(height: 16),

              // 💉 VACCINE LIST (At Birth → 14 Weeks)
              VaccineList(
                statuses: vaccineStatuses,
                childAgeInWeeks: childAgeInWeeks,
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
