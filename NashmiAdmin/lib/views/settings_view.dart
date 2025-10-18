import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nashmi_admin_v2/services/supabase_service.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  final SupabaseService supabaseService = Get.find<SupabaseService>();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController appNameController = TextEditingController();
  final TextEditingController logoUrlController = TextEditingController();
  final TextEditingController primaryColorController = TextEditingController();
  final TextEditingController currentPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _scrollController.dispose();
    appNameController.dispose();
    logoUrlController.dispose();
    primaryColorController.dispose();
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الإعدادات'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: RawScrollbar(
          controller: _scrollController,
          thumbVisibility: true,
          thickness: 8,
          radius: const Radius.circular(8),
          trackVisibility: true,
          interactive: true,
          scrollbarOrientation: ScrollbarOrientation.right,
          child: SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // App Settings Section
                const Text(
                  'إعدادات التطبيق',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 16),

                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        TextField(
                          controller: appNameController,
                          decoration: const InputDecoration(
                            labelText: 'اسم التطبيق',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.apps),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: logoUrlController,
                          decoration: const InputDecoration(
                            labelText: 'رابط الشعار',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.image),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: primaryColorController,
                          decoration: const InputDecoration(
                            labelText: 'اللون الأساسي (Hex Code)',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.color_lens),
                            hintText: '#007bff',
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            _saveAppSettings();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 50),
                          ),
                          child: const Text('حفظ إعدادات التطبيق'),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Change Password Section
                const Text(
                  'تغيير كلمة المرور',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 16),

                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        TextField(
                          controller: currentPasswordController,
                          decoration: const InputDecoration(
                            labelText: 'كلمة المرور الحالية',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.lock),
                          ),
                          obscureText: true,
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: newPasswordController,
                          decoration: const InputDecoration(
                            labelText: 'كلمة المرور الجديدة',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.lock_outline),
                          ),
                          obscureText: true,
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: confirmPasswordController,
                          decoration: const InputDecoration(
                            labelText: 'تأكيد كلمة المرور الجديدة',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.lock_reset),
                          ),
                          obscureText: true,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            _changePassword();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 50),
                          ),
                          child: const Text('تغيير كلمة المرور'),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // System Info Section
                const Text(
                  'معلومات النظام',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 16),

                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSystemInfoItem('إصدار التطبيق', '1.0.0'),
                        const Divider(),
                        _buildSystemInfoItem('تاريخ الإنشاء', '2024'),
                        const Divider(),
                        _buildSystemInfoItem('عدد الأفلام', '0'),
                        const Divider(),
                        _buildSystemInfoItem('عدد المسلسلات', '0'),
                        const Divider(),
                        _buildSystemInfoItem('عدد الإعلانات', '0'),
                        const Divider(),
                        _buildSystemInfoItem('عدد المستخدمين', '0'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSystemInfoItem(String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  void _saveAppSettings() {
    if (appNameController.text.isEmpty) {
      Get.snackbar('خطأ', 'يرجى إدخال اسم التطبيق');
      return;
    }

    // Save app settings logic
    Get.snackbar('نجاح', 'تم حفظ إعدادات التطبيق بنجاح');
  }

  void _changePassword() {
    if (currentPasswordController.text.isEmpty ||
        newPasswordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty) {
      Get.snackbar('خطأ', 'يرجى ملء جميع الحقول');
      return;
    }

    if (newPasswordController.text != confirmPasswordController.text) {
      Get.snackbar('خطأ', 'كلمة المرور الجديدة غير متطابقة');
      return;
    }

    // Change password logic
    Get.snackbar('نجاح', 'تم تغيير كلمة المرور بنجاح');
    
    // Clear fields
    currentPasswordController.clear();
    newPasswordController.clear();
    confirmPasswordController.clear();
  }
}
