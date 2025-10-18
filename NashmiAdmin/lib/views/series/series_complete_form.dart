import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nashmi_admin_v2/services/supabase_service.dart';
import 'package:nashmi_admin_v2/services/auth_service.dart';
import 'package:nashmi_admin_v2/models/category_model.dart';
import 'package:uuid/uuid.dart';

class SeriesCompleteForm extends StatefulWidget {
  final Map<String, dynamic>? series;

  const SeriesCompleteForm({super.key, this.series});

  @override
  State<SeriesCompleteForm> createState() => _SeriesCompleteFormState();
}

class _SeriesCompleteFormState extends State<SeriesCompleteForm> {
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
  final TextEditingController episodeNumberController = TextEditingController();

  List<String> selectedCategories = [];
  List<CategoryModel> availableCategories = [];
  bool isActive = true;
  String? posterUrl;
  int episodeCount = 0;
  bool isSaving = false; // Add loading state
  bool isLoadingCategories = true;
  bool useVideoUrl =
      false; // Toggle between video URL and embed code, default to embed code

  @override
  void initState() {
    super.initState();
    _loadCategories();
    if (widget.series != null) {
      _loadSeriesData();
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

  void _loadSeriesData() {
    final series = widget.series!;
    titleController.text = series['title'] ?? '';
    descriptionController.text = series['description'] ?? '';
    videoUrlController.text = series['video_url'] ?? '';
    embedCodeController.text = series['embed_code'] ?? '';
    yearController.text = series['year']?.toString() ?? '';
    durationController.text = series['duration']?.toString() ?? '';
    tagsController.text = (series['tags'] as List?)?.join(', ') ?? '';
    selectedCategories = List<String>.from(series['categories'] ?? []);
    isActive = series['isActive'] ?? true;
    posterUrl = series['posterUrl']; // Load from posterUrl (database field)
    posterUrlController.text =
        series['posterUrl'] ?? ''; // Load from posterUrl (database field)
    episodeCount = series['total_episodes'] ?? 0;
    episodeNumberController.text = episodeCount.toString();
    useVideoUrl = series['embed_code']?.isNotEmpty == true
        ? false
        : true; // Default to embed code if exists, otherwise video URL
  }

  bool _validateForm() {
    if (titleController.text.isEmpty) {
      Get.snackbar(
        'خطأ',
        'عنوان المسلسل مطلوب',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
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

    final episodeNumber = int.tryParse(episodeNumberController.text);
    if (episodeNumberController.text.isNotEmpty &&
        (episodeNumber == null || episodeNumber < 0)) {
      Get.snackbar(
        'خطأ',
        'عدد الحلقات يجب أن يكون رقم صحيح موجب',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }

    return true;
  }

  Future<void> saveSeries() async {
    if (!_validateForm()) return;

    setState(() => isSaving = true); // Show loading state

    try {
      final seriesData = {
        'title': titleController.text,
        'slug': titleController.text.toLowerCase().replaceAll(' ', '-'),
        'description': descriptionController.text,
        'categories': selectedCategories,
        'year': int.tryParse(yearController.text) ?? 0,
        'duration': int.tryParse(durationController.text) ?? 0,
        'posterUrl':
            posterUrlController.text, // Use camelCase to match DB schema
        'video_url': videoUrlController.text,
        'embed_code': embedCodeController.text,
        'tags': tagsController.text
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList(),
        'views': 0,
        'rating': 0.0,
        'total_episodes': int.tryParse(episodeNumberController.text) ?? 0,
        'isSeries': true,
      };

      if (widget.series == null) {
        seriesData['id'] = uuid.v4();
        await supabaseService.addSeries(seriesData);
        Get.snackbar(
          'نجاح',
          'تم إضافة المسلسل بنجاح',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 3),
        );
      } else {
        seriesData['isSeries'] =
            true; // Ensure isSeries remains true for updates
        await supabaseService.updateSeries(widget.series!['id'], seriesData);
        Get.snackbar(
          'نجاح',
          'تم تحديث المسلسل بنجاح',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 3),
        );
      }

      // Wait a bit more to ensure database operation is complete
      await Future.delayed(const Duration(seconds: 1));

      if (mounted) {
        Get.back(result: true);
      }
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'فشل في حفظ المسلسل: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
    } finally {
      if (mounted) {
        setState(() => isSaving = false);
      }
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
                widget.series == null ? 'إضافة مسلسل جديد' : 'تعديل المسلسل',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // Image URL Field
              TextField(
                controller: posterUrlController,
                decoration: const InputDecoration(
                  labelText: 'رابط الصورة',
                  border: OutlineInputBorder(),
                  hintText: 'https://example.com/image.jpg',
                ),
                keyboardType: TextInputType.url,
              ),

              const SizedBox(height: 16),

              // Title Field
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'عنوان المسلسل *',
                  border: OutlineInputBorder(),
                  hintText: 'أدخل عنوان المسلسل',
                ),
              ),
              const SizedBox(height: 8),

              // Description Field
              TextField(
                controller: descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'وصف المسلسل',
                  border: OutlineInputBorder(),
                  hintText: 'أدخل وصف المسلسل',
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

              // Video URL or Embed Code Field
              if (useVideoUrl)
                TextField(
                  controller: videoUrlController,
                  decoration: const InputDecoration(
                    labelText: 'رابط الفيديو *',
                    border: OutlineInputBorder(),
                    hintText: 'https://example.com/video.m3u8',
                  ),
                  keyboardType: TextInputType.url,
                )
              else
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
                        hintText: '45',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Episode Number Field
              TextField(
                controller: episodeNumberController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'عدد الحلقات',
                  border: OutlineInputBorder(),
                  hintText: '10',
                ),
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

              // Active Status
              Row(
                children: [
                  Checkbox(
                    value: isActive,
                    onChanged: (value) =>
                        setState(() => isActive = value ?? true),
                  ),
                  const Text('نشط'),
                ],
              ),
              const SizedBox(height: 16),

              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: isSaving ? null : () => Get.back(),
                    child: const Text('إلغاء'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: isSaving ? null : () => saveSeries(),
                    child: isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(widget.series == null ? 'إضافة' : 'تحديث'),
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
    episodeNumberController.dispose();
    super.dispose();
  }
}

// Helper function to show the form
void showSeriesCompleteForm({Map<String, dynamic>? series}) {
  Get.dialog(SeriesCompleteForm(series: series));
}
