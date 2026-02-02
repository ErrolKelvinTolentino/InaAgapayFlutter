import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../widgets/main_header.dart';
import '../widgets/midwife_bottom_navigation.dart';
import '../widgets/small_description.dart';
import '../widgets/app_input_field.dart';
import '../widgets/floating_add_child_button.dart';

import 'midwife_mother_overview.dart';

class MidwifeMothersPage extends StatefulWidget {
  const MidwifeMothersPage({super.key});

  @override
  State<MidwifeMothersPage> createState() => _MidwifeMothersPageState();
}

class _MidwifeMothersPageState extends State<MidwifeMothersPage> {
  final TextEditingController _searchController = TextEditingController();

  // 🔧 TEMP MOCK DATA (backend later)
  final int motherCount = 2;

  void _openMotherProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const MidwifeMotherOverviewPage(),
      ),
    );
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
          onNotificationTap: () {},
          onAvatarTap: () {},
        ),
      ),

      /// 🔽 BODY
      body: SafeArea(
        child: SingleChildScrollView(
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
                                text: '$motherCount Mothers!',
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
                onChanged: (_) {},
              ),

              const SizedBox(height: 8),

              const SmallDescription(
                text: 'Tap a mother to view health records',
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 20),

              /// 🤰 MOTHER LIST
              Column(
                children: [
                  _MotherCard(
                    fullName: 'First Name MI. Surname',
                    pregnancyText: 'XX weeks pregnant',
                    onTap: _openMotherProfile,
                  ),
                  const SizedBox(height: 12),
                  _MotherCard(
                    fullName: 'First Name MI. Surname',
                    pregnancyText: 'XX weeks pregnant',
                    onTap: _openMotherProfile,
                  ),
                ],
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),

      /// ➕ ADD CHILD (FLOATING)
      floatingActionButton: FloatingAddChildButton(
        onPressed: () {
          Navigator.pushNamed(context, '/midwife-add-parent');
        },
      ),

      /// 🔻 BOTTOM NAV
      bottomNavigationBar: const MidwifeBottomNavigation(
        currentIndex: 1, // ✅ Mothers tab
      ),
    );
  }
}

/// 🧩 SIMPLE MOTHER CARD (matches design)
class _MotherCard extends StatelessWidget {
  final String fullName;
  final String pregnancyText;
  final VoidCallback onTap;

  const _MotherCard({
    required this.fullName,
    required this.pregnancyText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
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
            Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.brandPrimary,
              ),
            ),
            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fullName,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    pregnancyText,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            const Icon(
              Icons.chevron_right,
              color: AppColors.brandPrimary,
            ),
          ],
        ),
      ),
    );
  }
}
