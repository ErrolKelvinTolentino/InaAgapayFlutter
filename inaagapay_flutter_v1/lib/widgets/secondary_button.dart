import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class SecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool showIcons; // 👈 ADD

  const SecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.showIcons = true, // 👈 ADD
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: AppColors.textSecondary,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          side: BorderSide(
            color: AppColors.borderPrimary,
          ),
        ),
        child: _ButtonContent(
          label: label,
          textColor: AppColors.textSecondary,
          iconColor: AppColors.textSecondary,
          showIcons: showIcons, // 👈 PASS THROUGH
        ),
      ),
    );
  }
}

class _ButtonContent extends StatelessWidget {
  final String label;
  final Color textColor;
  final Color iconColor;
  final bool showIcons;

  const _ButtonContent({
    required this.label,
    required this.textColor,
    required this.iconColor,
    this.showIcons = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (showIcons) ...[
          Icon(Icons.arrow_forward, color: iconColor),
          const SizedBox(width: 8),
        ],
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
        if (showIcons) ...[
          const SizedBox(width: 8),
          Icon(Icons.arrow_forward, color: iconColor),
        ],
      ],
    );
  }
}
