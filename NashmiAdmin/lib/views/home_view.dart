import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nashmi_admin_v2/services/statistics_service.dart';
import 'package:nashmi_admin_v2/services/notification_service.dart';
import 'package:nashmi_admin_v2/services/keyboard_shortcuts_service.dart';
import 'package:nashmi_admin_v2/widgets/statistics_card.dart';
import 'package:nashmi_admin_v2/widgets/notification_widget.dart';
import 'package:nashmi_admin_v2/widgets/keyboard_shortcuts_widget.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final StatisticsService _statisticsService = Get.find<StatisticsService>();
    final NotificationService _notificationService = Get.find<NotificationService>();
    final ScrollController _scrollController = ScrollController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('نشمي - لوحة التحكم التفاعلية'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          // Notifications Button
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications),
                onPressed: () {
                  _showNotificationsDialog(context, _notificationService);
                },
                tooltip: 'الإشعارات',
              ),
              Obx(() => _notificationService.unreadCount.value > 0
                ? Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: Center(
                        child: Text(
                          _notificationService.unreadCount.value > 9
                            ? '9+'
                            : _notificationService.unreadCount.value.toString(),
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
              ),
            ],
          ),
          // Keyboard Shortcuts Button
          IconButton(
            icon: const Icon(Icons.keyboard),
            onPressed: () {
              showKeyboardShortcutsDialog(context);
            },
            tooltip: 'اختصارات لوحة المفاتيح',
          ),
          // Quick Actions Menu
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'refresh':
                  _statisticsService.loadStatistics();
                  Get.snackbar('تحديث', 'جاري تحديث البيانات...');
                  break;
                case 'settings':
                  Get.toNamed('/settings');
                  break;
                case 'reports':
                  Get.toNamed('/reports');
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'refresh',
                child: Row(
                  children: [
                    Icon(Icons.refresh, size: 18),
                    SizedBox(width: 8),
                    Text('تحديث البيانات'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings, size: 18),
                    SizedBox(width: 8),
                    Text('الإعدادات'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'reports',
                child: Row(
                  children: [
                    Icon(Icons.bar_chart, size: 18),
                    SizedBox(width: 8),
                    Text('التقارير'),
                  ],
                ),
              ),
            ],
          ),
          // Logout Button
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Get.offAllNamed('/login');
            },
            tooltip: 'تسجيل الخروج',
          ),
        ],
      ),
      body: GetX<StatisticsService>(
        builder: (controller) => Scrollbar(
          controller: _scrollController,
          thumbVisibility: true,
          thickness: 8,
          radius: const Radius.circular(8),
          trackVisibility: true,
          interactive: true,
          scrollbarOrientation: ScrollbarOrientation.right,
          child: SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome Section
                _buildWelcomeSection(),

                const SizedBox(height: 32),

                // Statistics Cards
                controller.isLoading.value
                  ? const Center(child: CircularProgressIndicator())
                  : _buildStatisticsSection(controller),

                const SizedBox(height: 32),

                // Quick Actions Grid
                _buildQuickActionsSection(),

                const SizedBox(height: 32),

                // Recent Activities
                _buildRecentActivitiesSection(controller),

                const SizedBox(height: 32),

                // System Health
                _buildSystemHealthSection(controller),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showNotificationsDialog(BuildContext context, NotificationService notificationService) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('الإشعارات'),
          content: SizedBox(
            width: double.maxFinite,
            child: Obx(() => notificationService.notifications.isEmpty
              ? const Text('لا توجد إشعارات')
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: notificationService.notifications.length,
                  itemBuilder: (context, index) {
                    final notification = notificationService.notifications[index];
                    return ListTile(
                      leading: Icon(
                        _getNotificationIcon(notification.type),
                        color: _getNotificationColor(notification.type),
                      ),
                      title: Text(notification.title),
                      subtitle: Text(notification.message),
                      trailing: notification.isRead
                        ? const Icon(Icons.check_circle, color: Colors.green)
                        : const Icon(Icons.circle, color: Colors.red),
                      onTap: () {
                        if (!notification.isRead) {
                          notificationService.markAsRead(notification.id);
                        }
                      },
                    );
                  },
                ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                notificationService.markAllAsRead();
                Navigator.of(context).pop();
              },
              child: const Text('تحديد الكل كمقروء'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('إغلاق'),
            ),
          ],
        );
      },
    );
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

  Widget _buildWelcomeSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.teal, Colors.teal.shade700],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.dashboard,
                color: Colors.white,
                size: 32,
              ),
              const SizedBox(width: 16),
              const Text(
                'مرحباً بك في لوحة تحكم نشمي التفاعلية',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'إدارة شاملة ومتقدمة لجميع جوانب النظام',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: 16),
          Builder(
            builder: (context) {
              final now = DateTime.now();
              return Text(
                'آخر تحديث: ${now.hour}:${now.minute.toString().padLeft(2, '0')}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.8),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsSection(StatisticsService controller) {
    final stats = controller.getQuickStats();
    final growth = controller.getGrowthIndicators();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'إحصائيات سريعة',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: _getGridCrossAxisCount(),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            StatisticsCard(
              title: 'الأفلام',
              value: stats['movies'].toString(),
              change: growth['movies_growth'],
              icon: Icons.movie,
              color: Colors.blue,
              onTap: () => Get.toNamed('/movies'),
            ),
            StatisticsCard(
              title: 'المسلسلات',
              value: stats['series'].toString(),
              change: growth['series_growth'],
              icon: Icons.tv,
              color: Colors.green,
              onTap: () => Get.toNamed('/series'),
            ),
            StatisticsCard(
              title: 'المستخدمون',
              value: stats['users'].toString(),
              change: growth['users_growth'],
              icon: Icons.people,
              color: Colors.purple,
              onTap: () => Get.toNamed('/users'),
            ),
            StatisticsCard(
              title: 'الإعلانات النشطة',
              value: stats['ads'].toString(),
              change: growth['ads_growth'],
              icon: Icons.campaign,
              color: Colors.orange,
              onTap: () => Get.toNamed('/ads'),
            ),
            StatisticsCard(
              title: 'إجمالي المحتوى',
              value: stats['total_content'].toString(),
              icon: Icons.library_books,
              color: Colors.teal,
            ),
            StatisticsCard(
              title: 'حالة النظام',
              value: '${stats['system_health'].toStringAsFixed(1)}%',
              icon: Icons.health_and_safety,
              color: stats['system_health'] > 90 ? Colors.green : Colors.orange,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'الإجراءات السريعة',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: _getGridCrossAxisCount(),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _buildActionCard(
              'إضافة فيلم',
              Icons.add,
              Colors.blue,
              () => Get.toNamed('/movies'),
            ),
            _buildActionCard(
              'إضافة مسلسل',
              Icons.add,
              Colors.green,
              () => Get.toNamed('/series'),
            ),
            _buildActionCard(
              'إدارة الإعلانات',
              Icons.campaign,
              Colors.orange,
              () => Get.toNamed('/ads'),
            ),
            _buildActionCard(
              'إدارة المستخدمين',
              Icons.people,
              Colors.purple,
              () => Get.toNamed('/users'),
            ),
            _buildActionCard(
              'الفئات',
              Icons.category,
              Colors.teal,
              () => Get.toNamed('/categories'),
            ),
            _buildActionCard(
              'التقارير',
              Icons.bar_chart,
              Colors.red,
              () => Get.toNamed('/reports'),
            ),
            _buildActionCard(
              'الإعدادات',
              Icons.settings,
              Colors.grey,
              () => Get.toNamed('/settings'),
            ),
            _buildActionCard(
              'الأجهزة',
              Icons.build,
              Colors.brown,
              () => Get.toNamed('/hardware'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRecentActivitiesSection(StatisticsService controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'الأنشطة الأخيرة',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        controller.recentActivities.isEmpty
          ? const Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('لا توجد أنشطة حديثة'),
              ),
            )
          : ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.recentActivities.take(5).length,
              itemBuilder: (context, index) {
                final activity = controller.recentActivities[index];
                return Card(
                  child: ListTile(
                    leading: Icon(
                      activity['type'] == 'movie' ? Icons.movie :
                      activity['type'] == 'series' ? Icons.tv :
                      Icons.campaign,
                      color: activity['type'] == 'movie' ? Colors.blue :
                             activity['type'] == 'series' ? Colors.green :
                             Colors.orange,
                    ),
                    title: Text(activity['title'] ?? 'نشاط جديد'),
                    subtitle: Text(_formatActivityDate(activity['createdat'])),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Colors.grey[400],
                    ),
                    onTap: () {
                      // Navigate to relevant section
                      switch (activity['type']) {
                        case 'movie':
                          Get.toNamed('/movies');
                          break;
                        case 'series':
                          Get.toNamed('/series');
                          break;
                        case 'ad':
                          Get.toNamed('/ads');
                          break;
                      }
                    },
                  ),
                );
              },
            ),
      ],
    );
  }

  Widget _buildSystemHealthSection(StatisticsService controller) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'حالة النظام',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('الصحة العامة'),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: controller.systemHealth.value / 100,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          controller.systemHealth.value > 90
                            ? Colors.green
                            : controller.systemHealth.value > 70
                              ? Colors.orange
                              : Colors.red,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${controller.systemHealth.value.toStringAsFixed(1)}% صحة النظام',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Icon(
                  controller.systemHealth.value > 90
                    ? Icons.check_circle
                    : controller.systemHealth.value > 70
                      ? Icons.warning
                      : Icons.error,
                  color: controller.systemHealth.value > 90
                    ? Colors.green
                    : controller.systemHealth.value > 70
                      ? Colors.orange
                      : Colors.red,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: color.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 32,
                color: color,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  int _getGridCrossAxisCount() {
    // Use MediaQuery to get screen size safely
    final context = Get.context;
    if (context == null) return 2; // Default fallback

    final width = MediaQuery.of(context).size.width;
    if (width > 1200) return 4;
    if (width > 800) return 3;
    if (width > 600) return 2;
    return 1;
  }

  String _formatActivityDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays > 0) {
        return 'قبل ${difference.inDays} يوم';
      } else if (difference.inHours > 0) {
        return 'قبل ${difference.inHours} ساعة';
      } else if (difference.inMinutes > 0) {
        return 'قبل ${difference.inMinutes} دقيقة';
      } else {
        return 'الآن';
      }
    } catch (e) {
      return 'تاريخ غير محدد';
    }
  }
}
