import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/hero_card.dart';
import '../widgets/records_display_card.dart';
import '../widgets/small_description.dart';
import '../widgets/growth_line_chart.dart';

class MotherChildWeightPage extends StatelessWidget {
  const MotherChildWeightPage({super.key});

  @override
  Widget build(BuildContext context) {
    // 🧒 MOCK CHILD DATA
    const String childName = 'First Name MI. Last Name';
    const String childAge = 'XX Years Old';

    // 📊 MOCK WEIGHT DATA (kg)
    final List<double> weightValues = [3.2, 3.8, 4.4, 5.0, 5.6];
    final List<String> weightLabels = ['0w', '4w', '8w', '12w', '16w'];

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        children: [
          // 👶 HERO
          HeroCard(
            image: const AssetImage('assets/images/baby.png'),
            title: childName,
            subtitle: childAge,
            showWeekBadge: false,
            showHeartRow: false,
          ),

          const SizedBox(height: 20),

          // ⚖️ WEIGHT CHART
          RecordsDisplayCard(
            title: 'Weight Chart',
            headerIcon: Icons.monitor_weight,
            items: [
              RecordItem(
                label: 'Growth Trend',
                value: '',
                trailingWidget: GrowthLine(
                  values: weightValues,
                  labels: weightLabels,
                  unit: 'kg',
                  lineColor: AppColors.warning,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // 📋 WEIGHT STATS
          RecordsDisplayCard(
            title: 'Weight Records',
            headerIcon: Icons.scale,
            items: const [
              RecordItem(
                leadingIcon: Icons.flag,
                label: 'Starting Weight',
                value: '3.2 kg',
              ),
              RecordItem(
                leadingIcon: Icons.trending_up,
                label: 'Latest Record',
                value: '5.6 kg',
              ),
            ],
          ),

          const SizedBox(height: 14),

          // 📊 INSIGHT
          const SmallDescription(
            text: '[CHILD NAME] gained 2.4 kg in this period!',
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 20),

          // 🤖 AI ANALYSIS
          _AiAnalysisCard(
            text:
                'Your child’s weight gain is healthy and consistent with standard growth patterns.',
          ),
        ],
      ),
    );
  }
}

/// ♻️ Same AI card (kept local to file for now)
class _AiAnalysisCard extends StatelessWidget {
  final String text;

  const _AiAnalysisCard({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.brandPrimary,
          width: 1.2,
        ),
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.psychology, color: AppColors.brandPrimary),
              SizedBox(width: 8),
              Text(
                'AI Analysis',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.brandPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
