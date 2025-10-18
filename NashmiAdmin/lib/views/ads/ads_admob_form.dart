import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nashmi_admin_v2/services/supabase_service.dart';
import 'package:nashmi_admin_v2/services/auth_service.dart';
import 'package:uuid/uuid.dart';

class AdsAdmobForm extends StatefulWidget {
  final Map<String, dynamic>? ad;

  const AdsAdmobForm({super.key, this.ad});

  @override
  State<AdsAdmobForm> createState() => _AdsAdmobFormState();
}

class _AdsAdmobFormState extends State<AdsAdmobForm> {
  final SupabaseService supabaseService = Get.find<SupabaseService>();
  final AuthService authService = Get.find<AuthService>();
  final Uuid uuid = const Uuid();

  final TextEditingController titleController = TextEditingController();
  final TextEditingController appIdController = TextEditingController();
  final TextEditingController adUnitIdController = TextEditingController();
  final TextEditingController frequencyController = TextEditingController();

  final TextEditingController startAtController = TextEditingController();
  final TextEditingController endAtController = TextEditingController();

  String selectedAdType = 'banner';
  bool isActive = true;

  @override
  void initState() {
    super.initState();
    if (widget.ad != null) {
      _loadAdData();
    } else {
      // Set default start and end dates
      startAtController.text = DateTime.now().toIso8601String();
      endAtController.text = DateTime.now().add(Duration(days: 365 * 10)).toIso8601String();
    }
  }

  void _loadAdData() {
    final ad = widget.ad!;
    titleController.text = ad['title'] ?? '';
    appIdController.text = ad['adMobAppId'] ?? '';
    adUnitIdController.text = ad['adUnitId'] ?? '';
    frequencyController.text = ad['frequency']?.toString() ?? '';
    startAtController.text = ad['start_at'] ?? '';
    endAtController.text = ad['end_at'] ?? '';
    selectedAdType = ad['adtype'] ?? 'banner';
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

    if (frequencyController.text.isEmpty) {
      Get.snackbar(
        'خطأ',
        'التكرار مطلوب',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }

    if (int.tryParse(frequencyController.text) == null) {
      Get.snackbar(
        'خطأ',
        'التكرار يجب أن يكون رقماً صحيحاً',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }

    if (startAtController.text.isEmpty || endAtController.text.isEmpty) {
      Get.snackbar(
        'خطأ',
        'تاريخ البداية والنهاية مطلوبان',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }

    return true;
  }

  Future<void> saveAd() async {
    if (!_validateForm()) return;

    try {
      final adData = {
        'title': titleController.text,
        'adMobAppId': appIdController.text,
        'adUnitId': adUnitIdController.text,
        'adtype': selectedAdType,
        'frequency': int.parse(frequencyController.text),
        'start_at': startAtController.text,
        'end_at': endAtController.text,
        'is_active': isActive,
      };

      if (widget.ad == null) {
        adData['id'] = uuid.v4();
        await supabaseService.addAd(adData);
        Get.snackbar(
          'نجاح',
          'تم إضافة الإعلان بنجاح',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        await supabaseService.updateAd(widget.ad!['id'], adData);
        Get.snackbar(
          'نجاح',
          'تم تحديث الإعلان بنجاح',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }

      Get.back(result: true);
    } catch (e) {
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
                controller: appIdController,
                decoration: const InputDecoration(
                  labelText: 'معرف تطبيق AdMob *',
                  border: OutlineInputBorder(),
                  hintText: 'ca-app-pub-xxxxxxxxxxxxxxxx~yyyyyyyyyy',
                ),
              ),
              const SizedBox(height: 8),

              TextField(
                controller: adUnitIdController,
                decoration: const InputDecoration(
                  labelText: 'معرف وحدة إعلان AdMob *',
                  border: OutlineInputBorder(),
                  hintText: 'ca-app-pub-xxxxxxxxxxxxxxxx/zzzzzzzzzz',
                ),
              ),
              const SizedBox(height: 8),

              DropdownButtonFormField<String>(
                value: selectedAdType,
                decoration: const InputDecoration(
                  labelText: 'نوع الإعلان *',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'banner', child: Text('بانر')),
                  DropdownMenuItem(value: 'interstitial', child: Text('إعلان داخلي')),
                  DropdownMenuItem(value: 'rewarded', child: Text('إعلان مكافأة')),
                  DropdownMenuItem(value: 'native', child: Text('إعلان أصلي')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      selectedAdType = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 8),

              TextField(
                controller: frequencyController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'التكرار (بالدقائق) *',
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
    appIdController.dispose();
    adUnitIdController.dispose();
    frequencyController.dispose();
    super.dispose();
  }
}
