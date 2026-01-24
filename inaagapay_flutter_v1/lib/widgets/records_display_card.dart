import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class RecordsDisplayCard extends StatelessWidget {
  final String title;
  final List<RecordItem> items;

  /// Header icon (optional)
  final IconData? headerIcon;

  /// 🆕 Optional subtitle
  final String? subtitle;

  /// 🆕 Optional progress (0–14 only)
  final int? progress; // number of completed boxes

  const RecordsDisplayCard({
    super.key,
    required this.title,
    required this.items,
    this.headerIcon,
    this.subtitle,
    this.progress,
  }) : assert(
          progress == null || (progress >= 0 && progress <= 14),
          'progress must be between 0 and 14',
        );

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          // 🏷 TITLE
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (headerIcon != null) ...[
                Icon(
                  headerIcon,
                  size: 20,
                  color: AppColors.brandPrimary,
                ),
                const SizedBox(width: 8),
              ],
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),

          // 🆕 Subtitle
          if (subtitle != null) ...[
            const SizedBox(height: 6),
            Text(
              subtitle!,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],

          // 🆕 Progress bar (14 boxes)
          if (progress != null) ...[
            const SizedBox(height: 12),
            _ProgressBar(progress: progress!),
          ],

          const SizedBox(height: 14),

          // 📊 Records
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _RecordRow(item: item),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final int progress;

  const _ProgressBar({required this.progress});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: List.generate(14, (index) {
        final bool filled = index < progress;

        return Container(
          width: 12,
          height: 6,
          decoration: BoxDecoration(
            color: filled
                ? AppColors.success
                : AppColors.brandPrimary.withOpacity(0.2),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}

class _RecordRow extends StatelessWidget {
  final RecordItem item;

  const _RecordRow({required this.item});

  @override
  Widget build(BuildContext context) {
    final bool isTappable = item.onTap != null;

    return InkWell(
      onTap: item.onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.brandPrimary.withOpacity(0.06),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            if (item.leadingIcon != null) ...[
              Icon(
                item.leadingIcon,
                size: 20,
                color: AppColors.brandPrimary,
              ),
              const SizedBox(width: 10),
            ],

            Expanded(
              child: Row(
                children: [
                  Text(
                    '${item.label}: ',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.brandPrimary,
                    ),
                  ),
                  Text(
                    item.value,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),

            if (item.trailingWidget != null)
              item.trailingWidget!
            else if (isTappable)
              const Icon(
                Icons.chevron_right_rounded,
                size: 22,
                color: AppColors.textSecondary,
              ),
          ],
        ),
      ),
    );
  }
}

class RecordItem {
  final IconData? leadingIcon;
  final String label;
  final String value;
  final Widget? trailingWidget;
  final VoidCallback? onTap;

  const RecordItem({
    this.leadingIcon,
    required this.label,
    required this.value,
    this.trailingWidget,
    this.onTap,
  });
}
