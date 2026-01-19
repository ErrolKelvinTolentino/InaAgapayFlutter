import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

enum PasswordStrength {
  weak,
  medium,
  strong,
}

class PasswordStrengthIndicator extends StatelessWidget {
  final PasswordStrength strength;

  const PasswordStrengthIndicator({
    super.key,
    required this.strength,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _StrengthRow(
          label: 'Strong',
          isActive: strength == PasswordStrength.strong,
          color: AppColors.success,
          icon: Icons.check_circle,
        ),
        _StrengthRow(
          label: 'Medium',
          isActive: strength == PasswordStrength.medium,
          color: AppColors.warning,
          icon: Icons.radio_button_unchecked,
        ),
        _StrengthRow(
          label: 'Weak',
          isActive: strength == PasswordStrength.weak,
          color: AppColors.error,
          icon: Icons.cancel,
        ),
      ],
    );
  }
}

class _StrengthRow extends StatelessWidget {
  final String label;
  final bool isActive;
  final Color color;
  final IconData icon;

  const _StrengthRow({
    required this.label,
    required this.isActive,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: isActive ? 1 : 0.4,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              icon,
              size: 18,
              color: color,
            ),
          ],
        ),
      ),
    );
  }
}
