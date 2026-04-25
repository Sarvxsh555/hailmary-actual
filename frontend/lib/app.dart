import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'theme/theme_provider.dart';
import 'screens/splash_screen.dart';

class HailMaryApp extends StatelessWidget {
  const HailMaryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeProvider.instance,
      builder: (context, mode, child) {
        return MaterialApp(
          title: 'HailMary Health',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          themeMode: mode,
          home: const SplashScreen(),
        );
      },
    );
  }
}
