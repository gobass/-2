import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nashmi_admin_v2/services/supabase_service.dart';
import 'package:nashmi_admin_v2/services/auth_service.dart';
import 'package:nashmi_admin_v2/widgets/banner_ad_widget.dart';
import 'package:nashmi_admin_v2/views/series/series_complete_form.dart';
import 'package:nashmi_admin_v2/views/series/episodes_management.dart';
import 'package:nashmi_admin_v2/views/series/add_episode_screen.dart';

class SeriesView extends StatefulWidget {
  const SeriesView({super.key});

  @override
  State<SeriesView> createState() => _SeriesViewState();
}

class _SeriesViewState extends State<SeriesView> {
  final SupabaseService supabaseService = Get.find<SupabaseService>();
  final AuthService authService = Get.find<AuthService>();
  final TextEditingController searchController = TextEditingController();

  List<Map<String, dynamic>> series = [];
  List<Map<String, dynamic>> filteredSeries = [];
  bool isLoading = true;
  String? selectedCategory;

  List<String> selectedCategories = [];

  @override
  void initState() {
    super.initState();
    loadSeries();
  }

  Future<void> loadSeries() async {
    try {
      setState(() => isLoading = true);
      final response = await supabaseService.getSeries();

      series = List<Map<String, dynamic>>.from(response);

      filterSeries();
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'فشل في تحميل المسلسلات: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  void filterSeries() {
    filteredSeries = series.where((serie) {
      final matchesSearch = searchController.text.isEmpty ||
          serie['title']?.toString().toLowerCase().contains(searchController.text.toLowerCase()) == true;

      final matchesCategory = selectedCategory == null ||
          (serie['categories'] as List?)?.contains(selectedCategory) == true;

      return matchesSearch && matchesCategory;
    }).toList();
  }

  void showSeriesDetails(Map<String, dynamic> serie) {
    Get.dialog(
      Dialog(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                serie['title'] ?? 'بدون عنوان',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              if (serie['posterUrl']?.isNotEmpty == true)
                Image.network(
                  serie['posterUrl']!,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              const SizedBox(height: 16),
              Text('السنة: ${serie['year'] ?? 'غير محدد'}'),
              Text('المدة: ${serie['duration'] ?? 0} دقيقة'),
              Text('المشاهدات: ${serie['views'] ?? 0}'),
              if (serie['categories'] != null)
                Text('التصنيفات: ${(serie['categories'] as List).join(', ')}'),
              if (serie['description']?.isNotEmpty == true)
                Text('الوصف: ${serie['description']}'),
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

  void showAddEditSeriesDialog({Map<String, dynamic>? series}) async {
    final result = await Get.dialog(SeriesCompleteForm(series: series));
    if (result == true) {
      // Add a small delay to ensure the database operation is complete
      await Future.delayed(const Duration(milliseconds: 500));
      loadSeries(); // Reload series list after successful save
    }
  }

  void navigateToEpisodesManagement(Map<String, dynamic> serie) {
    Get.to(() => EpisodesManagement(
      seriesId: serie['id'],
      seriesTitle: serie['title'] ?? 'بدون عنوان',
    ));
  }

  void showAddEpisodeToSeriesDialog(String seriesId, String seriesTitle) {
    Get.dialog(
      Dialog(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'إضافة حلقة جديدة إلى $seriesTitle',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  final result = await Get.to(() => AddEpisodeScreen(
                    seriesId: seriesId,
                    seriesTitle: seriesTitle,
                  ));
                  if (result == true) {
                    Get.back();
                    loadSeries();
                  }
                },
                child: const Text('إضافة حلقة جديدة'),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Get.back(),
                child: const Text('إلغاء'),
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
        title: const Text('إدارة المسلسلات'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: loadSeries,
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
                      labelText: 'بحث بالمسلسلات',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (_) => filterSeries(),
                  ),
                ),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: selectedCategory,
                  hint: const Text('التصنيف'),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('الكل')),
                    ...['أكشن', 'دراما', 'كوميدي', 'رعب', 'رومانسي', 'هندي', 'أجنبي', 'عربي مصري'].map((category) {
                      return DropdownMenuItem(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                  ],
                  onChanged: (value) {
                    setState(() => selectedCategory = value);
                    filterSeries();
                  },
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () => showAddEditSeriesDialog(),
                  icon: const Icon(Icons.add),
                  label: const Text('إضافة مسلسل جديد'),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
          : filteredSeries.isEmpty
              ? const Center(child: Text('لا توجد مسلسلات'))
          : Scrollbar(
              thumbVisibility: true,
              thickness: 8,
              radius: const Radius.circular(8),
              trackVisibility: true,
              interactive: true,
              scrollbarOrientation: ScrollbarOrientation.right,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Scrollbar(
                  thumbVisibility: true,
                  thickness: 8,
                  radius: const Radius.circular(8),
                  trackVisibility: true,
                  interactive: true,
                  scrollbarOrientation: ScrollbarOrientation.bottom,
                  child: SingleChildScrollView(
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('البوستر')),
                        DataColumn(label: Text('العنوان')),
                        DataColumn(label: Text('السنة')),
                        DataColumn(label: Text('التصنيفات')),
                        DataColumn(label: Text('المشاهدات')),
                        DataColumn(label: Text('الإجراءات')),
                      ],
                      rows: filteredSeries.map((serie) {
                        return DataRow(cells: [
                          DataCell(
                            serie['posterUrl']?.isNotEmpty == true
                                ? Image.network(
                                    serie['posterUrl']!,
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                  )
                                : const Icon(Icons.tv),
                          ),
                          DataCell(Text(serie['title'] ?? 'بدون عنوان')),
                          DataCell(Text(serie['year']?.toString() ?? '')),
                          DataCell(Text(
                            (serie['categories'] as List?)?.join(', ') ?? '',
                            maxLines: 2,
                          )),
                          DataCell(Text(serie['views']?.toString() ?? '0')),
                          DataCell(Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.visibility, size: 20),
                                onPressed: () => showSeriesDetails(serie),
                                tooltip: 'عرض التفاصيل',
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit, size: 20),
                                onPressed: () => showAddEditSeriesDialog(series: serie),
                                tooltip: 'تعديل',
                              ),
                              IconButton(
                                icon: const Icon(Icons.add_circle, size: 20),
                                onPressed: () => showAddEpisodeToSeriesDialog(
                                  serie['id'],
                                  serie['title'] ?? 'بدون عنوان',
                                ),
                                tooltip: 'إضافة حلقة',
                              ),
                              IconButton(
                                icon: const Icon(Icons.playlist_play, size: 20),
                                onPressed: () => navigateToEpisodesManagement(serie),
                                tooltip: 'إدارة الحلقات',
                              ),
                            ],
                          )),
                        ]);
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
