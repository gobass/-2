import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_theme.dart';

class ThemeService extends GetxService {
  static ThemeService get to => Get.find<ThemeService>();

  late SharedPreferences _prefs;
  final _key = 'isDarkMode';

  /// Get isDarkMode from local storage and if it's not there, returns false (that means default theme is light)
  bool get isDarkMode => _prefs.getBool(_key) ?? false;

  /// Load theme from local storage
  ThemeMode get theme => isDarkMode ? ThemeMode.dark : ThemeMode.light;

  /// Save theme to local storage
  void saveTheme(bool isDarkMode) => _prefs.setBool(_key, isDarkMode);

  /// Switch theme
  void switchTheme() {
    Get.changeThemeMode(isDarkMode ? ThemeMode.light : ThemeMode.dark);
    saveTheme(!isDarkMode);
  }

  /// Get theme data
  ThemeData get themeData => isDarkMode ? AppTheme.darkTheme : AppTheme.lightTheme;

  /// Initialize theme service
  Future<ThemeService> init() async {
    _prefs = await SharedPreferences.getInstance();
    // Load theme from storage
    Get.changeThemeMode(theme);
    return this;
  }

  /// Get current theme colors
  Color get primaryColor => isDarkMode ? Colors.red : Colors.red;
  Color get backgroundColor => isDarkMode ? Colors.black : Colors.white;
  Color get surfaceColor => isDarkMode ? const Color(0xFF212121) : Colors.white;
  Color get cardColor => isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
  Color get textColor => isDarkMode ? Colors.white : Colors.black;
  Color get textSecondaryColor => isDarkMode ? Colors.white70 : Colors.black87;
}
