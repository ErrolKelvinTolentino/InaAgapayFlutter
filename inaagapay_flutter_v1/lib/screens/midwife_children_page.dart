import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../services/auth_storage.dart';
import '../theme/app_colors.dart';
import 'add_child_step1.dart';
import 'child_profile_page.dart';

class MidwifeChildrenPage extends StatefulWidget {
  const MidwifeChildrenPage({super.key});

  @override
  State<MidwifeChildrenPage> createState() => _MidwifeChildrenPageState();
}

class _MidwifeChildrenPageState extends State<MidwifeChildrenPage> {
  bool loading = true;
  List<Map<String, dynamic>> children = [];
  String query = '';
  String sort = 'recent';

  @override
  void initState() {
    super.initState();
    _load();
  }

  /// ================= FETCH CHILDREN =================
  Future<void> _load() async {
    setState(() => loading = true);
    try {
      final token = await AuthStorage.getToken();
      final res = await http.get(
        Uri.parse(
          'https://inaagapay.alwaysdata.net/api/midwife/midwife_children.php',
        ),
        headers: {'Authorization': 'Bearer $token'},
      );

      final decoded = jsonDecode(res.body);
      final data = decoded['data'] is List ? decoded['data'] : [];

      if (!mounted) return;
      setState(() {
        children = List<Map<String, dynamic>>.from(data);
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => children = []);
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  /// ================= AGE CALCULATOR =================
  String calculateAge(String? birthdate) {
    if (birthdate == null) return '-';

    final birth = DateTime.tryParse(birthdate);
    if (birth == null) return '-';

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

  List<Map<String, dynamic>> get _filtered {
    final q = query.toLowerCase();
    final filtered = children.where((c) {
      final name =
          '${c['first_name'] ?? ''} ${c['middle_name'] ?? ''} ${c['last_name'] ?? ''}'
              .toLowerCase();
      final mother = (c['mother_name'] ?? '').toString().toLowerCase();
      return name.contains(q) || mother.contains(q);
    }).toList();

    if (sort == 'name') {
      filtered.sort((a, b) {
        final na =
            '${(a['last_name'] ?? '').toString()}${(a['first_name'] ?? '').toString()}';
        final nb =
            '${(b['last_name'] ?? '').toString()}${(b['first_name'] ?? '').toString()}';
        return na.toLowerCase().compareTo(nb.toLowerCase());
      });
    } else {
      filtered.sort((a, b) {
        DateTime? parse(dynamic v) =>
            v == null ? null : DateTime.tryParse(v.toString());
        final da = parse(a['created_at'] ?? a['added_at']);
        final db = parse(b['created_at'] ?? b['added_at']);
        if (da == null && db == null) return 0;
        if (da == null) return 1;
        if (db == null) return -1;
        return db.compareTo(da);
      });
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        title: const Text('Children'),
        backgroundColor: AppColors.bgPrimary,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: loading
            ? ListView(
                children: const [
                  SizedBox(
                    height: 260,
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ],
              )
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        TextField(
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.search),
                            hintText: 'Search by name or mother',
                          ),
                          onChanged: (v) => setState(() => query = v),
                        ),
                        const SizedBox(height: 10),
                        DropdownButtonFormField<String>(
                          value: sort,
                          decoration: const InputDecoration(labelText: 'Sort'),
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
                          onChanged: (v) =>
                              setState(() => sort = v ?? 'recent'),
                        ),
                        const SizedBox(height: 6),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Showing ${filtered.length} of ${children.length} children',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (filtered.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 32),
                      child: Center(
                        child: Text(
                          'No children found',
                          style: TextStyle(color: Colors.black54),
                        ),
                      ),
                    )
                  else
                    ...filtered.map((c) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.borderPrimary),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          leading: CircleAvatar(
                            radius: 24,
                            backgroundColor: AppColors.brandPrimary.withOpacity(
                              0.12,
                            ),
                            child: Icon(
                              c['sex'] == 'male' ? Icons.male : Icons.female,
                              color: AppColors.brandPrimary,
                            ),
                          ),
                          title: Text(
                            '${c['first_name'] ?? ''} ${c['last_name'] ?? ''}'
                                .trim(),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              'Mother: ${c['mother_name'] ?? '-'} • ${calculateAge(c['birthdate'])}',
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            final id = int.tryParse(
                              c['child_id']?.toString() ?? '',
                            );
                            if (id != null) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ChildProfilePage(childId: id),
                                ),
                              );
                            }
                          },
                        ),
                      );
                    }).toList(),
                ],
              ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.brandPrimary,
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddChildStep1Parent()),
          );
        },
      ),
    );
  }
}
