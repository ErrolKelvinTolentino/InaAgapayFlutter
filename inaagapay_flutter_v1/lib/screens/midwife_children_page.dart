import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../theme/app_colors.dart';
import '../services/auth_storage.dart';
import '../widgets/main_header.dart';
import '../widgets/midwife_bottom_navigation.dart'; // Remove if not exists
import '../widgets/small_description.dart';
import '../widgets/app_input_field.dart';
import '../widgets/child_card.dart';
import '../widgets/vaccine_schedule_status.dart';
import '../widgets/floating_add_child_button.dart';
import 'child_profile_page.dart';
import 'add_child_step1.dart';

class MidwifeChildrenPage extends StatefulWidget {
  const MidwifeChildrenPage({super.key});

  @override
  State<MidwifeChildrenPage> createState() => _MidwifeChildrenPageState();
}

class _MidwifeChildrenPageState extends State<MidwifeChildrenPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _allChildren = [];
  List<Map<String, dynamic>> _filteredChildren = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadChildren();
  }

  /// ================= FETCH CHILDREN =================
  Future<void> _loadChildren() async {
    setState(() {
      _isLoading = true;
    });

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

    if (decoded['success'] == true) {
      _allChildren = List<Map<String, dynamic>>.from(decoded['data'] ?? []);
      _filteredChildren = List.from(_allChildren);
    } else {
      _allChildren = [];
      _filteredChildren = [];
    }

    setState(() {
      _isLoading = false;
    });
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

  /// ================= SEARCH FILTER =================
  void _filterChildren(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredChildren = List.from(_allChildren);
      } else {
        _filteredChildren = _allChildren.where((child) {
          final fullName = '${child['first_name']} ${child['last_name']}'.toLowerCase();
          final motherName = (child['mother_name'] ?? '').toLowerCase();
          return fullName.contains(query.toLowerCase()) ||
                 motherName.contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  /// ================= VACCINE STATUS =================
  VaccineScheduleStatus _getVaccineStatus(Map<String, dynamic> child) {
    // This should be replaced with actual vaccine status logic from your database
    // For now, we'll use a simple placeholder logic
    final childId = child['child_id'].toString();
    final lastDigit = int.tryParse(childId.substring(childId.length - 1)) ?? 0;
    
    if (lastDigit % 3 == 0) {
      return VaccineScheduleStatus.overdue;
    } else if (lastDigit % 3 == 1) {
      return VaccineScheduleStatus.onSchedule;
    } else {
      // Return a default status
      return VaccineScheduleStatus.onSchedule;
    }
  }

  /// ================= NAVIGATION TO CHILD PROFILE =================
  void _openChildProfile(Map<String, dynamic> child) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChildProfilePage(
          childId: int.parse(child['child_id'].toString()),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      
      // 🔝 Header
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(72),
        child: MainHeader(
          title: 'CHILDREN',
        ),
      ),

      // 🔽 Body
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🧸 TOP INFO CARD
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
                      // 📝 Text
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
                                text: '${_filteredChildren.length} Children!',
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
                      // 👶 Image
                      Image.asset(
                        'assets/images/baby.png',
                        height: 72,
                        width: 72,
                        fit: BoxFit.contain,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // 🔍 Search
              AppInputField(
                hintText: 'Search Child',
                controller: _searchController,
                trailingIcon: Icons.search,
                onTrailingTap: () {},
                onChanged: _filterChildren,
              ),
              const SizedBox(height: 8),

              const SmallDescription(
                text: 'Tap a child to view health records',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              // 👶 CHILD LIST
              if (_isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (_filteredChildren.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Text(
                      _searchController.text.isNotEmpty
                          ? 'No children match your search'
                          : 'No children found',
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 16,
                      ),
                    ),
                  ),
                )
              else
                Column(
                  children: _filteredChildren.map((child) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: ChildCard(
                        fullName: '${child['first_name']} ${child['last_name']}',
                        ageText: calculateAge(child['birthdate']),
                        vaccineStatus: _getVaccineStatus(child),
                        image: const AssetImage('assets/images/child.png'),
                        onTap: () => _openChildProfile(child),
                      ),
                    );
                  }).toList(),
                ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),

      floatingActionButton: FloatingAddChildButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AddChildStep1Parent(),
            ),
          );
        },
      ),

      // 🔻 Bottom Nav - COMMENT OUT OR REPLACE
      // bottomNavigationBar: const MidwifeBottomNavigation(
      //   currentIndex: 2, // ✅ Children tab active
      // ),
    );
  }
}