import 'package:flutter/material.dart';
import '../theme/app_palette.dart';

/// Central color access for the app.
///
/// Two layers:
///   1. **Brand constants** below — never change regardless of theme
///      (e.g. third-party brand colors like Vodacom red).
///   2. **Theme-aware getters** — delegate to the currently-active
///      [AppPalette] held in [_palette]. Calling [setPalette] updates
///      all of these at once.
///
/// To switch themes at runtime: call `AppColors.setPalette(AppPalette.dark)`.
/// To re-tune a theme: edit the relevant [AppPalette] preset.
class AppColors {
  AppColors._();

  static AppPalette _palette = AppPalette.light;

  /// Subscribe to this if you need to rebuild when the theme changes.
  static final ValueNotifier<AppPalette> notifier =
      ValueNotifier<AppPalette>(_palette);

  static AppPalette get palette => _palette;

  static void setPalette(AppPalette p) {
    _palette = p;
    notifier.value = p;
  }

  // ------------------------------------------------------ Brand constants
  // These do NOT change with the active theme — they represent
  // third-party brand identities.
  static const Color vodacomRed = Color(0xFFEB001B);
  static const Color tigoBlue = Color(0xFF0066B3);

  // ------------------------------------------------------ Theme-aware getters
  // Brand
  static Color get navyBlue => _palette.navyBlue;
  static Color get orange => _palette.orange;

  // Neutrals
  static Color get white => _palette.white;
  static Color get textDark => _palette.textDark;
  static Color get textLight => _palette.textLight;
  static Color get lightGray => _palette.lightGray;
  static Color get inputFill => _palette.inputFill;
  static Color get pageBg => _palette.pageBg;
  static Color get surface => _palette.surface;

  // Semantic
  static Color get success => _palette.success;
  static Color get successDark => _palette.successDark;
  static Color get successBg => _palette.successBg;
  static Color get danger => _palette.danger;
  static Color get dangerBg => _palette.dangerBg;
  static Color get warningBg => _palette.warningBg;
  static Color get infoBg => _palette.infoBg;
  static Color get accentBlue => _palette.accentBlue;

  // Legacy alias
  static Color get error => _palette.danger;
}
