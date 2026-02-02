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
  late Future<GreetingModel> greetingFuture;

  @override
  void initState() {
    super.initState();
    greetingFuture = fetchGreeting();
    statsFuture = fetchStats();
  }

  // ================= API =================

  Future<GreetingModel> fetchGreeting() async {
    final token = await AuthStorage.getToken();
    if (token == null) throw Exception('Not authenticated');

    final res = await http.get(
      Uri.parse('https://inaagapay.alwaysdata.net/api/auth/greeting.php'),
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    final Map<String, dynamic> decoded = jsonDecode(res.body);

    if (decoded['success'] != true) {
      throw Exception('Greeting API failed');
    }

    return GreetingModel.fromJson(decoded);
  }

  Future<DashboardStats> fetchStats() async {
    final token = await AuthStorage.getToken();
    if (token == null) throw Exception('Not authenticated');

    final uri = Uri.parse(
      'https://inaagapay.alwaysdata.net/api/midwife/dashboard_stats.php'
      '?filter=$selectedFilter',
    );

    final res = await http.get(
      uri,
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    if (res.statusCode == 200) {
      return DashboardStats.fromJson(jsonDecode(res.body));
    }

    throw Exception('Failed to load dashboard stats');
  }

  Future<void> logout() async {
    final token = await AuthStorage.getToken();

    if (token != null) {
      await http.post(
        Uri.parse('https://inaagapay.alwaysdata.net/api/auth/logout.php'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );
    }

    await AuthStorage.clearToken();
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

      appBar: AppBar(
        backgroundColor: AppColors.bgPrimary,
        elevation: 0,
        title: const Text(
          'Dashboard',
          style: TextStyle(color: AppColors.brandText),
        ),
        actions: [
          PopupMenuButton<_ProfileAction>(
            onSelected: (action) async {
              if (action == _ProfileAction.logout) {
                await logout();
                if (!mounted) return;
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login',
                  (_) => false,
                );
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: _ProfileAction.logout,
                child: ListTile(
                  leading: Icon(Icons.logout, color: Colors.red),
                  title: Text('Logout', style: TextStyle(color: Colors.red)),
                ),
              ),
            ],
          ),
        ],
      ),

      body: FutureBuilder<GreetingModel>(
        future: greetingFuture,
        builder: (context, greetingSnap) {
          if (greetingSnap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (greetingSnap.hasError) {
            return Center(
              child: Text(
                greetingSnap.error.toString(),
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          final g = greetingSnap.data!;

          return FutureBuilder<DashboardStats>(
            future: statsFuture,
            builder: (context, statsSnap) {
              if (statsSnap.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (statsSnap.hasError) {
                return Center(
                  child: Text(
                    statsSnap.error.toString(),
                    style: const TextStyle(color: Colors.red),
                  ),
                );
              }

              final s = statsSnap.data!;

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 👋 GREETING
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: AppColors.brandPrimary.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.borderPrimary),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome, ${g.roleLabel} ${g.displayName}',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.brandText,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Assigned BHC: ${g.bhcName ?? 'No Barangay Assigned'}',
                            style: const TextStyle(
                              color: AppColors.brandAccent,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const PageTitle(
                      title: 'Overview',
                      leadingIcon: Icons.medical_services,
                      trailingIcon: Icons.check_circle,
                    ),

                    const SizedBox(height: 20),

                    section('Mothers by Trimester'),
                    statRow('1st Trimester', s.firstTrimester),
                    statRow('2nd Trimester', s.secondTrimester),
                    statRow('3rd Trimester', s.thirdTrimester),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  // ================= HELPERS =================

  static Widget section(String title) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      title,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        color: AppColors.brandText,
      ),
    ),
  );

  static Widget statRow(String label, int value) => Container(
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

enum _ProfileAction { logout }

// ================= MODELS =================

class GreetingModel {
  final String? accountType;
  final String? firstName;
  final String? middleName;
  final String? lastName;
  final String? extensionName;
  final String? bhcName;

  GreetingModel({
    this.accountType,
    this.firstName,
    this.middleName,
    this.lastName,
    this.extensionName,
    this.bhcName,
  });

  factory GreetingModel.fromJson(Map<String, dynamic> json) {
    return GreetingModel(
      accountType: json['role']?.toString(), // PHP sends role = account_type
      firstName: json['first_name']?.toString(),
      middleName: json['middle_name']?.toString(),
      lastName: json['last_name']?.toString(),
      extensionName: json['extension_name']?.toString(),
      bhcName: json['bhc_name']?.toString(),
    );
  }

  String get displayName {
    final parts = [firstName, middleName, lastName, extensionName];

    return parts
        .where((p) => p != null && p!.trim().isNotEmpty)
        .map((p) => p!.trim())
        .join(' ');
  }

  String get roleLabel {
    switch (accountType) {
      case 'midwife':
        return 'Midwife';
      case 'mother':
        return 'Mother';
      case 'admin':
        return 'Admin';
      default:
        return 'User';
    }
  }
}

class DashboardStats {
  final int firstTrimester;
  final int secondTrimester;
  final int thirdTrimester;

  DashboardStats({
    required this.firstTrimester,
    required this.secondTrimester,
    required this.thirdTrimester,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    int safe(dynamic v) => int.tryParse(v?.toString() ?? '0') ?? 0;

    return DashboardStats(
      firstTrimester: safe(json['trimester']['first_trimester']),
      secondTrimester: safe(json['trimester']['second_trimester']),
      thirdTrimester: safe(json['trimester']['third_trimester']),
    );
  }
}
