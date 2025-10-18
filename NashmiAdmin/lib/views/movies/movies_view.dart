import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import 'package:nashmi_admin_v2/services/supabase_service.dart';
import 'package:nashmi_admin_v2/services/auth_service.dart';
import 'package:nashmi_admin_v2/widgets/banner_ad_widget.dart';
import 'package:uuid/uuid.dart';

class MoviesView extends StatefulWidget {
  const MoviesView({super.key});

  @override
  State<MoviesView> createState() => _MoviesViewState();
}

class _MoviesViewState extends State<MoviesView> {
  final SupabaseService supabaseService = Get.find<SupabaseService>();
  final AuthService authService = Get.find<AuthService>();
  final TextEditingController searchController = TextEditingController();
  final Uuid uuid = const Uuid();

  final ScrollController _horizontalScrollController = ScrollController();
  final ScrollController _verticalScrollController = ScrollController();

  List<Map<String, dynamic>> movies = [];
  List<Map<String, dynamic>> filteredMovies = [];
  bool isLoading = true;
  String? selectedCategory;


  // Form controllers
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController videoUrlController = TextEditingController();
  final TextEditingController yearController = TextEditingController();
  final TextEditingController durationController = TextEditingController();
  final TextEditingController tagsController = TextEditingController();
  final TextEditingController posterUrlController = TextEditingController();
    
  List<String> selectedCategories = [];

  @override
  void initState() {
    super.initState();
    loadMovies();
  }

