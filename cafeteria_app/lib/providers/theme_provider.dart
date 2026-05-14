import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_colors.dart';
import '../core/theme/app_palette.dart';

const _prefsKey = 'theme_palette_id';

class ThemeNotifier extends StateNotifier<AppPalette> {
  ThemeNotifier() : super(AppPalette.light) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString(_prefsKey);
    if (id != null) {
      final p = AppPalette.byId(id);
      AppColors.setPalette(p);
      state = p;
    }
  }

  Future<void> setPalette(AppPalette p) async {
    AppColors.setPalette(p);
    state = p;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, p.id);
  }
}

final themeProvider = StateNotifierProvider<ThemeNotifier, AppPalette>((ref) {
  return ThemeNotifier();
});
