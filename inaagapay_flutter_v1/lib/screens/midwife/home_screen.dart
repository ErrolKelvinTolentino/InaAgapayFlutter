import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String selectedFilter = 'all';

  late Future<DashboardStats> statsFuture;

  @override
  void initState() {
    super.initState();
    statsFuture = fetchStats();
  }

  Future<DashboardStats> fetchStats() async {
    final response = await http.get(
      Uri.parse(
        'https://inaagapay.alwaysdata.net/api/midwife/dashboard_stats.php?filter=$selectedFilter',
      ),
    );

    if (response.statusCode == 200) {
      return DashboardStats.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load dashboard stats');
    }
  }

  void changeFilter(String filter) {
    setState(() {
      selectedFilter = filter;
      statsFuture = fetchStats();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          'Welcome, Midwife 🌸',
          style: TextStyle(color: Colors.pink),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: FutureBuilder<DashboardStats>(
          future: statsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text(snapshot.error.toString()));
            }

            final stats = snapshot.data!;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ================= FILTER BUTTONS =================
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

                // ================= TRIMESTERS =================
                const Text(
                  'Mothers by Trimester',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.pink,
                  ),
                ),
                const SizedBox(height: 10),

                Row(
                  children: [
                    Expanded(
                      child: statCard('1st Trimester', stats.firstTrimester),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: statCard('2nd Trimester', stats.secondTrimester),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                statCard('3rd Trimester', stats.thirdTrimester),

                const SizedBox(height: 20),

                // ================= SCHEDULED CHECKUPS =================
                sectionTitle('Scheduled for Checkups'),
                statWideCard(
                  'Mothers & Children',
                  '${stats.mothers} Mothers • ${stats.children} Children',
                ),

                const SizedBox(height: 20),

                // ================= BIRTH OUTCOMES =================
                sectionTitle('Birth Outcomes'),
                Row(
                  children: [
                    Expanded(child: statCard('Live Births', stats.liveBirths)),
                    const SizedBox(width: 10),
                    Expanded(child: statCard('Stillbirths', stats.stillBirths)),
                  ],
                ),

                const SizedBox(height: 20),

                // ================= PLACE OF DELIVERY =================
                sectionTitle('Place of Delivery'),
                Row(
                  children: [
                    Expanded(child: statCard('Hospital', stats.hospital)),
                    const SizedBox(width: 10),
                    Expanded(child: statCard('Center', stats.center)),
                    const SizedBox(width: 10),
                    Expanded(child: statCard('Home', stats.home)),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // ================= UI COMPONENTS =================

  Widget filterChip(String label, String value) {
    final isSelected = selectedFilter == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: Colors.pink.shade100,
      onSelected: (_) => changeFilter(value),
      labelStyle: TextStyle(
        color: isSelected ? Colors.pink : Colors.black,
        fontWeight: FontWeight.bold,
      ),
      shape: StadiumBorder(side: BorderSide(color: Colors.pink)),
    );
  }

  Widget sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.pink,
      ),
    );
  }

  Widget statCard(String title, int value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.pink),
      ),
      child: Column(
        children: [
          Text(title),
          const SizedBox(height: 6),
          Text(
            value.toString(),
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.pink,
            ),
          ),
        ],
      ),
    );
  }

  Widget statWideCard(String title, String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.pink),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.pink,
            ),
          ),
        ],
      ),
    );
  }
}

// ================= DATA MODEL =================

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
    return DashboardStats(
      firstTrimester: int.parse(
        json['trimester']['first_trimester'].toString(),
      ),
      secondTrimester: int.parse(
        json['trimester']['second_trimester'].toString(),
      ),
      thirdTrimester: int.parse(
        json['trimester']['third_trimester'].toString(),
      ),
      mothers: int.parse(json['checkups']['mothers'].toString()),
      children: int.parse(json['checkups']['children'].toString()),
      liveBirths: int.parse(json['outcomes']['live_births'].toString()),
      stillBirths: int.parse(json['outcomes']['stillbirths'].toString()),
      hospital: int.parse(json['delivery']['hospital'].toString()),
      center: int.parse(json['delivery']['center'].toString()),
      home: int.parse(json['delivery']['home'].toString()),
    );
  }
}
