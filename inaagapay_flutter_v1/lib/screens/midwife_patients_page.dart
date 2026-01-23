import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../widgets/page_title.dart';

class MidwifePatientsPage extends StatefulWidget {
  const MidwifePatientsPage({super.key});

  @override
  State<MidwifePatientsPage> createState() => _MidwifePatientsPageState();
}

class _MidwifePatientsPageState extends State<MidwifePatientsPage> {
  late Future<List<MotherPatient>> _patientsFuture;

  @override
  void initState() {
    super.initState();
    _patientsFuture = fetchPatients();
  }

  // 🟢 MOCK DATA
  Future<List<MotherPatient>> fetchPatients() async {
    await Future.delayed(const Duration(seconds: 1));

    return [
      MotherPatient(fullName: 'Maria Santos', riskLevel: 'low'),
      MotherPatient(fullName: 'Ana Cruz', riskLevel: 'high'),
      MotherPatient(fullName: 'Liza Reyes', riskLevel: 'medium'),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<MotherPatient>>(
      future: _patientsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              snapshot.error.toString(),
              style: const TextStyle(color: AppColors.error),
            ),
          );
        }

        final mothers = snapshot.data!;

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const PageTitle(
              title: 'Patients',
              leadingIcon: Icons.people,
              trailingIcon: Icons.favorite,
            ),
            const SizedBox(height: 12),

            ...mothers.map(
              (m) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.faintWhite,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.borderPrimary),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: AppColors.brandPrimary,
                      child: Text(
                        m.initials,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            m.fullName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Risk: ${m.riskLevel.toUpperCase()}',
                            style: TextStyle(
                              fontSize: 13,
                              color: m.riskLevel == 'high'
                                  ? AppColors.error
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/* ================= MODEL ================= */

class MotherPatient {
  final String fullName;
  final String riskLevel;

  MotherPatient({
    required this.fullName,
    required this.riskLevel,
  });

  String get initials =>
      fullName.split(' ').map((e) => e[0]).take(2).join();
}
