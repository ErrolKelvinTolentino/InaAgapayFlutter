import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../theme/app_colors.dart';
import '../widgets/page_title.dart';
import '../services/auth_storage.dart';

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

  // ================= API =================

  Future<DashboardStats> fetchStats() async {
    final uri = Uri.parse(
      'https://inaagapay.alwaysdata.net/api/midwife/dashboard_stats.php'
      '?filter=$selectedFilter',
    );

    final res = await http.get(
      uri,
      headers: {
        'Accept': 'application/json',
      },
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

  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,

      // 🔝 APP BAR
      appBar: AppBar(
        backgroundColor: AppColors.bgPrimary,
        elevation: 0,
        title: const Text(
          'Midwife Dashboard',
          style: TextStyle(color: AppColors.brandText),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: PopupMenuButton<_ProfileAction>(
              offset: const Offset(0, 52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              onSelected: (action) async {
                switch (action) {
                  case _ProfileAction.profile:
                    break;

                  case _ProfileAction.settings:
                    break;

                  case _ProfileAction.logout:
                    await AuthStorage.clearToken();
                    if (!mounted) return;
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/login',
                      (route) => false,
                    );
                    break;
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem(
                  value: _ProfileAction.profile,
                  child: ListTile(
                    leading: Icon(Icons.person),
                    title: Text('Profile'),
                  ),
                ),
                PopupMenuItem(
                  value: _ProfileAction.settings,
                  child: ListTile(
                    leading: Icon(Icons.settings),
                    title: Text('Settings'),
                  ),
                ),
                PopupMenuItem(
                  value: _ProfileAction.logout,
                  child: ListTile(
                    leading: Icon(Icons.logout, color: Colors.red),
                    title: Text(
                      'Logout',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ),
              ],
              child: const CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.brandPrimary,
                child: Icon(Icons.person, color: Colors.white, size: 20),
              ),
            ),
          ),
        ],
      ),

      // 🔽 BODY
      body: FutureBuilder<DashboardStats>(
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
                const SizedBox(height: 12),

                const PageTitle(
                  title: 'Overview',
                  leadingIcon: Icons.medical_services,
                  trailingIcon: Icons.check_circle,
                ),

                const SizedBox(height: 24),

                // 🔘 FILTERS
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.bgSecondary,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.borderPrimary),
                  ),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      filterChip('ALL', 'all'),
                      filterChip('TODAY', 'today'),
                      filterChip('THIS WEEK', 'week'),
                      filterChip('THIS MONTH', 'month'),
                    ],
                  ),
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

                const SizedBox(height: 80),
              ],
            ),
          );
        },
      ),
    );
  }

  // ================= HELPERS =================

  Widget filterChip(String label, String value) {
    final selected = selectedFilter == value;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => changeFilter(value),
      selectedColor: AppColors.brandPrimary.withOpacity(0.2),
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
            Text(label),
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

// ================= ENUM =================

enum _ProfileAction { profile, settings, logout }

// ================= MODEL =================

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
