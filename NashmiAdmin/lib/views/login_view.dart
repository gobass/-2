import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nashmi_admin_v2/services/auth_service.dart';

class LoginView extends StatelessWidget {
  final AuthService authService = Get.find<AuthService>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final RxBool isLoading = false.obs;

  LoginView({super.key});

  Future<void> _login() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      Get.snackbar(
        'خطأ',
        'يرجى إدخال اسم المستخدم وكلمة المرور',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    // Convert username to email format
    String email = emailController.text;
    if (!email.contains('@')) {
      email = '$email@nashmi.com';
    }

    isLoading.value = true;
    final success = await authService.signIn(
      email,
      passwordController.text,
    );
    isLoading.value = false;

    if (success) {
      Get.offAllNamed('/home');
      Get.snackbar(
        'تم بنجاح',
        'تم تسجيل الدخول بنجاح',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } else {
      Get.snackbar(
        'خطأ',
        'فشل تسجيل الدخول، يرجى التحقق من البيانات',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Scrollbar(
        child: SingleChildScrollView(
          child: Center(
            child: Container(
              width: 400,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Logo
                  const Icon(
                    Icons.movie_filter,
                    size: 80,
                    color: Colors.teal,
                  ),
                  const SizedBox(height: 20),

                  // Title
                  const Text(
                    'نشمي - لوحة التحكم',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal,
                    ),
                  ),
                  const SizedBox(height: 10),

                  const Text(
                    'تسجيل الدخول للإدارة',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 36),

                  // Username Field
                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: 'اسم المستخدم',
                      prefixIcon: const Icon(Icons.person, color: Colors.teal),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Password Field
                  TextField(
                    controller: passwordController,
                    decoration: InputDecoration(
                      labelText: 'كلمة المرور',
                      prefixIcon: const Icon(Icons.lock, color: Colors.teal),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 28),

                  // Login Button
                  Obx(() => SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isLoading.value ? null : _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: isLoading.value
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'تسجيل الدخول',
                              style: TextStyle(fontSize: 18),
                            ),
                    ),
                  )),

                  const SizedBox(height: 20),

                  // Demo Credentials
                  const Text(
                    'بيانات الدخول:\nadmin / 123',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
