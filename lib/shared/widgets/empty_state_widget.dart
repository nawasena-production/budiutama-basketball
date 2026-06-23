import 'package:flutter/material.dart';

import 'package:budiutama_basketball/core/theme/app_colors.dart';

class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String message;
  final String? ctaLabel;
  final VoidCallback? onCtaPressed;

  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.message,
    this.ctaLabel,
    this.onCtaPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.borderSoft),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: const BoxDecoration(
                      color: AppColors.navySoft,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, size: 32, color: AppColors.navy),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.ink,
                          height: 1.35,
                        ),
                  ),
                  if (ctaLabel != null && onCtaPressed != null) ...[
                    const SizedBox(height: 20),
                    FilledButton(
                      onPressed: onCtaPressed,
                      child: Text(ctaLabel!),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
