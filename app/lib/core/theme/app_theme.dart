import 'package:flutter/material.dart';

abstract final class AppTheme {
  static ThemeData get light => _build(Brightness.light);
  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final dark = brightness == Brightness.dark;
    final scheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF0087E0),
      brightness: brightness,
      surface: dark ? const Color(0xFF111A2E) : Colors.white,
    );
    final background = dark ? const Color(0xFF0B1220) : const Color(0xFFF4F7FC);
    final subtle = dark ? const Color(0xFF0F172A) : const Color(0xFFEAF0F8);
    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: background,
      fontFamily: 'sans-serif',
    );
    return base.copyWith(
      textTheme: base.textTheme.copyWith(
        headlineLarge: base.textTheme.headlineLarge?.copyWith(
          fontWeight: FontWeight.w800, letterSpacing: -1,
        ),
        headlineSmall: base.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
        titleLarge: base.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        bodyLarge: base.textTheme.bodyLarge?.copyWith(color: scheme.onSurfaceVariant, height: 1.5),
        bodyMedium: base.textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant, height: 1.4),
      ),
      cardTheme: CardThemeData(
        color: scheme.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: scheme.outlineVariant),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: subtle,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.primary, width: 2),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: subtle, indicatorColor: scheme.secondaryContainer,
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: subtle,
        indicatorColor: scheme.secondaryContainer,
        selectedIconTheme: IconThemeData(color: scheme.onSecondaryContainer),
      ),
    );
  }
}
