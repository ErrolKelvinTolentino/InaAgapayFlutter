import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../theme/app_colors.dart';
import '../services/auth_storage.dart';
import '../widgets/main_header.dart';
import '../widgets/small_description.dart';
import '../widgets/app_input_field.dart';
import '../widgets/floating_add_child_button.dart';
import 'mother_profile_page.dart';
import 'add_mother_flow.dart';

class MidwifeMothersPage extends StatefulWidget {
  const MidwifeMothersPage({super.key});

  @override
  State<MidwifeMothersPage> createState() => _MidwifeMothersPageState();
}

class _MidwifeMothersPageState extends State<MidwifeMothersPage> {
  late Future<List<Map<String, dynamic>>> _future;
  final TextEditingController _searchController = TextEditingController();
  String _riskFilter = 'all';
  String _sort = 'name';
  List<Map<String, dynamic>> _allMothers = [];
  List<Map<String, dynamic>> _filteredMothers = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _future = fetchMothers();
    });
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
    _allMothers = list.cast<Map<String, dynamic>>();
    _filteredMothers = _applyFilters(_allMothers);
    return _allMothers;
  }

  List<Map<String, dynamic>> _applyFilters(List<Map<String, dynamic>> list) {
    final query = _searchController.text.trim().toLowerCase();
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

  /// ================= CALCULATE PREGNANCY WEEKS =================
  String calculatePregnancyWeeks(String? lastMenstrualDate) {
    if (lastMenstrualDate == null || lastMenstrualDate.isEmpty) {
      return 'Unknown weeks';
    }

    try {
      final lmp = DateTime.parse(lastMenstrualDate);
      final now = DateTime.now();
      final difference = now.difference(lmp);
      final weeks = (difference.inDays / 7).floor();
      
      if (weeks < 0) return '0 weeks';
      if (weeks >= 40) return '40+ weeks';
      return '$weeks weeks pregnant';
    } catch (e) {
      return 'Unknown weeks';
    }
  }

  /// ================= GET RISK COLOR =================
  Color _getRiskColor(String? level) {
    switch ((level ?? '').toLowerCase()) {
      case 'high':
        return AppColors.error;
      case 'medium':
        return AppColors.warning;
      default:
        return AppColors.success;
    }
  }

  void _applyFiltersAndSort() {
    setState(() {
      _filteredMothers = _applyFilters(_allMothers);
    });
  }

  void _openMotherProfile(Map<String, dynamic> mother) async {
    final motherId = int.tryParse(mother['mother_id']?.toString() ?? '') ?? 0;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MotherProfilePage(motherId: motherId),
      ),
    );
    if (mounted) {
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      
      /// 🔝 HEADER
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(72),
        child: MainHeader(
          title: 'MOTHERS',
        ),
      ),

      /// 🔽 BODY
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _load,
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red, size: 48),
                      const SizedBox(height: 16),
                      Text(
                        snapshot.error.toString(),
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _load,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// 🧸 TOP INFO CARD
                    Container(
                      height: 96,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        image: const DecorationImage(
                          image: AssetImage('assets/images/pinkbg.png'),
                          fit: BoxFit.cover,
                          opacity: 0.5,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: RichText(
                                text: TextSpan(
                                  children: [
                                    const TextSpan(
                                      text: 'There are\n',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: AppColors.textPrimary,
                                        height: 1.4,
                                      ),
                                    ),
                                    TextSpan(
                                      text: '${_filteredMothers.length} Mothers!',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.brandText,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Image.asset(
                              'assets/images/pregnant1.png',
                              height: 72,
                              width: 72,
                              fit: BoxFit.contain,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    /// 🔍 SEARCH
                    AppInputField(
                      hintText: 'Search Mother',
                      controller: _searchController,
                      trailingIcon: Icons.search,
                      onTrailingTap: () {},
                      onChanged: (_) => _applyFiltersAndSort(),
                    ),
                    const SizedBox(height: 8),

                    /// FILTER & SORT ROW
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButton<String>(
                            value: _riskFilter,
                            isExpanded: true,
                            items: const [
                              DropdownMenuItem(
                                value: 'all',
                                child: Text('All risks'),
                              ),
                              DropdownMenuItem(
                                value: 'low',
                                child: Text('Low risk'),
                              ),
                              DropdownMenuItem(
                                value: 'medium',
                                child: Text('Medium risk'),
                              ),
                              DropdownMenuItem(
                                value: 'high',
                                child: Text('High risk'),
                              ),
                            ],
                            onChanged: (v) {
                              setState(() {
                                _riskFilter = v ?? 'all';
                                _applyFiltersAndSort();
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButton<String>(
                            value: _sort,
                            isExpanded: true,
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
                            onChanged: (v) {
                              setState(() {
                                _sort = v ?? 'name';
                                _applyFiltersAndSort();
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    const SmallDescription(
                      text: 'Tap a mother to view health records',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),

                    /// 🤰 MOTHER LIST
                    if (_filteredMothers.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Text(
                            _searchController.text.isNotEmpty || _riskFilter != 'all'
                                ? 'No mothers match your search'
                                : 'No mothers found',
                            style: const TextStyle(
                              color: Colors.black54,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      )
                    else
                      Column(
                        children: _filteredMothers.map((mother) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: MotherCard(
                              mother: mother,
                              onTap: () => _openMotherProfile(mother),
                            ),
                          );
                        }).toList(),
                      ),
                    const SizedBox(height: 24),
                  ],
                ),
              );
            },
          ),
        ),
      ),

      /// ➕ ADD MOTHER (FLOATING)
      floatingActionButton: FloatingAddChildButton(
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

/// 🧩 MOTHER CARD (matches design)
class MotherCard extends StatelessWidget {
  final Map<String, dynamic> mother;
  final VoidCallback onTap;

  const MotherCard({
    super.key,
    required this.mother,
    required this.onTap,
  });

  String getFullName() {
    return [
      mother['first_name'],
      mother['middle_name'],
      mother['last_name'],
      mother['extension_name'],
    ].where((e) => e != null && e.toString().trim().isNotEmpty).join(' ');
  }

  String getPregnancyText() {
    final weeks = calculatePregnancyWeeks(mother['last_menstrual_date']);
    final edd = mother['expected_date_of_delivery']?.toString();
    if (edd != null && edd.isNotEmpty) {
      return '$weeks • EDD: $edd';
    }
    return weeks;
  }

  String calculatePregnancyWeeks(String? lastMenstrualDate) {
    if (lastMenstrualDate == null || lastMenstrualDate.isEmpty) {
      return 'Unknown weeks';
    }

    try {
      final lmp = DateTime.parse(lastMenstrualDate);
      final now = DateTime.now();
      final difference = now.difference(lmp);
      final weeks = (difference.inDays / 7).floor();
      
      if (weeks < 0) return '0 weeks';
      if (weeks >= 40) return '40+ weeks';
      return '$weeks weeks pregnant';
    } catch (e) {
      return 'Unknown weeks';
    }
  }

  Color _getRiskColor(String? level) {
    switch ((level ?? '').toLowerCase()) {
      case 'high':
        return AppColors.error;
      case 'medium':
        return AppColors.warning;
      default:
        return AppColors.success;
    }
  }

  @override
  Widget build(BuildContext context) {
    final riskLevel = mother['pregnancy_risk_level']?.toString() ?? 'low';
    final riskColor = _getRiskColor(riskLevel);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            // Profile avatar with risk indicator
            Stack(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.brandPrimary,
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: riskColor,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    getFullName(),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    getPregnancyText(),
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Risk level badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: riskColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: riskColor.withOpacity(0.3)),
                    ),
                    child: Text(
                      '${riskLevel.toUpperCase()} RISK',
                      style: TextStyle(
                        fontSize: 10,
                        color: riskColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.brandPrimary),
          ],
        ),
      ),
    );
  }
}