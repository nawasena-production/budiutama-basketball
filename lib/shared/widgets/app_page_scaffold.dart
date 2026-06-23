import 'package:flutter/material.dart';

import 'package:budiutama_basketball/core/theme/app_breakpoints.dart';
import 'package:budiutama_basketball/core/theme/app_colors.dart';

class AppPageScaffold extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final Widget child;
  final Widget? bottom;
  final List<Widget> actions;
  final Widget? floatingActionButton;
  final bool scrollBody;

  const AppPageScaffold({
    super.key,
    required this.title,
    this.subtitle,
    required this.icon,
    required this.child,
    this.bottom,
    this.actions = const [],
    this.floatingActionButton,
    this.scrollBody = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: floatingActionButton,
      body: Column(
        children: [
          _PageHeader(
            title: title,
            subtitle: subtitle,
            icon: icon,
            actions: actions,
            bottom: bottom,
          ),
          Expanded(
            child: scrollBody ? SingleChildScrollView(child: child) : child,
          ),
        ],
      ),
    );
  }
}

class _PageHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final List<Widget> actions;
  final Widget? bottom;

  const _PageHeader({
    required this.title,
    this.subtitle,
    required this.icon,
    required this.actions,
    this.bottom,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final horizontalInset =
            AppBreakpoints.isDesktop(constraints.maxWidth) ? 24.0 : 72.0;
        final canPop = Navigator.canPop(context);

        return DecoratedBox(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            border: Border(bottom: BorderSide(color: AppColors.borderSoft)),
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(horizontalInset, 14, 18, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (canPop) ...[
                        IconButton(
                          tooltip: 'Kembali',
                          onPressed: () => Navigator.of(context).maybePop(),
                          icon: const Icon(Icons.arrow_back_rounded),
                          color: AppColors.navy,
                        ),
                        const SizedBox(width: 6),
                      ],
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: AppColors.navySoft,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(icon, color: AppColors.navy, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppColors.ink,
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            if (subtitle != null && subtitle!.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 2),
                                child: Text(
                                  subtitle!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: AppColors.muted,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      ...actions,
                    ],
                  ),
                  if (bottom != null) ...[
                    const SizedBox(height: 12),
                    bottom!,
                  ] else
                    const SizedBox(height: 14),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
