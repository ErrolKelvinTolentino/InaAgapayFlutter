import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../widgets/secondary_header.dart';
import '../widgets/records_display_card.dart';
import '../widgets/hero_card.dart';
import '../widgets/ai_analytics_card.dart';

class MotherCheckupDetailsPage extends StatelessWidget {
  final VoidCallback onBack;

  const MotherCheckupDetailsPage({
    super.key,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,

      // 🔝 HEADER
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: SecondaryHeader(
          title: 'Check-up Details',
          onBack: onBack,
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: const [

            HeroCard(
              image: const AssetImage('assets/images/prenatal.png'),
              title: 'First Name MI. Last Name',
              showHeartRow: false,
              showWeekBadge: false,
            ),

            const SizedBox(height: 20),

            // 🗓 CHECK-UP DETAILS
            RecordsDisplayCard(
              title: 'Overview',
              headerIcon: Icons.info_outline_rounded,
              items: [
                RecordItem(
                  leadingIcon: Icons.calendar_today_rounded,
                  label: 'Date',
                  value: 'Month Day, Year',
                ),
                RecordItem(
                  leadingIcon: Icons.person_rounded,
                  label: 'Midwife',
                  value: 'First Name MI. Surname',
                ),
              ],
            ),

            SizedBox(height: 14),

            // ❤️ VITALS
            RecordsDisplayCard(
              title: 'Vitals',
              headerIcon: Icons.favorite_rounded,
              items: [
                RecordItem(
                  leadingIcon: Icons.monitor_weight_rounded,
                  label: 'Weight',
                  value: '__ kg',
                ),
                RecordItem(
                  leadingIcon: Icons.speed_rounded,
                  label: 'Blood Pressure',
                  value: '__ / __ mmHg',
                ),
                RecordItem(
                  leadingIcon: Icons.child_care_rounded,
                  label: 'Fetal Position',
                  value: 'Cephalic',
                ),
                RecordItem(
                  leadingIcon: Icons.favorite_border_rounded,
                  label: 'Fetal Heartbeat',
                  value: '__ bpm',
                ),
                RecordItem(
                  leadingIcon: Icons.hearing_rounded,
                  label: 'Fetal Heart Tone',
                  value: 'Normal',
                ),
                RecordItem(
                  leadingIcon: Icons.water_drop_outlined,
                  label: 'Edema',
                  value: 'None',
                ),
              ],
            ),

            SizedBox(height: 14),

            // 💉 VACCINES & MEDICINES
            RecordsDisplayCard(
              title: 'Vaccines and Medicines',
              headerIcon: Icons.medical_services_rounded,
              items: [
                RecordItem(
                  leadingIcon: Icons.vaccines_rounded,
                  label: 'TD Vaccine',
                  value: 'XX doses',
                ),
                RecordItem(
                  leadingIcon: Icons.medication_rounded,
                  label: 'Ferrous + FA',
                  value: 'XX tablets',
                ),
                RecordItem(
                  leadingIcon: Icons.medication_liquid_rounded,
                  label: 'Calcium',
                  value: 'XX tablets',
                ),
              ],
            ),

             SizedBox(height: 14),

            // 🧑‍⚕️ MIDWIFE REMARKS  ✅ ADDED
            RecordsDisplayCard(
              title: 'Midwife Remarks',
              headerIcon: Icons.notes_rounded,
              items: [
                RecordItem(
                  label: '',
                  value: 'Midwife remarks here',
                ),
              ],
            ),

            SizedBox(height: 14),

            // ⏭ NEXT VISIT
            RecordsDisplayCard(
              title: 'Next Recommended Visit',
              headerIcon: Icons.schedule_rounded,
              items: [
                RecordItem(
                  leadingIcon: Icons.calendar_month_rounded,
                  label: 'Date',
                  value: 'Month Day, Year',
                ),
              ],
            ),

            SizedBox(height: 18),

            // 🤖 AI ANALYSIS
            AiAnalyticsCard(
              text:
                  'Routine prenatal checkup findings are normal. Vital signs are stable, and no maternal or fetal complications are noted. Continued regular follow-up is recommended.',
            ),
          ],
        ),
      ),
    );
  }
}
