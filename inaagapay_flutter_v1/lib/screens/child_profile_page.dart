import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class ChildProfilePage extends StatelessWidget {
  final Map<String, dynamic> childData;

  const ChildProfilePage({
    super.key,
    required this.childData,
  });

  // ---------- HELPERS ----------
  String _v(String key) =>
      (childData[key] ?? '').toString().trim();

  String get fullName {
    final fn = _v('child_first_name');
    final mi = _v('child_middle_name');
    final ln = _v('child_last_name');

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

  // ---------- UI ----------
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
            // 👶 HEADER
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 45,
                    backgroundColor: AppColors.brandPrimary,
                    child: Icon(Icons.child_care, size: 40, color: Colors.white),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    fullName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.brandPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    ageText,
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 📅 BIRTH DETAILS
            _section(
              title: 'Birth Details',
              children: [
                _row('Birth Date', _v('birthdate')),
                _row('Time of Birth', _v('birth_time')),
                _row('Birthplace', _v('birth_place')),
              ],
            ),

            // 📈 GROWTH
            _section(
              title: 'Latest Growth Records',
              children: [
                _row('Height', '${_v('height')} cm'),
                _row('Weight', '${_v('weight')} kg'),
                _row('BMI', _v('bmi')),
              ],
            ),

            // 💉 IMMUNIZATION
            _section(
              title: 'Latest Immunization',
              children: [
                _row('Vaccine', _v('last_vaccine')),
                _row('Date Taken', _v('last_vaccine_date')),
              ],
            ),

            const SizedBox(height: 20),

            // 🔘 BUTTON
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.brandPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () {},
                child: const Text(
                  'View Vaccination Details',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------- REUSABLE ----------
  Widget _section({required String title, required List<Widget> children}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
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
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    if (value.isEmpty) value = '-';
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
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
}
