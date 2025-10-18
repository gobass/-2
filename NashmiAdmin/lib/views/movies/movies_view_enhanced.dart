import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import 'package:nashmi_admin_v2/services/supabase_service.dart';
import 'package:nashmi_admin_v2/services/auth_service.dart';

class MoviesViewEnhanced extends StatefulWidget {
  const MoviesViewEnhanced({super.key});

  @override
  State<MoviesViewEnhanced> createState() => _MoviesViewEnhancedState();
}

class _MoviesViewEnhancedState extends State<MoviesViewEnhanced> {
  final SupabaseService supabaseService = Get.find<SupabaseService>();
  final AuthService authService = Get.find<AuthService>();
  final TextEditingController searchController = TextEditingController();

  List<Map<String, dynamic>> movies = [];
  List<Map<String, dynamic>> filteredMovies = [];
  bool isLoading = true;
  String? selectedCategory;
  bool showArchived = false;

  // Form controllers
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController videoUrlController = TextEditingController();
  final TextEditingController embedCodeController = TextEditingController();
  final TextEditingController yearController = TextEditingController();
  final TextEditingController durationController = TextEditingController();
  final TextEditingController tagsController = TextEditingController();
  final TextEditingController posterUrlController = TextEditingController();

  List<String> selectedCategories = [];
  bool isActive = true;
  bool isSeries = false;
  String? posterUrl;

  // New state variables for poster upload
  File? posterFile;
  bool isUploading = false;
  double uploadProgress = 0.0;
  bool useUrlUpload = true; // Toggle between file upload and URL input
  // Only embed code for movies

  // Available categories
  final List<String> availableCategories = [
    'أكشن',
    'دراما',
    'كوميدي',
    'رعب',
    'رومانسي',
    'خيال علمي',
    'وثائقي',
    'مغامرة',
    'جريمة',
    'عائلي',
  ];

  @override
  void initState() {
    super.initState();
    loadMovies();
  }

