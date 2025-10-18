import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nashmi_admin_v2/services/supabase_service.dart';
import 'package:uuid/uuid.dart';

class AddEpisodeScreen extends StatefulWidget {
  final String seriesId;
  final String seriesTitle;

  const AddEpisodeScreen({
    super.key,
    required this.seriesId,
    required this.seriesTitle,
  });

  @override
  State<AddEpisodeScreen> createState() => _AddEpisodeScreenState();
}

class _AddEpisodeScreenState extends State<AddEpisodeScreen> {
  final SupabaseService supabaseService = Get.find<SupabaseService>();
  final Uuid uuid = const Uuid();

  final TextEditingController episodeNumberController = TextEditingController();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController videoUrlController = TextEditingController();
  final TextEditingController embedCodeController = TextEditingController();

  bool isSaving = false;
  bool useVideoUrl =
      false; // Toggle between video URL and embed code, default to embed code

  @override
  void dispose() {
    episodeNumberController.dispose();
    titleController.dispose();
    descriptionController.dispose();
    videoUrlController.dispose();
    embedCodeController.dispose();
    super.dispose();
  }

  Future<void> _saveEpisode() async {
    // Clear the unused field when switching
    if (useVideoUrl) {
      embedCodeController.clear();
    } else {
      videoUrlController.clear();
    }

    // Validation
    if (titleController.text.isEmpty || episodeNumberController.text.isEmpty) {
      Get.snackbar(
        'خطأ',
        'يرجى ملء جميع الحقول المطلوبة',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (useVideoUrl && videoUrlController.text.isEmpty) {
      Get.snackbar(
        'خطأ',
        'رابط الفيديو مطلوب',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (!useVideoUrl && embedCodeController.text.isEmpty) {
      Get.snackbar(
        'خطأ',
        'كود التمضن مطلوب',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    setState(() => isSaving = true);

    try {
      final episodeData = {
        'id': uuid.v4(),
        'series_id': widget.seriesId,
        'episode_number': int.tryParse(episodeNumberController.text) ?? 0,
        'title': titleController.text,
        'description': descriptionController.text,
        'video_url': videoUrlController.text,
        'embed_code': embedCodeController.text,
        'duration': 0,
        'views': 0,
        'is_active': true,
        'posters': '',
      };

      await supabaseService.addEpisode(episodeData);

      Get.snackbar(
        'نجاح',
        'تم إضافة الحلقة بنجاح',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      Get.back(result: true); // Return true to indicate success
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'فشل في إضافة الحلقة: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setState(() => isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('إضافة حلقة لـ ${widget.seriesTitle}'),
        actions: [
          if (isSaving)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            )
          else
            TextButton(
              onPressed: _saveEpisode,
              child: const Text('حفظ', style: TextStyle(color: Colors.white)),
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: episodeNumberController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'رقم الحلقة *',
                  border: OutlineInputBorder(),
                  hintText: '1',
                ),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'عنوان الحلقة *',
                  border: OutlineInputBorder(),
                  hintText: 'أدخل عنوان الحلقة',
                ),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'وصف الحلقة',
                  border: OutlineInputBorder(),
                  hintText: 'أدخل وصف الحلقة',
                ),
              ),
              const SizedBox(height: 16),

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
                        onChanged: (value) {
                          setState(() => useVideoUrl = value ?? true);
                          // Clear the other field when switching
                          if (useVideoUrl) {
                            embedCodeController.clear();
                          } else {
                            videoUrlController.clear();
                          }
                        },
                      ),
                      const Text('رابط'),
                      const SizedBox(width: 16),
                      Radio<bool>(
                        value: false,
                        groupValue: useVideoUrl,
                        onChanged: (value) {
                          setState(() => useVideoUrl = value ?? false);
                          // Clear the other field when switching
                          if (useVideoUrl) {
                            embedCodeController.clear();
                          } else {
                            videoUrlController.clear();
                          }
                        },
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
                    hintText: 'https://example.com/episode1.m3u8',
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
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isSaving ? null : _saveEpisode,
                  child: isSaving
                      ? const CircularProgressIndicator()
                      : const Text('إضافة الحلقة'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
