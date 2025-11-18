// lib/core/theme.dart
import 'package:flutter/material.dart';

Color _hex(String hex) {
  final h = hex.replaceAll('#', '');
  return Color(int.parse('FF$h', radix: 16));
}

class AppTheme {
  static ThemeData light({required Color primary, required Color accent}) {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: primary, brightness: Brightness.light),
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: const AppBarTheme(centerTitle: true),
      cardTheme: const CardThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
        clipBehavior: Clip.antiAlias,
      ),
    );
    return base.copyWith(
      colorScheme: base.colorScheme.copyWith(secondary: accent),
    );
  }

  static ThemeData dark({required Color primary, required Color accent}) {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: primary, brightness: Brightness.dark),
      cardTheme: const CardThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
        clipBehavior: Clip.antiAlias,
      ),
    );
    return base.copyWith(
      colorScheme: base.colorScheme.copyWith(secondary: accent),
    );
  }
}
