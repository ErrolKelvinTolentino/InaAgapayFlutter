import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/secondary_header.dart';
import '../widgets/records_display_card.dart';
import '../widgets/ai_analytics_card.dart';

class MotherUltrasoundDetailsPage extends StatelessWidget {
  final VoidCallback onBack;

  const MotherUltrasoundDetailsPage({
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
          title: 'Ultrasound Details',
          onBack: onBack,
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // 🖼 ULTRASOUND IMAGE
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Ultrasound Image',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.brandText, // ✅ FIXED
                    ),
                  ),
                  SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(14)),
                    child: Image(
                      image: AssetImage('assets/images/ultrasound.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 📋 ULTRASOUND DETAILS
            const RecordsDisplayCard(
              title: 'Ultrasound Details',
              headerIcon: Icons.info_outline_rounded,
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
              ],
            ),

            const SizedBox(height: 14),

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

            const SizedBox(height: 16),

            // 🤖 AI ANALYSIS
            const AiAnalyticsCard(
              text:
                  'Your weight progress is very ideal for a 4-month pregnant mother. '
                  'Other AI-like words and phrase analysis here.',
            ),
          ],
        ),
      ),
    );
  }
}
