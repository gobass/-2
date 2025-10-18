import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nashmi_admin_v2/services/supabase_service.dart';

enum NotificationType {
  success,
  error,
  warning,
  info,
}

enum NotificationPriority {
  low,
  medium,
  high,
  urgent,
}

class AppNotification {
  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final NotificationPriority priority;
  final DateTime timestamp;
  final bool isRead;
  final String? actionUrl;
  final Map<String, dynamic>? metadata;

  AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    this.priority = NotificationPriority.medium,
    DateTime? timestamp,
    this.isRead = false,
    this.actionUrl,
    this.metadata,
  }) : timestamp = timestamp ?? DateTime.now();

  AppNotification copyWith({
    String? id,
    String? title,
    String? message,
    NotificationType? type,
    NotificationPriority? priority,
    DateTime? timestamp,
    bool? isRead,
    String? actionUrl,
    Map<String, dynamic>? metadata,
  }) {
    return AppNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      actionUrl: actionUrl ?? this.actionUrl,
      metadata: metadata ?? this.metadata,
    );
  }
}

class NotificationService extends GetxService {
  final SupabaseService _supabaseService = Get.find<SupabaseService>();

  // Observable notifications
  final RxList<AppNotification> notifications = <AppNotification>[].obs;
  final RxInt unreadCount = 0.obs;

  // Notification settings
  final RxBool enableSound = true.obs;
  final RxBool enableVibration = true.obs;
  final RxBool showOnLockScreen = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadNotifications();
    startNotificationChecker();
  }

  void startNotificationChecker() {
    // Check for new notifications every 10 seconds
    Future.delayed(const Duration(seconds: 10), () {
      checkForNewNotifications();
      startNotificationChecker();
    });
  }

  Future<void> loadNotifications() async {
    try {
      // Load notifications from database
      // For now, we'll use mock data until we implement the notifications table
      _loadMockNotifications();
    } catch (e) {
      print('Error loading notifications: $e');
      _loadMockNotifications();
    }
  }

  void _loadMockNotifications() {
    notifications.assignAll([
      AppNotification(
        id: '1',
        title: 'تحديث جديد',
        message: 'تم إضافة 5 أفلام جديدة للمراجعة',
        type: NotificationType.info,
        priority: NotificationPriority.medium,
        metadata: {'count': 5, 'type': 'movies'},
      ),
      AppNotification(
        id: '2',
        title: 'تنبيه أمان',
        message: 'محاولة دخول مشبوهة من IP: 192.168.1.100',
        type: NotificationType.warning,
        priority: NotificationPriority.high,
      ),
      AppNotification(
        id: '3',
        title: 'نجح العملية',
        message: 'تم حفظ جميع التغييرات بنجاح',
        type: NotificationType.success,
        priority: NotificationPriority.low,
        isRead: true,
      ),
    ]);

    updateUnreadCount();
  }

  Future<void> checkForNewNotifications() async {
    try {
      // Check for new activities that should generate notifications
      final recentActivities = await _supabaseService.getRecentActivities();

      // Generate notifications based on recent activities
      for (final activity in recentActivities.take(5)) {
        if (!notifications.any((n) => n.metadata?['activity_id'] == activity['id'])) {
          await addNotificationFromActivity(activity);
        }
      }
    } catch (e) {
      print('Error checking for new notifications: $e');
    }
  }

  Future<void> addNotificationFromActivity(Map<String, dynamic> activity) async {
    String title = '';
    String message = '';
    NotificationType type = NotificationType.info;

    switch (activity['type']) {
      case 'movie':
        title = 'فيلم جديد';
        message = 'تم إضافة فيلم: ${activity['title'] ?? 'غير معروف'}';
        type = NotificationType.success;
        break;
      case 'series':
        title = 'مسلسل جديد';
        message = 'تم إضافة مسلسل: ${activity['title'] ?? 'غير معروف'}';
        type = NotificationType.success;
        break;
      case 'ad':
        title = 'إعلان جديد';
        message = 'تم إضافة إعلان جديد للمراجعة';
        type = NotificationType.info;
        break;
      default:
        title = 'نشاط جديد';
        message = 'تم إجراء نشاط جديد في النظام';
    }

    final notification = AppNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      message: message,
      type: type,
      metadata: {'activity_id': activity['id'], 'activity_type': activity['type']},
    );

    await addNotification(notification);
  }

  Future<void> addNotification(AppNotification notification) async {
    notifications.insert(0, notification);
    updateUnreadCount();

    // Show in-app notification
    _showInAppNotification(notification);

    // In real implementation, save to database
    // await _supabaseService.saveNotification(notification);
  }

  void _showInAppNotification(AppNotification notification) {
    Get.snackbar(
      notification.title,
      notification.message,
      backgroundColor: _getNotificationColor(notification.type),
      colorText: Colors.white,
      duration: const Duration(seconds: 4),
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(8),
      borderRadius: 8,
      icon: Icon(
        _getNotificationIcon(notification.type),
        color: Colors.white,
      ),
    );
  }

  Color _getNotificationColor(NotificationType type) {
    switch (type) {
      case NotificationType.success:
        return Colors.green;
      case NotificationType.error:
        return Colors.red;
      case NotificationType.warning:
        return Colors.orange;
      case NotificationType.info:
        return Colors.blue;
    }
  }

  IconData _getNotificationIcon(NotificationType type) {
    switch (type) {
      case NotificationType.success:
        return Icons.check_circle;
      case NotificationType.error:
        return Icons.error;
      case NotificationType.warning:
        return Icons.warning;
      case NotificationType.info:
        return Icons.info;
    }
  }

  void markAsRead(String notificationId) {
    final index = notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      notifications[index] = notifications[index].copyWith(isRead: true);
      updateUnreadCount();
    }
  }

  void markAllAsRead() {
    for (int i = 0; i < notifications.length; i++) {
      notifications[i] = notifications[i].copyWith(isRead: true);
    }
    updateUnreadCount();
  }

  void deleteNotification(String notificationId) {
    notifications.removeWhere((n) => n.id == notificationId);
    updateUnreadCount();
  }

  void clearAllNotifications() {
    notifications.clear();
    unreadCount.value = 0;
  }

  void updateUnreadCount() {
    unreadCount.value = notifications.where((n) => !n.isRead).length;
  }

  // Get notifications by type
  List<AppNotification> getNotificationsByType(NotificationType type) {
    return notifications.where((n) => n.type == type).toList();
  }

  // Get notifications by priority
  List<AppNotification> getNotificationsByPriority(NotificationPriority priority) {
    return notifications.where((n) => n.priority == priority).toList();
  }

  // Get recent notifications (last 24 hours)
  List<AppNotification> getRecentNotifications() {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return notifications.where((n) => n.timestamp.isAfter(yesterday)).toList();
  }
}
