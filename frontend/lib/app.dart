import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'theme/theme_provider.dart';
import 'screens/splash_screen.dart';

class HailMaryApp extends StatelessWidget {
  const HailMaryApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Always initialise as dark clinical theme
    AppTheme.setUpThemeColors(ThemeMode.dark);
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeProvider.instance,
      builder: (context, mode, child) {
        AppTheme.setUpThemeColors(ThemeMode.dark);
        return MaterialApp(
          title: 'HailMary Health',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.darkTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.dark,
          home: const SplashScreen(),
        );
      },
    );
  }
}
