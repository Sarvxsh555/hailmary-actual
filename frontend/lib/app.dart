import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/splash_screen.dart';

class HailMaryApp extends StatelessWidget {
  const HailMaryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HailMary Health',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
    );
  }
}
