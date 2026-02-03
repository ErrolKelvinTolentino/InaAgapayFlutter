import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../theme/app_colors.dart';
import '../widgets/main_header.dart';
import '../widgets/hero_card.dart';
import '../widgets/overview_info.dart';
import '../widgets/midwife_statistics_card.dart';
import '../widgets/midwife_history_card.dart';
import '../widgets/chart_card.dart';
import '../services/auth_storage.dart';

class MidwifeDashboard extends StatefulWidget {
  const MidwifeDashboard({super.key});

  @override
  State<MidwifeDashboard> createState() => _MidwifeDashboardState();
}

class _MidwifeDashboardState extends State<MidwifeDashboard> {
  late Future<DashboardData> _dashboardFuture;
  late Future<GreetingModel> _greetingFuture;

  @override
  void initState() {
    super.initState();
    _greetingFuture = _fetchGreeting();
    _dashboardFuture = _fetchDashboardData();
  }

  // ================= API CALLS =================

  Future<GreetingModel> _fetchGreeting() async {
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

  Future<DashboardData> _fetchDashboardData() async {
    final token = await AuthStorage.getToken();
    if (token == null) throw Exception('Not authenticated');

    final res = await http.get(
      Uri.parse('https://inaagapay.alwaysdata.net/api/midwife/dashboard_stats.php'),
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    if (res.statusCode == 200) {
      return DashboardData.fromJson(jsonDecode(res.body));
    }

    throw Exception('Failed to load dashboard data');
  }

  Future<void> _logout() async {
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

  Future<void> _refreshData() async {
    setState(() {
      _dashboardFuture = _fetchDashboardData();
      _greetingFuture = _fetchGreeting();
    });
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      
      body: Column(
        children: [
          /// 🔝 HEADER
          MainHeader(
            title: 'Home',
            // Remove undefined parameters
          ),

          /// 🔽 BODY
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refreshData,
              child: FutureBuilder<GreetingModel>(
                future: _greetingFuture,
                builder: (context, greetingSnapshot) {
                  if (greetingSnapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (greetingSnapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline, color: Colors.red, size: 48),
                          const SizedBox(height: 16),
                          Text(
                            'Error: ${greetingSnapshot.error}',
                            style: const TextStyle(color: Colors.red),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _refreshData,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }

                  final greeting = greetingSnapshot.data!;

                  return FutureBuilder<DashboardData>(
                    future: _dashboardFuture,
                    builder: (context, dashboardSnapshot) {
                      if (dashboardSnapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (dashboardSnapshot.hasError) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.error_outline, color: Colors.red, size: 48),
                              const SizedBox(height: 16),
                              Text(
                                'Error: ${dashboardSnapshot.error}',
                                style: const TextStyle(color: Colors.red),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _refreshData,
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        );
                      }

                      final dashboardData = dashboardSnapshot.data!;

                      return SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          children: [
                            const SizedBox(height: 16),

                            /// 👋 HERO
                            HeroCard(
                              image: const AssetImage('assets/images/midwife.png'),
                              title: 'Welcome, ${greeting.firstName ?? 'Midwife'}! 🌸',
                              subtitle: 'Barangay ${greeting.bhcName ?? 'Health Center'} Midwife',
                              showWeekBadge: false,
                              showHeartRow: false,
                            ),
                            const SizedBox(height: 20),

                            /// 📊 QUICK OVERVIEW - Using real data
                            Row(
                              children: [
                                Expanded(
                                  child: OverviewInfo(
                                    value: dashboardData.registeredChildren,
                                    label: 'Registered\nChildren',
                                    icon: Icons.child_care_rounded,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: OverviewInfo(
                                    value: dashboardData.registeredMothers,
                                    label: 'Registered\nMothers',
                                    icon: Icons.pregnant_woman,
                                  ),
                                ),
                                const SizedBox(width: 12),
                              ],
                            ),
                            const SizedBox(height: 20),

                            Row(
                              children: [
                                Expanded(
                                  child: OverviewInfo(
                                    value: dashboardData.ferrousGiven,
                                    label: 'Ferrous FA\ngiven',
                                    icon: Icons.medication,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: OverviewInfo(
                                    value: dashboardData.calciumGiven,
                                    label: 'Calcium\ngiven',
                                    icon: Icons.local_pharmacy,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: OverviewInfo(
                                    value: dashboardData.tdDosesGiven,
                                    label: 'TD Vaccine\ndoses given',
                                    icon: Icons.vaccines,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),

                            /// 🤰 ACTIVE PREGNANCIES CARD - Using real data
                            MidwifeStatisticsCard(
                              totalPregnancies: dashboardData.totalPregnancies,
                              firstTrimester: dashboardData.firstTrimester,
                              secondTrimester: dashboardData.secondTrimester,
                              thirdTrimester: dashboardData.thirdTrimester,
                            ),
                            const SizedBox(height: 20),

                            /// 🕘 RECENT VISITS - TODO: Replace with real data
                            const MidwifeHistoryCard(
                              visits: [
                                MidwifeVisitItem(
                                  fullName: 'First Name Last Name',
                                  visitType: 'Prenatal Check-up',
                                  timeLabel: 'Today',
                                ),
                                MidwifeVisitItem(
                                  fullName: 'First Name Last Name',
                                  visitType: 'Prenatal Check-up',
                                  timeLabel: 'Yesterday',
                                ),
                                MidwifeVisitItem(
                                  fullName: 'First Name Last Name',
                                  visitType: 'Prenatal Check-up',
                                  timeLabel: '2 days ago',
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),

                            /// 📈 BHC VISITS CHART - TODO: Replace with real data
                            ChartCard(
                              title: 'BHC Daily Visits Chart',
                              headerIcon: Icons.show_chart_rounded,
                              values: dashboardData.bhcVisitValues,
                              labels: dashboardData.bhcVisitDays,
                              unit: 'visits',
                              lineColor: AppColors.brandPrimary,
                              startingLabel: 'Lowest',
                              startingValue: '3 visits',
                              latestLabel: 'Highest',
                              latestValue: '9 visits',
                              insightText: 'Tuesday had the most prenatal visits this week!',
                            ),
                            const SizedBox(height: 32),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

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
      accountType: json['role']?.toString(),
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

class DashboardData {
  final int registeredChildren;
  final int registeredMothers;
  final int ferrousGiven;
  final int calciumGiven;
  final int tdDosesGiven;
  final int totalPregnancies;
  final int firstTrimester;
  final int secondTrimester;
  final int thirdTrimester;

  // For chart data (you'll need to fetch this from your API)
  final List<double> bhcVisitValues;
  final List<String> bhcVisitDays;

  DashboardData({
    required this.registeredChildren,
    required this.registeredMothers,
    required this.ferrousGiven,
    required this.calciumGiven,
    required this.tdDosesGiven,
    required this.totalPregnancies,
    required this.firstTrimester,
    required this.secondTrimester,
    required this.thirdTrimester,
    List<double>? bhcVisitValues,
    List<String>? bhcVisitDays,
  })  : bhcVisitValues = bhcVisitValues ?? [5, 7, 6, 8, 9, 4, 3],
        bhcVisitDays = bhcVisitDays ?? ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    int safe(dynamic v) => int.tryParse(v?.toString() ?? '0') ?? 0;

    // Parse trimester data
    final trimesterData = json['trimester'] as Map<String, dynamic>? ?? {};
    final firstTri = safe(trimesterData['first_trimester']);
    final secondTri = safe(trimesterData['second_trimester']);
    final thirdTri = safe(trimesterData['third_trimester']);

    // TODO: Update these to match your actual API response structure
    // You'll need to adjust these based on what your API returns
    return DashboardData(
      registeredChildren: safe(json['registered_children'] ?? 0),
      registeredMothers: safe(json['registered_mothers'] ?? 0),
      ferrousGiven: safe(json['ferrous_given'] ?? 0),
      calciumGiven: safe(json['calcium_given'] ?? 0),
      tdDosesGiven: safe(json['td_doses_given'] ?? 0),
      totalPregnancies: firstTri + secondTri + thirdTri,
      firstTrimester: firstTri,
      secondTrimester: secondTri,
      thirdTrimester: thirdTri,
    );
  }
}