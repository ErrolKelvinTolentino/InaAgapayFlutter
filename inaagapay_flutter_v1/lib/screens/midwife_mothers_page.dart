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

              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                child: ListTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.person),
                  ),

                  title: Text(
                    fullName.isNotEmpty ? fullName : 'Unnamed Mother',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),

                  subtitle: Text(
                    [
                      m['barangay'],
                      m['city_municipality'],
                    ]
                        .where((e) =>
                            e != null && e.toString().trim().isNotEmpty)
                        .join(', '),
                  ),

                  trailing: const Icon(Icons.chevron_right),

                  // ✅ CLICKABLE AGAIN
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MotherProfilePage(
                          motherId: motherId,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),

      // ➕ ADD MOTHER BUTTON
      floatingActionButton: FloatingActionButton(
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