  Future<void> loadMovies() async {
    try {
      setState(() => isLoading = true);
      movies = await supabaseService.getMovies();
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
      final matchesSearch =
          searchController.text.isEmpty ||
          movie['title']?.toString().toLowerCase().contains(
                searchController.text.toLowerCase(),
              ) ==
              true;

      final matchesCategory =
          selectedCategory == null ||
          (movie['categories'] as List?)?.contains(selectedCategory) == true;

      final matchesArchiveStatus = showArchived
          ? true
          : movie['archived'] != true;

      return matchesSearch && matchesCategory && matchesArchiveStatus;
    }).toList();
  }

  bool _validateForm() {
    if (titleController.text.isEmpty) {
      Get.snackbar('خطأ', 'عنوان الفيلم مطلوب', colorText: Colors.white);
      return false;
    }

    // Video source validation
    if (useVideoUrl) {
      if (videoUrlController.text.isEmpty) {
        Get.snackbar(
          'خطأ',
          'رابط الفيديو مطلوب',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return false;
      }

      if (!videoUrlController.text.startsWith('http')) {
        Get.snackbar(
          'خطأ',
          'الرابط غير صالح',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return false;
      }
    } else {
      if (embedCodeController.text.isEmpty) {
        Get.snackbar(
          'خطأ',
          'كود التمضن مطلوب',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return false;
      }
    }

    if (selectedCategories.isEmpty) {
      Get.snackbar(
        'خطأ',
        'يجب اختيار تصنيف واحد على الأقل',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }

    return true;
  }

  Future<void> pickPoster() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final fileSize = await file.length();

        if (fileSize > 5 * 1024 * 1024) {
          // 5MB limit
          Get.snackbar(
            'خطأ',
            'حجم الصورة أكبر من 5MB',
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
          return;
        }

        setState(() {
          posterFile = file;
        });
      }
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'فشل في اختيار الصورة: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<String?> uploadPoster() async {
    if (posterFile == null) return null;

    try {
      setState(() {
        isUploading = true;
        uploadProgress = 0.0;
      });

      final bytes = await posterFile!.readAsBytes();
      final path =
          'posters/${DateTime.now().millisecondsSinceEpoch}_${posterFile!.path.split('/').last}';

      final response = await supabaseService.uploadFile('images', path, bytes);

      return response;
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'فشل في رفع الصورة: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return null;
    } finally {
      setState(() => isUploading = false);
    }
  }

  Future<void> addMovie() async {
    if (!_validateForm()) return;

    try {
      setState(() => isUploading = true);

      final uploadedPosterUrl = await uploadPoster();

      final movieData = {
        'title': titleController.text,
        'slug': titleController.text.toLowerCase().replaceAll(' ', '-'),
        'description': descriptionController.text,
        'categories': selectedCategories,
        'year': int.tryParse(yearController.text) ?? 0,
        'posterUrl': posterUrlController.text.isNotEmpty
            ? posterUrlController.text
            : (uploadedPosterUrl ?? ''),
        'videoUrl': videoUrlController.text,
        'embedCode': embedCodeController.text,
        'duration': int.tryParse(durationController.text) ?? 0,
        'isActive': isActive,
        'isSeries': isSeries,
        'tags': tagsController.text
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList(),
        'createdat': DateTime.now().toIso8601String(),
        'updatedat': DateTime.now().toIso8601String(),
        'views': 0,
        'archived': false,
      };

      Get.back();
      await loadMovies();

      Get.snackbar(
        'نجاح',
        'تم إضافة الفيلم بنجاح',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'فشل في إضافة الفيلم: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setState(() => isUploading = false);
    }
  }

  Future<void> updateMovie(
    String movieId,
    Map<String, dynamic> currentData,
  ) async {
    if (!_validateForm()) return;

    try {
      setState(() => isUploading = true);

      String? uploadedPosterUrl;
      if (posterFile != null) {
        uploadedPosterUrl = await uploadPoster();
      }

      final movieData = {
        'title': titleController.text,
        'slug': titleController.text.toLowerCase().replaceAll(' ', '-'),
        'description': descriptionController.text,
        'categories': selectedCategories,
        'year': int.tryParse(yearController.text) ?? currentData['year'] ?? 0,
        'posterUrl': posterUrlController.text.isNotEmpty
            ? posterUrlController.text
            : (uploadedPosterUrl ?? currentData['posterUrl'] ?? ''),
        'videoUrl': videoUrlController.text,
        'embedCode': embedCodeController.text,
        'duration':
            int.tryParse(durationController.text) ??
            currentData['duration'] ??
            0,
        'isActive': isActive,
        'isSeries': isSeries,
        'tags': tagsController.text
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList(),
        'updatedat': DateTime.now().toIso8601String(),
      };

      await supabaseService.updateMovie(movieId, movieData);

      Get.back();
      await loadMovies();

      Get.snackbar(
        'نجاح',
        'تم تحديث الفيلم بنجاح',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'فشل في تحديث الفيلم: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setState(() => isUploading = false);
    }
  }

  Future<void> toggleMovieStatus(String movieId, bool currentStatus) async {
    try {
      await supabaseService.updateMovie(movieId, {
        'isActive': !currentStatus,
        'updatedat': DateTime.now().toIso8601String(),
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
        'updatedat': DateTime.now().toIso8601String(),
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
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              if (movie['posterUrl']?.isNotEmpty == true)
                Image.network(
                  movie['posterUrl']!,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
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
                Text('الوصف: ${movie['description']}'),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(onPressed: Get.back, child: const Text('إغلاق')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void showAddEditMovieDialog({Map<String, dynamic>? movie}) {
    if (movie != null) {
      titleController.text = movie['title'] ?? '';
      descriptionController.text = movie['description'] ?? '';
      videoUrlController.text = movie['videoUrl'] ?? '';
      embedCodeController.text = movie['embedCode'] ?? '';
      yearController.text = movie['year']?.toString() ?? '';
      durationController.text = movie['duration']?.toString() ?? '';
      tagsController.text = (movie['tags'] as List?)?.join(', ') ?? '';
      selectedCategories = List<String>.from(movie['categories'] ?? []);
      isActive = movie['isActive'] ?? true;
      isSeries = movie['isSeries'] ?? false;
      posterUrl = movie['posterUrl'];
      posterUrlController.text = movie['posterUrl'] ?? '';
      useVideoUrl = movie['embedCode']?.isNotEmpty == true
          ? false
          : true; // Default to embed code if exists, otherwise video URL
    } else {
      titleController.clear();
      descriptionController.clear();
      videoUrlController.clear();
      embedCodeController.clear();
      yearController.clear();
      durationController.clear();
      tagsController.clear();
      posterUrlController.clear();
      selectedCategories.clear();
      isActive = true;
      isSeries = false;
      posterFile = null;
      posterUrl = null;
      useVideoUrl = true; // Default to video URL for new movies
    }

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
                  movie == null ? 'إضافة فيلم جديد' : 'تعديل الفيلم',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // Poster URL Input
                TextField(
                  controller: posterUrlController,
                  decoration: const InputDecoration(
                    labelText: 'رابط البوستر',
                    border: OutlineInputBorder(),
                    hintText: 'https://example.com/poster.jpg',
                    prefixIcon: Icon(Icons.link),
                  ),
                  onChanged: (value) {
                    setState(() {
                      posterUrl = value;
                    });
                  },
                ),
                const SizedBox(height: 8),

                // Poster Preview
                if (posterUrl?.isNotEmpty == true)
                  Container(
                    height: 150,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Image.network(
                      posterUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.broken_image,
                              size: 40,
                              color: Colors.grey,
                            ),
                            Text('فشل في تحميل الصورة'),
                          ],
                        );
                      },
                    ),
                  ),

                const SizedBox(height: 16),

                // Title
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'عنوان الفيلم *',
                    border: OutlineInputBorder(),
                    errorText: null,
                  ),
                ),
                const SizedBox(height: 8),

                // Description
                TextField(
                  controller: descriptionController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'الوصف',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),

                // Video Source Toggle
                Row(
                  children: [
                    const Text(
                      'مصدر الفيديو:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 16),
                    Row(
                      children: [
                        Radio<bool>(
                          value: true,
                          groupValue: useVideoUrl,
                          onChanged: (value) =>
                              setState(() => useVideoUrl = value ?? true),
                        ),
                        const Text('رابط'),
                        const SizedBox(width: 16),
                        Radio<bool>(
                          value: false,
                          groupValue: useVideoUrl,
                          onChanged: (value) =>
                              setState(() => useVideoUrl = value ?? false),
                        ),
                        const Text('كود التمضن'),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Video URL or Embed Code
                if (useVideoUrl)
                  TextField(
                    controller: videoUrlController,
                    decoration: InputDecoration(
                      labelText: 'رابط الفيديو',
                      border: const OutlineInputBorder(),
                      hintText: 'https://example.com/video.m3u8',
                      suffixIcon: videoUrlController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () =>
                                  setState(() => videoUrlController.clear()),
                            )
                          : null,
                    ),
                  )
                else
                  TextField(
                    controller: embedCodeController,
                    maxLines: 5,
                    decoration: InputDecoration(
                      labelText: 'كود التمضن',
                      border: const OutlineInputBorder(),
                      hintText: '<iframe>...</iframe>',
                      suffixIcon: embedCodeController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () =>
                                  setState(() => embedCodeController.clear()),
                            )
                          : null,
                    ),
                  ),
                const SizedBox(height: 8),

                // Year and Duration
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: yearController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'سنة الإنتاج',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: durationController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'المدة (دقيقة)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Categories
                const Text(
                  'التصنيفات *',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: availableCategories.map((category) {
                    final isSelected = selectedCategories.contains(category);
                    return FilterChip(
                      label: Text(category),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            selectedCategories.add(category);
                          } else {
                            selectedCategories.remove(category);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 8),

                // Tags
                TextField(
                  controller: tagsController,
                  decoration: const InputDecoration(
                    labelText: 'الكلمات المفتاحية (مفصولة بفاصلة)',
                    border: OutlineInputBorder(),
                    hintText: 'جديد, حصري, 2024',
                  ),
                ),
                const SizedBox(height: 8),

                // Active Status and Series Type
                Row(
                  children: [
                    Checkbox(
                      value: isActive,
                      onChanged: (value) =>
                          setState(() => isActive = value ?? true),
                    ),
                    const Text('نشط'),
                    const SizedBox(width: 16),
                    Checkbox(
                      value: isSeries,
                      onChanged: (value) =>
                          setState(() => isSeries = value ?? false),
                    ),
                    const Text('مسلسل'),
                  ],
                ),

                const SizedBox(height: 16),

                // Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(onPressed: Get.back, child: const Text('إلغاء')),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: isUploading
                          ? null
                          : () {
                              if (movie == null) {
                                addMovie();
                              } else {
                                updateMovie(movie['id'], movie);
                              }
                            },
                      child: isUploading
                          ? const CircularProgressIndicator()
                          : Text(movie == null ? 'إضافة' : 'تحديث'),
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
            onPressed: () => showAddEditMovieDialog(),
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
                  onPressed: () => showAddEditMovieDialog(),
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
                        return DataRow(
                          cells: [
                            DataCell(
                              Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: movie['posterUrl']?.isNotEmpty == true
                                    ? Image.network(
                                        movie['posterUrl']!,
                                        width: 60,
                                        height: 60,
                                        fit: BoxFit.cover,
                                      )
                                    : const Icon(Icons.movie),
                              ),
                            ),
                            DataCell(Text(movie['title'] ?? 'بدون عنوان')),
                            DataCell(Text(movie['year']?.toString() ?? '')),
                            DataCell(
                              Text(
                                (movie['categories'] as List?)?.join(', ') ??
                                    '',
                                maxLines: 2,
                              ),
                            ),
                            DataCell(
                              Text(
                                movie['isSeries'] == true ? 'مسلسل' : 'فيلم',
                              ),
                            ),
                            DataCell(
                              Switch(
                                value: movie['isActive'] == true,
                                onChanged: (value) => toggleMovieStatus(
                                  movie['id'],
                                  movie['isActive'] == true,
                                ),
                              ),
                            ),
                            DataCell(Text(movie['views']?.toString() ?? '0')),
                            DataCell(
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.visibility,
                                      size: 20,
                                    ),
                                    onPressed: () => showMovieDetails(movie),
                                    tooltip: 'عرض التفاصيل',
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.edit, size: 20),
                                    onPressed: () =>
                                        showAddEditMovieDialog(movie: movie),
                                    tooltip: 'تعديل',
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.archive, size: 20),
                                    onPressed: () => archiveMovie(movie['id']),
                                    tooltip: 'أرشفة',
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
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
    titleController.dispose();
    descriptionController.dispose();
    videoUrlController.dispose();
    embedCodeController.dispose();
    yearController.dispose();
    durationController.dispose();
    tagsController.dispose();
    posterUrlController.dispose();
    searchController.dispose();
    super.dispose();
  }
}
