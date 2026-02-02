import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../theme/app_colors.dart';
import '../services/auth_storage.dart';

class ChildImmunizationListPage extends StatefulWidget {
  final int childId;

  const ChildImmunizationListPage({
    super.key,
    required this.childId,
  });

  @override
  State<ChildImmunizationListPage> createState() =>
      _ChildImmunizationListPageState();
}

class _ChildImmunizationListPageState
    extends State<ChildImmunizationListPage> {
  bool loading = true;
  List records = [];

  Future<void> fetchImmunizations() async {
    final token = await AuthStorage.getToken();

    final res = await http.get(
      Uri.parse(
        'https://inaagapay.alwaysdata.net/api/midwife/child_immunization_list.php?child_id=${widget.childId}',
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
    fetchImmunizations();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(title: const Text('Immunization Records')),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : records.isEmpty
              ? const Center(child: Text('No immunization records found'))
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
                          Icons.vaccines,
                          color: AppColors.brandPrimary,
                        ),
                        title: Text(
                          '${r['vaccine_name']} (Dose ${r['dose_number']})',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Date: ${r['vaccination_date']}'),
                            if ((r['remarks'] ?? '').toString().isNotEmpty)
                              Text('Remarks: ${r['remarks']}'),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
