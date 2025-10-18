import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nashmi_admin_v2/services/supabase_service.dart';
import 'package:nashmi_admin_v2/services/auth_service.dart';
import 'package:nashmi_admin_v2/views/ads/ads_complete_form.dart';

class AdsViewEnhanced extends StatefulWidget {
  const AdsViewEnhanced({super.key});

  @override
  State<AdsViewEnhanced> createState() => _AdsViewEnhancedState();
}

class _AdsViewEnhancedState extends State<AdsViewEnhanced> {
  final SupabaseService supabaseService = Get.find<SupabaseService>();
  final AuthService authService = Get.find<AuthService>();
  final TextEditingController searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  String? selectedAdType;
  bool showInactive = false;

  @override
  void initState() {
    super.initState();
    searchController.addListener(() {
      setState(() {});
    });
  }

  List<Map<String, dynamic>> filterAds(List<Map<String, dynamic>> ads) {
    return ads.where((ad) {
      final matchesSearch = searchController.text.isEmpty ||
          ad['title']?.toString().toLowerCase().contains(searchController.text.toLowerCase()) == true;

      final matchesType = selectedAdType == null ||
          ad['adtype'] == selectedAdType;

      final matchesActiveStatus = showInactive ? true : ad['is_active'] == true;

      return matchesSearch && matchesType && matchesActiveStatus;
    }).toList();
  }

  void showAddEditAdDialog({Map<String, dynamic>? ad}) async {
    print("Opening add/edit dialog");
    final result = await Get.dialog<bool>(
      AdsCompleteForm(ad: ad),
    );
    print("Dialog closed with result: $result");
    // No need to reload, stream will update automatically
  }

  Future<void> toggleAdStatus(String adId, bool currentStatus) async {
    try {
      await supabaseService.updateAd(adId, {
        'is_active': !currentStatus,
      });

      // No need to reload, stream will update automatically

      Get.snackbar(
        'نجاح',
        'تم تغيير حالة الإعلان',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'فشل في تغيير الحالة: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> deleteAd(String adId) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: const Text('هل أنت متأكد من حذف هذا الإعلان؟'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('حذف'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await supabaseService.deleteAd(adId);
      // No need to reload, stream will update automatically

      Get.snackbar(
        'نجاح',
        'تم حذف الإعلان بنجاح',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'فشل في حذف الإعلان: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة الإعلانات'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => showAddEditAdDialog(),
            tooltip: 'إضافة إعلان جديد',
          ),
          // Real-time updates, no need for manual refresh
        ],
      ),
      body: Column(
        children: [
          // Search and Filter Bar
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: searchController,
                    decoration: const InputDecoration(
                      labelText: 'البحث في العناوين',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    // Listener in initState handles rebuild
                  ),
                ),
                const SizedBox(width: 8),
                Checkbox(
                  value: showInactive,
                  onChanged: (value) {
                    setState(() => showInactive = value ?? false);
                  },
                ),
                const Text('عرض غير النشط'),
              ],
            ),
          ),
          // Ads Table
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: supabaseService.watchAds(),
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

                final ads = snapshot.data ?? [];
                final filteredAds = filterAds(ads);

                if (filteredAds.isEmpty) {
                  return const Center(child: Text('لا توجد إعلانات متاحة'));
                }

                return SizedBox(
                  height: MediaQuery.of(context).size.height * 0.6,
                  child: Scrollbar(
                    controller: _scrollController,
                    thumbVisibility: true,
                    trackVisibility: true,
                    thickness: 16,
                    radius: const Radius.circular(8),
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(8.0),
                      itemCount: filteredAds.length,
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                      final ad = filteredAds[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12.0),
                        elevation: 4.0,
                        color: Colors.red.shade100,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Header with title and status
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      ad['title'] ?? 'بدون عنوان',
                                      style: const TextStyle(
                                        fontSize: 18.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0,
                                      vertical: 4.0,
                                    ),
                                    decoration: BoxDecoration(
                                      color: ad['is_active'] == true
                                          ? Colors.green
                                          : Colors.red,
                                      borderRadius: BorderRadius.circular(12.0),
                                    ),
                                    child: Text(
                                      ad['is_active'] == true ? 'نشط' : 'غير نشط',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12.0),
                              // Ad details in a grid-like layout
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'نوع الإعلان: ${ad['adtype'] ?? 'غير محدد'}',
                                          style: const TextStyle(
                                            fontSize: 14.0,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        const SizedBox(height: 4.0),
                                        Text(
                                          'التكرار: ${ad['frequency'] ?? '0'} دقيقة',
                                          style: const TextStyle(
                                            fontSize: 14.0,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 16.0),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'معرف التطبيق:',
                                          style: const TextStyle(
                                            fontSize: 12.0,
                                            color: Colors.grey,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          ad['adMobAppId'] ?? '-',
                                          style: const TextStyle(
                                            fontSize: 12.0,
                                            color: Colors.black87,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4.0),
                                        Text(
                                          'معرف الوحدة:',
                                          style: const TextStyle(
                                            fontSize: 12.0,
                                            color: Colors.grey,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          ad['adUnitId'] ?? '-',
                                          style: const TextStyle(
                                            fontSize: 12.0,
                                            color: Colors.black87,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16.0),
                              // Action buttons
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  TextButton.icon(
                                    onPressed: () => showAddEditAdDialog(ad: ad),
                                    icon: const Icon(Icons.edit, size: 18.0),
                                    label: const Text('تعديل'),
                                    style: TextButton.styleFrom(
                                      foregroundColor: Colors.blue,
                                    ),
                                  ),
                                  const SizedBox(width: 8.0),
                                  TextButton.icon(
                                    onPressed: () => deleteAd(ad['id']),
                                    icon: const Icon(Icons.delete, size: 18.0),
                                    label: const Text('حذف'),
                                    style: TextButton.styleFrom(
                                      foregroundColor: Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
