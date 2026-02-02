import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../theme/app_colors.dart';
import '../services/auth_storage.dart';

import 'add_growth_step1.dart';
import 'add_immunization_page.dart';
import 'child_growth_list_page.dart';
import 'child_immunization_list_page.dart';
import 'child_growth_ai_page.dart';

class ChildProfilePage extends StatefulWidget {
  final int childId;

  const ChildProfilePage({
    super.key,
    required this.childId,
  });

  @override
  State<ChildProfilePage> createState() => _ChildProfilePageState();
}

class _ChildProfilePageState extends State<ChildProfilePage> {
  bool loading = true;
  Map<String, dynamic>? response;

  String v(Map<String, dynamic> map, String key) =>
      (map[key] ?? '').toString().trim();

  Future<void> fetchProfile() async {
    final token = await AuthStorage.getToken();

    final res = await http.get(
      Uri.parse(
        'https://inaagapay.alwaysdata.net/api/midwife/child_profile.php?child_id=${widget.childId}',
      ),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    final decoded = jsonDecode(res.body);

    setState(() {
      response = decoded;
      loading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    fetchProfile();
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (response == null || response!['success'] != true) {
      return const Scaffold(
        body: Center(child: Text('Failed to load child profile')),
      );
    }

    final Map<String, dynamic> child =
        response!['child'] is Map ? response!['child'] : {};

    final Map<String, dynamic> birth =
        response!['birth'] is Map ? response!['birth'] : {};

    final Map<String, dynamic> growth =
        response!['growth'] is Map ? response!['growth'] : {};

    final Map<String, dynamic> immunization =
        response!['immunization'] is Map ? response!['immunization'] : {};

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        title: const Text('Child Profile'),
        backgroundColor: AppColors.bgPrimary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ================= BASIC INFO =================
            _card(
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 40,
                    backgroundColor: AppColors.brandPrimary,
                    child: Icon(
                      Icons.child_care,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '${v(child, 'first_name')} ${v(child, 'last_name')}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    v(child, 'sex').isNotEmpty
                        ? v(child, 'sex').toUpperCase()
                        : '',
                  ),
                ],
              ),
            ),

            // ================= BIRTH INFORMATION =================
            _section('Birth Information', [
              _row('Birth Date', v(birth, 'birthdate')),
              _row(
                'Birthplace',
                '${v(birth, 'birthplace_city_municipality')}, ${v(birth, 'birthplace_province')}',
              ),
              _row('Birth Length', '${v(birth, 'birth_length')} cm'),
              _row(
                'Head Circumference',
                '${v(birth, 'head_circumference')} cm',
              ),
            ]),

            // ================= BIRTH COMPLICATIONS =================
            if (v(birth, 'birth_complications').isNotEmpty)
              _section('Birth Complications', [
                Text(
                  v(birth, 'birth_complications'),
                  style: const TextStyle(height: 1.4),
                ),
              ]),

            // ================= LATEST GROWTH =================
            _section('Latest Growth Record', [
              _row('Height', '${v(growth, 'child_height')} cm'),
              _row('Weight', '${v(growth, 'child_weight')} kg'),
              _row('BMI', v(growth, 'bmi')),
              const SizedBox(height: 10),
              OutlinedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChildGrowthListPage(
                        childId: widget.childId,
                      ),
                    ),
                  );
                },
                child: const Text('View All Growth Records'),
              ),
            ]),

            // ================= LATEST IMMUNIZATION (FIX #3) =================
            _section('Latest Immunization', [
              if (immunization.isEmpty) ...[
                const Text(
                  'No immunization recorded yet',
                  style: TextStyle(color: Colors.black54),
                ),
              ] else ...[
                _row('Vaccine', v(immunization, 'vaccine_name')),
                if (v(immunization, 'dose_number').isNotEmpty)
                  _row('Dose', v(immunization, 'dose_number')),
                _row('Date Given', v(immunization, 'vaccination_date')),
              ],
              const SizedBox(height: 10),
              OutlinedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChildImmunizationListPage(
                        childId: widget.childId,
                      ),
                    ),
                  );
                },
                child: const Text('View All Immunizations'),
              ),
            ]),

            const SizedBox(height: 20),

            // ================= ACTION BUTTONS =================
            _primaryBtn(
              'Add Growth Record',
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        AddGrowthStep1(childId: widget.childId),
                  ),
                );
              },
            ),

            const SizedBox(height: 12),

            // ================= ADD IMMUNIZATION (FIX #1) =================
            _primaryBtn(
              'Add Immunization',
              () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        AddImmunizationPage(childId: widget.childId),
                  ),
                );

                // 🔥 refresh profile when immunization is added
                if (result == true) {
                  setState(() => loading = true);
                  await fetchProfile();
                }
              },
            ),

            const SizedBox(height: 12),

            // ================= AI GROWTH ANALYSIS =================
            _primaryBtn(
              'AI Growth Analysis',
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChildGrowthAIPage(
                      childId: widget.childId,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // ================= UI HELPERS =================

  Widget _section(String title, List<Widget> children) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.brandPrimary,
            ),
          ),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    if (value.isEmpty || value == 'null') value = '-';

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

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

  Widget _primaryBtn(String label, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.brandPrimary,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        onPressed: onTap,
        child: Text(
          label,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
