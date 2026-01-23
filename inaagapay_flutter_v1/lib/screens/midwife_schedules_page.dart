import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../widgets/page_title.dart';

class MidwifeSchedulesPage extends StatefulWidget {
  const MidwifeSchedulesPage({super.key});

  @override
  State<MidwifeSchedulesPage> createState() =>
      _MidwifeSchedulesPageState();
}

class _MidwifeSchedulesPageState extends State<MidwifeSchedulesPage> {
  late Future<List<ScheduleItem>> _scheduleFuture;

  @override
  void initState() {
    super.initState();
    _scheduleFuture = fetchSchedules();
  }

  // 🟢 MOCK DATA
  Future<List<ScheduleItem>> fetchSchedules() async {
    await Future.delayed(const Duration(seconds: 1));

    return [
      ScheduleItem(
        motherName: 'Maria Santos',
        date: '2026-02-01',
        status: 'scheduled',
      ),
      ScheduleItem(
        motherName: 'Ana Cruz',
        date: '2026-02-03',
        status: 'completed',
      ),
      ScheduleItem(
        motherName: 'Liza Reyes',
        date: '2026-02-05',
        status: 'missed',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ScheduleItem>>(
      future: _scheduleFuture,
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

        final schedules = snapshot.data!;

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const PageTitle(
              title: 'Schedules',
              leadingIcon: Icons.calendar_today,
              trailingIcon: Icons.check_circle,
            ),
            const SizedBox(height: 12),

            ...schedules.map(
              (s) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.faintWhite,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.borderPrimary),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.event,
                        color: AppColors.brandPrimary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            s.motherName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${s.date} • ${s.status.toUpperCase()}',
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
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

class ScheduleItem {
  final String motherName;
  final String date;
  final String status;

  ScheduleItem({
    required this.motherName,
    required this.date,
    required this.status,
  });
}
