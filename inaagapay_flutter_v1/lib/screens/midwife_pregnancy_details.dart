import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/secondary_header.dart';
import '../widgets/records_display_card.dart';

class MidwifePregnancyDetailsPage extends StatelessWidget {
  const MidwifePregnancyDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,

      // 🔝 HEADER
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: SecondaryHeader(
          title: 'Pregnancy History',
          onBack: () => Navigator.pop(context),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: const [
            _PregnancyCard(
              pregnancyNumber: 1,
              deliveryDate: 'Month Day, Year',
              deliveryPlace: 'Institution Name',
              method: 'Normal / Cesarean',
              outcome: 'Healthy',
            ),

            SizedBox(height: 20),

            _PregnancyCard(
              pregnancyNumber: 2,
              deliveryDate: 'Month Day, Year',
              deliveryPlace: 'Institution Name',
              method: 'Normal / Cesarean',
              outcome: 'Healthy',
            ),
          ],
        ),
      ),
    );
  }
}

/* -------------------------------------------------------------------------- */
/*                            PREGNANCY DETAILS CARD                           */
/* -------------------------------------------------------------------------- */

class _PregnancyCard extends StatelessWidget {
  final int pregnancyNumber;
  final String deliveryDate;
  final String deliveryPlace;
  final String method;
  final String outcome;

  const _PregnancyCard({
    required this.pregnancyNumber,
    required this.deliveryDate,
    required this.deliveryPlace,
    required this.method,
    required this.outcome,
  });

  @override
  Widget build(BuildContext context) {
    return RecordsDisplayCard(
      title: 'Pregnancy #$pregnancyNumber Details',
      headerIcon: Icons.info_outline_rounded,
      items: [
        // 📅 DELIVERY DATE
        const RecordItem(
          leadingIcon: Icons.calendar_today_rounded,
          label: 'Delivery Date',
          value: '',
        ),
        RecordItem(
          leadingIcon: Icons.event_rounded,
          label: 'Date',
          value: deliveryDate,
        ),

        // 📍 DELIVERY PLACE
        const RecordItem(
          leadingIcon: Icons.location_on_rounded,
          label: 'Delivery Place',
          value: '',
        ),
        RecordItem(
          leadingIcon: Icons.local_hospital_rounded,
          label: 'Institution',
          value: deliveryPlace,
        ),

        // 🏥 METHOD
        RecordItem(
          leadingIcon: Icons.medical_services_rounded,
          label: 'Method',
          value: method,
        ),

        // ✅ OUTCOME
        RecordItem(
          leadingIcon: Icons.fact_check_rounded,
          label: 'Outcome',
          value: outcome,
        ),
      ],
    );
  }
}
