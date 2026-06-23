import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData light() {
    const colorScheme = ColorScheme.light(
      primary: AppColors.navy,
      onPrimary: Colors.white,
      secondary: AppColors.orange,
      onSecondary: Colors.white,
      error: AppColors.danger,
      surface: AppColors.surface,
      onSurface: AppColors.ink,
    );

    final base = ThemeData(
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.background,
      useMaterial3: true,
      fontFamily: 'Roboto',
    );

    return base.copyWith(
      textTheme: base.textTheme
          .apply(
            bodyColor: AppColors.ink,
            displayColor: AppColors.ink,
          )
          .copyWith(
            headlineSmall: base.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: 0,
            ),
            titleLarge: base.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: 0,
            ),
            titleMedium: base.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: 0,
            ),
            bodyMedium: base.textTheme.bodyMedium?.copyWith(
              color: AppColors.ink,
              height: 1.35,
              letterSpacing: 0,
            ),
            labelLarge: base.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: 0,
            ),
          ),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.ink,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: AppColors.borderSoft),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceAlt,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.navy, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.danger),
        ),
        prefixIconColor: AppColors.muted,
        suffixIconColor: AppColors.muted,
        labelStyle: const TextStyle(color: AppColors.muted),
        hintStyle: const TextStyle(color: AppColors.subtle),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.orange,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.orange.withValues(alpha: 0.45),
          disabledForegroundColor: Colors.white.withValues(alpha: 0.8),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.navy,
          side: const BorderSide(color: AppColors.border),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.navy,
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.orange,
        foregroundColor: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
      chipTheme: base.chipTheme.copyWith(
        backgroundColor: AppColors.surfaceAlt,
        selectedColor: AppColors.navy,
        disabledColor: AppColors.surfaceAlt,
        labelStyle: const TextStyle(color: AppColors.ink),
        secondaryLabelStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
        side: const BorderSide(color: AppColors.border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      tabBarTheme: const TabBarThemeData(
        labelColor: AppColors.navy,
        unselectedLabelColor: AppColors.muted,
        indicatorColor: AppColors.orange,
        dividerColor: AppColors.borderSoft,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.borderSoft,
        thickness: 1,
        space: 1,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.ink,
        contentTextStyle: const TextStyle(color: Colors.white),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      dataTableTheme: DataTableThemeData(
        headingTextStyle: const TextStyle(
          color: AppColors.muted,
          fontWeight: FontWeight.w800,
          fontSize: 12,
        ),
        dataTextStyle: const TextStyle(color: AppColors.ink, fontSize: 12),
        headingRowColor: WidgetStateProperty.all(AppColors.surfaceAlt),
        dividerThickness: 0.6,
      ),
      navigationRailTheme: const NavigationRailThemeData(
        backgroundColor: AppColors.surface,
        selectedIconTheme: IconThemeData(color: AppColors.orange),
        unselectedIconTheme: IconThemeData(color: AppColors.muted),
        selectedLabelTextStyle: TextStyle(
          color: AppColors.navy,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelTextStyle: TextStyle(color: AppColors.muted),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.orangeSoft,
        labelTextStyle: WidgetStateProperty.all(
          const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
