import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class LongInfoBox extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color? borderColor;
  final Color? iconColor;

  const LongInfoBox({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.borderColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: borderColor ?? AppColors.brandPrimary,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: iconColor ?? AppColors.brandPrimary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 13,
                  height: 1.4,
                  color: AppColors.textSecondary,
                ),
                children: [
                  TextSpan(text: '$title\n'),
                  TextSpan(
                    text: subtitle,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
