import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class HeroCard extends StatelessWidget {
  final String imagePath;
  final String message;
  final int? week;
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
        color: AppColors.bgPrimary,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08), // 👈 soft but visible
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none, // 👈 allow overlap
            children: [
              Center(
                child: Container(
                  padding: const EdgeInsets.all(26),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.bgSecondary,
                  ),
                  child: Image.asset(imagePath, height: 150),
                ),
              ),

              if (showWeekBadge && week != null)
                Positioned(
                  top: 6, // 👈 lower
                  right: 24, // 👈 pushed left, overlaps circle more
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.brandPrimary,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Text(
                      'Week $week',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textOnColor,
                      ),
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 18),

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
