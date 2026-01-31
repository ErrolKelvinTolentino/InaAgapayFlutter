import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../theme/app_colors.dart';
import '../services/auth_storage.dart';

import 'add_prenatal_checkup.dart';
import 'add_ultrasound_page.dart';
import 'add_lab_test_page.dart';

class MotherProfilePage extends StatelessWidget {
  final int motherId;

  const MotherProfilePage({super.key, required this.motherId});

  // ================= API =================

  Future<Map<String, dynamic>> fetchMotherProfile() async {
    final token = await AuthStorage.getToken();
    if (token == null) throw Exception('Not authenticated');

    final res = await http.get(
      Uri.parse(
        'https://inaagapay.alwaysdata.net/api/midwife/mother_profile.php'
        '?mother_id=$motherId',
      ),
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
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
          ].where((e) => e != null && e.toString().trim().isNotEmpty).join(' ');

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
                  Expanded(flex: 5, child: Text(value?.toString() ?? '—')),
                ],
              ),
            );
          }

          String? fmtDate(dynamic v) {
            if (v == null) return null;
            final parsed = DateTime.tryParse(v.toString());
            if (parsed == null) return v.toString();
            return '${parsed.year}-${parsed.month.toString().padLeft(2, '0')}-${parsed.day.toString().padLeft(2, '0')}';
          }

          String fmtValue(dynamic v) {
            if (v == null) return '—';
            final value = v.toString().trim();
            return value.isEmpty ? '—' : value;
          }

          List<dynamic> listOrEmpty(dynamic v) => v is List ? v : [];

          String? resolveImageUrl(dynamic v) {
            if (v == null) return null;
            final raw = v.toString().trim();
            if (raw.isEmpty) return null;
            if (raw.startsWith('http')) return raw;
            final cleaned = raw.startsWith('/') ? raw.substring(1) : raw;
            return 'https://inaagapay.alwaysdata.net/$cleaned';
          }

          Widget infoCard(String title, List<Widget> children) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
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

          Widget statChip(String label, String value) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.bgSecondary,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: AppColors.borderPrimary),
              ),
              child: Text('$label: $value'),
            );
          }

          Widget _tagChip(String text) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.bgSecondary,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: AppColors.borderPrimary),
              ),
              child: Text(text, style: const TextStyle(fontSize: 12)),
            );
          }

          Widget recordCard({
            required IconData icon,
            required String title,
            String? subtitle,
            List<String> tags = const [],
            VoidCallback? onTap,
          }) {
            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(14),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.bgSecondary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(icon, color: AppColors.brandText),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (subtitle != null && subtitle.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                subtitle,
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                            if (tags.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 6,
                                runSpacing: 6,
                                children: tags.map(_tagChip).toList(),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right),
                    ],
                  ),
                ),
              ),
            );
          }

          Widget _detailRow(String label, String value) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: Text(
                      label,
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                  Expanded(flex: 5, child: Text(value)),
                ],
              ),
            );
          }

          void showRecordSheet({
            required String title,
            required List<MapEntry<String, String>> rows,
            IconData icon = Icons.receipt_long,
            String? subtitle,
            String? imageUrl,
          }) {
            showModalBottomSheet<void>(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.white,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              builder: (_) => SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: AppColors.bgSecondary,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(icon, color: AppColors.brandText),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (subtitle != null && subtitle.isNotEmpty)
                                  Text(
                                    subtitle,
                                    style: const TextStyle(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (imageUrl != null) ...[
                        ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: AspectRatio(
                            aspectRatio: 4 / 3,
                            child: Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, _, __) => Container(
                                color: AppColors.bgSecondary,
                                child: const Center(
                                  child: Text('Image not available'),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.faintWhite,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.borderPrimary),
                        ),
                        child: Column(
                          children: rows
                              .map((r) => _detailRow(r.key, r.value))
                              .toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          final currentPreg = m['current_pregnancy'];
          final pastPregs = listOrEmpty(m['past_pregnancies']);
          final medicalConditions = listOrEmpty(m['medical_conditions']);
          final allergies = listOrEmpty(m['allergies']);

          Future<void> addPrenatalCheckup() async {
            final pregnancyId =
                currentPreg?['pregnancy_id'] ?? m['pregnancy_id'];
            if (pregnancyId == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('No ongoing pregnancy found.')),
              );
              return;
            }

            DateTime? lmp;
            final lmpRaw =
                currentPreg?['last_menstrual_period'] ??
                m['last_menstrual_period'];
            if (lmpRaw != null) {
              lmp = DateTime.tryParse(lmpRaw.toString());
            }

            final added = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AddPrenatalCheckupScreen(
                  motherId: motherId,
                  pregnancyId: int.parse(pregnancyId.toString()),
                  lmp: lmp,
                  motherWeight: null,
                ),
              ),
            );

            if (added == true) {
              (context as Element).reassemble();
            }
          }

          return DefaultTabController(
            length: 3,
            child: Column(
              children: [
                Expanded(
                  child: NestedScrollView(
                    headerSliverBuilder: (context, _) => [
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Center(
                                child: Column(
                                  children: [
                                    const CircleAvatar(
                                      radius: 42,
                                      child: Icon(Icons.person, size: 40),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      fullName.isNotEmpty
                                          ? fullName
                                          : 'Unnamed Mother',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Status: ${m['status'] ?? '—'}',
                                      style: const TextStyle(
                                        color: AppColors.brandAccent,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      alignment: WrapAlignment.center,
                                      children: [
                                        statChip(
                                          'Children',
                                          '${m['children_count'] ?? 0}',
                                        ),
                                        statChip(
                                          'Risk',
                                          '${m['pregnancy_risk_level'] ?? '—'}',
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                              const TabBar(
                                tabs: [
                                  Tab(text: 'Overview'),
                                  Tab(text: 'Current'),
                                  Tab(text: 'History'),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                    body: TabBarView(
                      children: [
                        // ================= OVERVIEW =================
                        SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              infoCard('Quick Actions', [
                                Wrap(
                                  spacing: 10,
                                  runSpacing: 10,
                                  children: [
                                    ElevatedButton.icon(
                                      onPressed: addPrenatalCheckup,
                                      icon: const Icon(Icons.add),
                                      label: const Text('Add Checkup'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.pink,
                                      ),
                                    ),
                                    OutlinedButton.icon(
                                      onPressed: () async {
                                        final added = await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => AddUltrasoundPage(
                                              motherId: motherId,
                                            ),
                                          ),
                                        );
                                        if (added == true) {
                                          (context as Element).reassemble();
                                        }
                                      },
                                      icon: const Icon(Icons.monitor_heart),
                                      label: const Text('Add Ultrasound'),
                                    ),
                                    OutlinedButton.icon(
                                      onPressed: () async {
                                        final added = await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => AddLabTestPage(
                                              motherId: motherId,
                                            ),
                                          ),
                                        );
                                        if (added == true) {
                                          (context as Element).reassemble();
                                        }
                                      },
                                      icon: const Icon(Icons.science),
                                      label: const Text('Add Lab Test'),
                                    ),
                                  ],
                                ),
                              ]),
                              infoCard('Personal Information', [
                                field('Phone', m['phone_number']),
                                field('Email', m['email_address']),
                                field('Birthdate', m['birthdate']),
                              ]),
                              infoCard('Address', [
                                field('House No.', m['house_number']),
                                field('Street', m['street']),
                                field('Barangay', m['barangay']),
                                field('City', m['city_municipality']),
                                field('Province', m['province']),
                              ]),
                              infoCard('Medical Info', [
                                field('Height (cm)', m['height']),
                                field('Weight (kg)', m['weight']),
                                field('Blood Type', m['blood_type']),
                                ExpansionTile(
                                  tilePadding: EdgeInsets.zero,
                                  title: Text(
                                    'Medical Conditions (${medicalConditions.length})',
                                  ),
                                  children: medicalConditions.isEmpty
                                      ? [
                                          const Padding(
                                            padding: EdgeInsets.only(bottom: 8),
                                            child: Text('No records.'),
                                          ),
                                        ]
                                      : medicalConditions.map((c) {
                                          return ListTile(
                                            dense: true,
                                            title: Text(
                                              c['condition_name'] ?? '—',
                                            ),
                                            subtitle: Text(
                                              '${c['status'] ?? 'active'} • ${fmtDate(c['diagnosis_date']) ?? '—'}',
                                            ),
                                          );
                                        }).toList(),
                                ),
                                ExpansionTile(
                                  tilePadding: EdgeInsets.zero,
                                  title: Text(
                                    'Allergies (${allergies.length})',
                                  ),
                                  children: allergies.isEmpty
                                      ? [
                                          const Padding(
                                            padding: EdgeInsets.only(bottom: 8),
                                            child: Text('No records.'),
                                          ),
                                        ]
                                      : allergies.map((a) {
                                          return ListTile(
                                            dense: true,
                                            title: Text(a['allergen'] ?? '—'),
                                            subtitle: Text(
                                              '${a['status'] ?? 'active'} • ${fmtDate(a['diagnosis_date']) ?? '—'}',
                                            ),
                                          );
                                        }).toList(),
                                ),
                              ]),
                            ],
                          ),
                        ),

                        // ================= CURRENT PREGNANCY =================
                        SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          child: currentPreg == null
                              ? infoCard('Current Pregnancy', const [
                                  Text('No ongoing pregnancy found.'),
                                ])
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    infoCard('Current Pregnancy', [
                                      field(
                                        'Risk Level',
                                        currentPreg['pregnancy_risk_level'],
                                      ),
                                      field('Status', currentPreg['status']),
                                      field(
                                        'LMP',
                                        fmtDate(
                                          currentPreg['last_menstrual_period'],
                                        ),
                                      ),
                                      field(
                                        'EDD',
                                        fmtDate(
                                          currentPreg['expected_date_of_delivery'],
                                        ),
                                      ),
                                    ]),
                                    infoCard('Checkups', [
                                      ...listOrEmpty(
                                        currentPreg['checkups'],
                                      ).map((c) {
                                        final date =
                                            fmtDate(c['checkup_date']) ?? '—';
                                        final bpSys = fmtValue(
                                          c['blood_pressure_systolic'],
                                        );
                                        final bpDia = fmtValue(
                                          c['blood_pressure_diastolic'],
                                        );
                                        final bp =
                                            (bpSys == '—' && bpDia == '—')
                                            ? null
                                            : 'BP: $bpSys/$bpDia';
                                        final aog = fmtValue(
                                          c['age_of_gestation'],
                                        );
                                        final wt = fmtValue(
                                          c['checkup_weight'],
                                        );
                                        final tags = <String>[];
                                        if (bp != null) tags.add(bp);
                                        if (aog != '—') tags.add('AOG: $aog');
                                        if (wt != '—') tags.add('Wt: $wt kg');

                                        final next = fmtDate(
                                          c['next_schedule'],
                                        );
                                        return recordCard(
                                          icon: Icons.medical_services,
                                          title: 'Checkup • $date',
                                          subtitle:
                                              (next == null || next.isEmpty)
                                              ? null
                                              : 'Next: $next',
                                          tags: tags,
                                          onTap: () => showRecordSheet(
                                            title: 'Checkup Details',
                                            subtitle: date,
                                            icon: Icons.medical_services,
                                            rows: [
                                              MapEntry(
                                                'Checkup Date',
                                                fmtValue(
                                                  fmtDate(c['checkup_date']),
                                                ),
                                              ),
                                              MapEntry(
                                                'Age of Gestation',
                                                fmtValue(c['age_of_gestation']),
                                              ),
                                              MapEntry(
                                                'Weight (kg)',
                                                fmtValue(c['checkup_weight']),
                                              ),
                                              MapEntry(
                                                'Blood Pressure',
                                                '${fmtValue(c['blood_pressure_systolic'])}/${fmtValue(c['blood_pressure_diastolic'])}',
                                              ),
                                              MapEntry(
                                                'Fetal Position',
                                                fmtValue(c['fetal_position']),
                                              ),
                                              MapEntry(
                                                'Fetal Heart Beat',
                                                fmtValue(c['fetal_heart_beat']),
                                              ),
                                              MapEntry(
                                                'Fetal Heart Tone',
                                                fmtValue(c['fetal_heart_tone']),
                                              ),
                                              MapEntry(
                                                'TD Vaccine Dose',
                                                fmtValue(c['td_vaccine_dose']),
                                              ),
                                              MapEntry(
                                                'Edema',
                                                fmtValue(c['edema']),
                                              ),
                                              MapEntry(
                                                'Remarks',
                                                fmtValue(c['remarks']),
                                              ),
                                              MapEntry(
                                                'Next Schedule',
                                                fmtValue(
                                                  fmtDate(c['next_schedule']),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }),
                                      if (listOrEmpty(
                                        currentPreg['checkups'],
                                      ).isEmpty)
                                        const Text('No checkups yet.'),
                                    ]),
                                    infoCard('Ultrasounds', [
                                      ...listOrEmpty(
                                        currentPreg['ultrasounds'],
                                      ).map((u) {
                                        final date =
                                            fmtDate(u['ultrasound_date']) ??
                                            '—';
                                        final imageUrl = resolveImageUrl(
                                          u['ultrasound_image'],
                                        );
                                        final tags = <String>[];
                                        final worker = fmtValue(
                                          u['health_worker_name'],
                                        );
                                        if (worker != '—') {
                                          tags.add(worker);
                                        }
                                        if (imageUrl != null) {
                                          tags.add('Image');
                                        }
                                        return recordCard(
                                          icon: Icons.monitor_heart,
                                          title: 'Ultrasound • $date',
                                          subtitle: fmtValue(
                                            u['ultrasound_location'],
                                          ),
                                          tags: tags,
                                          onTap: () => showRecordSheet(
                                            title: 'Ultrasound Details',
                                            subtitle: date,
                                            icon: Icons.monitor_heart,
                                            imageUrl: imageUrl,
                                            rows: [
                                              MapEntry(
                                                'Date',
                                                fmtValue(
                                                  fmtDate(u['ultrasound_date']),
                                                ),
                                              ),
                                              MapEntry(
                                                'Location',
                                                fmtValue(
                                                  u['ultrasound_location'],
                                                ),
                                              ),
                                              MapEntry(
                                                'Health Worker',
                                                fmtValue(
                                                  u['health_worker_name'],
                                                ),
                                              ),
                                              MapEntry(
                                                'Institution',
                                                fmtValue(
                                                  u['health_worker_institution'],
                                                ),
                                              ),
                                              MapEntry(
                                                'Profession',
                                                fmtValue(
                                                  u['health_worker_profession'],
                                                ),
                                              ),
                                              MapEntry(
                                                'Remarks',
                                                fmtValue(u['remarks']),
                                              ),
                                            ],
                                          ),
                                        );
                                      }),
                                      if (listOrEmpty(
                                        currentPreg['ultrasounds'],
                                      ).isEmpty)
                                        const Text('No ultrasounds yet.'),
                                    ]),
                                    infoCard('Lab Tests', [
                                      ...listOrEmpty(
                                        currentPreg['lab_tests'],
                                      ).map((l) {
                                        final date =
                                            fmtDate(l['lab_test_date']) ?? '—';
                                        final imageUrl = resolveImageUrl(
                                          l['lab_test_image'],
                                        );
                                        final tags = <String>[];
                                        final worker = fmtValue(
                                          l['health_worker_name'],
                                        );
                                        if (worker != '—') {
                                          tags.add(worker);
                                        }
                                        if (imageUrl != null) {
                                          tags.add('Image');
                                        }
                                        return recordCard(
                                          icon: Icons.science,
                                          title:
                                              '${l['lab_test_type'] ?? 'Lab Test'} • $date',
                                          subtitle: fmtValue(
                                            l['lab_test_location'],
                                          ),
                                          tags: tags,
                                          onTap: () => showRecordSheet(
                                            title: 'Lab Test Details',
                                            subtitle: date,
                                            icon: Icons.science,
                                            imageUrl: imageUrl,
                                            rows: [
                                              MapEntry(
                                                'Type',
                                                fmtValue(l['lab_test_type']),
                                              ),
                                              MapEntry(
                                                'Date',
                                                fmtValue(
                                                  fmtDate(l['lab_test_date']),
                                                ),
                                              ),
                                              MapEntry(
                                                'Location',
                                                fmtValue(
                                                  l['lab_test_location'],
                                                ),
                                              ),
                                              MapEntry(
                                                'Health Worker',
                                                fmtValue(
                                                  l['health_worker_name'],
                                                ),
                                              ),
                                              MapEntry(
                                                'Institution',
                                                fmtValue(
                                                  l['health_worker_institution'],
                                                ),
                                              ),
                                              MapEntry(
                                                'Profession',
                                                fmtValue(
                                                  l['health_worker_profession'],
                                                ),
                                              ),
                                              MapEntry(
                                                'Remarks',
                                                fmtValue(l['remarks']),
                                              ),
                                            ],
                                          ),
                                        );
                                      }),
                                      if (listOrEmpty(
                                        currentPreg['lab_tests'],
                                      ).isEmpty)
                                        const Text('No lab tests yet.'),
                                    ]),
                                  ],
                                ),
                        ),

                        // ================= HISTORY =================
                        SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          child: pastPregs.isEmpty
                              ? infoCard('Past Pregnancies', const [
                                  Text('No past pregnancies recorded.'),
                                ])
                              : Column(
                                  children: pastPregs.map((p) {
                                    final delivery = p['delivery'];
                                    return infoCard('Pregnancy • ${p['outcome'] ?? '—'}', [
                                      field(
                                        'Outcome Date',
                                        fmtDate(p['outcome_date']),
                                      ),
                                      field(
                                        'Gestational Age',
                                        p['gestational_age_at_end'],
                                      ),
                                      if (delivery != null) ...[
                                        field(
                                          'Delivery Place',
                                          delivery['place_of_delivery'],
                                        ),
                                        field(
                                          'Delivery Method',
                                          delivery['delivery_method'],
                                        ),
                                      ],
                                      ExpansionTile(
                                        tilePadding: EdgeInsets.zero,
                                        title: Text(
                                          'Checkups (${listOrEmpty(p['checkups']).length})',
                                        ),
                                        children:
                                            listOrEmpty(p['checkups']).isEmpty
                                            ? [
                                                const Padding(
                                                  padding: EdgeInsets.only(
                                                    bottom: 8,
                                                  ),
                                                  child: Text('No checkups.'),
                                                ),
                                              ]
                                            : listOrEmpty(p['checkups']).map((
                                                c,
                                              ) {
                                                final date =
                                                    fmtDate(
                                                      c['checkup_date'],
                                                    ) ??
                                                    '—';
                                                final bpSys = fmtValue(
                                                  c['blood_pressure_systolic'],
                                                );
                                                final bpDia = fmtValue(
                                                  c['blood_pressure_diastolic'],
                                                );
                                                final bp =
                                                    (bpSys == '—' &&
                                                        bpDia == '—')
                                                    ? null
                                                    : 'BP: $bpSys/$bpDia';
                                                final aog = fmtValue(
                                                  c['age_of_gestation'],
                                                );
                                                final wt = fmtValue(
                                                  c['checkup_weight'],
                                                );
                                                final tags = <String>[];
                                                if (bp != null) tags.add(bp);
                                                if (aog != '—') {
                                                  tags.add('AOG: $aog');
                                                }
                                                if (wt != '—')
                                                  tags.add('Wt: $wt kg');

                                                return recordCard(
                                                  icon: Icons.medical_services,
                                                  title: 'Checkup • $date',
                                                  tags: tags,
                                                  onTap: () => showRecordSheet(
                                                    title: 'Checkup Details',
                                                    subtitle: date,
                                                    icon:
                                                        Icons.medical_services,
                                                    rows: [
                                                      MapEntry(
                                                        'Checkup Date',
                                                        fmtValue(
                                                          fmtDate(
                                                            c['checkup_date'],
                                                          ),
                                                        ),
                                                      ),
                                                      MapEntry(
                                                        'Age of Gestation',
                                                        fmtValue(
                                                          c['age_of_gestation'],
                                                        ),
                                                      ),
                                                      MapEntry(
                                                        'Weight (kg)',
                                                        fmtValue(
                                                          c['checkup_weight'],
                                                        ),
                                                      ),
                                                      MapEntry(
                                                        'Blood Pressure',
                                                        '${fmtValue(c['blood_pressure_systolic'])}/${fmtValue(c['blood_pressure_diastolic'])}',
                                                      ),
                                                      MapEntry(
                                                        'Fetal Position',
                                                        fmtValue(
                                                          c['fetal_position'],
                                                        ),
                                                      ),
                                                      MapEntry(
                                                        'Fetal Heart Beat',
                                                        fmtValue(
                                                          c['fetal_heart_beat'],
                                                        ),
                                                      ),
                                                      MapEntry(
                                                        'Fetal Heart Tone',
                                                        fmtValue(
                                                          c['fetal_heart_tone'],
                                                        ),
                                                      ),
                                                      MapEntry(
                                                        'TD Vaccine Dose',
                                                        fmtValue(
                                                          c['td_vaccine_dose'],
                                                        ),
                                                      ),
                                                      MapEntry(
                                                        'Edema',
                                                        fmtValue(c['edema']),
                                                      ),
                                                      MapEntry(
                                                        'Remarks',
                                                        fmtValue(c['remarks']),
                                                      ),
                                                      MapEntry(
                                                        'Next Schedule',
                                                        fmtValue(
                                                          fmtDate(
                                                            c['next_schedule'],
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              }).toList(),
                                      ),
                                      ExpansionTile(
                                        tilePadding: EdgeInsets.zero,
                                        title: Text(
                                          'Ultrasounds (${listOrEmpty(p['ultrasounds']).length})',
                                        ),
                                        children:
                                            listOrEmpty(
                                              p['ultrasounds'],
                                            ).isEmpty
                                            ? [
                                                const Padding(
                                                  padding: EdgeInsets.only(
                                                    bottom: 8,
                                                  ),
                                                  child: Text(
                                                    'No ultrasounds.',
                                                  ),
                                                ),
                                              ]
                                            : listOrEmpty(
                                                p['ultrasounds'],
                                              ).map((u) {
                                                final date =
                                                    fmtDate(
                                                      u['ultrasound_date'],
                                                    ) ??
                                                    '—';
                                                final imageUrl =
                                                    resolveImageUrl(
                                                      u['ultrasound_image'],
                                                    );
                                                final tags = <String>[];
                                                final worker = fmtValue(
                                                  u['health_worker_name'],
                                                );
                                                if (worker != '—')
                                                  tags.add(worker);
                                                if (imageUrl != null) {
                                                  tags.add('Image');
                                                }
                                                return recordCard(
                                                  icon: Icons.monitor_heart,
                                                  title: 'Ultrasound • $date',
                                                  subtitle: fmtValue(
                                                    u['ultrasound_location'],
                                                  ),
                                                  tags: tags,
                                                  onTap: () => showRecordSheet(
                                                    title: 'Ultrasound Details',
                                                    subtitle: date,
                                                    icon: Icons.monitor_heart,
                                                    imageUrl: imageUrl,
                                                    rows: [
                                                      MapEntry(
                                                        'Date',
                                                        fmtValue(
                                                          fmtDate(
                                                            u['ultrasound_date'],
                                                          ),
                                                        ),
                                                      ),
                                                      MapEntry(
                                                        'Location',
                                                        fmtValue(
                                                          u['ultrasound_location'],
                                                        ),
                                                      ),
                                                      MapEntry(
                                                        'Health Worker',
                                                        fmtValue(
                                                          u['health_worker_name'],
                                                        ),
                                                      ),
                                                      MapEntry(
                                                        'Institution',
                                                        fmtValue(
                                                          u['health_worker_institution'],
                                                        ),
                                                      ),
                                                      MapEntry(
                                                        'Profession',
                                                        fmtValue(
                                                          u['health_worker_profession'],
                                                        ),
                                                      ),
                                                      MapEntry(
                                                        'Remarks',
                                                        fmtValue(u['remarks']),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              }).toList(),
                                      ),
                                      ExpansionTile(
                                        tilePadding: EdgeInsets.zero,
                                        title: Text(
                                          'Lab Tests (${listOrEmpty(p['lab_tests']).length})',
                                        ),
                                        children:
                                            listOrEmpty(p['lab_tests']).isEmpty
                                            ? [
                                                const Padding(
                                                  padding: EdgeInsets.only(
                                                    bottom: 8,
                                                  ),
                                                  child: Text('No lab tests.'),
                                                ),
                                              ]
                                            : listOrEmpty(p['lab_tests']).map((
                                                l,
                                              ) {
                                                final date =
                                                    fmtDate(
                                                      l['lab_test_date'],
                                                    ) ??
                                                    '—';
                                                final imageUrl =
                                                    resolveImageUrl(
                                                      l['lab_test_image'],
                                                    );
                                                final tags = <String>[];
                                                final worker = fmtValue(
                                                  l['health_worker_name'],
                                                );
                                                if (worker != '—')
                                                  tags.add(worker);
                                                if (imageUrl != null)
                                                  tags.add('Image');
                                                return recordCard(
                                                  icon: Icons.science,
                                                  title:
                                                      '${l['lab_test_type'] ?? 'Lab Test'} • $date',
                                                  subtitle: fmtValue(
                                                    l['lab_test_location'],
                                                  ),
                                                  tags: tags,
                                                  onTap: () => showRecordSheet(
                                                    title: 'Lab Test Details',
                                                    subtitle: date,
                                                    icon: Icons.science,
                                                    imageUrl: imageUrl,
                                                    rows: [
                                                      MapEntry(
                                                        'Type',
                                                        fmtValue(
                                                          l['lab_test_type'],
                                                        ),
                                                      ),
                                                      MapEntry(
                                                        'Date',
                                                        fmtValue(
                                                          fmtDate(
                                                            l['lab_test_date'],
                                                          ),
                                                        ),
                                                      ),
                                                      MapEntry(
                                                        'Location',
                                                        fmtValue(
                                                          l['lab_test_location'],
                                                        ),
                                                      ),
                                                      MapEntry(
                                                        'Health Worker',
                                                        fmtValue(
                                                          l['health_worker_name'],
                                                        ),
                                                      ),
                                                      MapEntry(
                                                        'Institution',
                                                        fmtValue(
                                                          l['health_worker_institution'],
                                                        ),
                                                      ),
                                                      MapEntry(
                                                        'Profession',
                                                        fmtValue(
                                                          l['health_worker_profession'],
                                                        ),
                                                      ),
                                                      MapEntry(
                                                        'Remarks',
                                                        fmtValue(l['remarks']),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              }).toList(),
                                      ),
                                    ]);
                                  }).toList(),
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
