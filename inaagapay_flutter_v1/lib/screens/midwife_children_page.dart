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

  /// ================= AGE CALCULATOR =================
  String calculateAge(String? birthdate) {
    if (birthdate == null) return '-';

    final birth = DateTime.parse(birthdate);
    final now = DateTime.now();

    int years = now.year - birth.year;
    int months = now.month - birth.month;

    if (months < 0) {
      years--;
      months += 12;
    }

    if (years <= 0) {
      return '$months months';
    } else {
      return '$years yrs${months > 0 ? ' $months mos' : ''}';
    }
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
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 1,
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),

                  /// ================= CHILD ICON =================
                  leading: CircleAvatar(
                    radius: 24,
                    backgroundColor:
                        AppColors.brandPrimary.withOpacity(0.12),
                    child: Icon(
                      c['sex'] == 'male'
                          ? Icons.male
                          : Icons.female,
                      color: AppColors.brandPrimary,
                    ),
                  ),

                  /// ================= NAME + AGE + GENDER =================
                  title: Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${c['first_name']} ${c['last_name']}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.brandPrimary.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${c['sex']} • ${calculateAge(c['birthdate'])}',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.brandPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),

                  /// ================= MOTHER NAME =================
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      'Mother: ${c['mother_name'] ?? '-'}',
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),

                  trailing: const Icon(Icons.chevron_right),

                  /// ================= NAVIGATION =================
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChildProfilePage(
                          childId: int.parse(
                            c['child_id'].toString(),
                          ),
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
