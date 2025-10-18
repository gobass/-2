import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:nashmi_admin_v2/services/statistics_service.dart';

class KeyboardShortcutsService extends GetxService {
  static const String _channelName = 'nashmi_admin/shortcuts';
  static const MethodChannel _platformChannel = MethodChannel(_channelName);

  final RxBool isEnabled = true.obs;

  // Keyboard shortcuts map
  final Map<LogicalKeyboardKey, VoidCallback> _shortcuts = {};

  @override
  void onInit() {
    super.onInit();
    _initializeShortcuts();
    _setupGlobalShortcuts();
  }

  void _initializeShortcuts() {
    _shortcuts.clear();

    // Navigation shortcuts
    _shortcuts[LogicalKeyboardKey.digit1] = () => Get.toNamed('/home');
    _shortcuts[LogicalKeyboardKey.digit2] = () => Get.toNamed('/movies');
    _shortcuts[LogicalKeyboardKey.digit3] = () => Get.toNamed('/series');
    _shortcuts[LogicalKeyboardKey.digit4] = () => Get.toNamed('/ads');
    _shortcuts[LogicalKeyboardKey.digit5] = () => Get.toNamed('/users');
    _shortcuts[LogicalKeyboardKey.digit6] = () => Get.toNamed('/categories');
    _shortcuts[LogicalKeyboardKey.digit7] = () => Get.toNamed('/reports');
    _shortcuts[LogicalKeyboardKey.digit8] = () => Get.toNamed('/settings');
    _shortcuts[LogicalKeyboardKey.digit9] = () => Get.toNamed('/hardware');

    // Action shortcuts
    _shortcuts[LogicalKeyboardKey.keyR] = _refreshCurrentPage;
    _shortcuts[LogicalKeyboardKey.keyN] = _showNotifications;
    _shortcuts[LogicalKeyboardKey.escape] = _closeOverlays;
    _shortcuts[LogicalKeyboardKey.keyH] = () => Get.toNamed('/home');
    _shortcuts[LogicalKeyboardKey.keyL] = () => Get.offAllNamed('/login');

    // Ctrl/Cmd shortcuts
    _shortcuts[LogicalKeyboardKey.keyF] = _focusSearch;
    _shortcuts[LogicalKeyboardKey.keyS] = _saveCurrentForm;
  }

  void _setupGlobalShortcuts() {
    // Listen for hardware keyboard events
    HardwareKeyboard.instance.addHandler(_handleKeyEvent);
  }

  bool _handleKeyEvent(KeyEvent event) {
    if (!isEnabled.value) return false;

    // Only handle key down events
    if (event is! KeyDownEvent) return false;

    // Check for Ctrl/Cmd modifier
    final bool isCtrlPressed = HardwareKeyboard.instance.logicalKeysPressed
        .any((key) => key == LogicalKeyboardKey.controlLeft || key == LogicalKeyboardKey.controlRight);
    final bool isCmdPressed = HardwareKeyboard.instance.logicalKeysPressed
        .any((key) => key == LogicalKeyboardKey.metaLeft || key == LogicalKeyboardKey.metaRight);

    // Handle shortcuts with modifiers
    if (isCtrlPressed || isCmdPressed) {
      if (event.logicalKey == LogicalKeyboardKey.keyR) {
        _refreshCurrentPage();
        return true;
      }
      if (event.logicalKey == LogicalKeyboardKey.keyF) {
        _focusSearch();
        return true;
      }
      if (event.logicalKey == LogicalKeyboardKey.keyS) {
        _saveCurrentForm();
        return true;
      }
    }

    // Handle single key shortcuts
    final callback = _shortcuts[event.logicalKey];
    if (callback != null) {
      callback();
      return true;
    }

    return false;
  }

  void _refreshCurrentPage() {
    final currentRoute = Get.currentRoute;
    switch (currentRoute) {
      case '/home':
        Get.find<StatisticsService>().loadStatistics();
        Get.snackbar('تحديث', 'جاري تحديث البيانات...');
        break;
      case '/movies':
        // Refresh movies page
        break;
      case '/series':
        // Refresh series page
        break;
      default:
        Get.snackbar('تحديث', 'تم تحديث الصفحة');
    }
  }

  void _showNotifications() {
    // This will be handled by the notification service
    Get.snackbar('اختصار', 'اضغط على أيقونة الإشعارات للعرض');
  }

  void _closeOverlays() {
    Get.until((route) => route.isFirst);
  }

  void _focusSearch() {
    // Focus search field if available
    FocusScope.of(Get.context!).requestFocus();
  }

  void _saveCurrentForm() {
    // Save current form if available
    Get.snackbar('حفظ', 'لا يوجد نموذج للحفظ حالياً');
  }

  // Public methods
  void enableShortcuts() {
    isEnabled.value = true;
  }

  void disableShortcuts() {
    isEnabled.value = false;
  }

  void toggleShortcuts() {
    isEnabled.value = !isEnabled.value;
  }

  Map<LogicalKeyboardKey, String> getShortcutDescriptions() {
    return {
      LogicalKeyboardKey.digit1: 'الصفحة الرئيسية (1)',
      LogicalKeyboardKey.digit2: 'الأفلام (2)',
      LogicalKeyboardKey.digit3: 'المسلسلات (3)',
      LogicalKeyboardKey.digit4: 'الإعلانات (4)',
      LogicalKeyboardKey.digit5: 'المستخدمون (5)',
      LogicalKeyboardKey.digit6: 'الفئات (6)',
      LogicalKeyboardKey.digit7: 'التقارير (7)',
      LogicalKeyboardKey.digit8: 'الإعدادات (8)',
      LogicalKeyboardKey.digit9: 'الأجهزة (9)',
      LogicalKeyboardKey.keyR: 'تحديث الصفحة (R)',
      LogicalKeyboardKey.keyN: 'الإشعارات (N)',
      LogicalKeyboardKey.escape: 'إغلاق (Esc)',
      LogicalKeyboardKey.keyH: 'الرئيسية (H)',
      LogicalKeyboardKey.keyL: 'تسجيل الخروج (L)',
      LogicalKeyboardKey.keyF: 'البحث (Ctrl+F)',
      LogicalKeyboardKey.keyS: 'الحفظ (Ctrl+S)',
    };
  }

  String getShortcutString(LogicalKeyboardKey key) {
    switch (key) {
      case LogicalKeyboardKey.digit1:
        return '1';
      case LogicalKeyboardKey.digit2:
        return '2';
      case LogicalKeyboardKey.digit3:
        return '3';
      case LogicalKeyboardKey.digit4:
        return '4';
      case LogicalKeyboardKey.digit5:
        return '5';
      case LogicalKeyboardKey.digit6:
        return '6';
      case LogicalKeyboardKey.digit7:
        return '7';
      case LogicalKeyboardKey.digit8:
        return '8';
      case LogicalKeyboardKey.digit9:
        return '9';
      case LogicalKeyboardKey.keyR:
        return 'R';
      case LogicalKeyboardKey.keyN:
        return 'N';
      case LogicalKeyboardKey.escape:
        return 'Esc';
      case LogicalKeyboardKey.keyH:
        return 'H';
      case LogicalKeyboardKey.keyL:
        return 'L';
      case LogicalKeyboardKey.keyF:
        return 'Ctrl+F';
      case LogicalKeyboardKey.keyS:
        return 'Ctrl+S';
      default:
        return key.keyLabel;
    }
  }
}
