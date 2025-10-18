import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nashmi_admin_v2/services/supabase_service.dart';

class UsersView extends StatefulWidget {
  const UsersView({super.key});

  @override
  State<UsersView> createState() => _UsersViewState();
}

class _UsersViewState extends State<UsersView> {
  final SupabaseService supabaseService = Get.find<SupabaseService>();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة المستخدمين'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              _showAddUserDialog(context);
            },
            tooltip: 'إضافة مستخدم جديد',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search and Filter Section
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: 'بحث في المستخدمين',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {
                    // Filter functionality
                  },
                  child: const Row(
                    children: [
                      Icon(Icons.filter_list),
                      SizedBox(width: 4),
                      Text('تصفية'),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Users List
            Expanded(
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: supabaseService.getUsersStream(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Text('خطأ في تحميل البيانات: ${snapshot.error}'),
                    );
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  final users = snapshot.data ?? [];

                  if (users.isEmpty) {
                    return const Center(
                      child: Text('لا توجد مستخدمين متاحين'),
                    );
                  }

                  return RawScrollbar(
                    controller: _scrollController,
                    thumbVisibility: true,
                    thickness: 8,
                    radius: const Radius.circular(8),
                    trackVisibility: true,
                    interactive: true,
                    scrollbarOrientation: ScrollbarOrientation.right,
                    child: ListView.builder(
                      controller: _scrollController,
                      itemCount: users.length,
                      itemBuilder: (context, index) {
                        final user = users[index];

                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: const Icon(Icons.person, size: 40),
                            title: Text(
                              user['name'] ?? 'بدون اسم',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user['email'] ?? 'بدون بريد إلكتروني',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'الحالة: ${_getStatusText(user['status'])}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: _getStatusColor(user['status']),
                                  ),
                                ),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.blue),
                                  onPressed: () {
                                    _showEditUserDialog(context, user['id'], user);
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () {
                                    _showDeleteConfirmation(context, user['id']);
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getStatusText(String? status) {
    switch (status) {
      case 'active':
        return 'نشط';
      case 'banned':
        return 'محظور';
      case 'inactive':
        return 'غير نشط';
      default:
        return 'غير محدد';
    }
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'active':
        return Colors.green;
      case 'banned':
        return Colors.red;
      case 'inactive':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  void _showAddUserDialog(BuildContext context) {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    String selectedStatus = 'active';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('إضافة مستخدم جديد'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'اسم المستخدم',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'البريد الإلكتروني',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedStatus,
                  decoration: const InputDecoration(
                    labelText: 'حالة الحساب',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'active',
                      child: Text('نشط'),
                    ),
                    DropdownMenuItem(
                      value: 'inactive',
                      child: Text('غير نشط'),
                    ),
                    DropdownMenuItem(
                      value: 'banned',
                      child: Text('محظور'),
                    ),
                  ],
                  onChanged: (value) {
                    selectedStatus = value!;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isEmpty || 
                    emailController.text.isEmpty) {
                  Get.snackbar('خطأ', 'يرجى ملء جميع الحقول');
                  return;
                }

                try {
                  final userData = {
                    'name': nameController.text,
                    'email': emailController.text,
                    'status': selectedStatus,
                    'createdAt': DateTime.now().toIso8601String(),
                    'updatedAt': DateTime.now().toIso8601String(),
                  };

                  await supabaseService.addUser(userData);
                  Get.back();
                  Get.snackbar('نجاح', 'تم إضافة المستخدم بنجاح');
                } catch (e) {
                  Get.snackbar('خطأ', 'فشل إضافة المستخدم: $e');
                }
              },
              child: const Text('إضافة'),
            ),
          ],
        );
      },
    );
  }

  void _showEditUserDialog(BuildContext context, String userId, Map<String, dynamic> data) {
    final nameController = TextEditingController(text: data['name']);
    final emailController = TextEditingController(text: data['email']);
    String selectedStatus = data['status'] ?? 'active';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('تعديل المستخدم'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'اسم المستخدم',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'البريد الإلكتروني',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedStatus,
                  decoration: const InputDecoration(
                    labelText: 'حالة الحساب',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'active',
                      child: Text('نشط'),
                    ),
                    DropdownMenuItem(
                      value: 'inactive',
                      child: Text('غير نشط'),
                    ),
                    DropdownMenuItem(
                      value: 'banned',
                      child: Text('محظور'),
                    ),
                  ],
                  onChanged: (value) {
                    selectedStatus = value!;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isEmpty || emailController.text.isEmpty) {
                  Get.snackbar('خطأ', 'يرجى ملء جميع الحقول');
                  return;
                }

                try {
                  final userData = {
                    'name': nameController.text,
                    'email': emailController.text,
                    'status': selectedStatus,
                    'updatedAt': DateTime.now().toIso8601String(),
                  };

                  await supabaseService.updateUser(userId, userData);
                  Get.back();
                  Get.snackbar('نجاح', 'تم تعديل المستخدم بنجاح');
                } catch (e) {
                  Get.snackbar('خطأ', 'فشل تعديل المستخدم: $e');
                }
              },
              child: const Text('حفظ'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmation(BuildContext context, String userId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('تأكيد الحذف'),
          content: const Text('هل أنت متأكد من حذف هذا المستخدم؟'),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () {
                supabaseService.deleteUser(userId);
                Get.back();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text('حذف'),
            ),
          ],
        );
      },
    );
  }
}
