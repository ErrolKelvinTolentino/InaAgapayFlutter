import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class SmallDescription extends StatelessWidget {
  final String text;
  final IconData? icon;
  final Color? color;

  const SmallDescription({
    super.key,
    required this.text,
    this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final Color textColor = color ?? AppColors.textSecondary;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (icon != null)
          Icon(
            icon,
            size: 18,
            color: textColor,
          ),

        if (icon != null) const SizedBox(width: 8),

        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: textColor,
            ),
          ),
        ),
      ],
    );
  }
}
