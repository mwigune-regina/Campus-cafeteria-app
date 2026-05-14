import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/constants/app_strings.dart';
import 'core/theme/app_theme.dart';
import 'providers/theme_provider.dart';
import 'app_router.dart';

void main() {
  // Log the API URL once at startup so it's obvious from the debug console
  // which host the app is actually targeting. Pass with --dart-define=API_HOST=...
  debugPrint('[Cafeteria] Using API base URL: ${AppStrings.baseUrl}');
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final palette = ref.watch(themeProvider);

    return MaterialApp.router(
      title: 'Campus Cafeteria',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.fromPalette(palette),
      routerConfig: router,
    );
  }
}
