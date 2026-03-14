import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

class MovieDbApp extends ConsumerWidget {
  const MovieDbApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Movie DB',
      debugShowCheckedModeBanner: false,

      // OLED dark mode — True Black #000000
      theme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,

      routerConfig: router,
    );
  }
}
