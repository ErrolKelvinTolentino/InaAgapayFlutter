import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../theme/app_colors.dart';
import '../services/auth_storage.dart';

import 'mother_profile_page.dart';
import 'add_mother_flow.dart';

class MidwifeMothersPage extends StatelessWidget {
  const MidwifeMothersPage({super.key});

  // ================= API =================

  Future<List<Map<String, dynamic>>> fetchMothers() async {
    final token = await AuthStorage.getToken();
    if (token == null) {
      throw Exception('Not authenticated');
    }

    final res = await http.get(
      Uri.parse(
        'https://inaagapay.alwaysdata.net/api/midwife/midwife_mothers.php',
      ),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    final decoded = jsonDecode(res.body);

    if (decoded['success'] != true) {
      throw Exception(decoded['message'] ?? 'Failed to load mothers');
    }

    final List list = decoded['data'] ?? [];
    return list.cast<Map<String, dynamic>>();
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,

      appBar: AppBar(
        title: const Text('Patients / Mothers'),
        backgroundColor: AppColors.bgPrimary,
        elevation: 0,
      ),

      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchMothers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                snapshot.error.toString(),
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          final mothers = snapshot.data ?? [];

          if (mothers.isEmpty) {
            return const Center(child: Text('No mothers found'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: mothers.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final m = mothers[index];

              final int motherId =
                  int.tryParse(m['mother_id']?.toString() ?? '') ?? 0;

              final String fullName = [
                m['first_name'],
                m['middle_name'],
                m['last_name'],
                m['extension_name'],
              ]
                  .where((e) => e != null && e.toString().trim().isNotEmpty)
                  .join(' ');

              Color riskColor(String? risk) {
                switch (risk) {
                  case 'high':
                    return Colors.red;
                  case 'medium':
                    return Colors.orange;
                  case 'low':
                    return Colors.green;
                  default:
                    return Colors.grey;
                }
              }

              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),

                  leading: const CircleAvatar(
                    backgroundColor: AppColors.brandPrimary,
                    child: Icon(Icons.person, color: Colors.white),
                  ),

                  title: Row(
                    children: [
                      Expanded(
                        child: Text(
                          fullName.isNotEmpty
                              ? fullName
                              : 'Unnamed Mother',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (m['pregnancy_risk_level'] != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: riskColor(
                                    m['pregnancy_risk_level'])
                                .withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            m['pregnancy_risk_level']
                                .toString()
                                .toUpperCase(),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: riskColor(
                                  m['pregnancy_risk_level']),
                            ),
                          ),
                        ),
                    ],
                  ),

                  // 🔥 ADDITION STARTS HERE
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (m['phone_number'] != null)
                          Text('📞 ${m['phone_number']}'),
                        if (m['email_address'] != null)
                          Text('✉️ ${m['email_address']}'),
                        if (m['next_checkup_date'] != null)
                          Text(
                            'Next Checkup: ${m['next_checkup_date']}',
                          ),
                        if (m['expected_date_of_delivery'] != null)
                          Text(
                            'EDD: ${m['expected_date_of_delivery']}',
                          ),
                      ],
                    ),
                  ),
                  // 🔥 ADDITION ENDS HERE

                  trailing: const Icon(Icons.chevron_right),

                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            MotherProfilePage(motherId: motherId),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        heroTag: 'add-mother-fab',
        backgroundColor: AppColors.brandPrimary,
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AddMotherFlow(),
            ),
          );
        },
      ),
    );
  }
}
