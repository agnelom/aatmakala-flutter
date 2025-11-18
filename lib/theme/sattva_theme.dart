import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Aatmkala "Sattva" Theme:
/// - Primary (Saffron): #F57C00
/// - Accent (Tulsi Green): #4B7F52
/// - Cream background: #FFF8E1
/// - Deep text browns for a spiritual, grounded feel
class SattvaTheme {
  // Base palette
  static const Color saffron = Color(0xFFF57C00);
  static const Color saffronLight = Color(0xFFF9A825);
  static const Color tulsi = Color(0xFF4B7F52);
  static const Color cream = Color(0xFFFFF8E1);
  static const Color paper = Color(0xFFF9F8F6);
  static const Color textDark = Color(0xFF3E2723);
  static const Color textSoft = Color(0xFF5D4037);

  static const LinearGradient saffronGradient = LinearGradient(
    colors: [saffron, saffronLight],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  /// Parse optional hex from .env (e.g. BRAND_PRIMARY/BRAND_ACCENT) with fallback
  static Color _parseHex(String? hex, Color fallback) {
    if (hex == null || hex.isEmpty) return fallback;
    final raw = hex.replaceAll('#', '').trim();
    final v = int.tryParse(raw, radix: 16);
    if (v == null) return fallback;
    final argb = raw.length <= 6 ? (0xFF000000 | v) : v;
    return Color(argb);
  }

  /// Build the light theme. Will respect optional BRAND_PRIMARY/BRAND_ACCENT
  /// from .env, otherwise uses saffron + tulsi defaults.
  static ThemeData light() {
    final primary = _parseHex(dotenv.env['BRAND_PRIMARY'], saffron);
    final accent = _parseHex(dotenv.env['BRAND_ACCENT'], tulsi);

    final scheme = ColorScheme.fromSeed(
      seedColor: primary,
      primary: primary,
      secondary: accent,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      // Match your HTML's strong colored header/app bar look
      appBarTheme: AppBarTheme(
        backgroundColor: tulsi, // calm green app bar (you said you like it)
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 1,
      ),
      scaffoldBackgroundColor: cream, // warm background instead of pure white
      // Material 3 uses CardThemeData here
      cardTheme: const CardThemeData(
        elevation: 2,
        color: Colors.white,
        margin: EdgeInsets.all(8),
      ),
      // Typography through material2021 (Flutter 3.24+)
      typography: Typography.material2021(
        platform: defaultTargetPlatform,
        black: Typography.material2021().black.apply(
          fontFamily: 'Roboto',
          displayColor: textDark,
          bodyColor: textDark,
        ),
        white: Typography.material2021().white.apply(
          fontFamily: 'Roboto',
          displayColor: textDark,
          bodyColor: textDark,
        ),
      ),
    );
  }
}
