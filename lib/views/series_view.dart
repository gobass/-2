import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/supabase_service.dart';

class SeriesView extends StatefulWidget {
  const SeriesView({super.key});

  @override
  State<SeriesView> createState() => _SeriesViewState();
}

class _SeriesViewState extends State<SeriesView> {
  final SupabaseService _supabaseService = Get.find<SupabaseService>();
  final TextEditingController _searchController = TextEditingController();
  
  List<Map<String, dynamic>> _series = [];
  List<Map<String, dynamic>> _filteredSeries = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadSeries();
  }

  Future<void> _loadSeries() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final series = await _supabaseService.getSeries();
      setState(() {
        _series = series;
        _filteredSeries = series;
        _isLoading = false;
      });
    } catch (e) {
      Get.snackbar('خطأ', 'فشل في تحميل المسلسلات: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _filterSeries(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredSeries = _series;
      } else {
        _filteredSeries = _series.where((series) {
          final title = series['title']?.toString().toLowerCase() ?? '';
          final description = series['description']?.toString().toLowerCase() ?? '';
          final genre = series['genre']?.toString().toLowerCase() ?? '';
          return title.contains(query.toLowerCase()) || 
                 description.contains(query.toLowerCase()) ||
                 genre.contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  void _showAddSeriesDialog() {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final genreController = TextEditingController();
    final thumbnailUrlController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: const Text('إضافة مسلسل جديد'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'عنوان المسلسل',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'وصف المسلسل',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 10),
              TextField(
                controller: genreController,
                decoration: const InputDecoration(
                  labelText: 'النوع/التصنيف',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: thumbnailUrlController,
                decoration: const InputDecoration(
                  labelText: 'رابط الصورة المصغرة',
                  border: OutlineInputBorder(),
                ),
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
              if (titleController.text.isEmpty) {
                Get.snackbar('خطأ', 'عنوان المسلسل مطلوب');
                return;
              }

              try {
                final seriesData = {
                  'title': titleController.text,
                  'description': descriptionController.text,
                  'genre': genreController.text,
                  'thumbnail_url': thumbnailUrlController.text,
                  'created_at': DateTime.now().toIso8601String(),
                };

                await _supabaseService.addSeries(seriesData);
                Get.back();
                Get.snackbar('نجاح', 'تم إضافة المسلسل بنجاح');
                _loadSeries();
              } catch (e) {
                Get.snackbar('خطأ', 'فشل في إضافة المسلسل: $e');
              }
            },
            child: const Text('إضافة'),
          ),
        ],
      ),
    );
  }

  void _showEditSeriesDialog(Map<String, dynamic> series) {
    final titleController = TextEditingController(text: series['title']?.toString());
    final descriptionController = TextEditingController(text: series['description']?.toString());
    final genreController = TextEditingController(text: series['genre']?.toString());
    final thumbnailUrlController = TextEditingController(text: series['thumbnail_url']?.toString());

    Get.dialog(
      AlertDialog(
        title: const Text('تعديل المسلسل'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'عنوان المسلسل',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'وصف المسلسل',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 10),
              TextField(
                controller: genreController,
                decoration: const InputDecoration(
                  labelText: 'النوع/التصنيف',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: thumbnailUrlController,
                decoration: const InputDecoration(
                  labelText: 'رابط الصورة المصغرة',
                  border: OutlineInputBorder(),
                ),
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
              if (titleController.text.isEmpty) {
                Get.snackbar('خطأ', 'عنوان المسلسل مطلوب');
                return;
              }

              try {
                final seriesData = {
                  'title': titleController.text,
                  'description': descriptionController.text,
                  'genre': genreController.text,
                  'thumbnail_url': thumbnailUrlController.text,
                };

                await _supabaseService.updateSeries(series['id'].toString(), seriesData);
                Get.back();
                Get.snackbar('نجاح', 'تم تعديل المسلسل بنجاح');
                _loadSeries();
              } catch (e) {
                Get.snackbar('خطأ', 'فشل في تعديل المسلسل: $e');
              }
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(Map<String, dynamic> series) {
    Get.dialog(
      AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Text('هل تريد حذف المسلسل "${series['title']}"؟'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await _supabaseService.deleteSeries(series['id'].toString());
                Get.back();
                Get.snackbar('نجاح', 'تم حذف المسلسل بنجاح');
                _loadSeries();
              } catch (e) {
                Get.snackbar('خطأ', 'فشل في حذف المسلسل: $e');
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
        title: const Text('إدارة المسلسلات'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadSeries,
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
                labelText: 'بحث في المسلسلات',
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _filterSeries('');
                        },
                      )
                    : null,
              ),
              onChanged: _filterSeries,
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredSeries.isEmpty
                    ? const Center(
                        child: Text(
                          'لا توجد مسلسلات',
                          style: TextStyle(fontSize: 18),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _filteredSeries.length,
                        itemBuilder: (context, index) {
                          final series = _filteredSeries[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 4),
                            child: ListTile(
                              title: Text(series['title']?.toString() ?? 'بدون عنوان'),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('النوع: ${series['genre'] ?? 'غير محدد'}'),
                                  if (series['description'] != null)
                                    Text(
                                      'الوصف: ${series['description']}',
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  if (series['created_at'] != null)
                                    Text('تاريخ الإضافة: ${_formatDate(series['created_at'])}'),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit, color: Colors.blue),
                                    onPressed: () => _showEditSeriesDialog(series),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => _showDeleteConfirmation(series),
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
        onPressed: _showAddSeriesDialog,
        child: const Icon(Icons.add),
      ),
    );
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
