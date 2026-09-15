import 'package:flutter/material.dart';

import 'app_colors.dart';

abstract final class AppTheme {
  static ThemeData get dark {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.accent,
      brightness: Brightness.dark,
      surface: AppColors.panel,
    ).copyWith(
      primary: AppColors.accent,
      secondary: AppColors.accentBright,
      surface: AppColors.panel,
      onSurface: AppColors.text,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.background,
      fontFamily: 'sans-serif',
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: AppColors.text,
          fontWeight: FontWeight.w800,
          letterSpacing: -1,
        ),
        headlineSmall: TextStyle(
          color: AppColors.text,
          fontWeight: FontWeight.w700,
        ),
        titleLarge: TextStyle(
          color: AppColors.text,
          fontWeight: FontWeight.w700,
        ),
        bodyLarge: TextStyle(color: AppColors.textMuted, height: 1.5),
        bodyMedium: TextStyle(color: AppColors.textMuted, height: 1.4),
      ),
      cardTheme: CardThemeData(
        color: AppColors.panel,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: Color(0x1FFFFFFF)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.backgroundSubtle,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0x1FFFFFFF)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0x1FFFFFFF)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.accent, width: 2),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      navigationBarTheme: const NavigationBarThemeData(
        backgroundColor: AppColors.backgroundSubtle,
        indicatorColor: Color(0x334DA3FF),
      ),
      navigationRailTheme: const NavigationRailThemeData(
        backgroundColor: AppColors.backgroundSubtle,
        indicatorColor: Color(0x334DA3FF),
        selectedIconTheme: IconThemeData(color: AppColors.accent),
      ),
    );
  }
}
