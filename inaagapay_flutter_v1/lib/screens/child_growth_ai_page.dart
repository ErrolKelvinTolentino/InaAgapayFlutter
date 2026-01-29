import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fl_chart/fl_chart.dart';

import '../theme/app_colors.dart';
import '../services/auth_storage.dart';

class ChildGrowthAIPage extends StatefulWidget {
  final int childId;

  const ChildGrowthAIPage({
    super.key,
    required this.childId,
  });

  @override
  State<ChildGrowthAIPage> createState() => _ChildGrowthAIPageState();
}

class _ChildGrowthAIPageState extends State<ChildGrowthAIPage> {
  bool loading = true;

  List allRecords = [];
  List filteredRecords = [];

  Map<String, dynamic>? aiParsed;
  String disclaimer = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final token = await AuthStorage.getToken();

      // ================= FETCH GROWTH RECORDS =================
      final growthRes = await http.get(
        Uri.parse(
          'https://inaagapay.alwaysdata.net/api/midwife/child_growth_list.php?child_id=${widget.childId}',
        ),
        headers: {'Authorization': 'Bearer $token'},
      );

      final decoded = jsonDecode(growthRes.body);
      allRecords = decoded['records'] ?? [];

      // ================= FILTER OUT BIRTH / NEONATAL DATA =================
      filteredRecords = allRecords.where((r) {
        final h = double.tryParse(r['child_height'].toString()) ?? 0;
        final w = double.tryParse(r['child_weight'].toString()) ?? 0;

        // Birth measurements are usually <= 55cm and <= 4kg
        return h > 55 && w > 4;
      }).toList();

      // ================= SORT OLDEST → NEWEST =================
      filteredRecords.sort(
        (a, b) => DateTime.parse(a['created_at'])
            .compareTo(DateTime.parse(b['created_at'])),
      );

      // ================= DEFAULT AI STATE =================
      aiParsed = null;
      disclaimer = '';

      // ================= REQUIRE AT LEAST 2 CLEAN RECORDS =================
      if (filteredRecords.length < 2) {
        aiParsed = {
          'status': 'More Data Needed',
          'remarks':
              'At least two post-infancy growth records are required for AI analysis.',
          'recommendation':
              'Please continue recording height and weight measurements.',
        };
      } else {
        // ================= CALL GEMINI AI =================
        final aiRes = await http.post(
          Uri.parse(
            'https://inaagapay.alwaysdata.net/api/midwife/ai_growth_analysis.php',
          ),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'records': filteredRecords
                .map((r) => {
                      'height': r['child_height'],
                      'weight': r['child_weight'],
                    })
                .toList(),
          }),
        );

        final aiDecoded = jsonDecode(aiRes.body);

        // 🔍 DEBUG LOG
        print('AI FULL RESPONSE: $aiDecoded');

        disclaimer = aiDecoded['disclaimer'] ?? '';

        final aiText = aiDecoded['ai_response'];

        if (aiText != null && aiText is String && aiText.isNotEmpty) {
          try {
            aiParsed = jsonDecode(aiText);
          } catch (_) {
            aiParsed = {
              'status': 'AI Response Error',
              'remarks':
                  'The AI returned an unexpected response format.',
              'recommendation': '',
            };
          }
        } else {
          aiParsed = {
            'status': 'AI Unavailable',
            'remarks':
                'The AI service did not return a response.',
            'recommendation': '',
          };
        }
      }
    } catch (e) {
      aiParsed = {
        'status': 'Error',
        'remarks':
            'An unexpected error occurred while loading the AI analysis.',
        'recommendation': '',
      };
    }

    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        title: const Text('AI Growth Analysis'),
        backgroundColor: AppColors.bgPrimary,
        elevation: 0,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : filteredRecords.isEmpty
              ? const Center(
                  child: Text('No post-infancy growth data available'),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _growthChart(),
                      const SizedBox(height: 16),
                      _aiResultCard(),
                    ],
                  ),
                ),
    );
  }

  // ================= GROWTH CHART =================
  Widget _growthChart() {
    final heightSpots = <FlSpot>[];
    final weightSpots = <FlSpot>[];

    for (int i = 0; i < filteredRecords.length; i++) {
      heightSpots.add(
        FlSpot(
          i.toDouble(),
          double.parse(filteredRecords[i]['child_height'].toString()),
        ),
      );

      weightSpots.add(
        FlSpot(
          i.toDouble(),
          double.parse(filteredRecords[i]['child_weight'].toString()),
        ),
      );
    }

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Growth Trend Over Time',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.brandPrimary,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 230,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
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
          const Text(
            'Blue: Height (cm) • Green: Weight (kg)',
            style: TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  // ================= AI RESULT =================
  Widget _aiResultCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            aiParsed?['status'] ?? '',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.brandPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(aiParsed?['remarks'] ?? ''),
          const SizedBox(height: 8),
          Text(
            aiParsed?['recommendation'] ?? '',
            style: const TextStyle(fontStyle: FontStyle.italic),
          ),
          if (disclaimer.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              disclaimer,
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ],
      ),
    );
  }

  // ================= UI CARD =================
  Widget _card({required Widget child}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: child,
    );
  }
}
