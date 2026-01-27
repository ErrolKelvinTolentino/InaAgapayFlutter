import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fl_chart/fl_chart.dart';

import '../theme/app_colors.dart';
import '../services/auth_storage.dart';

class ChildGrowthAIPage extends StatefulWidget {
  final int childId;

  const ChildGrowthAIPage({super.key, required this.childId});

  @override
  State<ChildGrowthAIPage> createState() => _ChildGrowthAIPageState();
}

class _ChildGrowthAIPageState extends State<ChildGrowthAIPage> {
  bool loading = true;
  List records = [];
  Map<String, dynamic>? ai;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final token = await AuthStorage.getToken();

    final res = await http.get(
      Uri.parse(
        'https://inaagapay.alwaysdata.net/api/midwife/child_growth_list.php?child_id=${widget.childId}',
      ),
      headers: {'Authorization': 'Bearer $token'},
    );

    final decoded = jsonDecode(res.body);
    records = decoded['records'] ?? [];

    if (records.isNotEmpty) {
      final latest = records.first;

      final aiRes = await http.post(
        Uri.parse(
          'https://inaagapay.alwaysdata.net/api/midwife/ai_growth_analysis.php',
        ),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'height': latest['child_height'],
          'weight': latest['child_weight'],
        }),
      );

      ai = jsonDecode(aiRes.body);
    }

    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(title: const Text('AI Growth Analysis')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : records.isEmpty
              ? const Center(child: Text('No growth data available'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _growthChart(),
                      const SizedBox(height: 16),
                      _aiFeedback(),
                    ],
                  ),
                ),
    );
  }

  // ================= GROWTH CHART =================
  Widget _growthChart() {
    final heightSpots = <FlSpot>[];
    final weightSpots = <FlSpot>[];

    for (int i = 0; i < records.length; i++) {
      heightSpots.add(
        FlSpot(
          i.toDouble(),
          double.parse(records[i]['child_height'].toString()),
        ),
      );
      weightSpots.add(
        FlSpot(
          i.toDouble(),
          double.parse(records[i]['child_weight'].toString()),
        ),
      );
    }

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Growth Trend',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.brandPrimary,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 220,
            child: LineChart(
              LineChartData(
                lineBarsData: [
                  LineChartBarData(
                    spots: heightSpots,
                    isCurved: true,
                    barWidth: 3,
                    color: Colors.blue,
                  ),
                  LineChartBarData(
                    spots: weightSpots,
                    isCurved: true,
                    barWidth: 3,
                    color: Colors.green,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),
          const Text('Blue: Height (cm) • Green: Weight (kg)'),
        ],
      ),
    );
  }

  // ================= AI FEEDBACK =================
  Widget _aiFeedback() {
    if (ai == null) return const SizedBox();

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            ai!['status'] ?? '',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.brandPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(ai!['remarks'] ?? ''),
          const SizedBox(height: 8),
          Text(
            ai!['recommendation'] ?? '',
            style: const TextStyle(fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: child,
    );
  }
}
