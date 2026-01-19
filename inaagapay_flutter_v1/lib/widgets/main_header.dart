import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class MainHeader extends StatelessWidget {
  /// Page title (e.g. HOME, PROFILE, SETTINGS)
  final String title;

  /// Callback when notification bell is tapped
  final VoidCallback? onNotificationTap;

  /// User avatar image (can be null for placeholder)
  final ImageProvider? avatarImage;

  /// Callback when avatar is tapped
  final VoidCallback? onAvatarTap;

  const MainHeader({
    super.key,
    required this.title,
    this.onNotificationTap,
    this.avatarImage,
    this.onAvatarTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.bgPrimary,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // 🔹 Logo
          Image.asset(
            'assets/images/logo.png', // replace with your logo path
            height: 36,
          ),

          const SizedBox(width: 12),

          // 🔹 Page title
          Text(
            title.toUpperCase(),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.brandText,
              letterSpacing: 0.5,
            ),
          ),

          const Spacer(),

          // 🔔 Notification bell
          IconButton(
            onPressed: onNotificationTap,
            icon: const Icon(
              Icons.notifications_none_rounded,
              size: 26,
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(width: 12),

          // 👤 Avatar
          GestureDetector(
            onTap: onAvatarTap,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.brandPrimary,
                image: avatarImage != null
                    ? DecorationImage(
                        image: avatarImage!,
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
