import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nashmi_admin_v2/services/supabase_service.dart';
import 'package:nashmi_admin_v2/services/auth_service.dart';
import 'package:nashmi_admin_v2/models/category_model.dart';
import 'package:uuid/uuid.dart';

class MoviesCompleteForm extends StatefulWidget {
  final Map<String, dynamic>? movie;

  const MoviesCompleteForm({super.key, this.movie});

  @override
  State<MoviesCompleteForm> createState() => _MoviesCompleteFormState();
}

class _MoviesCompleteFormState extends State<MoviesCompleteForm> {
  final SupabaseService supabaseService = Get.find<SupabaseService>();
  final AuthService authService = Get.find<AuthService>();
  final Uuid uuid = const Uuid();

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
  List<CategoryModel> availableCategories = [];
  bool isActive = true;
  bool isSeries = false;
  String? posterUrl;
  bool isLoadingCategories = true;
  // Only embed code for movies

  @override
  void initState() {
    super.initState();
    _loadCategories();
    if (widget.movie != null) {
      _loadMovieData();
    }
  }

  Future<void> _loadCategories() async {
    try {
      setState(() => isLoadingCategories = true);
      final categories = await supabaseService.getCategories();
      setState(() {
        availableCategories = categories;
        isLoadingCategories = false;
      });
    } catch (e) {
      setState(() => isLoadingCategories = false);
      Get.snackbar(
        'Error',
        'Error loading categories: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _loadMovieData() {
    final movie = widget.movie!;
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
    // No toggle needed, only embed code
  }

  bool _validateForm() {
    // Title validation
    if (titleController.text.isEmpty) {
      Get.snackbar(
        'خطأ',
        'عنوان الفيلم مطلوب',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }

    // Embed code validation (only option for movies)
    if (embedCodeController.text.isEmpty) {
      Get.snackbar(
        'خطأ',
        'كود التمضن مطلوب',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }

    // Categories validation
    if (selectedCategories.isEmpty) {
      Get.snackbar(
        'خطأ',
        'يجب اختيار تصنيف واحد على الأقل',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }

    // Year validation
    final year = int.tryParse(yearController.text);
    if (yearController.text.isNotEmpty &&
        (year == null || year < 1900 || year > 2100)) {
      Get.snackbar(
        'خطأ',
        'سنة الإنتاج يجب أن تكون بين 1900 و 2100',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }

    // Duration validation
    final duration = int.tryParse(durationController.text);
    if (durationController.text.isNotEmpty &&
        (duration == null || duration < 0)) {
      Get.snackbar(
        'خطأ',
        'المدة يجب أن تكون رقم صحيح موجب',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }

    return true;
  }

  Future<void> saveMovie() async {
    if (!_validateForm()) return;

    try {
      final movieData = {
        'title': titleController.text,
        'slug': titleController.text.toLowerCase().replaceAll(' ', '-'),
        'description': descriptionController.text,
        'categories': selectedCategories,
        'year': int.tryParse(yearController.text) ?? 0,
        'duration': int.tryParse(durationController.text) ?? 0,
        'posterUrl': posterUrlController.text,
        'videoUrl': '', // Empty for movies
        'embedCode': embedCodeController.text,
        'isActive': isActive,
        'tags': tagsController.text
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList(),
        'views': 0,
        'createdat': DateTime.now().toIso8601String(),
      };

      if (widget.movie == null) {
        // Generate unique ID for new movie
        movieData['id'] = uuid.v4();
        await supabaseService.addMovie(movieData);
        Get.snackbar(
          'نجاح',
          'تم إضافة الفيلم بنجاح',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        await supabaseService.updateMovie(widget.movie!['id'], movieData);
        Get.snackbar(
          'نجاح',
          'تم تحديث الفيلم بنجاح',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }

      Get.back(result: true);
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'فشل في حفظ الفيلم: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.movie == null ? 'إضافة فيلم جديد' : 'تعديل الفيلم',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // Poster URL Field
              TextField(
                controller: posterUrlController,
                decoration: const InputDecoration(
                  labelText: 'رابط البوستر',
                  border: OutlineInputBorder(),
                  hintText: 'https://example.com/poster.jpg',
                ),
                keyboardType: TextInputType.url,
              ),

              const SizedBox(height: 16),

              // Title Field
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'عنوان الفيلم *',
                  border: OutlineInputBorder(),
                  hintText: 'أدخل عنوان الفيلم',
                ),
              ),
              const SizedBox(height: 8),

              // Description Field
              TextField(
                controller: descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'وصف الفيلم',
                  border: OutlineInputBorder(),
                  hintText: 'أدخل وصف الفيلم',
                ),
              ),
              const SizedBox(height: 8),

              // Embed Code Field (only option for movies)
              TextField(
                controller: embedCodeController,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'كود التمضن *',
                  border: OutlineInputBorder(),
                  hintText: '<iframe>...</iframe>',
                ),
              ),
              const SizedBox(height: 8),

              // Year and Duration Fields
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: yearController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'سنة الإنتاج',
                        border: OutlineInputBorder(),
                        hintText: '2024',
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
                        hintText: '120',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Categories Section
              const Text(
                'التصنيفات *',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              isLoadingCategories
                  ? const Center(child: CircularProgressIndicator())
                  : availableCategories.isEmpty
                  ? const Text('لا توجد فئات متاحة')
                  : Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: availableCategories.map((category) {
                        final isSelected = selectedCategories.contains(
                          category.displayName,
                        );
                        return FilterChip(
                          label: Text(category.displayName),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                selectedCategories.add(category.displayName);
                              } else {
                                selectedCategories.remove(category.displayName);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
              const SizedBox(height: 8),

              // Tags Field
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
              if (isSeries)
                const Text(
                  'ملاحظة: إذا كان مسلسلاً، سيتم إضافة الحلقات من صفحة إدارة المسلسلات',
                  style: TextStyle(color: Colors.blue, fontSize: 12),
                ),

              const SizedBox(height: 16),

              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: const Text('إلغاء'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: saveMovie,
                    child: Text(widget.movie == null ? 'إضافة' : 'تحديث'),
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
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    videoUrlController.dispose();
    embedCodeController.dispose();
    yearController.dispose();
    durationController.dispose();
    tagsController.dispose();
    posterUrlController.dispose();
    super.dispose();
  }
}

// Helper function to show the form
void showMoviesCompleteForm({Map<String, dynamic>? movie}) {
  Get.dialog(MoviesCompleteForm(movie: movie));
}
