import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/secondary_header.dart';
import '../widgets/tab_button.dart';
import 'mother_child_height_page.dart';
import 'mother_child_weight_page.dart';

class MotherChildGrowthPage extends StatefulWidget {
  final VoidCallback onBack;

  const MotherChildGrowthPage({
    super.key,
    required this.onBack,
  });

  @override
  State<MotherChildGrowthPage> createState() =>
      _MotherChildGrowthPageState();
}

class _MotherChildGrowthPageState extends State<MotherChildGrowthPage> {
  int _currentIndex = 0;

  void _switchTo(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,

      // 🔝 HEADER + TABS (SAFE AREA APPLIED ONCE)
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(120),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              SecondaryHeader(
                title: 'Growth Statistics',
                onBack: widget.onBack,
              ),

              const SizedBox(height: 8),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TabButton(
                    label: 'Height Chart',
                    isActive: _currentIndex == 0,
                    onTap: () => _switchTo(0),
                  ),
                  const SizedBox(width: 12),
                  TabButton(
                    label: 'Weight Chart',
                    isActive: _currentIndex == 1,
                    onTap: () => _switchTo(1),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),

      // 📊 CONTENT STACK
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          MotherChildHeightPage(),
          MotherChildWeightPage(),
        ],
      ),
    );
  }
}
