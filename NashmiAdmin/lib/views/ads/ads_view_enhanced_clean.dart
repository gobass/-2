import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nashmi_admin_v2/services/supabase_service.dart';
import 'package:nashmi_admin_v2/services/auth_service.dart';

class AdsViewEnhancedClean extends StatefulWidget {
  const AdsViewEnhancedClean({super.key});

  @override
  State<AdsViewEnhancedClean> createState() => _AdsViewEnhancedCleanState();
}

class _AdsViewEnhancedCleanState extends State<AdsViewEnhancedClean> {
  final SupabaseService supabaseService = Get.find<SupabaseService>();
  final AuthService authService = Get.find<AuthService>();
  final TextEditingController searchController = TextEditingController();

  List<Map<String, dynamic>> ads = [];
  List<Map<String, dynamic>> filteredAds = [];
  bool isLoading = true;
  String? selectedAdType;
  bool showInactive = false;

  // Pagination variables
  int currentPage = 1;
  int itemsPerPage = 10;
  int totalPages = 0;

  @override
  void initState() {
    super.initState();
    loadAds();
  }

  Future<void> loadAds() async {
    try {
      setState(() => isLoading = true);
      final adsData = await supabaseService.getAllAds();
      ads = adsData;
      
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
    // First, filter the ads
    List<Map<String, dynamic>> tempFilteredAds = ads.where((ad) {
      final matchesSearch = searchController.text.isEmpty ||
          ad['title']?.toString().toLowerCase().contains(searchController.text.toLowerCase()) == true;

      final matchesType = selectedAdType == null ||
          ad['adType'] == selectedAdType;

      final matchesActiveStatus = showInactive ? true : ad['isActive'] == true;

      return matchesSearch && matchesType && matchesActiveStatus;
    }).toList();

    // Calculate total pages
    totalPages = (tempFilteredAds.length / itemsPerPage).ceil();
    if (currentPage > totalPages) {
      currentPage = totalPages > 0 ? totalPages : 1;
    }

    // Slice filteredAds for current page
    final startIndex = (currentPage - 1) * itemsPerPage;
    final endIndex = startIndex + itemsPerPage;
    filteredAds = tempFilteredAds.sublist(
      startIndex,
      endIndex > tempFilteredAds.length ? tempFilteredAds.length : endIndex,
    );
  }

  void changePage(int page) {
    if (page >= 1 && page <= totalPages) {
      setState(() => currentPage = page);
      filterAds();
    }
  }

  void changeItemsPerPage(int newItemsPerPage) {
    setState(() {
      itemsPerPage = newItemsPerPage;
      currentPage = 1; // Reset to first page
    });
    filterAds();
  }

  String _getAdTypeText(String? adType) {
    switch (adType) {
      case 'banner':
        return 'بانر';
      case 'interstitial':
        return 'إعلان داخلي';
      case 'rewarded':
        return 'إعلان مكافأة';
      case 'native':
        return 'إعلان أصلي';
      default:
        return 'غير محدد';
    }
  }

  String _getPositionText(String? position) {
    switch (position) {
      case 'home_top':
        return 'أعلى الصفحة الرئيسية';
      case 'player_pre':
        return 'قبل التشغيل';
      case 'player_mid':
        return 'أثناء التشغيل';
      case 'player_post':
        return 'بعد التشغيل';
      case 'footer':
        return 'أسفل الصفحة';
      default:
        return 'غير محدد';
    }
  }

  String _getProviderText(String? provider) {
    switch (provider) {
      case 'admob':
        return 'AdMob';
      case 'custom':
        return 'مخصص';
      default:
        return 'غير محدد';
    }
  }

  void showAddEditAdDialog({Map<String, dynamic>? ad}) {
    final titleController = TextEditingController(text: ad?['title'] ?? '');
    final appIdController = TextEditingController(text: ad?['appId'] ?? '');
    final adUnitIdController = TextEditingController(text: ad?['adUnitId'] ?? '');
    final mediaUrlController = TextEditingController(text: ad?['mediaUrl'] ?? '');
    final linkController = TextEditingController(text: ad?['link'] ?? '');
    final frequencyController = TextEditingController(text: ad?['frequency']?.toString() ?? '0');
    
    String selectedProvider = ad?['provider'] ?? 'admob';
    String selectedAdType = ad?['adType'] ?? 'banner';
    String selectedPosition = ad?['position'] ?? 'home_top';
    DateTime? startDate = ad?['startAt'] != null ? DateTime.parse(ad?['startAt']) : null;
    DateTime? endDate = ad?['endAt'] != null ? DateTime.parse(ad?['endAt']) : null;
    bool isActive = ad?['isActive'] ?? true;

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
                  ad == null ? 'إضافة إعلان جديد' : 'تعديل الإعلان',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                
                // Title
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'عنوان الإعلان *',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                
                // Provider Selection
                const Text('نوع المزود *', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Radio(
                      value: 'admob',
                      groupValue: selectedProvider,
                      onChanged: (value) => setState(() => selectedProvider = value!),
                    ),
                    const Text('AdMob'),
                    const SizedBox(width: 16),
                    Radio(
                      value: 'custom',
                      groupValue: selectedProvider,
                      onChanged: (value) => setState(() => selectedProvider = value!),
                    ),
                    const Text('مخصص'),
                  ],
                ),
                const SizedBox(height: 8),
                
                // AdMob Fields
                if (selectedProvider == 'admob') ...[
                  TextField(
                    controller: appIdController,
                    decoration: const InputDecoration(
                      labelText: 'معرف التطبيق *',
                      border: OutlineInputBorder(),
                      hintText: 'ca-app-pub-xxxxxxxxxxxxxxxx~yyyyyyyyyy',
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: adUnitIdController,
                    decoration: const InputDecoration(
                      labelText: 'معرف وحدة الإعلان *',
                      border: OutlineInputBorder(),
                      hintText: 'ca-app-pub-xxxxxxxxxxxxxxxx/zzzzzzzzzz',
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                
                // Ad Type
                const Text('نوع الإعلان *', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                DropdownButtonFormField<String>(
                  value: selectedAdType,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'banner', child: Text('بانر')),
                    DropdownMenuItem(value: 'interstitial', child: Text('إعلان داخلي')),
                    DropdownMenuItem(value: 'rewarded', child: Text('إعلان مكافأة')),
                    DropdownMenuItem(value: 'native', child: Text('إعلان أصلي')),
                  ],
                  onChanged: (value) => setState(() => selectedAdType = value!),
                ),
                const SizedBox(height: 8),
                
                // Position
                const Text('مكان الظهور *', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                DropdownButtonFormField<String>(
                  value: selectedPosition,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'home_top', child: Text('أعلى الصفحة الرئيسية')),
                    DropdownMenuItem(value: 'player_pre', child: Text('قبل التشغيل')),
                    DropdownMenuItem(value: 'player_mid', child: Text('أثناء التشغيل')),
                    DropdownMenuItem(value: 'player_post', child: Text('بعد التشغيل')),
                    DropdownMenuItem(value: 'footer', child: Text('أسفل الصفحة')),
                  ],
                  onChanged: (value) => setState(() => selectedPosition = value!),
                ),
                const SizedBox(height: 8),
                
                // Media URL (for custom ads)
                if (selectedProvider == 'custom') ...[
                  TextField(
                    controller: mediaUrlController,
                    decoration: const InputDecoration(
                      labelText: 'رابط الوسائط',
                      border: OutlineInputBorder(),
                      hintText: 'https://example.com/image.jpg',
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                
                // Link
                TextField(
                  controller: linkController,
                  decoration: const InputDecoration(
                    labelText: 'رابط الوجهة',
                    border: OutlineInputBorder(),
                    hintText: 'https://example.com',
                  ),
                ),
                const SizedBox(height: 8),
                
                // Frequency
                TextField(
                  controller: frequencyController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'التكرار (مرات الظهور)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                
                // Date Range
                const Text('فترة العرض', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          final date = await showDatePicker(
                            context: Get.context!,
                            initialDate: startDate ?? DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2030),
                          );
                          if (date != null) {
                            setState(() => startDate = date);
                          }
                        },
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'تاريخ البدء',
                          ),
                        child: Text(startDate != null 
                            ? '${startDate.day}/${startDate.month}/${startDate.year}'
                            : 'اختر التاريخ'),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          final date = await showDatePicker(
                            context: Get.context!,
                            initialDate: endDate ?? DateTime.now().add(const Duration(days: 30)),
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2030),
                          );
                          if (date != null) {
                            setState(() => endDate = date);
                          }
                        },
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'تاريخ الانتهاء',
                          ),
                        child: Text(endDate != null 
                            ? '${endDate.day}/${endDate.month}/${endDate.year}'
                            : 'اختر التاريخ'),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                
                // Active Status
                Row(
                  children: [
                    Checkbox(
                      value: isActive,
                      onChanged: (value) => setState(() => isActive = value ?? true),
                    ),
                    const Text('نشط'),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: Get.back,
                      child: const Text('إلغاء'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () async {
                        if (!_validateForm(selectedProvider, appIdController, adUnitIdController)) {
                          return;
                        }
                        
                        try {
                          final adData = {
                            'title': titleController.text,
                            'provider': selectedProvider,
                            'appId': appIdController.text,
                            'adUnitId': adUnitIdController.text,
                            'adType': selectedAdType,
                            'position': selectedPosition,
                            'mediaUrl': mediaUrlController.text,
                            'link': linkController.text,
                            'frequency': int.tryParse(frequencyController.text) ?? 0,
                            'startAt': startDate?.toIso8601String(),
                            'endAt': endDate?.toIso8601String(),
                            'isActive': isActive,
                            'updatedAt': DateTime.now().toIso8601String(),
                          };
                          
                          if (ad == null) {
                            adData['createdAt'] = DateTime.now().toIso8601String();
                            await supabaseService.addAd(adData);
                            Get.snackbar(
                              'نجاح',
                              'تم إضافة الإعلان بنجاح',
                              backgroundColor: Colors.green,
                              colorText: Colors.white,
                            );
                          } else {
                            await supabaseService.updateAd(ad['id'], adData);
                            Get.snackbar(
                              'نجاح',
                              'تم تعديل الإعلان بنجاح',
                              backgroundColor: Colors.green,
                              colorText: Colors.white,
                            );
                          }
                          
                          Get.back();
                          await loadAds();
                        } catch (e) {
                          Get.snackbar(
                            'خطأ',
                            'فشل في حفظ الإعلان: $e',
                            backgroundColor: Colors.red,
                            colorText: Colors.white,
                          );
                        }
                      },
                      child: Text(ad == null ? 'إضافة' : 'تحديث'),
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

  bool _validateForm(String provider, TextEditingController appIdController, TextEditingController adUnitIdController) {
    if (appIdController.text.isEmpty) {
      Get.snackbar(
        'خطأ',
        'معرف تطبيق AdMob مطلوب',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }

    if (adUnitIdController.text.isEmpty) {
      Get.snackbar(
        'خطأ',
        'معرف وحدة إعلان AdMob مطلوب',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }

    if (!appIdController.text.startsWith('ca-app-pub-')) {
      Get.snackbar(
        'خطأ',
        'معرف تطبيق AdMob غير صالح',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }

    if (!adUnitIdController.text.startsWith('ca-app-pub-')) {
      Get.snackbar(
        'خطأ',
        'معرف وحدة إعلان AdMob غير صالح',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }

    return true;
  }

  Future<void> toggleAdStatus(String adId, bool currentStatus) async {
    try {
      await supabaseService.updateAd(adId, {
        'isActive': !currentStatus,
        'updatedAt': DateTime.now().toIso8601String(),
      });
      
      await loadAds();
      
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
      await loadAds();
      
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

  void showAdDetails(Map<String, dynamic> ad) {
    Get.dialog(
      Dialog(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                ad['title'] ?? 'بدون عنوان',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Text('المزود: ${_getProviderText(ad['provider'])}'),
              Text('النوع: ${_getAdTypeText(ad['adType'])}'),
              Text('المكان: ${_getPositionText(ad['position'])}'),
              Text('الحالة: ${ad['isActive'] == true ? 'نشط' : 'غير نشط'}'),
              if (ad['appId'] != null) Text('معرف التطبيق: ${ad['appId']}'),
              if (ad['adUnitId'] != null) Text('معرف الوحدة: ${ad['adUnitId']}'),
              if (ad['frequency'] != null) Text('التكرار: ${ad['frequency']}'),
              if (ad['startAt'] != null) Text('تاريخ البدء: ${DateTime.parse(ad['startAt'])}'),
              if (ad['endAt'] != null) Text('تاريخ الانتهاء: ${DateTime.parse(ad['endAt'])}'),
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
    );
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
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: loadAds,
            tooltip: 'تحديث',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filters
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: searchController,
                    decoration: const InputDecoration(
                      labelText: 'بحث في الإعلانات',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                      hintText: 'ابحث بالعنوان أو المزود',
                    ),
                    onChanged: (_) => filterAds(),
                  ),
                ),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: selectedAdType,
                  hint: const Text('نوع الإعلان'),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('الكل')),
                    ...['banner', 'interstitial', 'rewarded', 'native'].map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Text(_getAdTypeText(type)),
                      );
                    }),
                  ],
                  onChanged: (value) {
                    setState(() => selectedAdType = value);
                    filterAds();
                  },
                ),
                const SizedBox(width: 8),
                Row(
                  children: [
                    const Text('غير النشطة'),
                    Switch(
                      value: showInactive,
                      onChanged: (value) {
                        setState(() => showInactive = value);
                        filterAds();
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Ads Table
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredAds.isEmpty
                    ? const Center(child: Text('لا توجد إعلانات متاحة'))
                    : SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columns: const [
                            DataColumn(label: Text('العنوان')),
                            DataColumn(label: Text('المزود')),
                            DataColumn(label: Text('النوع')),
                            DataColumn(label: Text('المكان')),
                            DataColumn(label: Text('الحالة')),
                            DataColumn(label: Text('التكرار')),
                            DataColumn(label: Text('الإجراءات')),
                          ],
                          rows: filteredAds.map((ad) {
                            return DataRow(cells: [
                              DataCell(Text(ad['title'] ?? 'بدون عنوان')),
                              DataCell(Text(_getProviderText(ad['provider']))),
                              DataCell(Text(_getAdTypeText(ad['adType']))),
                              DataCell(Text(_getPositionText(ad['position']))),
                              DataCell(
                                Switch(
                                  value: ad['isActive'] == true,
                                  onChanged: (value) => toggleAdStatus(ad['id'], ad['isActive'] == true),
                                ),
                              ),
                              DataCell(Text(ad['frequency']?.toString() ?? '0')),
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
                                  IconButton(
                                    icon: const Icon(Icons.delete, size: 20),
                                    onPressed: () => deleteAd(ad['id']),
                                    tooltip: 'حذف',
                                  ),
                                ],
                              )),
                            ]);
                          }).toList(),
                        ),
                      ),
          ),
          // Pagination Controls
          if (!isLoading && totalPages > 1)
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Colors.grey.shade300)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Items per page selector
                  Row(
                    children: [
                      const Text('عناصر لكل صفحة: '),
                      DropdownButton<int>(
                        value: itemsPerPage,
                        items: [5, 10, 20, 50].map((value) {
                          return DropdownMenuItem<int>(
                            value: value,
                            child: Text(value.toString()),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            changeItemsPerPage(value);
                          }
                        },
                      ),
                    ],
                  ),
                  // Page navigation
                  Row(
                    children: [
                      // Previous button
                      IconButton(
                        icon: const Icon(Icons.chevron_left),
                        onPressed: currentPage > 1
                            ? () => changePage(currentPage - 1)
                            : null,
                        tooltip: 'الصفحة السابقة',
                      ),
                      // Page numbers
                      ..._buildPageNumbers(),
                      // Next button
                      IconButton(
                        icon: const Icon(Icons.chevron_right),
                        onPressed: currentPage < totalPages
                            ? () => changePage(currentPage + 1)
                            : null,
                        tooltip: 'الصفحة التالية',
                      ),
                      // Jump to last page
                      if (totalPages > 5)
                        IconButton(
                          icon: const Icon(Icons.last_page),
                          onPressed: currentPage < totalPages
                              ? () => changePage(totalPages)
                              : null,
                          tooltip: 'الصفحة الأخيرة',
                        ),
                    ],
                  ),
                  // Page info
                  Text(
                    'الصفحة $currentPage من $totalPages (${ads.length} إعلان)',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  List<Widget> _buildPageNumbers() {
    List<Widget> pageButtons = [];

    int startPage = 1;
    int endPage = totalPages;

    if (totalPages > 5) {
      if (currentPage <= 3) {
        startPage = 1;
        endPage = 5;
      } else if (currentPage >= totalPages - 2) {
        startPage = totalPages - 4;
        endPage = totalPages;
      } else {
        startPage = currentPage - 2;
        endPage = currentPage + 2;
      }
    }

    for (int i = startPage; i <= endPage; i++) {
      pageButtons.add(
        TextButton(
          onPressed: i == currentPage ? null : () => changePage(i),
          child: Text(
            i.toString(),
            style: TextStyle(
              fontWeight: i == currentPage ? FontWeight.bold : FontWeight.normal,
              color: i == currentPage ? Colors.blue : Colors.black,
            ),
          ),
        ),
      );
    }

    return pageButtons;
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}
