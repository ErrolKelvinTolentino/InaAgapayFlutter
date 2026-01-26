import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../theme/app_colors.dart';
import '../services/auth_storage.dart';
import 'child_profile_page.dart';
import 'add_child_step1.dart';

class MidwifeChildrenPage extends StatelessWidget {
  const MidwifeChildrenPage({super.key});

  /// ================= FETCH CHILDREN =================
  Future<List<Map<String, dynamic>>> fetchChildren() async {
    final token = await AuthStorage.getToken();

    final res = await http.get(
      Uri.parse(
        'https://inaagapay.alwaysdata.net/api/midwife/midwife_children.php',
      ),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    final decoded = jsonDecode(res.body);

    if (decoded['success'] != true) {
      return [];
    }

    return List<Map<String, dynamic>>.from(decoded['data'] ?? []);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,

      /// ================= APP BAR =================
      appBar: AppBar(
        title: const Text('Children'),
        backgroundColor: AppColors.bgPrimary,
        elevation: 0,
      ),

      /// ================= BODY =================
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchChildren(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final children = snapshot.data ?? [];

          if (children.isEmpty) {
            return const Center(
              child: Text(
                'No children found',
                style: TextStyle(color: Colors.black54),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: children.length,
            itemBuilder: (_, index) {
              final c = children[index];

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                child: ListTile(
                  leading: const Icon(
                    Icons.child_care,
                    color: AppColors.brandPrimary,
                  ),

                  /// CHILD NAME
                  title: Text(
                    '${c['first_name']} ${c['last_name']}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  /// MOTHER NAME
                  subtitle: Text(
                    'Mother: ${c['mother_name'] ?? '-'}',
                  ),

                  trailing: const Icon(Icons.chevron_right),

                  /// ✅ FIXED NAVIGATION
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChildProfilePage(
                          childId:
                              int.parse(c['child_id'].toString()),
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

      /// ================= ADD CHILD FAB =================
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.brandPrimary,
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AddChildStep1Parent(),
            ),
          );
        },
      ),
    );
  }
}
