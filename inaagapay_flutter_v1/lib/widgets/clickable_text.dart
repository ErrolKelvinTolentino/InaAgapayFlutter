import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class ClickableText extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final bool underline;

  const ClickableText({
    super.key,
    required this.text,
    required this.onTap,
    this.underline = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.brandPrimary,
          decoration:
              underline ? TextDecoration.underline : TextDecoration.none,
        ),
      ),
    );
  }
}
