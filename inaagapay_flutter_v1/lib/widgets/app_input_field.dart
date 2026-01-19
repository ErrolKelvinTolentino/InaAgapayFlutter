import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class AppInputField extends StatefulWidget {
  final String hintText;
  final TextEditingController controller;

  /// Optional icons
  final IconData? leadingIcon;
  final IconData? trailingIcon;

  /// Trailing icon tap (e.g. toggle password visibility)
  final VoidCallback? onTrailingTap;

  /// Input behavior
  final bool obscureText;
  final TextInputType keyboardType;

  /// Error
  final String? errorText;

  const AppInputField({
    super.key,
    required this.hintText,
    required this.controller,
    this.leadingIcon,
    this.trailingIcon,
    this.onTrailingTap,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.errorText,
  });

  @override
  State<AppInputField> createState() => _AppInputFieldState();
}

class _AppInputFieldState extends State<AppInputField> {
  bool _isHovered = false;
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    final bool hasError = widget.errorText != null;

    Color borderColor() {
      if (hasError) return AppColors.error;
      if (_isFocused) return AppColors.brandPrimary;
      if (_isHovered) return AppColors.brandPrimary.withOpacity(0.4);
      return Colors.transparent;
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Focus(
        onFocusChange: (focused) =>
            setState(() => _isFocused = focused),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 56,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: borderColor(),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // 🔹 Leading icon
                  if (widget.leadingIcon != null)
                    Icon(
                      widget.leadingIcon,
                      color: hasError
                          ? AppColors.error
                          : AppColors.brandAccent,
                    ),

                  if (widget.leadingIcon != null)
                    const SizedBox(width: 12),

                  // 🔹 Text field
                  Expanded(
                    child: TextField(
                      controller: widget.controller,
                      obscureText: widget.obscureText,
                      keyboardType: widget.keyboardType,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: widget.hintText,
                        hintStyle: TextStyle(
                          color: hasError
                              ? AppColors.error.withOpacity(0.7)
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),

                  // 🔹 Trailing icon
                  if (widget.trailingIcon != null)
                    GestureDetector(
                      onTap: widget.onTrailingTap,
                      child: Icon(
                        widget.trailingIcon,
                        color: hasError
                            ? AppColors.error
                            : AppColors.brandAccent,
                      ),
                    ),
                ],
              ),
            ),

            // 🔴 Error text
            if (hasError)
              Padding(
                padding: const EdgeInsets.only(left: 16, top: 6),
                child: Text(
                  widget.errorText!,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.error,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
