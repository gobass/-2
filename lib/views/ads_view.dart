import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/supabase_service.dart';

class AdsView extends StatefulWidget {
  const AdsView({super.key});

  @override
  State<AdsView> createState() => _AdsViewState();
}

class _AdsViewState extends State<AdsView> {
  final SupabaseService _supabaseService = Get.find<SupabaseService>();
  final TextEditingController _searchController = TextEditingController();
  
  List<Map<String, dynamic>> _ads = [];
  List<Map<String, dynamic>> _filteredAds = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadAds();
  }

  Future<void> _loadAds() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final ads = await _supabaseService.getAllAds();
      setState(() {
        _ads = ads;
        _filteredAds = ads;
        _isLoading = false;
      });
    } catch (e) {
      Get.snackbar('خطأ', 'فشل في تحميل الإعلانات: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _filterAds(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredAds = _ads;
      } else {
        _filteredAds = _ads.where((ad) {
          final appId = ad['app_id']?.toString().toLowerCase() ?? '';
          final adUnitId = ad['ad_unit_id']?.toString().toLowerCase() ?? '';
          final adType = ad['ad_type']?.toString().toLowerCase() ?? '';
          return appId.contains(query.toLowerCase()) || 
                 adUnitId.contains(query.toLowerCase()) ||
                 adType.contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  void _showAddAdDialog() {
    final appIdController = TextEditingController();
    final adUnitIdController = TextEditingController();
    final adTypeController = TextEditingController();
    final isActiveController = TextEditingController(text: 'true');

    Get.dialog(
      AlertDialog(
        title: const Text('إضافة إعلان جديد'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: appIdController,
                decoration: const InputDecoration(
                  labelText: 'معرف التطبيق (App ID)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: adUnitIdController,
                decoration: const InputDecoration(
                  labelText: 'معرف الإعلان (Ad Unit ID)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'نوع الإعلان',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'banner', child: Text('بانر')),
                  DropdownMenuItem(value: 'interstitial', child: Text('إعلان كامل')),
                  DropdownMenuItem(value: 'rewarded', child: Text('إعلان مكافأة')),
                ],
                onChanged: (value) {
                  adTypeController.text = value ?? '';
                },
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'الحالة',
                  border: OutlineInputBorder(),
                ),
                value: 'true',
                items: const [
                  DropdownMenuItem(value: 'true', child: Text('نشط')),
                  DropdownMenuItem(value: 'false', child: Text('غير نشط')),
                ],
                onChanged: (value) {
                  isActiveController.text = value ?? 'true';
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
              if (appIdController.text.isEmpty || adUnitIdController.text.isEmpty || adTypeController.text.isEmpty) {
                Get.snackbar('خطأ', 'جميع الحقول مطلوبة');
                return;
              }

              try {
                final adData = {
                  'app_id': appIdController.text,
                  'ad_unit_id': adUnitIdController.text,
                  'ad_type': adTypeController.text,
                  'is_active': isActiveController.text == 'true',
                  'created_at': DateTime.now().toIso8601String(),
                };

                await _supabaseService.addAd(adData);
                Get.back();
                Get.snackbar('نجاح', 'تم إضافة الإعلان بنجاح');
                _loadAds();
              } catch (e) {
                Get.snackbar('خطأ', 'فشل في إضافة الإعلان: $e');
              }
            },
            child: const Text('إضافة'),
          ),
        ],
      ),
    );
  }

  void _showEditAdDialog(Map<String, dynamic> ad) {
    final appIdController = TextEditingController(text: ad['app_id']?.toString());
    final adUnitIdController = TextEditingController(text: ad['ad_unit_id']?.toString());
    final adTypeController = TextEditingController(text: ad['ad_type']?.toString());
    final isActiveController = TextEditingController(text: ad['is_active']?.toString() ?? 'true');

    Get.dialog(
      AlertDialog(
        title: const Text('تعديل الإعلان'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: appIdController,
                decoration: const InputDecoration(
                  labelText: 'معرف التطبيق (App ID)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: adUnitIdController,
                decoration: const InputDecoration(
                  labelText: 'معرف الإعلان (Ad Unit ID)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'نوع الإعلان',
                  border: OutlineInputBorder(),
                ),
                value: ad['ad_type']?.toString(),
                items: const [
                  DropdownMenuItem(value: 'banner', child: Text('بانر')),
                  DropdownMenuItem(value: 'interstitial', child: Text('إعلان كامل')),
                  DropdownMenuItem(value: 'rewarded', child: Text('إعلان مكافأة')),
                ],
                onChanged: (value) {
                  adTypeController.text = value ?? '';
                },
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'الحالة',
                  border: OutlineInputBorder(),
                ),
                value: ad['is_active']?.toString() ?? 'true',
                items: const [
                  DropdownMenuItem(value: 'true', child: Text('نشط')),
                  DropdownMenuItem(value: 'false', child: Text('غير نشط')),
                ],
                onChanged: (value) {
                  isActiveController.text = value ?? 'true';
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
              if (appIdController.text.isEmpty || adUnitIdController.text.isEmpty || adTypeController.text.isEmpty) {
                Get.snackbar('خطأ', 'جميع الحقول مطلوبة');
                return;
              }

              try {
                final adData = {
                  'app_id': appIdController.text,
                  'ad_unit_id': adUnitIdController.text,
                  'ad_type': adTypeController.text,
                  'is_active': isActiveController.text == 'true',
                };

                await _supabaseService.updateAd(ad['id'].toString(), adData);
                Get.back();
                Get.snackbar('نجاح', 'تم تعديل الإعلان بنجاح');
                _loadAds();
              } catch (e) {
                Get.snackbar('خطأ', 'فشل في تعديل الإعلان: $e');
              }
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(Map<String, dynamic> ad) {
    Get.dialog(
      AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Text('هل تريد حذف الإعلان "${ad['ad_unit_id']}"؟'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await _supabaseService.deleteAd(ad['id'].toString());
                Get.back();
                Get.snackbar('نجاح', 'تم حذف الإعلان بنجاح');
                _loadAds();
              } catch (e) {
                Get.snackbar('خطأ', 'فشل في حذف الإعلان: $e');
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة الإعلانات'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAds,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'بحث في الإعلانات',
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _filterAds('');
                        },
                      )
                    : null,
              ),
              onChanged: _filterAds,
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredAds.isEmpty
                    ? const Center(
                        child: Text(
                          'لا توجد إعلانات',
                          style: TextStyle(fontSize: 18),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _filteredAds.length,
                        itemBuilder: (context, index) {
                          final ad = _filteredAds[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 4),
                            child: ListTile(
                              title: Text(ad['ad_unit_id']?.toString() ?? 'بدون معرف'),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('التطبيق: ${ad['app_id'] ?? 'غير محدد'}'),
                                  Text('النوع: ${_getAdTypeName(ad['ad_type'])}'),
                                  Text('الحالة: ${ad['is_active'] == true ? 'نشط' : 'غير نشط'}'),
                                  if (ad['created_at'] != null)
                                    Text('تاريخ الإضافة: ${_formatDate(ad['created_at'])}'),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit, color: Colors.blue),
                                    onPressed: () => _showEditAdDialog(ad),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => _showDeleteConfirmation(ad),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddAdDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  String _getAdTypeName(String? adType) {
    switch (adType) {
      case 'banner':
        return 'بانر';
      case 'interstitial':
        return 'إعلان كامل';
      case 'rewarded':
        return 'إعلان مكافأة';
      default:
        return adType ?? 'غير محدد';
    }
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'غير محدد';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'غير محدد';
    }
  }
}
