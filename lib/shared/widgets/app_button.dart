import 'package:flutter/material.dart';

import 'package:budiutama_basketball/core/theme/app_colors.dart';

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isDestructive;
  final IconData? icon;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.isDestructive = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final backgroundColor = isDestructive ? AppColors.danger : AppColors.orange;

    return FilledButton.icon(
      onPressed: isLoading ? null : onPressed,
      icon: isLoading
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : Icon(icon ?? Icons.check, size: 18),
      label: Text(label),
      style: FilledButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: Colors.white,
        disabledBackgroundColor: backgroundColor.withValues(alpha: 0.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
