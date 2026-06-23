import 'package:flutter/material.dart';

import 'package:budiutama_basketball/core/theme/app_colors.dart';

Future<bool?> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String content,
  String confirmLabel = 'Ya',
  bool isDestructive = false,
}) {
  return showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Batal'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: FilledButton.styleFrom(
            backgroundColor:
                isDestructive ? AppColors.danger : AppColors.orange,
          ),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
}
