import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class MainButton extends StatelessWidget {
  final String label;
  final bool showIcons;
  final VoidCallback? onPressed;

  const MainButton({
    super.key,
    required this.label,
    this.showIcons = true,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.resolveWith<Color>(
            (states) {
              if (states.contains(MaterialState.disabled)) {
                // 🔥 clearly disabled but still brand-consistent
                return AppColors.brandPrimary.withOpacity(0.85);
              }
              return AppColors.brandPrimary;
            },
          ),
          foregroundColor: MaterialStateProperty.resolveWith<Color>(
            (states) {
              if (states.contains(MaterialState.disabled)) {
                return AppColors.textOnColor.withOpacity(0.9);
              }
              return AppColors.textOnColor;
            },
          ),
          elevation: MaterialStateProperty.resolveWith<double>(
            (states) {
              if (states.contains(MaterialState.disabled)) {
                return 0;
              }
              return 4;
            },
          ),
          padding: MaterialStateProperty.all(
            const EdgeInsets.symmetric(vertical: 16),
          ),
          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(32),
            ),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
