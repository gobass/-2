import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService extends GetxController {
  static ThemeService get instance => Get.find();
  
  final RxBool _isDarkMode = true.obs;
  
  bool get isDarkMode => _isDarkMode.value;
  
  @override
  void onInit() {
    super.onInit();
    _loadThemePreference();
  }

  Future<void> _loadThemePreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isDark = prefs.getBool('is_dark_mode') ?? true;
      _isDarkMode.value = isDark;
    } catch (e) {
      print('Error loading theme preference: $e');
    }
  }

  Future<void> toggleTheme() async {
    try {
      _isDarkMode.value = !_isDarkMode.value;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_dark_mode', _isDarkMode.value);
      
      // تحديث الثيم في GetX
      Get.changeTheme(_isDarkMode.value ? _darkTheme : _lightTheme);
    } catch (e) {
      print('Error toggling theme: $e');
    }
  }

  ThemeData get currentTheme => _isDarkMode.value ? _darkTheme : _lightTheme;

  static final ThemeData _darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: Colors.red,
    scaffoldBackgroundColor: Colors.black,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.red,
      brightness: Brightness.dark,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.white),
      bodyMedium: TextStyle(color: Colors.white),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      selectedItemColor: Colors.red,
      unselectedItemColor: Colors.grey,
    ),
  );

  static final ThemeData _lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: Colors.red,
    scaffoldBackgroundColor: Colors.white,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.red,
      brightness: Brightness.light,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.black),
      bodyMedium: TextStyle(color: Colors.black),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      elevation: 1,
      iconTheme: IconThemeData(color: Colors.black),
      titleTextStyle: TextStyle(
        color: Colors.black,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      selectedItemColor: Colors.red,
      unselectedItemColor: Colors.grey,
    ),
  );

  // مساعدات للألوان المتكيفة مع الثيم
  Color get backgroundColor => _isDarkMode.value ? Colors.black : Colors.white;
  Color get cardColor => _isDarkMode.value ? Colors.grey[900]! : Colors.grey[100]!;
  Color get textColor => _isDarkMode.value ? Colors.white : Colors.black;
  Color get subtitleColor => _isDarkMode.value ? Colors.white70 : Colors.black54;
  Color get borderColor => _isDarkMode.value ? Colors.grey[700]! : Colors.grey[300]!;
  
  LinearGradient get primaryGradient => _isDarkMode.value
      ? const LinearGradient(colors: [Colors.red, Color(0xFFFF6B6B)])
      : const LinearGradient(colors: [Colors.red, Color(0xFFE53E3E)]);
      
  LinearGradient get cardGradient => _isDarkMode.value
      ? LinearGradient(colors: [Colors.grey[800]!, Colors.grey[900]!])
      : LinearGradient(colors: [Colors.grey[50]!, Colors.grey[100]!]);
}
