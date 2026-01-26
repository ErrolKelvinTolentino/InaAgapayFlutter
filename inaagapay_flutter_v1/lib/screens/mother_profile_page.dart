import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../theme/app_colors.dart';
import '../services/auth_storage.dart';

import 'add_checkup_page.dart';
import 'add_ultrasound_page.dart';
import 'add_lab_test_page.dart';

class MotherProfilePage extends StatelessWidget {
  final int motherId;

  const MotherProfilePage({
    super.key,
    required this.motherId,
  });

  // ================= API =================

  Future<Map<String, dynamic>> fetchMotherProfile() async {
    final token = await AuthStorage.getToken();
    if (token == null) throw Exception('Not authenticated');

    final res = await http.get(
      Uri.parse(
        'https://inaagapay.alwaysdata.net/api/midwife/mother_profile.php'
        '?mother_id=$motherId',
      ),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    final decoded = jsonDecode(res.body);

    if (decoded['success'] != true) {
      throw Exception(decoded['message'] ?? 'Failed to load profile');
    }

    return decoded['mother'];
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,

      appBar: AppBar(
        title: const Text('Mother Profile'),
        backgroundColor: AppColors.bgPrimary,
        elevation: 0,
      ),

      body: FutureBuilder<Map<String, dynamic>>(
        future: fetchMotherProfile(),
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

          final m = snapshot.data!;

          String fullName = [
            m['first_name'],
            m['middle_name'],
            m['last_name'],
            m['extension_name'],
          ]
              .where((e) => e != null && e.toString().trim().isNotEmpty)
              .join(' ');

          Widget section(String title, List<Widget> children) {
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.faintWhite,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.borderPrimary),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.brandText,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ...children,
                ],
              ),
            );
          }

          Widget field(String label, dynamic value) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Text(
                      label,
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                  Expanded(
                    flex: 5,
                    child: Text(value?.toString() ?? '—'),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 👩 HEADER
                Center(
                  child: Column(
                    children: [
                      const CircleAvatar(
                        radius: 40,
                        child: Icon(Icons.person, size: 40),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        fullName.isNotEmpty ? fullName : 'Unnamed Mother',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Status: ${m['status'] ?? '—'}',
                        style: const TextStyle(
                          color: AppColors.brandAccent,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // ➕ ADD CHECKUP
                ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Add New Checkup'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pink,
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () async {
                    final added = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            AddCheckupPage(motherId: motherId),
                      ),
                    );

                    if (added == true) {
                      (context as Element).reassemble();
                    }
                  },
                ),

                const SizedBox(height: 10),

                // ➕ ADD ULTRASOUND
                ElevatedButton.icon(
                  icon: const Icon(Icons.monitor_heart),
                  label: const Text('Add New Ultrasound'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pinkAccent,
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () async {
                    final added = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            AddUltrasoundPage(motherId: motherId),
                      ),
                    );

                    if (added == true) {
                      (context as Element).reassemble();
                    }
                  },
                ),

                const SizedBox(height: 10),

                // ➕ ADD LAB TEST
                ElevatedButton.icon(
                  icon: const Icon(Icons.science),
                  label: const Text('Add New Lab Test'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () async {
                    final added = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            AddLabTestPage(motherId: motherId),
                      ),
                    );

                    if (added == true) {
                      (context as Element).reassemble();
                    }
                  },
                ),

                const SizedBox(height: 20),

                // 👩 PERSONAL
                section('Personal Information', [
                  field('Phone', m['phone_number']),
                  field('Email', m['email_address']),
                ]),

                // 🏠 ADDRESS
                section('Address', [
                  field('House No.', m['house_number']),
                  field('Street', m['street']),
                  field('Barangay', m['barangay']),
                  field('City', m['city_municipality']),
                  field('Province', m['province']),
                ]),

                // 🩺 MEDICAL
                section('Medical Info', [
                  field('Height (cm)', m['height']),
                  field('Blood Type', m['blood_type']),
                ]),

                // 🤰 PREGNANCY
                section('Pregnancy Summary', [
                  field('Risk Level', m['pregnancy_risk_level']),
                  field('Status', m['pregnancy_status']),
                  field(
                    'Expected Delivery',
                    m['expected_date_of_delivery'],
                  ),
                ]),

                // 👶 CHILDREN
                section('Children', [
                  field('Total Children', m['children_count']),
                ]),
              ],
            ),
          );
        },
      ),
    );
  }
}
