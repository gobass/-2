import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nashmi_admin_v2/services/supabase_service.dart';
import 'package:nashmi_admin_v2/services/auth_service.dart';
import 'package:nashmi_admin_v2/views/movies/movies_complete_form.dart';

class MoviesCompleteCRUD extends StatefulWidget {
  const MoviesCompleteCRUD({super.key});

  @override
  State<MoviesCompleteCRUD> createState() => _MoviesCompleteCRUDState();
}

class _MoviesCompleteCRUDState extends State<MoviesCompleteCRUD> {
  final SupabaseService supabaseService = Get.find<SupabaseService>();
  final AuthService authService = Get.find<AuthService>();
  final TextEditingController searchController = TextEditingController();
  
  List<Map<String, dynamic>> movies = [];
  List<Map<String, dynamic>> filteredMovies = [];
  bool isLoading = true;
  String? selectedCategory;
  bool showArchived = false;

  // Available categories in Arabic
  final List<String> availableCategories = [
    'أكشن', 'دراما', 'كوميدي', 'رعب', 'رومانسي', 
    'خيال علمي', 'وثائقي', 'مغامرة', 'جريمة', 'عائلي'
  ];

  @override
  void initState() {
    super.initState();
    loadMovies();
  }

  Future<void> loadMovies() async {
    try {
      setState(() => isLoading = true);
      final moviesData = await supabaseService.getMovies();
      movies = moviesData;
      
      filterMovies();
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'فشل في تحميل الأفلام: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  void filterMovies() {
    filteredMovies = movies.where((movie) {
      final matchesSearch = searchController.text.isEmpty ||
          movie['title']?.toString().toLowerCase().contains(searchController.text.toLowerCase()) == true;
      
      final matchesCategory = selectedCategory == null ||
          (movie['categories'] as List?)?.contains(selectedCategory) == true;
      
      final matchesArchiveStatus = showArchived ? true : movie['archived'] != true;
      
      return matchesSearch && matchesCategory && matchesArchiveStatus;
    }).toList();
  }

  Future<void> toggleMovieStatus(String movieId, bool currentStatus) async {
    try {
      await supabaseService.updateMovie(movieId, {
        'isActive': !currentStatus,
        'updatedAt': DateTime.now().toIso8601String(),
      });
      
      await loadMovies();
      
      Get.snackbar(
        'نجاح',
        'تم تغيير حالة الفيلم',
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

  Future<void> archiveMovie(String movieId) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('تأكيد الأرشفة'),
        content: const Text('هل تريد أرشفة هذا الفيلم؟ يمكن استرجاعه لاحقاً.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('أرشفة'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await supabaseService.updateMovie(movieId, {
        'archived': true,
        'updatedAt': DateTime.now().toIso8601String(),
      });
      
      await loadMovies();
      
      Get.snackbar(
        'نجاح',
        'تم أرشفة الفيلم',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'فشل في أرشفة الفيلم: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> deleteMovie(String movieId) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: const Text('هل أنت متأكد من حذف هذا الفيلم نهائياً؟ لا يمكن التراجع عن هذا الإجراء.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('حذف نهائي'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await supabaseService.deleteMovie(movieId);
      await loadMovies();
      
      Get.snackbar(
        'نجاح',
        'تم حذف الفيلم نهائياً',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'فشل في حذف الفيلم: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void showMovieDetails(Map<String, dynamic> movie) {
    Get.dialog(
      Dialog(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                movie['title'] ?? 'بدون عنوان',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              if (movie['posterUrl']?.isNotEmpty == true)
                Image.network(
                  movie['posterUrl']!,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.movie, size: 100, color: Colors.grey);
                  },
                ),
              const SizedBox(height: 16),
              Text('السنة: ${movie['year'] ?? 'غير محدد'}'),
              Text('المدة: ${movie['duration'] ?? 0} دقيقة'),
              Text('المشاهدات: ${movie['views'] ?? 0}'),
              Text('الحالة: ${movie['isActive'] == true ? 'نشط' : 'غير نشط'}'),
              Text('النوع: ${movie['isSeries'] == true ? 'مسلسل' : 'فيلم'}'),
              if (movie['categories'] != null)
                Text('التصنيفات: ${(movie['categories'] as List).join(', ')}'),
              if (movie['description']?.isNotEmpty == true)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    const Text('الوصف:', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(movie['description']!),
                  ],
                ),
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
        title: const Text('إدارة الأفلام'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => showMoviesCompleteForm(),
            tooltip: 'إضافة فيلم جديد',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: loadMovies,
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
                      labelText: 'بحث في الأفلام',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                      hintText: 'ابحث بالعنوان أو الكلمات المفتاحية',
                    ),
                    onChanged: (_) => filterMovies(),
                  ),
                ),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: selectedCategory,
                  hint: const Text('التصنيف'),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('الكل')),
                    ...availableCategories.map((category) {
                      return DropdownMenuItem(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                  ],
                  onChanged: (value) {
                    setState(() => selectedCategory = value);
                    filterMovies();
                  },
                ),
                const SizedBox(width: 8),
                Row(
                  children: [
                    const Text('المؤرشفة'),
                    Switch(
                      value: showArchived,
                      onChanged: (value) {
                        setState(() => showArchived = value);
                        filterMovies();
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Quick Actions
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () => showMoviesCompleteForm(),
                  icon: const Icon(Icons.add),
                  label: const Text('إضافة فيلم جديد'),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: () {
                    Get.snackbar(
                      'قريباً',
                      'ميزة الاستيراد قريباً',
                      backgroundColor: Colors.blue,
                      colorText: Colors.white,
                    );
                  },
                  icon: const Icon(Icons.import_export),
                  label: const Text('استيراد CSV'),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: () {
                    Get.snackbar(
                      'قريباً',
                      'ميزة التصدير قريباً',
                      backgroundColor: Colors.blue,
                      colorText: Colors.white,
                    );
                  },
                  icon: const Icon(Icons.download),
                  label: const Text('تصدير CSV'),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Movies Table
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredMovies.isEmpty
                    ? const Center(child: Text('لا توجد أفلام متاحة'))
                    : SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columns: const [
                            DataColumn(label: Text('البوستر')),
                            DataColumn(label: Text('العنوان')),
                            DataColumn(label: Text('السنة')),
                            DataColumn(label: Text('التصنيفات')),
                            DataColumn(label: Text('النوع')),
                            DataColumn(label: Text('الحالة')),
                            DataColumn(label: Text('المشاهدات')),
                            DataColumn(label: Text('الإجراءات')),
                          ],
                          rows: filteredMovies.map((movie) {
                            return DataRow(cells: [
                              DataCell(
                                movie['posterUrl']?.isNotEmpty == true
                                    ? Image.network(
                                        movie['posterUrl']!,
                                        width: 60,
                                        height: 60,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return const Icon(Icons.movie, size: 30);
                                        },
                                      )
                                    : const Icon(Icons.movie, size: 30),
                              ),
                              DataCell(Text(movie['title'] ?? 'بدون عنوان')),
                              DataCell(Text(movie['year']?.toString() ?? '')),
                              DataCell(Text(
                                (movie['categories'] as List?)?.join(', ') ?? '',
                                maxLines: 2,
                              )),
                              DataCell(Text(movie['isSeries'] == true ? 'مسلسل' : 'فيلم')),
                              DataCell(
                                Switch(
                                  value: movie['isActive'] == true,
                                  onChanged: (value) => toggleMovieStatus(movie['id'], movie['isActive'] == true),
                                ),
                              ),
                              DataCell(Text(movie['views']?.toString() ?? '0')),
                              DataCell(Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.visibility, size: 20),
                                    onPressed: () => showMovieDetails(movie),
                                    tooltip: 'عرض التفاصيل',
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.edit, size: 20),
                                    onPressed: () => showMoviesCompleteForm(movie: movie),
                                    tooltip: 'تعديل',
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.archive, size: 20),
                                    onPressed: () => archiveMovie(movie['id']),
                                    tooltip: 'أرشفة',
                                  ),
                                  if (authService.userRole.value == 'admin')
                                    IconButton(
                                      icon: const Icon(Icons.delete_forever, size: 20, color: Colors.red),
                                      onPressed: () => deleteMovie(movie['id']),
                                      tooltip: 'حذف نهائي',
                                    ),
                                ],
                              )),
                            ]);
                          }).toList(),
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}
