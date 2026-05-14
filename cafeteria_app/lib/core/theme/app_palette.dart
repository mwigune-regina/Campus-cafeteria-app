import 'package:flutter/material.dart';

/// All theme-dependent colors live on an [AppPalette] instance.
///
/// To add a new theme:
///   1. Add a `const AppPalette` preset below.
///   2. Add it to [AppPalette.all] so the picker can see it.
///
/// To re-tune an existing theme, edit its preset in place.
class AppPalette {
  final String name;
  final String id; // stable id for persistence
  final Brightness brightness;

  // Brand
  final Color navyBlue;
  final Color orange;

  // Neutrals
  final Color white;
  final Color textDark;
  final Color textLight;
  final Color lightGray;
  final Color inputFill;
  final Color pageBg;
  final Color surface;

  // Semantic
  final Color success;
  final Color successDark;
  final Color successBg;
  final Color danger;
  final Color dangerBg;
  final Color warningBg;
  final Color infoBg;
  final Color accentBlue;

  const AppPalette({
    required this.name,
    required this.id,
    required this.brightness,
    required this.navyBlue,
    required this.orange,
    required this.white,
    required this.textDark,
    required this.textLight,
    required this.lightGray,
    required this.inputFill,
    required this.pageBg,
    required this.surface,
    required this.success,
    required this.successDark,
    required this.successBg,
    required this.danger,
    required this.dangerBg,
    required this.warningBg,
    required this.infoBg,
    required this.accentBlue,
  });

  // ---------------------------------------------------------------- Presets

  static const AppPalette light = AppPalette(
    name: 'Light',
    id: 'light',
    brightness: Brightness.light,
    navyBlue: Color(0xFF1A2B6B),
    orange: Color(0xFFE8771A),
    white: Colors.white,
    textDark: Color(0xFF1A1A2E),
    textLight: Color(0xFF8A8A9A),
    lightGray: Color(0xFFF0F0F5),
    inputFill: Color(0xFFEAEAF0),
    pageBg: Color(0xFFF5F5F8),
    surface: Colors.white,
    success: Color(0xFF22A55B),
    successDark: Color(0xFF2E7D32),
    successBg: Color(0xFFE6F4EA),
    danger: Color(0xFFE53935),
    dangerBg: Color(0xFFFFEBEE),
    warningBg: Color(0xFFFFF1E0),
    infoBg: Color(0xFFE7F0FF),
    accentBlue: Color(0xFF1A73E8),
  );

  static const AppPalette dark = AppPalette(
    name: 'Dark',
    id: 'dark',
    brightness: Brightness.dark,
    navyBlue: Color(0xFF6E84D1),
    orange: Color(0xFFFF9F45),
    white: Color(0xFF181924),
    textDark: Color(0xFFE8E8F0),
    textLight: Color(0xFF9B9BAA),
    lightGray: Color(0xFF1E1F2A),
    inputFill: Color(0xFF252735),
    pageBg: Color(0xFF0D0E14),
    surface: Color(0xFF181924),
    success: Color(0xFF49C97D),
    successDark: Color(0xFF6BCF8E),
    successBg: Color(0xFF1B3D2A),
    danger: Color(0xFFFF6B6B),
    dangerBg: Color(0xFF3A1F1F),
    warningBg: Color(0xFF3A2E1A),
    infoBg: Color(0xFF1A2540),
    accentBlue: Color(0xFF4E94E8),
  );

  /// Warm cream + emerald — a friendlier alt to navy.
  static const AppPalette emerald = AppPalette(
    name: 'Emerald',
    id: 'emerald',
    brightness: Brightness.light,
    navyBlue: Color(0xFF0E6E55),
    orange: Color(0xFFE7A33D),
    white: Colors.white,
    textDark: Color(0xFF1F2D24),
    textLight: Color(0xFF8B958E),
    lightGray: Color(0xFFF1F4F0),
    inputFill: Color(0xFFEAEFEA),
    pageBg: Color(0xFFF7F8F5),
    surface: Colors.white,
    success: Color(0xFF22A55B),
    successDark: Color(0xFF2E7D32),
    successBg: Color(0xFFE6F4EA),
    danger: Color(0xFFE53935),
    dangerBg: Color(0xFFFFEBEE),
    warningBg: Color(0xFFFFF1E0),
    infoBg: Color(0xFFE0EEEA),
    accentBlue: Color(0xFF1A73E8),
  );

  static const List<AppPalette> all = [light, dark, emerald];

  static AppPalette byId(String id) =>
      all.firstWhere((p) => p.id == id, orElse: () => light);
}
