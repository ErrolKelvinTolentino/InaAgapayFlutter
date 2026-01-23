import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class ComparisonCard extends StatelessWidget {
  final String label;
  final String comparison;
  final String imagePath;

  const ComparisonCard({
    super.key,
    required this.label,
    required this.comparison,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 96, // slightly taller to accommodate bigger image + spacing
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        image: DecorationImage(
          image: const AssetImage('assets/images/pinkbg.png'),
          fit: BoxFit.cover,
          opacity: 0.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 32,
          vertical: 14,
        ),
        child: Row(
          children: [
            // 📝 Text
            Expanded(
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '$label\n',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textPrimary,
                        height: 0, // 👈 increased label line spacing
                      )
        
                    ),
                    TextSpan(
                      text: comparison,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.brandText,
                        height: 2.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(width: 12),

            // 🫐 Image (bigger)
            Image.asset(
              imagePath,
              height: 72, // 👈 increased
              width: 72,
              fit: BoxFit.contain,
            ),
          ],
        ),
      ),
    );
  }
}
