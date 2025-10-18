import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nashmi_admin_v2/services/keyboard_shortcuts_service.dart';

class KeyboardShortcutsWidget extends StatelessWidget {
  const KeyboardShortcutsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final keyboardService = Get.find<KeyboardShortcutsService>();
    final shortcuts = keyboardService.getShortcutDescriptions();

    return Container(
      width: 400,
      height: 500,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                const Text(
                  'اختصارات لوحة المفاتيح',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Obx(() => Switch(
                  value: keyboardService.isEnabled.value,
                  onChanged: (value) {
                    if (value) {
                      keyboardService.enableShortcuts();
                    } else {
                      keyboardService.disableShortcuts();
                    }
                  },
                )),
                const SizedBox(width: 8),
                const Text('تفعيل'),
              ],
            ),
          ),

          // Shortcuts List
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Navigation Section
                const Text(
                  'التنقل',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
                ),
                const SizedBox(height: 8),
                ..._buildShortcutSection([
                  'الصفحة الرئيسية (1)',
                  'الأفلام (2)',
                  'المسلسلات (3)',
                  'الإعلانات (4)',
                  'المستخدمون (5)',
                  'الفئات (6)',
                  'التقارير (7)',
                  'الإعدادات (8)',
                  'الأجهزة (9)',
                ]),

                const SizedBox(height: 16),

                // Actions Section
                const Text(
                  'الإجراءات',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
                ),
                const SizedBox(height: 8),
                ..._buildShortcutSection([
                  'تحديث الصفحة (R)',
                  'الإشعارات (N)',
                  'إغلاق (Esc)',
                  'الرئيسية (H)',
                  'تسجيل الخروج (L)',
                ]),

                const SizedBox(height: 16),

                // Advanced Section
                const Text(
                  'الإجراءات المتقدمة',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
                ),
                const SizedBox(height: 8),
                ..._buildShortcutSection([
                  'البحث (Ctrl+F)',
                  'الحفظ (Ctrl+S)',
                ]),

                const SizedBox(height: 16),

                // Instructions
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.withOpacity(0.3)),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'تعليمات الاستخدام:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '• اضغط على المفاتيح المعروضة للتنقل السريع\n'
                        '• استخدم Ctrl+F للبحث في الصفحة الحالية\n'
                        '• اضغط R لتحديث البيانات\n'
                        '• استخدم Esc لإغلاق النوافذ المنبثقة',
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildShortcutSection(List<String> shortcuts) {
    return shortcuts.map((shortcut) {
      final parts = shortcut.split(' (');
      final description = parts[0];
      final keyText = parts[1].replaceAll(')', '');

      return Container(
        margin: const EdgeInsets.only(bottom: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                description,
                style: const TextStyle(fontSize: 14),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.teal.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.teal.withOpacity(0.3)),
              ),
              child: Text(
                keyText,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal,
                ),
              ),
            ),
          ],
        ),
      );
    }).toList();
  }
}

// Helper function to show shortcuts dialog
void showKeyboardShortcutsDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => Dialog(
      child: const KeyboardShortcutsWidget(),
    ),
  );
}
