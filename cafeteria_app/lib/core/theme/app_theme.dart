import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_palette.dart';

class AppTheme {
  AppTheme._();

  /// Build a [ThemeData] from any palette. Material widgets get colors from
  /// here; custom widgets that read `AppColors.*` get them from the
  /// runtime palette.
  static ThemeData fromPalette(AppPalette p) {
    final scheme = ColorScheme.fromSeed(
      seedColor: p.navyBlue,
      brightness: p.brightness,
      primary: p.navyBlue,
      onPrimary: p.white,
      secondary: p.orange,
      onSecondary: p.white,
      surface: p.surface,
      onSurface: p.textDark,
      error: p.danger,
      onError: p.white,
    );

    final textTheme = GoogleFonts.robotoTextTheme(
      ThemeData(brightness: p.brightness).textTheme,
    ).apply(
      bodyColor: p.textDark,
      displayColor: p.textDark,
    );

    return ThemeData(
      colorScheme: scheme,
      brightness: p.brightness,
      scaffoldBackgroundColor: p.pageBg,
      useMaterial3: true,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: p.navyBlue,
        foregroundColor: p.white,
        elevation: 0,
        centerTitle: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: p.navyBlue,
          foregroundColor: p.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: p.navyBlue,
      ),
    );
  }

  static ThemeData get lightTheme => fromPalette(AppPalette.light);
}
