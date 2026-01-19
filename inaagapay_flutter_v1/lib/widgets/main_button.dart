import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class MainButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const MainButton({
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
            if (states.contains(MaterialState.pressed)) return 2;
            return 6;
          }),
          backgroundColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.pressed)) {
              return AppColors.brandAccent; // pressed (darker pink)
            }
            if (states.contains(MaterialState.hovered)) {
              return AppColors.brandPrimary.withOpacity(0.9); // hovered
            }
            return AppColors.brandPrimary; // default
          }),
          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
          ),
        ),
        child: _ButtonContent(
          label: label,
          textColor: AppColors.textOnColor,
          iconColor: AppColors.textOnColor,
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

