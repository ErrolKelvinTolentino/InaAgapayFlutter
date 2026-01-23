import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class HeroCard extends StatelessWidget {
  final String imagePath;
  final String message;
  final int? week; // 👈 optional
  final bool showWeekBadge;

  const HeroCard({
    super.key,
    required this.imagePath,
    required this.message,
    this.week,
    this.showWeekBadge = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgSecondary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.topRight,
            children: [
              Center(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.faintWhite,
                  ),
                  child: Image.asset(
                    imagePath,
                    height: 140,
                  ),
                ),
              ),

              if (showWeekBadge && week != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.brandPrimary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Week $week',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textOnColor,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.favorite,
                size: 16,
                color: AppColors.brandPrimary,
              ),
              const SizedBox(width: 6),
              Text(
                message,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
