import 'package:flutter/material.dart';
import 'app_theme.dart';

class ThemeProvider extends ValueNotifier<ThemeMode> {
  ThemeProvider([super.value = ThemeMode.light]) {
    // Initialize standard colors based on starting mode
    AppTheme.setUpThemeColors(value);
  }

  static late ThemeProvider instance;

  static void init() {
    instance = ThemeProvider();
  }

  bool get isDarkMode => value == ThemeMode.dark;

  void toggleTheme() {
    value = isDarkMode ? ThemeMode.light : ThemeMode.dark;
    AppTheme.setUpThemeColors(value);
    notifyListeners();
  }
}
