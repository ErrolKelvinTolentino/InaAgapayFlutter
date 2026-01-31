import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../theme/app_colors.dart';
import '../services/auth_storage.dart';

import 'mother_profile_page.dart';
import 'add_mother_flow.dart';

class MidwifeMothersPage extends StatefulWidget {
  const MidwifeMothersPage({super.key});

  @override
  State<MidwifeMothersPage> createState() => _MidwifeMothersPageState();
}

class _MidwifeMothersPageState extends State<MidwifeMothersPage> {
  Future<List<Map<String, dynamic>>>? _future;
  final TextEditingController _search = TextEditingController();
  String _riskFilter = 'all';
  String _sort = 'name';

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _load() {
    _future = fetchMothers();
    setState(() {});
  }

  Future<List<Map<String, dynamic>>> fetchMothers() async {
    final token = await AuthStorage.getToken();
    if (token == null) {
      throw Exception('Not authenticated');
    }

    final res = await http.get(
      Uri.parse(
        'https://inaagapay.alwaysdata.net/api/midwife/midwife_mothers.php',
      ),
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    final decoded = jsonDecode(res.body);

    if (decoded['success'] != true) {
      throw Exception(decoded['message'] ?? 'Failed to load mothers');
    }

    final List list = decoded['data'] ?? [];
    return list.cast<Map<String, dynamic>>();
  }

  List<Map<String, dynamic>> _applyFilters(List<Map<String, dynamic>> list) {
    final query = _search.text.trim().toLowerCase();
    List<Map<String, dynamic>> filtered = list.where((m) {
      final matchesSearch = query.isEmpty
          ? true
          : ([
              m['first_name'],
              m['middle_name'],
              m['last_name'],
              m['extension_name'],
              m['barangay'],
              m['city_municipality'],
            ].whereType<String>().any((v) => v.toLowerCase().contains(query)));

      final matchesRisk = _riskFilter == 'all'
          ? true
          : (m['pregnancy_risk_level']?.toString().toLowerCase() ==
                _riskFilter);

      return matchesSearch && matchesRisk;
    }).toList();

    int levelRank(String? level) {
      switch ((level ?? '').toLowerCase()) {
        case 'high':
          return 2;
        case 'medium':
          return 1;
        default:
          return 0;
      }
    }

    filtered.sort((a, b) {
      switch (_sort) {
        case 'risk':
          return levelRank(
            b['pregnancy_risk_level'],
          ).compareTo(levelRank(a['pregnancy_risk_level']));
        case 'edd':
          final eddA = DateTime.tryParse(
            (a['expected_date_of_delivery'] ?? '').toString(),
          );
          final eddB = DateTime.tryParse(
            (b['expected_date_of_delivery'] ?? '').toString(),
          );
          if (eddA == null && eddB == null) return 0;
          if (eddA == null) return 1;
          if (eddB == null) return -1;
          return eddA.compareTo(eddB);
        case 'name':
        default:
          final nameA = [
            a['last_name'] ?? '',
            a['first_name'] ?? '',
          ].join(' ').toLowerCase();
          final nameB = [
            b['last_name'] ?? '',
            b['first_name'] ?? '',
          ].join(' ').toLowerCase();
          return nameA.compareTo(nameB);
      }
    });

    return filtered;
  }

  Color _riskColor(String? level) {
    switch ((level ?? '').toLowerCase()) {
      case 'high':
        return AppColors.error;
      case 'medium':
        return AppColors.warning;
      default:
        return AppColors.success;
    }
  }

  Widget _riskChip(String? level) {
    final color = _riskColor(level);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(
        (level ?? 'unknown').toString().toUpperCase(),
        style: TextStyle(color: color, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _listItem(Map<String, dynamic> m) {
    final int motherId = int.tryParse(m['mother_id']?.toString() ?? '') ?? 0;
    final String fullName = [
      m['first_name'],
      m['middle_name'],
      m['last_name'],
      m['extension_name'],
    ].where((e) => e != null && e.toString().trim().isNotEmpty).join(' ');

    final edd = m['expected_date_of_delivery']?.toString();
    final location = [
      m['barangay'],
      m['city_municipality'],
    ].where((e) => e != null && e.toString().trim().isNotEmpty).join(', ');

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: CircleAvatar(
          backgroundColor: AppColors.bgSecondary,
          child: const Icon(Icons.person, color: AppColors.brandText),
        ),
        title: Text(
          fullName.isNotEmpty ? fullName : 'Unnamed Mother',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (location.isNotEmpty)
              Text(
                location,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            const SizedBox(height: 6),
            Row(
              children: [
                _riskChip(m['pregnancy_risk_level']),
                const SizedBox(width: 8),
                if (edd != null && edd.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.bgSecondary,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.borderPrimary),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          size: 14,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 6),
                        Text('EDD: $edd'),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => MotherProfilePage(motherId: motherId),
            ),
          );
          _load();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        title: const Text('Patients / Mothers'),
        backgroundColor: AppColors.bgPrimary,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () async => _load(),
        child: FutureBuilder<List<Map<String, dynamic>>>(
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

            final mothers = _applyFilters(snapshot.data ?? []);

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      TextField(
                        controller: _search,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.search),
                          hintText: 'Search name or location',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          DropdownButton<String>(
                            value: _riskFilter,
                            items: const [
                              DropdownMenuItem(
                                value: 'all',
                                child: Text('All risks'),
                              ),
                              DropdownMenuItem(
                                value: 'low',
                                child: Text('Low'),
                              ),
                              DropdownMenuItem(
                                value: 'medium',
                                child: Text('Medium'),
                              ),
                              DropdownMenuItem(
                                value: 'high',
                                child: Text('High'),
                              ),
                            ],
                            onChanged: (v) =>
                                setState(() => _riskFilter = v ?? 'all'),
                          ),
                          const SizedBox(width: 12),
                          DropdownButton<String>(
                            value: _sort,
                            items: const [
                              DropdownMenuItem(
                                value: 'name',
                                child: Text('Sort: Name'),
                              ),
                              DropdownMenuItem(
                                value: 'risk',
                                child: Text('Sort: Risk'),
                              ),
                              DropdownMenuItem(
                                value: 'edd',
                                child: Text('Sort: EDD'),
                              ),
                            ],
                            onChanged: (v) =>
                                setState(() => _sort = v ?? 'name'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: mothers.isEmpty
                      ? const Center(child: Text('No mothers found'))
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          itemCount: mothers.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 8),
                          itemBuilder: (context, index) =>
                              _listItem(mothers[index]),
                        ),
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'add-mother-fab',
        backgroundColor: AppColors.brandPrimary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
        onPressed: () async {
          final added = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddMotherFlow()),
          );
          if (added == true) _load();
        },
      ),
    );
  }
}
