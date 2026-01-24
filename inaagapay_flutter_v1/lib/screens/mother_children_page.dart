import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../widgets/main_header.dart';
import '../widgets/main_bottom_navigation.dart';
import '../widgets/small_description.dart';
import '../widgets/app_input_field.dart';
import '../widgets/child_card.dart';
import '../widgets/vaccine_schedule_status.dart';

class MotherChildrenPage extends StatefulWidget {
  const MotherChildrenPage({super.key});

  @override
  State<MotherChildrenPage> createState() => _MotherChildrenPageState();
}

class _MotherChildrenPageState extends State<MotherChildrenPage> {
  final TextEditingController _searchController = TextEditingController();

  // 🔧 TEMP MOCK DATA (backend later)
  final int childCount = 2;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,

      // 🔝 Header
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(72),
        child: MainHeader(
          title: 'CHILDREN',
          onNotificationTap: () {},
          onAvatarTap: () {},
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
                                text: 'You have\n',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textPrimary,
                                  height: 1.4,
                                ),
                              ),
                              TextSpan(
                                text: '$childCount Beautiful Children!',
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
                onTrailingTap: () {
                  // TODO: search logic
                },
                onChanged: (value) {
                  // TODO: live filter
                },
              ),

              const SizedBox(height: 8),

              const SmallDescription(
                text: 'Tap a child to view health records',
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 20),

              // 👶 CHILD LIST
              Column(
                children: [
                  ChildCard(
                    fullName: 'First Name MI. Surname',
                    ageText: '0 years 5 months old',
                    vaccineStatus: VaccineScheduleStatus.overdue,
                    image: const AssetImage('assets/images/child.png'),
                    onTap: () {
                      // TODO: navigate to child profile
                    },
                  ),

                  const SizedBox(height: 12),

                  ChildCard(
                    fullName: 'First Name MI. Surname',
                    ageText: '0 years 5 months old',
                    vaccineStatus: VaccineScheduleStatus.onSchedule,
                    image: const AssetImage('assets/images/child.png'),
                    onTap: () {
                      // TODO
                    },
                  ),
                ],
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),

      // 🔻 Bottom Nav
      bottomNavigationBar: MainBottomNavigation(
        currentIndex: 2, // Children tab
      ),
    );
  }
}
