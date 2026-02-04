import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/secondary_header.dart';
import '../widgets/records_display_card.dart';
import '../widgets/ai_analytics_card.dart';

class MotherLabDetails extends StatelessWidget {
  final VoidCallback onBack;

  const MotherLabDetails({
    super.key,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,

      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: SecondaryHeader(
          title: 'Laboratory Test Details',
          onBack: onBack,
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: const [
            // 📋 LAB DETAILS
            RecordsDisplayCard(
              title: 'Laboratory Test Details',
              headerIcon: Icons.science_rounded,
              items: [
                RecordItem(
                  leadingIcon: Icons.calendar_today_rounded,
                  label: 'Date',
                  value: 'Month Day, Year',
                ),
                RecordItem(
                  leadingIcon: Icons.person_rounded,
                  label: 'Specialist',
                  value: 'First Name MI. Surname',
                ),
                RecordItem(
                  leadingIcon: Icons.local_hospital_rounded,
                  label: 'Clinic',
                  value: 'Institution Name',
                ),
                RecordItem(
                  leadingIcon: Icons.science_outlined,
                  label: 'Type',
                  value: 'Lab Test Type',
                ),
              ],
            ),

            SizedBox(height: 14),

            // 📝 MIDWIFE REMARKS
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

            SizedBox(height: 16),

            // 🤖 AI ANALYSIS
            AiAnalyticsCard(
              text:
                  'Your weight progress is very ideal for a 4-month pregnant mother. '
                  'Other AI-like words and phrase analytics here.',
            ),
          ],
        ),
      ),
    );
  }
}
