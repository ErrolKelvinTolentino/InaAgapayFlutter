import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'add_growth_step1.dart';
import 'add_immunization_page.dart';

class ChildProfilePage extends StatelessWidget {
  final Map<String, dynamic> childData;

  const ChildProfilePage({
    super.key,
    required this.childData,
  });

  // ---------- SAFE VALUE ----------
  String _v(String key) =>
      (childData[key] ?? '').toString().trim();

  int get childId =>
      int.tryParse(childData['child_id'].toString()) ?? 0;

  String get fullName {
    final fn = _v('first_name');
    final mi = _v('middle_name');
    final ln = _v('last_name');

    if (mi.isNotEmpty) {
      return '$fn ${mi[0]}. $ln';
    }
    return '$fn $ln';
  }

  String get ageText {
    final birth = _v('birthdate');
    if (birth.isEmpty) return '';

    try {
      final d = DateTime.parse(birth);
      final years = DateTime.now().year - d.year;
      return '$years Years Old';
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
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
            _card(
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 40,
                    backgroundColor: AppColors.brandPrimary,
                    child: Icon(Icons.child_care,
                        color: Colors.white, size: 40),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    fullName,
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                  Text(ageText),
                ],
              ),
            ),

            _section('Birth Details', [
              _row('Birth Date', _v('birthdate')),
              _row('Birthplace', _v('birth_place')),
            ]),

            _section('Latest Growth', [
              _row('Height', '${_v('height')} cm'),
              _row('Weight', '${_v('weight')} kg'),
              _row('BMI', _v('bmi')),
            ]),

            const SizedBox(height: 20),

            // ➕ ADD GROWTH
            _primaryBtn(
              'Add Growth Record',
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AddGrowthStep1(
                      childId: childId,
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 12),

            // 💉 ADD IMMUNIZATION
            _primaryBtn(
              'Add Immunization',
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AddImmunizationPage(
                      childId: childId,
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

  // ---------- UI HELPERS ----------
  Widget _section(String title, List<Widget> children) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.brandPrimary)),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    if (value.isEmpty) value = '-';
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
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
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        onPressed: onTap,
        child: Text(label, style: const TextStyle(color: Colors.white)),
      ),
    );
  }
}
