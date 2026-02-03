import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../widgets/secondary_header.dart';
import '../widgets/tab_button.dart';
import '../widgets/hero_card.dart';
import '../widgets/chart_card.dart';
import '../widgets/ai_analytics_card.dart';
import '../widgets/main_button.dart';
import '../widgets/midwife_bottom_navigation.dart';
import 'midwife_add_child_growth.dart';

class MidwifeChildGrowthPage extends StatefulWidget {
  const MidwifeChildGrowthPage({super.key});

  @override
  State<MidwifeChildGrowthPage> createState() => _MidwifeChildGrowthPageState();
}

class _MidwifeChildGrowthPageState extends State<MidwifeChildGrowthPage> {
  int _currentIndex = 0;

  void _switchTo(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,

      /// 🔝 HEADER
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: SecondaryHeader(
          title: 'Growth Statistics',
          onBack: () {
            Navigator.pop(context); // ✅ Midwife flow
          },
        ),
      ),

      body: Column(
        children: [
          const SizedBox(height: 12),

          /// 🟢 TABS
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

          const SizedBox(height: 16),

          /// 📊 CONTENT
          Expanded(
            child: IndexedStack(
              index: _currentIndex,
              children: [_heightContent(), _weightContent()],
            ),
          ),
        ],
      ),

      /// 🔻 BOTTOM NAV
      bottomNavigationBar: const MidwifeBottomNavigation(currentIndex: 2),
    );
  }

  // =========================
  // 📏 HEIGHT CONTENT
  // =========================
  Widget _heightContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Column(
        children: [
          /// 👶 HERO
          HeroCard(
            image: const AssetImage('assets/images/height.png'),
            title: 'First Name MI. Last Name',
            subtitle: 'XX Years Old',
            showWeekBadge: false,
            showHeartRow: false,
          ),

          const SizedBox(height: 16),

          /// 📈 CHART
          ChartCard(
            title: 'Height Chart',
            headerIcon: Icons.height,
            values: const [50, 50.8, 51.6, 51.6, 52.4, 53.2],
            labels: const ['0w', '4w', '8w', '12w', '16w', '18w'],
            unit: 'cm',
            lineColor: AppColors.brandPrimary,
            startingLabel: 'Starting Height',
            startingValue: '-- cm',
            latestLabel: 'Latest Record',
            latestValue: '-- cm',
            insightText: 'Height progression is within the expected range.',
          ),

          const SizedBox(height: 16),

          /// 🤖 AI ANALYSIS
          const AiAnalyticsCard(
            text:
                'The child’s height progression aligns with standard growth benchmarks for this age group.',
          ),

          const SizedBox(height: 16),

          /// ➕ ADD RECORD
          MainButton(
            label: 'Add Growth Record',
            showIcons: true,
            leadingIcon: Icons.add,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => MidwifeAddChildGrowthPage()),
              );
            },
          ),
        ],
      ),
    );
  }

  // =========================
  // ⚖️ WEIGHT CONTENT
  // =========================
  Widget _weightContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Column(
        children: [
          /// 👶 HERO
          HeroCard(
            image: const AssetImage('assets/images/weight.png'),
            title: 'First Name MI. Last Name',
            subtitle: 'XX Years Old',
            showWeekBadge: false,
            showHeartRow: false,
          ),

          const SizedBox(height: 16),

          /// 📊 CHART
          ChartCard(
            title: 'Weight Chart',
            headerIcon: Icons.monitor_weight,
            values: const [3.2, 3.8, 3.5, 3.8, 4.2, 4.1],
            labels: const ['0w', '4w', '8w', '12w', '16w', '18w'],
            unit: 'kg',
            lineColor: AppColors.brandPrimary,
            startingLabel: 'Starting Weight',
            startingValue: '-- kg',
            latestLabel: 'Latest Record',
            latestValue: '-- kg',
            insightText:
                'Weight change reflects normal developmental patterns.',
          ),

          const SizedBox(height: 16),

          /// 🤖 AI ANALYSIS
          const AiAnalyticsCard(
            text:
                'The child’s weight trend remains within a healthy and expected range.',
          ),

          const SizedBox(height: 16),

          /// ➕ ADD RECORD
          MainButton(
            label: 'Add Growth Record',
            showIcons: true,
            leadingIcon: Icons.add,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => MidwifeAddChildGrowthPage()),
              );
            },
          ),
        ],
      ),
    );
  }
}
