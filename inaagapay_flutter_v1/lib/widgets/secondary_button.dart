import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class SecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const SecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ButtonStyle(
          elevation: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.pressed)) return 1;
            return 4;
          }),
          backgroundColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.pressed)) {
              return AppColors.bgSecondary; // pressed
            }
            if (states.contains(MaterialState.hovered)) {
              return AppColors.faintWhite; // hovered
            }
            return Colors.white; // default
          }),
          foregroundColor: MaterialStateProperty.all(
            AppColors.textSecondary,
          ),
          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
          ),
          side: MaterialStateProperty.all(
            BorderSide(
              color: AppColors.borderPrimary,
            ),
          ),
        ),
        child: _ButtonContent(
          label: label,
          textColor: AppColors.textSecondary,
          iconColor: AppColors.textSecondary,
        ),
      ),
    );
  }
}

class _ButtonContent extends StatelessWidget {
  final String label;
  final Color textColor;
  final Color iconColor;

  const _ButtonContent({
    required this.label,
    required this.textColor,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.arrow_forward, color: iconColor),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
        const SizedBox(width: 8),
        Icon(Icons.arrow_forward, color: iconColor),
      ],
    );
  }
}
