import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/hero_card.dart';
import '../widgets/records_display_card.dart';
import '../widgets/small_description.dart';
import '../widgets/growth_line_chart.dart';

class MotherChildHeightPage extends StatelessWidget {
  const MotherChildHeightPage({super.key});

  @override
  Widget build(BuildContext context) {
    const String childName = 'First Name MI. Last Name';
    const String childAge = 'XX Years Old';

    final List<double> heightValues = [50, 50.8, 51.6, 52.4, 53.2];
    final List<String> heightLabels = ['0w', '4w', '8w', '12w', '16w'];

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        children: [
          HeroCard(
            image: const AssetImage('assets/images/baby.png'),
            title: childName,
            subtitle: childAge,
            showWeekBadge: false,
            showHeartRow: false,
          ),

          const SizedBox(height: 20),

          // 📈 HEIGHT CHART CARD
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.height, color: AppColors.brandPrimary),
                    SizedBox(width: 8),
                    Text(
                      'Height Chart',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 200,
                  child: GrowthLine(
                    values: heightValues,
                    labels: heightLabels,
                    unit: 'cm',
                    lineColor: AppColors.brandPrimary,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          RecordsDisplayCard(
            title: 'Height Records',
            headerIcon: Icons.straighten,
            items: const [
              RecordItem(
                leadingIcon: Icons.flag,
                label: 'Starting Height',
                value: '50 cm',
              ),
              RecordItem(
                leadingIcon: Icons.trending_up,
                label: 'Latest Record',
                value: '53.2 cm',
              ),
            ],
          ),

          const SizedBox(height: 14),

          const SmallDescription(
            text: '[CHILD NAME] grew by 3.2 cm over the last period!',
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 20),

          const _AiAnalysisCard(
            text:
                'Your child’s height growth is steady and ideal for this age range.',
          ),
        ],
      ),
    );
  }
}

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
        border: Border.all(color: AppColors.brandPrimary, width: 1.2),
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
