import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../theme/app_colors.dart';
import '../services/auth_storage.dart';

class ChildGrowthListPage extends StatefulWidget {
  final int childId;

  const ChildGrowthListPage({
    super.key,
    required this.childId,
  });

  @override
  State<ChildGrowthListPage> createState() => _ChildGrowthListPageState();
}

class _ChildGrowthListPageState extends State<ChildGrowthListPage> {
  bool loading = true;
  List records = [];

  Future<void> fetchGrowthRecords() async {
    final token = await AuthStorage.getToken();

    final res = await http.get(
      Uri.parse(
        'https://inaagapay.alwaysdata.net/api/midwife/child_growth_list.php?child_id=${widget.childId}',
      ),
      headers: {'Authorization': 'Bearer $token'},
    );

    final decoded = jsonDecode(res.body);

    setState(() {
      records = decoded['records'] ?? [];
      loading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    fetchGrowthRecords();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(title: const Text('Growth Records')),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : records.isEmpty
              ? const Center(child: Text('No growth records found'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: records.length,
                  itemBuilder: (_, i) {
                    final r = records[i];

                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: ListTile(
                        leading: const Icon(
                          Icons.trending_up,
                          color: AppColors.brandPrimary,
                        ),
                        title: Text(
                          'Height: ${r['child_height']} cm • Weight: ${r['child_weight']} kg',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          'BMI: ${r['bmi']} • ${r['created_at']}',
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
