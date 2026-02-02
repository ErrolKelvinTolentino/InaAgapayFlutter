import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

import '../theme/app_colors.dart';
import '../services/auth_storage.dart';

import 'add_prenatal_checkup.dart';
import 'add_ultrasound_page.dart';
import 'add_lab_test_page.dart';
import 'child_profile_page.dart';

class MotherProfilePage extends StatefulWidget {
  final int motherId;

  const MotherProfilePage({super.key, required this.motherId});

  @override
  State<MotherProfilePage> createState() => _MotherProfilePageState();
}

class _MotherProfilePageState extends State<MotherProfilePage>
    with SingleTickerProviderStateMixin {
  Future<Map<String, dynamic>>? _future;
  bool _riskExpanded = false;
  String _childQuery = '';
  String _childSort = 'recent';
  String _checkupSort = 'desc';
  String _labSort = 'desc';
  String _usSort = 'desc';
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _future = fetchMotherProfile();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<Map<String, dynamic>> fetchMotherProfile() async {
    final token = await AuthStorage.getToken();
    if (token == null) throw Exception('Not authenticated');

    final res = await http.get(
      Uri.parse(
        'https://inaagapay.alwaysdata.net/api/midwife/mother_profile.php'
        '?mother_id=${widget.motherId}',
      ),
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    final decoded = jsonDecode(res.body);

    if (decoded['success'] != true) {
      throw Exception(decoded['message'] ?? 'Failed to load profile');
    }

    return decoded['mother'];
  }

  Future<void> _refresh() async {
    setState(() => _future = fetchMotherProfile());
    await _future;
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
        future: _future,
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

          Widget infoCard(String title, List<Widget> children) {
            return section(title, children);
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

          DateTime? parseDate(dynamic v) {
            if (v == null) return null;
            return DateTime.tryParse(v.toString());
          }

          DateTime? parseDateTime(dynamic v) {
            if (v == null) return null;
            final raw = v.toString().trim();
            if (raw.isEmpty) return null;
            return DateTime.tryParse(raw);
          }

          String? fmtDate(dynamic v) {
            if (v == null) return null;
            final parsed = DateTime.tryParse(v.toString());
            if (parsed == null) return v.toString();
            return DateFormat('MMM d, yyyy').format(parsed);
          }

          String? fmtDateTime(dynamic v) {
            final parsed = parseDateTime(v);
            if (parsed == null) return v?.toString();
            return DateFormat('MMM d, yyyy h:mm a').format(parsed);
          }

          String fmtValue(dynamic v) {
            if (v == null) return '—';
            final value = v.toString().trim();
            return value.isEmpty ? '—' : value;
          }

          List<dynamic> listOrEmpty(dynamic v) => v is List ? v : [];

          Map<String, dynamic>? riskData(dynamic v) {
            return v is Map<String, dynamic> ? v : null;
          }

          String? resolveImageUrl(dynamic v) {
            if (v == null) return null;
            final raw = v.toString().trim();
            if (raw.isEmpty) return null;
            if (raw.startsWith('http')) return raw;
            final cleaned = raw.startsWith('/') ? raw.substring(1) : raw;
            return 'https://inaagapay.alwaysdata.net/$cleaned';
          }

          String shortDate(dynamic v) {
            final parsed = parseDateTime(v) ?? parseDate(v);
            if (parsed == null) return '—';
            return DateFormat('MMM d').format(parsed);
          }

          double? toDouble(dynamic v) {
            if (v == null) return null;
            return double.tryParse(v.toString());
          }

          List<Map<String, dynamic>> sortedCheckups(dynamic v) {
            final list = listOrEmpty(
              v,
            ).whereType<Map<String, dynamic>>().toList();
            list.sort((a, b) {
              final da = parseDateTime(
                a['checkup_datetime'] ?? a['checkup_date'],
              );
              final db = parseDateTime(
                b['checkup_datetime'] ?? b['checkup_date'],
              );
              if (da == null && db == null) return 0;
              if (da == null) return 1;
              if (db == null) return -1;
              var cmp = da.compareTo(db);
              if (cmp == 0) {
                final ida =
                    int.tryParse(a['prenatal_checkup_id']?.toString() ?? '') ??
                    0;
                final idb =
                    int.tryParse(b['prenatal_checkup_id']?.toString() ?? '') ??
                    0;
                cmp = ida.compareTo(idb);
              }
              return _checkupSort == 'asc' ? cmp : -cmp;
            });
            return list;
          }

          List<Map<String, dynamic>> sortByDate(
            dynamic v,
            String field,
            String order,
          ) {
            final list = listOrEmpty(
              v,
            ).whereType<Map<String, dynamic>>().toList();
            list.sort((a, b) {
              final da = parseDate(a[field]);
              final db = parseDate(b[field]);
              if (da == null && db == null) return 0;
              if (da == null) return 1;
              if (db == null) return -1;
              var cmp = da.compareTo(db);
              if (cmp == 0) {
                final ida = int.tryParse(
                  a['prenatal_checkup_id']?.toString() ?? '',
                );
                final idb = int.tryParse(
                  b['prenatal_checkup_id']?.toString() ?? '',
                );
                if (ida != null && idb != null) {
                  cmp = ida.compareTo(idb);
                }
              }
              return order == 'asc' ? cmp : -cmp;
            });
            return list;
          }

          Widget metricTile({
            required String title,
            required String value,
            required IconData icon,
            Color? color,
          }) {
            final accent = color ?? AppColors.brandPrimary;
            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.borderPrimary),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: accent.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, color: accent, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          value,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }

          Widget chartCard({
            required String title,
            required Widget chart,
            String? subtitle,
          }) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.borderPrimary),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
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
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                  ],
                  const SizedBox(height: 12),
                  SizedBox(height: 190, child: chart),
                ],
              ),
            );
          }

          Widget emptyChart(String label) {
            return Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.bgSecondary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                label,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            );
          }

          LineChartData lineChartData({
            required List<LineChartBarData> lines,
            required List<String> labels,
            double? minY,
            double? maxY,
          }) {
            return LineChartData(
              minY: minY,
              maxY: maxY,
              gridData: FlGridData(show: true, drawVerticalLine: false),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 36,
                    getTitlesWidget: (value, _) => Text(
                      value.toInt().toString(),
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 28,
                    interval: 1,
                    getTitlesWidget: (value, _) {
                      final index = value.toInt();
                      if (index < 0 || index >= labels.length) {
                        return const SizedBox.shrink();
                      }
                      return Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          labels[index],
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 10,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              lineBarsData: lines,
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

          Widget tagChip(String text) {
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
                                children: tags.map(tagChip).toList(),
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

          Widget detailRow(String label, String value) {
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
                              .map((r) => detailRow(r.key, r.value))
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
          final emergencyContacts = listOrEmpty(m['emergency_contacts']);
          final motherMeds = listOrEmpty(m['mother_medications']);
          final givenMeds = listOrEmpty(m['given_medications']);
          final children = listOrEmpty(m['children']);

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
                  motherId: widget.motherId,
                  pregnancyId: int.parse(pregnancyId.toString()),
                  lmp: lmp,
                  motherWeight: null,
                ),
              ),
            );

            if (added == true) {
              await _refresh();
            }
          }

          Future<void> startNewPregnancy() async {
            DateTime? lmp;
            DateTime? edd;
            String method = 'lmp';
            final weeksCtrl = TextEditingController();
            final daysCtrl = TextEditingController();

            await showModalBottomSheet<void>(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.white,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              builder: (ctx) {
                return StatefulBuilder(
                  builder: (ctx, setModal) {
                    void computeFromAog() {
                      final weeks = int.tryParse(weeksCtrl.text.trim()) ?? 0;
                      final days = int.tryParse(daysCtrl.text.trim()) ?? 0;
                      final totalDays = (weeks * 7) + days;
                      setModal(() {
                        if (totalDays <= 0) {
                          lmp = null;
                          edd = null;
                        } else {
                          final base = DateTime.now().subtract(
                            Duration(days: totalDays),
                          );
                          lmp = base;
                          edd = base.add(const Duration(days: 280));
                        }
                      });
                    }

                    Future<void> pickDate(bool isLmp) async {
                      final picked = await showDatePicker(
                        context: ctx,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(1900),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (picked != null) {
                        setModal(() {
                          if (isLmp) {
                            lmp = picked;
                            edd = picked.add(const Duration(days: 280));
                          } else {
                            edd = picked;
                            lmp = picked.subtract(const Duration(days: 280));
                          }
                        });
                      }
                    }

                    return Padding(
                      padding: EdgeInsets.only(
                        left: 16,
                        right: 16,
                        bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
                        top: 16,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.playlist_add_check_circle),
                              const SizedBox(width: 8),
                              const Text(
                                'Start New Pregnancy',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Spacer(),
                              IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () => Navigator.pop(ctx),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const Text('Method'),
                              const SizedBox(width: 12),
                              DropdownButton<String>(
                                value: method,
                                items: const [
                                  DropdownMenuItem(
                                    value: 'lmp',
                                    child: Text('LMP'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'edd',
                                    child: Text('EDD'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'aog',
                                    child: Text('AOG'),
                                  ),
                                ],
                                onChanged: (v) {
                                  if (v == null) return;
                                  setModal(() {
                                    method = v;
                                    lmp = null;
                                    edd = null;
                                    weeksCtrl.clear();
                                    daysCtrl.clear();
                                  });
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          if (method == 'lmp')
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: const Text('Last menstrual period'),
                              subtitle: Text(
                                lmp == null
                                    ? 'Pick date'
                                    : DateFormat('MMM d, yyyy').format(lmp!),
                              ),
                              trailing: const Icon(Icons.calendar_today),
                              onTap: () => pickDate(true),
                            )
                          else if (method == 'edd')
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: const Text('Expected date of delivery'),
                              subtitle: Text(
                                edd == null
                                    ? 'Pick date'
                                    : DateFormat('MMM d, yyyy').format(edd!),
                              ),
                              trailing: const Icon(Icons.calendar_today),
                              onTap: () => pickDate(false),
                            )
                          else
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: weeksCtrl,
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(
                                      labelText: 'Weeks',
                                    ),
                                    onChanged: (_) => computeFromAog(),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: TextField(
                                    controller: daysCtrl,
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(
                                      labelText: 'Days',
                                    ),
                                    onChanged: (_) => computeFromAog(),
                                  ),
                                ),
                              ],
                            ),
                          const SizedBox(height: 12),
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text('Computed LMP'),
                            subtitle: Text(
                              lmp == null
                                  ? '—'
                                  : DateFormat('MMM d, yyyy').format(lmp!),
                            ),
                          ),
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text('Computed EDD'),
                            subtitle: Text(
                              edd == null
                                  ? '—'
                                  : DateFormat('MMM d, yyyy').format(edd!),
                            ),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton.icon(
                            onPressed: () async {
                              if (method == 'aog') {
                                computeFromAog();
                              }

                              if (lmp == null || edd == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Provide gestational info to compute LMP and EDD.',
                                    ),
                                  ),
                                );
                                return;
                              }

                              final spanDays = edd!.difference(lmp!).inDays;
                              if (spanDays < 259 || spanDays > 294) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'EDD must be 37–42 weeks from LMP.',
                                    ),
                                  ),
                                );
                                return;
                              }

                              try {
                                final token = await AuthStorage.getToken();
                                if (token == null) {
                                  throw Exception('Not authenticated');
                                }

                                final res = await http.post(
                                  Uri.parse(
                                    'https://inaagapay.alwaysdata.net/api/midwife/start_pregnancy.php',
                                  ),
                                  headers: {
                                    'Authorization': 'Bearer $token',
                                    'Accept': 'application/json',
                                    'Content-Type': 'application/json',
                                  },
                                  body: jsonEncode({
                                    'mother_id': widget.motherId,
                                    'last_menstrual_period': lmp!
                                        .toIso8601String(),
                                    'expected_date_of_delivery': edd!
                                        .toIso8601String(),
                                  }),
                                );

                                final decoded = jsonDecode(res.body);
                                if (decoded['success'] != true) {
                                  throw Exception(
                                    decoded['message'] ??
                                        'Failed to start pregnancy',
                                  );
                                }

                                if (!mounted) return;
                                Navigator.pop(ctx);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Pregnancy started.'),
                                  ),
                                );
                                await _refresh();
                              } catch (e) {
                                if (!mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(e.toString())),
                                );
                              }
                            },
                            icon: const Icon(Icons.play_arrow),
                            label: const Text('Start Pregnancy'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.brandPrimary,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            );
          }

          Future<void> concludePregnancy() async {
            if (currentPreg == null) return;
            String outcome = 'livebirth';
            DateTime? outcomeDate;
            DateTime? deliveryDate;
            String? deliveryMethod;
            String? placeOfDelivery;
            double? gestAge;
            final gestAgeController = TextEditingController();
            final lmpDate = parseDate(
              currentPreg['last_menstrual_period'] ??
                  m['last_menstrual_period'],
            );

            void recomputeGestAge() {
              if (lmpDate == null) return;
              final reference =
                  (outcome == 'livebirth' || outcome == 'stillbirth')
                  ? (deliveryDate ?? outcomeDate ?? DateTime.now())
                  : (outcomeDate ?? DateTime.now());
              final weeks = reference.difference(lmpDate).inDays / 7;
              final rounded = double.parse(weeks.toStringAsFixed(1));
              gestAge = rounded;
              gestAgeController.text = rounded.toStringAsFixed(1);
            }

            recomputeGestAge();

            await showModalBottomSheet<void>(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.white,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              builder: (ctx) {
                return StatefulBuilder(
                  builder: (ctx, setModal) {
                    Future<void> pickDate(bool isDelivery) async {
                      final picked = await showDatePicker(
                        context: ctx,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(1900),
                        lastDate: DateTime.now().add(const Duration(days: 30)),
                      );
                      if (picked != null) {
                        setModal(() {
                          if (isDelivery) {
                            deliveryDate = picked;
                            outcomeDate = picked;
                          } else {
                            outcomeDate = picked;
                          }
                          recomputeGestAge();
                        });
                      }
                    }

                    return Padding(
                      padding: EdgeInsets.only(
                        left: 16,
                        right: 16,
                        bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
                        top: 16,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.flag),
                              const SizedBox(width: 8),
                              const Text(
                                'Conclude Pregnancy',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Spacer(),
                              IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () => Navigator.pop(ctx),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<String>(
                            value: outcome,
                            decoration: const InputDecoration(
                              labelText: 'Outcome',
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'livebirth',
                                child: Text('Livebirth'),
                              ),
                              DropdownMenuItem(
                                value: 'stillbirth',
                                child: Text('Stillbirth'),
                              ),
                              DropdownMenuItem(
                                value: 'miscarriage',
                                child: Text('Miscarriage'),
                              ),
                              DropdownMenuItem(
                                value: 'abortion',
                                child: Text('Abortion'),
                              ),
                              DropdownMenuItem(
                                value: 'ectopic',
                                child: Text('Ectopic'),
                              ),
                            ],
                            onChanged: (v) => setModal(() {
                              outcome = v ?? outcome;
                              recomputeGestAge();
                            }),
                          ),
                          const SizedBox(height: 8),
                          if (outcome == 'livebirth' ||
                              outcome == 'stillbirth') ...[
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: const Text('Delivery date'),
                              subtitle: Text(
                                deliveryDate == null
                                    ? 'Pick date'
                                    : DateFormat(
                                        'MMM d, yyyy',
                                      ).format(deliveryDate!),
                              ),
                              trailing: const Icon(Icons.calendar_today),
                              onTap: () => pickDate(true),
                            ),
                            TextField(
                              decoration: const InputDecoration(
                                labelText: 'Place of delivery',
                              ),
                              onChanged: (v) => placeOfDelivery = v.trim(),
                            ),
                            DropdownButtonFormField<String>(
                              value: deliveryMethod,
                              decoration: const InputDecoration(
                                labelText: 'Delivery method',
                              ),
                              items: const [
                                DropdownMenuItem(
                                  value: 'NSD',
                                  child: Text('Normal Spontaneous Delivery'),
                                ),
                                DropdownMenuItem(
                                  value: 'CS',
                                  child: Text('Cesarean Section'),
                                ),
                                DropdownMenuItem(
                                  value: 'Instrumental',
                                  child: Text('Instrumental'),
                                ),
                              ],
                              onChanged: (v) =>
                                  setModal(() => deliveryMethod = v),
                            ),
                          ] else ...[
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: const Text('Outcome date'),
                              subtitle: Text(
                                outcomeDate == null
                                    ? 'Pick date'
                                    : DateFormat(
                                        'MMM d, yyyy',
                                      ).format(outcomeDate!),
                              ),
                              trailing: const Icon(Icons.calendar_today),
                              onTap: () => pickDate(false),
                            ),
                          ],
                          const SizedBox(height: 8),
                          TextField(
                            controller: gestAgeController,
                            decoration: const InputDecoration(
                              labelText: 'AOG at end (weeks)',
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (v) => gestAge = double.tryParse(v),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton.icon(
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: ctx,
                                builder: (dialogContext) => AlertDialog(
                                  title: const Text('Confirm conclude'),
                                  content: const Text(
                                    'This will end the current pregnancy. Proceed?',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(dialogContext, false),
                                      child: const Text('Cancel'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () =>
                                          Navigator.pop(dialogContext, true),
                                      child: const Text('Yes, conclude'),
                                    ),
                                  ],
                                ),
                              );
                              if (confirm != true) return;

                              try {
                                final token = await AuthStorage.getToken();
                                if (token == null)
                                  throw Exception('Not authenticated');

                                final res = await http.post(
                                  Uri.parse(
                                    'https://inaagapay.alwaysdata.net/api/midwife/conclude_pregnancy.php',
                                  ),
                                  headers: {
                                    'Authorization': 'Bearer $token',
                                    'Accept': 'application/json',
                                    'Content-Type': 'application/json',
                                  },
                                  body: jsonEncode({
                                    'pregnancy_id': currentPreg['pregnancy_id'],
                                    'outcome': outcome,
                                    'outcome_date': outcomeDate
                                        ?.toIso8601String(),
                                    'delivery_date': deliveryDate
                                        ?.toIso8601String(),
                                    'delivery_method': deliveryMethod,
                                    'place_of_delivery': placeOfDelivery,
                                    'gestational_age_at_end': gestAge,
                                  }),
                                );

                                final decoded = jsonDecode(res.body);
                                if (decoded['success'] != true) {
                                  throw Exception(
                                    decoded['message'] ?? 'Failed to conclude',
                                  );
                                }
                                if (!mounted) return;
                                Navigator.pop(ctx);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Pregnancy concluded.'),
                                  ),
                                );
                                await _refresh();
                              } catch (e) {
                                if (!mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(e.toString())),
                                );
                              }
                            },
                            icon: const Icon(Icons.check_circle),
                            label: const Text('Conclude pregnancy'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            );
            gestAgeController.dispose();
          }

          return DefaultTabController(
            length: 3,
            child: Column(
              children: [
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _refresh,
                    child: NestedScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      headerSliverBuilder: (context, _) => [
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(18),
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFFFFECF3),
                                        Color(0xFFFFF7FB),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    border: Border.all(
                                      color: AppColors.borderPrimary,
                                    ),
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: 64,
                                        height: 64,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(
                                                0.06,
                                              ),
                                              blurRadius: 12,
                                            ),
                                          ],
                                        ),
                                        child: const Icon(
                                          Icons.person,
                                          size: 34,
                                          color: AppColors.brandText,
                                        ),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
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
                                              m['phone_number'] ?? '—',
                                              style: const TextStyle(
                                                color: AppColors.textSecondary,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Wrap(
                                              spacing: 8,
                                              runSpacing: 8,
                                              children: [
                                                statChip(
                                                  'Status',
                                                  '${m['status'] ?? '—'}',
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
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 14),
                                Wrap(
                                  spacing: 10,
                                  runSpacing: 10,
                                  alignment: WrapAlignment.center,
                                  children: [
                                    statChip(
                                      'Children',
                                      '${m['children_count'] ?? 0}',
                                    ),
                                    statChip(
                                      'Barangay',
                                      '${m['barangay'] ?? '—'}',
                                    ),
                                    statChip(
                                      'City',
                                      '${m['city_municipality'] ?? '—'}',
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Builder(
                                  builder: (_) {
                                    final risk =
                                        riskData(m['pregnancy_risk']) ??
                                        riskData(
                                          m['current_pregnancy']?['risk'],
                                        );
                                    if (risk == null) return const SizedBox();
                                    final level = (risk['level'] ?? '—')
                                        .toString()
                                        .toLowerCase();
                                    Color cardColor;
                                    switch (level) {
                                      case 'high':
                                        cardColor = Colors.red.shade50;
                                        break;
                                      case 'medium':
                                        cardColor = Colors.orange.shade50;
                                        break;
                                      default:
                                        cardColor = Colors.green.shade50;
                                    }
                                    final reasons = listOrEmpty(
                                      risk['factors'],
                                    ).whereType<String>().toList();
                                    return Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(14),
                                      decoration: BoxDecoration(
                                        color: cardColor,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: Colors.black12,
                                        ),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              const Icon(Icons.warning),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  'Risk: ${level.toUpperCase()} (${risk['score'] ?? '—'})',
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              IconButton(
                                                icon: Icon(
                                                  _riskExpanded
                                                      ? Icons.expand_less
                                                      : Icons.expand_more,
                                                ),
                                                onPressed: () => setState(
                                                  () => _riskExpanded =
                                                      !_riskExpanded,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Text(
                                            risk['note'] ?? 'Risk summary',
                                            style: const TextStyle(
                                              color: AppColors.textSecondary,
                                            ),
                                          ),
                                          if (_riskExpanded &&
                                              reasons.isNotEmpty) ...[
                                            const SizedBox(height: 8),
                                            Wrap(
                                              spacing: 6,
                                              runSpacing: 6,
                                              children: reasons
                                                  .map((r) => tagChip(r))
                                                  .toList(),
                                            ),
                                          ],
                                        ],
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(height: 16),
                                TabBar(
                                  controller: _tabController,
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
                        controller: _tabController,
                        children: [
                          // ================= OVERVIEW =================
                          SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                infoCard('Quick Actions', [
                                  if (currentPreg == null) ...[
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'No ongoing pregnancy.',
                                          style: TextStyle(
                                            color: AppColors.textSecondary,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        OutlinedButton.icon(
                                          onPressed: startNewPregnancy,
                                          icon: const Icon(Icons.play_arrow),
                                          label: const Text(
                                            'Start New Pregnancy',
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        const Text(
                                          'Set LMP and EDD to begin tracking.',
                                          style: TextStyle(
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ] else ...[
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
                                                builder: (_) =>
                                                    AddUltrasoundPage(
                                                      motherId: widget.motherId,
                                                    ),
                                              ),
                                            );
                                            if (added == true) {
                                              await _refresh();
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
                                                  motherId: widget.motherId,
                                                ),
                                              ),
                                            );
                                            if (added == true) {
                                              await _refresh();
                                            }
                                          },
                                          icon: const Icon(Icons.science),
                                          label: const Text('Add Lab Test'),
                                        ),
                                        OutlinedButton.icon(
                                          onPressed: concludePregnancy,
                                          icon: const Icon(Icons.flag),
                                          label: const Text('Conclude'),
                                          style: OutlinedButton.styleFrom(
                                            foregroundColor: Colors.red,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
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
                                              padding: EdgeInsets.only(
                                                bottom: 8,
                                              ),
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
                                              padding: EdgeInsets.only(
                                                bottom: 8,
                                              ),
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
                                infoCard(
                                  'Emergency Contacts (${emergencyContacts.length})',
                                  [
                                    if (emergencyContacts.isEmpty)
                                      const Text('No emergency contacts yet.'),
                                    ...emergencyContacts.map((c) {
                                      final name =
                                          [
                                                c['first_name'],
                                                c['middle_name'],
                                                c['last_name'],
                                                c['extension_name'],
                                              ]
                                              .where(
                                                (e) =>
                                                    e != null &&
                                                    e
                                                        .toString()
                                                        .trim()
                                                        .isNotEmpty,
                                              )
                                              .join(' ');
                                      return ListTile(
                                        dense: true,
                                        contentPadding: EdgeInsets.zero,
                                        title: Text(
                                          name.isEmpty ? 'Unnamed' : name,
                                        ),
                                        subtitle: Text(
                                          '${c['phone_number'] ?? '—'} • ${c['affiliation'] ?? '—'}',
                                        ),
                                      );
                                    }),
                                  ],
                                ),
                                infoCard(
                                  'Medication Plans (${motherMeds.length})',
                                  [
                                    if (motherMeds.isEmpty)
                                      const Text(
                                        'No medication plans recorded.',
                                      ),
                                    ...motherMeds.map((mPlan) {
                                      final dates = [
                                        fmtDate(mPlan['start_date']),
                                        fmtDate(mPlan['end_date']),
                                      ].whereType<String>().join(' to ');
                                      return ListTile(
                                        dense: true,
                                        contentPadding: EdgeInsets.zero,
                                        title: Text(
                                          mPlan['mother_medication_name'] ??
                                              '—',
                                        ),
                                        subtitle: Text(
                                          [
                                            if ((mPlan['frequency'] ?? '')
                                                .toString()
                                                .trim()
                                                .isNotEmpty)
                                              'Freq: ${mPlan['frequency']}',
                                            if ((mPlan['quantity'] ?? '')
                                                .toString()
                                                .trim()
                                                .isNotEmpty)
                                              'Qty: ${mPlan['quantity']}',
                                            if (dates.isNotEmpty) dates,
                                          ].join(' · '),
                                        ),
                                        trailing: Text(
                                          (mPlan['status'] ?? 'active')
                                              .toString()
                                              .toUpperCase(),
                                          style: const TextStyle(
                                            color: AppColors.textSecondary,
                                            fontSize: 12,
                                          ),
                                        ),
                                      );
                                    }),
                                  ],
                                ),
                                infoCard(
                                  'Given Medications (${givenMeds.length})',
                                  [
                                    if (givenMeds.isEmpty)
                                      const Text('No given medications yet.'),
                                    ...givenMeds.map((g) {
                                      return ListTile(
                                        dense: true,
                                        contentPadding: EdgeInsets.zero,
                                        title: Text(
                                          g['given_medication_name'] ?? '—',
                                        ),
                                        subtitle: Text(
                                          [
                                            if (g['quantity'] != null)
                                              'Qty: ${g['quantity']}',
                                            if (fmtDate(g['date_given']) !=
                                                null)
                                              fmtDate(g['date_given'])!,
                                          ].join(' · '),
                                        ),
                                      );
                                    }),
                                  ],
                                ),
                                infoCard('Children (${children.length})', [
                                  TextField(
                                    decoration: const InputDecoration(
                                      prefixIcon: Icon(Icons.search),
                                      hintText: 'Search children...',
                                    ),
                                    onChanged: (v) =>
                                        setState(() => _childQuery = v),
                                  ),
                                  const SizedBox(height: 8),
                                  DropdownButtonFormField<String>(
                                    value: _childSort,
                                    decoration: const InputDecoration(
                                      labelText: 'Sort by',
                                    ),
                                    items: const [
                                      DropdownMenuItem(
                                        value: 'recent',
                                        child: Text('Most recent'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'name',
                                        child: Text('Name A–Z'),
                                      ),
                                    ],
                                    onChanged: (v) => setState(
                                      () => _childSort = v ?? 'recent',
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Builder(
                                    builder: (_) {
                                      var filtered = children
                                          .whereType<Map<String, dynamic>>()
                                          .where((c) {
                                            final name =
                                                [
                                                      c['first_name'],
                                                      c['middle_name'],
                                                      c['last_name'],
                                                      c['extension_name'],
                                                    ]
                                                    .where(
                                                      (e) =>
                                                          e != null &&
                                                          e
                                                              .toString()
                                                              .trim()
                                                              .isNotEmpty,
                                                    )
                                                    .join(' ')
                                                    .toLowerCase();
                                            return name.contains(
                                              _childQuery.toLowerCase(),
                                            );
                                          })
                                          .toList();

                                      if (_childSort == 'name') {
                                        filtered.sort((a, b) {
                                          final na =
                                              ((a['last_name'] ?? '') +
                                                      (a['first_name'] ?? ''))
                                                  .toString()
                                                  .toLowerCase();
                                          final nb =
                                              ((b['last_name'] ?? '') +
                                                      (b['first_name'] ?? ''))
                                                  .toString()
                                                  .toLowerCase();
                                          return na.compareTo(nb);
                                        });
                                      }

                                      if (filtered.isEmpty) {
                                        return const Padding(
                                          padding: EdgeInsets.symmetric(
                                            vertical: 8,
                                          ),
                                          child: Text('No children found.'),
                                        );
                                      }

                                      return Column(
                                        children: filtered.map((c) {
                                          final name =
                                              [
                                                    c['first_name'],
                                                    c['middle_name'],
                                                    c['last_name'],
                                                    c['extension_name'],
                                                  ]
                                                  .where(
                                                    (e) =>
                                                        e != null &&
                                                        e
                                                            .toString()
                                                            .trim()
                                                            .isNotEmpty,
                                                  )
                                                  .join(' ');
                                          return ListTile(
                                            contentPadding: EdgeInsets.zero,
                                            leading: const Icon(
                                              Icons.child_care,
                                            ),
                                            title: Text(
                                              name.isEmpty ? 'Unnamed' : name,
                                            ),
                                            subtitle: Text(
                                              fmtDate(c['added_at']) ?? '—',
                                            ),
                                            trailing: const Icon(
                                              Icons.chevron_right,
                                            ),
                                            onTap: () {
                                              final id = int.tryParse(
                                                c['child_id']?.toString() ?? '',
                                              );
                                              if (id != null) {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (_) =>
                                                        ChildProfilePage(
                                                          childId: id,
                                                        ),
                                                  ),
                                                );
                                              }
                                            },
                                          );
                                        }).toList(),
                                      );
                                    },
                                  ),
                                ]),
                              ],
                            ),
                          ),

                          // ================= CURRENT PREGNANCY =================
                          SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            child: currentPreg == null
                                ? infoCard('Current Pregnancy', const [
                                    Text('No ongoing pregnancy found.'),
                                  ])
                                : Builder(
                                    builder: (_) {
                                      final checkups = sortedCheckups(
                                        currentPreg['checkups'],
                                      );
                                      final lastCheckup = checkups.isNotEmpty
                                          ? checkups.last
                                          : null;
                                      final lastCheckupDate = fmtDateTime(
                                        lastCheckup?['checkup_datetime'] ??
                                            lastCheckup?['checkup_date'],
                                      );
                                      final nextSchedule = fmtDate(
                                        lastCheckup?['next_schedule'],
                                      );

                                      final lmp = parseDate(
                                        currentPreg['last_menstrual_period'],
                                      );
                                      final edd = parseDate(
                                        currentPreg['expected_date_of_delivery'],
                                      );
                                      final now = DateTime.now();
                                      final gestWeeks = lmp == null
                                          ? null
                                          : (now.difference(lmp).inDays / 7)
                                                .floor();
                                      final daysToEdd = edd
                                          ?.difference(now)
                                          .inDays;

                                      Widget weightChart() {
                                        final points = <FlSpot>[];
                                        final labels = <String>[];
                                        for (final c in checkups) {
                                          final w = toDouble(
                                            c['checkup_weight'],
                                          );
                                          if (w == null) continue;
                                          points.add(
                                            FlSpot(points.length.toDouble(), w),
                                          );
                                          labels.add(
                                            shortDate(
                                              c['checkup_datetime'] ??
                                                  c['checkup_date'],
                                            ),
                                          );
                                        }
                                        if (points.length < 2) {
                                          return emptyChart('Not enough data');
                                        }
                                        final minY = points
                                            .map((e) => e.y)
                                            .reduce((a, b) => a < b ? a : b);
                                        final maxY = points
                                            .map((e) => e.y)
                                            .reduce((a, b) => a > b ? a : b);
                                        return LineChart(
                                          lineChartData(
                                            lines: [
                                              LineChartBarData(
                                                spots: points,
                                                isCurved: true,
                                                color: AppColors.brandPrimary,
                                                barWidth: 3,
                                                dotData: FlDotData(show: true),
                                              ),
                                            ],
                                            labels: labels,
                                            minY: (minY - 1),
                                            maxY: (maxY + 1),
                                          ),
                                        );
                                      }

                                      Widget bpChart() {
                                        final sys = <FlSpot>[];
                                        final dia = <FlSpot>[];
                                        final labels = <String>[];
                                        for (final c in checkups) {
                                          final s = toDouble(
                                            c['blood_pressure_systolic'],
                                          );
                                          final d = toDouble(
                                            c['blood_pressure_diastolic'],
                                          );
                                          if (s == null || d == null) continue;
                                          final x = sys.length.toDouble();
                                          sys.add(FlSpot(x, s));
                                          dia.add(FlSpot(x, d));
                                          labels.add(
                                            shortDate(
                                              c['checkup_datetime'] ??
                                                  c['checkup_date'],
                                            ),
                                          );
                                        }
                                        if (sys.length < 2) {
                                          return emptyChart('Not enough data');
                                        }
                                        final values = [
                                          ...sys.map((e) => e.y),
                                          ...dia.map((e) => e.y),
                                        ];
                                        final minY = values.reduce(
                                          (a, b) => a < b ? a : b,
                                        );
                                        final maxY = values.reduce(
                                          (a, b) => a > b ? a : b,
                                        );
                                        return LineChart(
                                          lineChartData(
                                            lines: [
                                              LineChartBarData(
                                                spots: sys,
                                                isCurved: true,
                                                color: AppColors.brandPrimary,
                                                barWidth: 3,
                                                dotData: FlDotData(show: false),
                                              ),
                                              LineChartBarData(
                                                spots: dia,
                                                isCurved: true,
                                                color: AppColors.brandAccent,
                                                barWidth: 3,
                                                dotData: FlDotData(show: false),
                                              ),
                                            ],
                                            labels: labels,
                                            minY: (minY - 5),
                                            maxY: (maxY + 5),
                                          ),
                                        );
                                      }

                                      return Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          infoCard('Pregnancy Insights', [
                                            Wrap(
                                              spacing: 10,
                                              runSpacing: 10,
                                              children: [
                                                SizedBox(
                                                  width:
                                                      (MediaQuery.of(
                                                            context,
                                                          ).size.width -
                                                          56) /
                                                      2,
                                                  child: metricTile(
                                                    title: 'Gestation',
                                                    value: gestWeeks == null
                                                        ? '—'
                                                        : '$gestWeeks wks',
                                                    icon: Icons.timeline,
                                                  ),
                                                ),
                                                SizedBox(
                                                  width:
                                                      (MediaQuery.of(
                                                            context,
                                                          ).size.width -
                                                          56) /
                                                      2,
                                                  child: metricTile(
                                                    title: 'Days to EDD',
                                                    value: daysToEdd == null
                                                        ? '—'
                                                        : daysToEdd.toString(),
                                                    icon: Icons.event_available,
                                                    color: AppColors.warning,
                                                  ),
                                                ),
                                                SizedBox(
                                                  width:
                                                      (MediaQuery.of(
                                                            context,
                                                          ).size.width -
                                                          56) /
                                                      2,
                                                  child: metricTile(
                                                    title: 'Checkups',
                                                    value: checkups.length
                                                        .toString(),
                                                    icon: Icons.fact_check,
                                                    color: AppColors.success,
                                                  ),
                                                ),
                                                SizedBox(
                                                  width:
                                                      (MediaQuery.of(
                                                            context,
                                                          ).size.width -
                                                          56) /
                                                      2,
                                                  child: metricTile(
                                                    title: 'Last Checkup',
                                                    value:
                                                        lastCheckupDate ?? '—',
                                                    icon: Icons.event,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            if (nextSchedule != null &&
                                                nextSchedule.isNotEmpty) ...[
                                              const SizedBox(height: 10),
                                              Container(
                                                width: double.infinity,
                                                padding: const EdgeInsets.all(
                                                  12,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: AppColors.brandPrimary
                                                      .withOpacity(0.08),
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  border: Border.all(
                                                    color: AppColors
                                                        .brandPrimary
                                                        .withOpacity(0.2),
                                                  ),
                                                ),
                                                child: Row(
                                                  children: [
                                                    const Icon(
                                                      Icons.calendar_today,
                                                      size: 18,
                                                      color:
                                                          AppColors.brandText,
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Expanded(
                                                      child: Text(
                                                        'Next checkup: $nextSchedule',
                                                        style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ]),
                                          chartCard(
                                            title: 'Weight Trend (kg)',
                                            subtitle:
                                                'From recorded prenatal checkups',
                                            chart: weightChart(),
                                          ),
                                          chartCard(
                                            title: 'Blood Pressure Trend',
                                            subtitle: 'Systolic vs Diastolic',
                                            chart: bpChart(),
                                          ),
                                          infoCard('Current Pregnancy', [
                                            field(
                                              'Risk Level',
                                              currentPreg['pregnancy_risk_level'],
                                            ),
                                            field(
                                              'Status',
                                              currentPreg['status'],
                                            ),
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
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                const Text(
                                                  'Sort',
                                                  style: TextStyle(
                                                    color:
                                                        AppColors.textSecondary,
                                                  ),
                                                ),
                                                DropdownButton<String>(
                                                  value: _checkupSort,
                                                  items: const [
                                                    DropdownMenuItem(
                                                      value: 'desc',
                                                      child: Text(
                                                        'Newest first',
                                                      ),
                                                    ),
                                                    DropdownMenuItem(
                                                      value: 'asc',
                                                      child: Text(
                                                        'Oldest first',
                                                      ),
                                                    ),
                                                  ],
                                                  onChanged: (v) => setState(
                                                    () => _checkupSort =
                                                        v ?? 'desc',
                                                  ),
                                                ),
                                              ],
                                            ),
                                            ...sortedCheckups(
                                              currentPreg['checkups'],
                                            ).map((c) {
                                              final date =
                                                  fmtDateTime(
                                                    c['checkup_datetime'] ??
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
                                              if (aog != '—')
                                                tags.add('AOG: $aog');
                                              if (wt != '—')
                                                tags.add('Wt: $wt kg');

                                              final next = fmtDate(
                                                c['next_schedule'],
                                              );
                                              return recordCard(
                                                icon: Icons.medical_services,
                                                title: 'Checkup • $date',
                                                subtitle:
                                                    (next == null ||
                                                        next.isEmpty)
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
                                                        fmtDateTime(
                                                          c['checkup_datetime'] ??
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
                                            }),
                                            if (listOrEmpty(
                                              currentPreg['checkups'],
                                            ).isEmpty)
                                              const Text('No checkups yet.'),
                                          ]),
                                          infoCard('Ultrasounds', [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                const Text(
                                                  'Sort',
                                                  style: TextStyle(
                                                    color:
                                                        AppColors.textSecondary,
                                                  ),
                                                ),
                                                DropdownButton<String>(
                                                  value: _usSort,
                                                  items: const [
                                                    DropdownMenuItem(
                                                      value: 'desc',
                                                      child: Text(
                                                        'Newest first',
                                                      ),
                                                    ),
                                                    DropdownMenuItem(
                                                      value: 'asc',
                                                      child: Text(
                                                        'Oldest first',
                                                      ),
                                                    ),
                                                  ],
                                                  onChanged: (v) => setState(
                                                    () => _usSort = v ?? 'desc',
                                                  ),
                                                ),
                                              ],
                                            ),
                                            ...sortByDate(
                                              currentPreg['ultrasounds'],
                                              'ultrasound_date',
                                              _usSort,
                                            ).map((u) {
                                              final date =
                                                  fmtDate(
                                                    u['ultrasound_date'],
                                                  ) ??
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
                                            }),
                                            if (listOrEmpty(
                                              currentPreg['ultrasounds'],
                                            ).isEmpty)
                                              const Text('No ultrasounds yet.'),
                                          ]),
                                          infoCard('Lab Tests', [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                const Text(
                                                  'Sort',
                                                  style: TextStyle(
                                                    color:
                                                        AppColors.textSecondary,
                                                  ),
                                                ),
                                                DropdownButton<String>(
                                                  value: _labSort,
                                                  items: const [
                                                    DropdownMenuItem(
                                                      value: 'desc',
                                                      child: Text(
                                                        'Newest first',
                                                      ),
                                                    ),
                                                    DropdownMenuItem(
                                                      value: 'asc',
                                                      child: Text(
                                                        'Oldest first',
                                                      ),
                                                    ),
                                                  ],
                                                  onChanged: (v) => setState(
                                                    () =>
                                                        _labSort = v ?? 'desc',
                                                  ),
                                                ),
                                              ],
                                            ),
                                            ...sortByDate(
                                              currentPreg['lab_tests'],
                                              'lab_test_date',
                                              _labSort,
                                            ).map((l) {
                                              final date =
                                                  fmtDate(l['lab_test_date']) ??
                                                  '—';
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
                                            }),
                                            if (listOrEmpty(
                                              currentPreg['lab_tests'],
                                            ).isEmpty)
                                              const Text('No lab tests yet.'),
                                          ]),
                                        ],
                                      );
                                    },
                                  ),
                          ),

                          // ================= HISTORY =================
                          SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
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
                                                      fmtDateTime(
                                                        c['checkup_datetime'] ??
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
                                                    icon:
                                                        Icons.medical_services,
                                                    title: 'Checkup • $date',
                                                    tags: tags,
                                                    onTap: () => showRecordSheet(
                                                      title: 'Checkup Details',
                                                      subtitle: date,
                                                      icon: Icons
                                                          .medical_services,
                                                      rows: [
                                                        MapEntry(
                                                          'Checkup Date',
                                                          fmtValue(
                                                            fmtDate(
                                                              c['checkup_datetime'] ??
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
                                                          fmtValue(
                                                            c['remarks'],
                                                          ),
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
                                                      title:
                                                          'Ultrasound Details',
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
                                                          fmtValue(
                                                            u['remarks'],
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
                                            'Lab Tests (${listOrEmpty(p['lab_tests']).length})',
                                          ),
                                          children:
                                              listOrEmpty(
                                                p['lab_tests'],
                                              ).isEmpty
                                              ? [
                                                  const Padding(
                                                    padding: EdgeInsets.only(
                                                      bottom: 8,
                                                    ),
                                                    child: Text(
                                                      'No lab tests.',
                                                    ),
                                                  ),
                                                ]
                                              : listOrEmpty(
                                                  p['lab_tests'],
                                                ).map((l) {
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
                                                          fmtValue(
                                                            l['remarks'],
                                                          ),
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
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
