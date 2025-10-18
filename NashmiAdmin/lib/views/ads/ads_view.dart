import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nashmi_admin_v2/services/supabase_service.dart';
import 'package:nashmi_admin_v2/services/auth_service.dart';
import 'package:nashmi_admin_v2/widgets/banner_ad_widget.dart';
import 'package:nashmi_admin_v2/views/ads/ads_admob_form.dart';

class AdsView extends StatefulWidget {
  const AdsView({super.key});

  @override
  State<AdsView> createState() => _AdsViewState();
}

class _AdsViewState extends State<AdsView> {
  final SupabaseService supabaseService = Get.find<SupabaseService>();
  final AuthService authService = Get.find<AuthService>();
  final TextEditingController searchController = TextEditingController();

  List<Map<String, dynamic>> ads = [];
  List<Map<String, dynamic>> filteredAds = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadAds();
  }

  Future<void> loadAds() async {
    try {
      setState(() => isLoading = true);
      final response = await supabaseService.getAllAds();

      ads = List<Map<String, dynamic>>.from(response);

      filterAds();
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'فشل في تحميل الإعلانات: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  void filterAds() {
    filteredAds = ads.where((ad) {
      final matchesSearch = searchController.text.isEmpty ||
          ad['title']?.toString().toLowerCase().contains(searchController.text.toLowerCase()) == true;

      return matchesSearch;
    }).toList();
  }

  void showAdDetails(Map<String, dynamic> ad) {
    Get.dialog(
      Dialog(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ad['title'] ?? 'بدون عنوان',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                if (ad['imageUrl']?.isNotEmpty == true)
                  Image.network(
                    ad['imageUrl']!,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                const SizedBox(height: 16),
                if (ad['description']?.isNotEmpty == true)
                  Text('الوصف: ${ad['description']}'),
                const SizedBox(height: 8),
                if (ad['videoUrl']?.isNotEmpty == true)
                  Text('رابط الفيديو: ${ad['videoUrl']}'),
                const SizedBox(height: 8),
                if (ad['targetUrl']?.isNotEmpty == true)
                  Text('رابط الهدف: ${ad['targetUrl']}'),
                const SizedBox(height: 8),
                Text('تاريخ البداية: ${ad['start_at'] ?? 'غير محدد'}'),
                Text('تاريخ النهاية: ${ad['end_at'] ?? 'غير محدد'}'),
                const SizedBox(height: 8),
                Text('نشط: ${ad['is_active'] == true ? 'نعم' : 'لا'}'),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: Get.back,
                      child: const Text('إغلاق'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void showAddEditAdDialog({Map<String, dynamic>? ad}) async {
    final result = await Get.dialog<bool>(AdsAdmobForm(ad: ad));
    if (result == true) {
      await loadAds();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة الإعلانات'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: loadAds,
            tooltip: 'تحديث',
          ),
        ],
      ),
      body: Column(
        children: [
          const BannerAdWidget(),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: searchController,
                    decoration: const InputDecoration(
                      labelText: 'بحث بالإعلانات',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (_) => filterAds(),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () => showAddEditAdDialog(),
                  icon: const Icon(Icons.add),
                  label: const Text('إضافة إعلان جديد'),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          SizedBox(
            height: MediaQuery.of(context).size.height * 0.6, // Fixed height for table
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredAds.isEmpty
                    ? const Center(child: Text('لا توجد إعلانات'))
                    : Scrollbar(
                        thumbVisibility: true,
                        thickness: 8,
                        radius: const Radius.circular(8),
                        trackVisibility: true,
                        interactive: true,
                        scrollbarOrientation: ScrollbarOrientation.right,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            columns: const [
                              DataColumn(label: Text('الصورة')),
                              DataColumn(label: Text('العنوان')),
                              DataColumn(label: Text('تاريخ البداية')),
                              DataColumn(label: Text('تاريخ النهاية')),
                              DataColumn(label: Text('نشط')),
                              DataColumn(label: Text('الإجراءات')),
                            ],
                            rows: filteredAds.map((ad) {
                              return DataRow(cells: [
                                DataCell(
                                  ad['imageUrl']?.isNotEmpty == true
                                      ? Image.network(
                                          ad['imageUrl']!,
                                          width: 60,
                                          height: 60,
                                          fit: BoxFit.cover,
                                        )
                                      : const Icon(Icons.ad_units),
                                ),
                                DataCell(Text(ad['title'] ?? 'بدون عنوان')),
                                DataCell(Text(ad['start_at'] ?? '')),
                                DataCell(Text(ad['end_at'] ?? '')),
                                    DataCell(Text(ad['is_active'] == true ? 'نعم' : 'لا')),
                                DataCell(Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.visibility, size: 20),
                                      onPressed: () => showAdDetails(ad),
                                      tooltip: 'عرض التفاصيل',
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.edit, size: 20),
                                      onPressed: () => showAddEditAdDialog(ad: ad),
                                      tooltip: 'تعديل',
                                    ),
                                  ],
                                )),
                              ]);
                            }).toList(),
                          ),
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
