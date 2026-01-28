import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/main_header.dart';
import '../widgets/main_bottom_navigation.dart';
import 'mother_prenatal_stack.dart';

class MotherRecordsPage extends StatelessWidget {
  const MotherRecordsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,

      // 🔝 HEADER
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: MainHeader(
          title: 'Records',
          onNotificationTap: () {},
          onAvatarTap: () {},
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 🎀 HERO / SUMMARY
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
                                text: 'XX Stored Records!',
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
                        'assets/images/records.png',
                        height: 72,
                        width: 72,
                        fit: BoxFit.contain,
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 12),

            const Text(
              'All your pregnancy records in one place',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),

            const SizedBox(height: 20),

            // 📁 RECORD LIST
            _RecordCategoryCard(
  title: 'Prenatal Check-ups',
  countText: '1 file',
  icon: Icons.medical_services_rounded,
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MotherPrenatalStack(),
      ),
    );
  },
),

            const SizedBox(height: 12),

            _RecordCategoryCard(
              title: 'Ultrasound Records',
              countText: '1 file',
              icon: Icons.monitor_heart_rounded,
              onTap: () {},
            ),

            const SizedBox(height: 12),

            _RecordCategoryCard(
              title: 'Laboratory Test Results',
              countText: '1 file',
              icon: Icons.science_rounded,
              onTap: () {},
            ),

            const SizedBox(height: 12),

            _RecordCategoryCard(
              title: 'Pregnancy History',
              countText: '1 file',
              icon: Icons.history_rounded,
              onTap: () {},
            ),
          ],
        ),
      ),

      // 🔻 Bottom Nav
      bottomNavigationBar: const MainBottomNavigation(
        currentIndex: 3, // Children tab
      ),
    );
  }
}

class _RecordCategoryCard extends StatefulWidget {
  final String title;
  final String countText;
  final IconData icon;
  final VoidCallback onTap;

  const _RecordCategoryCard({
    required this.title,
    required this.countText,
    required this.icon,
    required this.onTap,
  });

  @override
  State<_RecordCategoryCard> createState() => _RecordCategoryCardState();
}

class _RecordCategoryCardState extends State<_RecordCategoryCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _pressed ? 0.97 : 1.0,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(20),
          onHighlightChanged: (isPressed) {
            setState(() => _pressed = isPressed);
          },
          splashColor: AppColors.brandPrimary.withOpacity(0.08),
          highlightColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
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
                // 📄 ICON
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.brandPrimary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    widget.icon,
                    color: AppColors.brandPrimary,
                  ),
                ),

                const SizedBox(width: 14),

                // 🧾 TEXT
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.countText,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),

                const Icon(
                  Icons.chevron_right_rounded,
                  size: 26,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
