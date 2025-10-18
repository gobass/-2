import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nashmi_admin_v2/services/supabase_service.dart';
import 'package:nashmi_admin_v2/services/auth_service.dart';
import 'package:uuid/uuid.dart';

class AdsCompleteForm extends StatefulWidget {
  final Map<String, dynamic>? ad;

  const AdsCompleteForm({super.key, this.ad});

  @override
  State<AdsCompleteForm> createState() => _AdsCompleteFormState();
}

class _AdsCompleteFormState extends State<AdsCompleteForm> {
  final SupabaseService supabaseService = Get.find<SupabaseService>();
  final AuthService authService = Get.find<AuthService>();
  final Uuid uuid = const Uuid();

  // Form controllers
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController imageUrlController = TextEditingController();
  final TextEditingController videoUrlController = TextEditingController();
  final TextEditingController targetUrlController = TextEditingController();
  final TextEditingController startAtController = TextEditingController();
  final TextEditingController endAtController = TextEditingController();

  // New AdMob fields
  final TextEditingController appIdController = TextEditingController();
  final TextEditingController adUnitIdController = TextEditingController();

  bool isActive = true;

  @override
  void initState() {
    super.initState();
    if (widget.ad != null) {
      _loadAdData();
    }
  }

    void _loadAdData() {
    final ad = widget.ad!;
    titleController.text = ad['title'] ?? '';
    descriptionController.text = ad['description'] ?? '';
    imageUrlController.text = ad['imageUrl'] ?? '';
    videoUrlController.text = ad['videoUrl'] ?? '';
    targetUrlController.text = ad['targetUrl'] ?? '';
    startAtController.text = ad['start_at'] ?? '';
    endAtController.text = ad['end_at'] ?? '';
    appIdController.text = ad['appId'] ?? '';
    adUnitIdController.text = ad['adUnitId'] ?? '';
    isActive = ad['is_active'] ?? true;
  }

  bool _validateForm() {
    if (titleController.text.isEmpty) {
      Get.snackbar(
        'خطأ',
        'عنوان الإعلان مطلوب',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }

    if (appIdController.text.isEmpty) {
      Get.snackbar(
        'خطأ',
        'معرف تطبيق AdMob مطلوب',
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

    if (adUnitIdController.text.isEmpty) {
      Get.snackbar(
        'خطأ',
        'معرف وحدة إعلان AdMob مطلوب',
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

    if (startAtController.text.isEmpty) {
      Get.snackbar(
        'خطأ',
        'تاريخ البداية مطلوب',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }

    // Additional validation can be added here for URLs and date formats

    return true;
  }

  Future<void> saveAd() async {
    print("Starting saveAd");
    if (!_validateForm()) {
      print("Validation failed");
      return;
    }

    try {
      print("Validation passed, preparing data");

      final endAt = endAtController.text.isEmpty
          ? DateTime.now().add(Duration(days: 7)).toIso8601String()
          : endAtController.text;

      final adData = {
        'title': titleController.text,
        'description': descriptionController.text,
        'imageUrl': imageUrlController.text,
        'videoUrl': videoUrlController.text,
        'targetUrl': targetUrlController.text,
        'start_at': startAtController.text,
        'end_at': endAt,
        'adMobAppId': appIdController.text,
        'adUnitId': adUnitIdController.text,
        'is_active': isActive,
      };

      print("Ad data prepared: $adData");

      if (widget.ad == null) {
        adData['id'] = uuid.v4();
        print("Adding new ad");
        await supabaseService.addAd(adData);
        print("Ad added to database");
        Get.snackbar(
          'نجاح',
          'تم إضافة الإعلان بنجاح',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        print("Updating existing ad");
        await supabaseService.updateAd(widget.ad!['id'], adData);
        print("Ad updated in database");
        Get.snackbar(
          'نجاح',
          'تم تحديث الإعلان بنجاح',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }

      print("About to close dialog with result true");
      // Refresh the UI by closing dialog and signaling success
      Get.back(result: true);
      print("Dialog closed");
    } catch (e) {
      print("Error in saveAd: $e");
      Get.snackbar(
        'خطأ',
        'فشل في حفظ الإعلان: $e',
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
                widget.ad == null ? 'إضافة إعلان جديد' : 'تعديل الإعلان',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'عنوان الإعلان *',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),

              TextField(
                controller: descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'وصف الإعلان',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),

              TextField(
                controller: imageUrlController,
                decoration: const InputDecoration(
                  labelText: 'رابط صورة الإعلان',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),

              TextField(
                controller: videoUrlController,
                decoration: const InputDecoration(
                  labelText: 'رابط فيديو الإعلان',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),

              TextField(
                controller: targetUrlController,
                decoration: const InputDecoration(
                  labelText: 'رابط الهدف',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),

              TextField(
                controller: startAtController,
                decoration: const InputDecoration(
                  labelText: 'تاريخ البداية (YYYY-MM-DD HH:MM:SS)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),

              TextField(
                controller: endAtController,
                decoration: const InputDecoration(
                  labelText: 'تاريخ النهاية (YYYY-MM-DD HH:MM:SS)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),

              TextField(
                controller: appIdController,
                decoration: const InputDecoration(
                  labelText: 'معرف تطبيق AdMob *',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),

              TextField(
                controller: adUnitIdController,
                decoration: const InputDecoration(
                  labelText: 'معرف وحدة إعلان AdMob *',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),

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

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: const Text('إلغاء'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: saveAd,
                    child: Text(widget.ad == null ? 'إضافة' : 'تحديث'),
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
    imageUrlController.dispose();
    videoUrlController.dispose();
    targetUrlController.dispose();
    startAtController.dispose();
    endAtController.dispose();
    appIdController.dispose();
    adUnitIdController.dispose();
    super.dispose();
  }
}
