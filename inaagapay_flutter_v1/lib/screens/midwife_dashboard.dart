import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../theme/app_colors.dart';
import '../widgets/page_title.dart';

class MidwifeDashboard extends StatefulWidget {
  const MidwifeDashboard({super.key});

  @override
  State<MidwifeDashboard> createState() => _MidwifeDashboardState();
}

class _MidwifeDashboardState extends State<MidwifeDashboard> {
  String selectedFilter = 'all';
  late Future<DashboardStats> statsFuture;

  @override
  void initState() {
    super.initState();
    statsFuture = fetchStats();
  }

  Future<DashboardStats> fetchStats() async {
    final res = await http.get(
      Uri.parse(
        'https://inaagapay.alwaysdata.net/dashboard_stats.php?filter=$selectedFilter',
      ),
    );

    if (res.statusCode == 200) {
      return DashboardStats.fromJson(jsonDecode(res.body));
    } else {
      throw Exception('Failed to load dashboard stats');
    }
  }

  void changeFilter(String f) {
    setState(() {
      selectedFilter = f;
      statsFuture = fetchStats();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        child: FutureBuilder<DashboardStats>(
          future: statsFuture,
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

            final s = snapshot.data!;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const PageTitle(
                    title: 'Midwife Dashboard',
                    leadingIcon: Icons.medical_services,
                    trailingIcon: Icons.check_circle,
                  ),

                  const SizedBox(height: 16),

                  Wrap(
                    spacing: 8,
                    children: [
                      filterChip('ALL', 'all'),
                      filterChip('TODAY', 'today'),
                      filterChip('THIS WEEK', 'week'),
                      filterChip('THIS MONTH', 'month'),
                    ],
                  ),

                  const SizedBox(height: 20),

                  section('Mothers by Trimester'),
                  statRow('1st Trimester', s.firstTrimester),
                  statRow('2nd Trimester', s.secondTrimester),
                  statRow('3rd Trimester', s.thirdTrimester),

                  const SizedBox(height: 20),

                  section('Scheduled Checkups'),
                  statRow('Mothers', s.mothers),
                  statRow('Children', s.children),

                  const SizedBox(height: 20),

                  section('Birth Outcomes'),
                  statRow('Live Births', s.liveBirths),
                  statRow('Stillbirths', s.stillBirths),

                  const SizedBox(height: 20),

                  section('Place of Delivery'),
                  statRow('Hospital', s.hospital),
                  statRow('Center', s.center),
                  statRow('Home', s.home),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget filterChip(String label, String value) {
    final selected = selectedFilter == value;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => changeFilter(value),
      selectedColor: AppColors.brandPrimary.withOpacity(0.2),
      labelStyle: TextStyle(
        fontWeight: FontWeight.bold,
        color: selected
            ? AppColors.brandAccent
            : AppColors.textPrimary,
      ),
    );
  }

  Widget section(String title) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.brandText,
          ),
        ),
      );

  Widget statRow(String label, int value) => Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.faintWhite,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderPrimary),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(color: AppColors.textSecondary)),
            Text(
              value.toString(),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.brandAccent,
              ),
            ),
          ],
        ),
      );
}

/* ================= MODEL (NULL-SAFE) ================= */

class DashboardStats {
  final int firstTrimester;
  final int secondTrimester;
  final int thirdTrimester;
  final int mothers;
  final int children;
  final int liveBirths;
  final int stillBirths;
  final int hospital;
  final int center;
  final int home;

  DashboardStats({
    required this.firstTrimester,
    required this.secondTrimester,
    required this.thirdTrimester,
    required this.mothers,
    required this.children,
    required this.liveBirths,
    required this.stillBirths,
    required this.hospital,
    required this.center,
    required this.home,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    int safe(dynamic v) => int.tryParse(v?.toString() ?? '0') ?? 0;

    return DashboardStats(
      firstTrimester: safe(json['trimester']['first_trimester']),
      secondTrimester: safe(json['trimester']['second_trimester']),
      thirdTrimester: safe(json['trimester']['third_trimester']),
      mothers: safe(json['checkups']['mothers']),
      children: safe(json['checkups']['children']),
      liveBirths: safe(json['outcomes']['live_births']),
      stillBirths: safe(json['outcomes']['stillbirths']),
      hospital: safe(json['delivery']['hospital']),
      center: safe(json['delivery']['center']),
      home: safe(json['delivery']['home']),
    );
  }
}
