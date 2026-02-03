import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class SecondaryHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onBack;

  const SecondaryHeader({
    super.key,
    required this.title,
    this.onBack, // 👈 optional
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: Row(
        children: [
          // 👈 Back button ONLY if onBack is provided
          if (onBack != null)
            IconButton(
              icon: const Icon(Icons.arrow_back_ios_new),
              color: AppColors.brandPrimary,
              onPressed: onBack,
            )
          else
            const SizedBox(width: 48), // keeps title centered

          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.brandPrimary,
              ),
            ),
          ),

          // right spacer to balance layout
          const SizedBox(width: 48),
        ],
      ),
    );
  }
}
