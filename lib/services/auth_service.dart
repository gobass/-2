import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService extends GetxController {
  static AuthService get instance => Get.find();
  
  final RxBool _isLoggedIn = false.obs;
  final RxBool _isLoading = false.obs;
  
  // Admin credentials (في التطبيق الحقيقي، يجب أن تكون مشفرة وفي قاعدة البيانات)
  final String _adminUsername = 'admin';
  final String _adminPassword = 'admin123';
  
  bool get isLoggedIn => _isLoggedIn.value;
  bool get isLoading => _isLoading.value;

  @override
  void onInit() {
    super.onInit();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isLoggedIn = prefs.getBool('is_admin_logged_in') ?? false;
      _isLoggedIn.value = isLoggedIn;
    } catch (e) {
      print('Error checking login status: $e');
    }
  }

  Future<bool> login(String username, String password) async {
    try {
      _isLoading.value = true;
      
      // محاكاة تأخير الشبكة
      await Future.delayed(const Duration(seconds: 1));
      
      // التحقق من بيانات الاعتماد
      if (username.trim() == _adminUsername && password.trim() == _adminPassword) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('is_admin_logged_in', true);
        _isLoggedIn.value = true;
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print('Login error: $e');
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_admin_logged_in', false);
      _isLoggedIn.value = false;
    } catch (e) {
      print('Logout error: $e');
    }
  }
}
