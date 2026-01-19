import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class SecondaryHeader extends StatelessWidget {
  /// Header title (e.g. COMPLETE PROFILE)
  final String title;

  /// Whether to show the leading/back icon
  final bool showLeading;

  /// Callback when leading icon is tapped
  final VoidCallback? onLeadingTap;

  const SecondaryHeader({
    super.key,
    required this.title,
    this.showLeading = false,
    this.onLeadingTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.bgSecondary,
        border: Border.all(
          color: AppColors.brandPrimary,
        ),
      ),
      child: Row(
        children: [
          // ◀ Back icon (optional)
          if (showLeading)
            IconButton(
              onPressed: onLeadingTap ?? () => Navigator.of(context).maybePop(),
              icon: const Icon(
                Icons.arrow_back,
                color: AppColors.brandPrimary,
              ),
            ),

          // Title
          Expanded(
            child: Center(
              child: Text(
                title.toUpperCase(),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.brandPrimary,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),

          // Spacer to balance layout when back icon is shown
          if (showLeading)
            const SizedBox(width: 48),
        ],
      ),
    );
  }
}