  Future<void> loadMovies() async {
    try {
      setState(() => isLoading = true);
      final response = await supabaseService.getMovies();

      movies = List<Map<String, dynamic>>.from(response);

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

      return matchesSearch && matchesCategory;
    }).toList();
  }





  Future<void> addMovie() async {
    if (titleController.text.isEmpty || videoUrlController.text.isEmpty) {
      Get.snackbar(
        'خطأ',
        'العنوان ورابط الفيديو مطلوبان',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      final movieData = {
        'id': uuid.v4(),
        'title': titleController.text,
        'description': descriptionController.text,
        'categories': selectedCategories,
        'posterUrl': posterUrlController.text,
        'videoUrl': videoUrlController.text,
        'isSeries': false,
        'rating': 0.0,
        'views': 0,
        'year': yearController.text,
        'duration': durationController.text,
        // 'isActive': true, // Removed to avoid DB error
      };

      await supabaseService.addMovie(movieData);

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
    }
  }

  Future<void> updateMovie(String movieId, Map<String, dynamic> currentData) async {
    if (titleController.text.isEmpty || videoUrlController.text.isEmpty) {
      Get.snackbar(
        'خطأ',
        'العنوان ورابط الفيديو مطلوبان',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      final movieData = {
        'title': titleController.text,
        'description': descriptionController.text,
        'categories': selectedCategories,
        'posterUrl': posterUrlController.text,
        'videoUrl': videoUrlController.text,
        'year': yearController.text,
        'duration': durationController.text,
        // 'isActive': true, // Removed to avoid DB error
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
    }
  }



  Future<void> archiveMovie(String movieId) async {
    try {
      await supabaseService.updateMovie(movieId, {'archived': true});
      await loadMovies();
      Get.snackbar(
        'نجاح',
        'تم أرشفة الفيلم بنجاح',
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
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
              if (movie['categories'] != null)
                Text('التصنيفات: ${(movie['categories'] as List).join(', ')}'),
              if (movie['description']?.isNotEmpty == true)
                Text('الوصف: ${movie['description']}'),
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

  void showAddEditMovieDialog({Map<String, dynamic>? movie}) {
    // Removed isActive state and related code to avoid DB errors
    if (movie != null) {
      titleController.text = movie['title'] ?? '';
      descriptionController.text = movie['description'] ?? '';
      videoUrlController.text = movie['videoUrl'] ?? '';
      yearController.text = movie['year']?.toString() ?? '';
      durationController.text = movie['duration']?.toString() ?? '';
      tagsController.text = (movie['tags'] as List?)?.join(', ') ?? '';
      selectedCategories = List<String>.from(movie['categories'] ?? []);
      // isActive = movie['isActive'] ?? true; // Removed
      posterUrlController.text = movie['posterUrl'] ?? '';
    } else {
      titleController.clear();
      descriptionController.clear();
      videoUrlController.clear();
      yearController.clear();
      durationController.clear();
      tagsController.clear();
      selectedCategories.clear();
      // isActive = true; // Removed
      posterUrlController.clear();
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
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                // Poster URL
                TextField(
                  controller: posterUrlController,
                  decoration: const InputDecoration(
                    labelText: 'رابط البوستر',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                // Remove any file picker or upload UI for poster or video, only allow URL input

                // Title
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'عنوان الفيلم *',
                    border: OutlineInputBorder(),
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

                // Video URL
                TextField(
                  controller: videoUrlController,
                  decoration: const InputDecoration(
                    labelText: 'رابط الفيديو *',
                    border: OutlineInputBorder(),
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
                          labelText: 'السنة',
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
                Wrap(
                  spacing: 8,
                children: ['أكشن', 'دراما', 'كوميدي', 'رعب', 'رومانسي', 'هندي', 'أجنبي', 'عربي مصري'].map((category) {
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
                  ),
                ),
                const SizedBox(height: 8),

                // Active Status
                Row(
                  children: [
                    // Removed isActive checkbox to avoid DB errors
                    // Checkbox(
                    //   value: isActive,
                    //   onChanged: (value) => setState(() => isActive = value ?? true),
                    // ),
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
                      onPressed: () {
                        if (movie == null) {
                          addMovie();
                        } else {
                          updateMovie(movie['id'], movie);
                        }
                      },
                      child: Text(movie == null ? 'إضافة' : 'تحديث'),
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
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: loadMovies,
            tooltip: 'تحديث',
          ),
        ],
      ),
      body: Scrollbar(
        thumbVisibility: true,
        thickness: 8,
        radius: const Radius.circular(8),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Google AdMob Banner
              const BannerAdWidget(),

              // Search and Filters
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: searchController,
                        decoration: const InputDecoration(
                          labelText: 'بحث بالأفلام',
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(),
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
                        ...['أكشن', 'دراما', 'كوميدي', 'رعب', 'رومانسي', 'هندي', 'أجنبي', 'عربي مصري'].map((category) {
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
                      onPressed: importMoviesFromCsv,
                      icon: const Icon(Icons.import_export),
                      label: const Text('استيراد CSV'),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton.icon(
                      onPressed: exportMoviesToCsv,
                      icon: const Icon(Icons.download),
                      label: const Text('تصدير CSV'),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Movies Table
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.6, // Fixed height for table
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : filteredMovies.isEmpty
                        ? const Center(child: Text('لا توجد أفلام'))
                        : Scrollbar(
                            controller: _horizontalScrollController,
                            thumbVisibility: true,
                            thickness: 8,
                            radius: const Radius.circular(8),
                            trackVisibility: true,
                            interactive: true,
                            scrollbarOrientation: ScrollbarOrientation.right,
                            child: SingleChildScrollView(
                              controller: _horizontalScrollController,
                              scrollDirection: Axis.horizontal,
                              child: Scrollbar(
                                controller: _verticalScrollController,
                                thumbVisibility: true,
                                thickness: 8,
                                radius: const Radius.circular(8),
                                trackVisibility: true,
                                interactive: true,
                                scrollbarOrientation: ScrollbarOrientation.bottom,
                                child: SingleChildScrollView(
                                  controller: _verticalScrollController,
                                  scrollDirection: Axis.vertical,
                                  child: DataTable(
                                  columns: const [
                                    DataColumn(label: Text('البوستر')),
                                    DataColumn(label: Text('العنوان')),
                                    DataColumn(label: Text('السنة')),
                                    DataColumn(label: Text('التصنيفات')),
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
                                              )
                                            : const Icon(Icons.movie),
                                      ),
                                      DataCell(Text(movie['title'] ?? 'بدون عنوان')),
                                      DataCell(Text(movie['year']?.toString() ?? '')),
                                      DataCell(Text(
                                        (movie['categories'] as List?)?.join(', ') ?? '',
                                        maxLines: 2,
                                      )),
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
                                            onPressed: () => showAddEditMovieDialog(movie: movie),
                                            tooltip: 'تعديل',
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.archive, size: 20),
                                            onPressed: () => archiveMovie(movie['id']),
                                            tooltip: 'أرشفة',
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
        ),
      ),
    );
  }

  Future<void> importMoviesFromCsv() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final content = await file.readAsString();
        final lines = content.split('\n');

        if (lines.isEmpty) {
          Get.snackbar('خطأ', 'الملف فارغ', backgroundColor: Colors.red, colorText: Colors.white);
          return;
        }

        // Skip header row
        final dataLines = lines.skip(1).where((line) => line.trim().isNotEmpty);

        int successCount = 0;
        int errorCount = 0;

        for (final line in dataLines) {
          try {
            final columns = line.split(',');
            if (columns.length >= 3) {
              final movieData = {
                'title': columns[0].trim(),
                'description': columns[1].trim(),
                'videoUrl': columns[2].trim(),
                'year': columns[3].trim(),
                'duration': columns[4].trim(),
                'categories': columns[5].trim().isEmpty ? [] : columns[5].split(';').map((e) => e.trim()).toList(),
                'posterUrl': columns[6].trim(),
                'isSeries': false,
                'rating': 0.0,
                'views': 0,
              };

              await supabaseService.addMovie(movieData);
              successCount++;
            }
          } catch (e) {
            errorCount++;
          }
        }

        await loadMovies();

        Get.snackbar(
          'نجاح',
          'تم استيراد $successCount فيلم بنجاح${errorCount > 0 ? ', فشل في $errorCount' : ''}',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'فشل في استيراد الملف: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> exportMoviesToCsv() async {
    try {
      final csvData = StringBuffer();

      // Add header
      csvData.writeln('العنوان,الوصف,رابط الفيديو,السنة,المدة,التصنيفات,الكلمات المفتاحية');

      // Add movie data
      for (final movie in movies) {
        final title = movie['title'] ?? '';
        final description = movie['description'] ?? '';
        final videoUrl = movie['videoUrl'] ?? '';
        final year = movie['year']?.toString() ?? '';
        final duration = movie['duration']?.toString() ?? '';
        final categories = (movie['categories'] as List?)?.join(';') ?? '';
        final tags = (movie['tags'] as List?)?.join(';') ?? '';

        csvData.writeln('$title,$description,$videoUrl,$year,$duration,$categories,$tags');
      }

      final fileName = 'movies_export_${DateTime.now().millisecondsSinceEpoch}.csv';
      final file = File(fileName);
      await file.writeAsString(csvData.toString());

      Get.snackbar(
        'نجاح',
        'تم تصدير الأفلام إلى $fileName',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'فشل في تصدير الأفلام: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    videoUrlController.dispose();
    yearController.dispose();
    durationController.dispose();
    tagsController.dispose();
    searchController.dispose();
    _horizontalScrollController.dispose();
    _verticalScrollController.dispose();
    super.dispose();
  }
}
