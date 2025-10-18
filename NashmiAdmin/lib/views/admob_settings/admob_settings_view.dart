import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nashmi_admin_v2/services/supabase_service.dart';

class AdMobSettingsView extends StatefulWidget {
  const AdMobSettingsView({super.key});

  @override
  State<AdMobSettingsView> createState() => _AdMobSettingsViewState();
}

class _AdMobSettingsViewState extends State<AdMobSettingsView> {
  final SupabaseService supabaseService = Get.find<SupabaseService>();

  // Controllers for AdMob settings
  final TextEditingController bannerAndroidController = TextEditingController();
  final TextEditingController bannerIosController = TextEditingController();
  final TextEditingController interstitialAndroidController = TextEditingController();
  final TextEditingController interstitialIosController = TextEditingController();
  final TextEditingController rewardedAndroidController = TextEditingController();
  final TextEditingController rewardedIosController = TextEditingController();
  final TextEditingController appIdAndroidController = TextEditingController();
  final TextEditingController appIdIosController = TextEditingController();

  bool isLoading = true;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    loadAdMobSettings();
  }

  Future<void> loadAdMobSettings() async {
    try {
      setState(() => isLoading = true);

      final config = await supabaseService.getAppConfig();

      setState(() {
        bannerAndroidController.text = config['admob_banner_android'] ?? '';
        bannerIosController.text = config['admob_banner_ios'] ?? '';
        interstitialAndroidController.text = config['admob_interstitial_android'] ?? '';
        interstitialIosController.text = config['admob_interstitial_ios'] ?? '';
        rewardedAndroidController.text = config['admob_rewarded_android'] ?? '';
        rewardedIosController.text = config['admob_rewarded_ios'] ?? '';
        appIdAndroidController.text = config['admob_app_id_android'] ?? '';
        appIdIosController.text = config['admob_app_id_ios'] ?? '';
      });
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'فشل في تحميل إعدادات AdMob: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> saveAdMobSettings() async {
    try {
      setState(() => isSaving = true);

      // Update Android Banner
      if (bannerAndroidController.text.isNotEmpty) {
        await supabaseService.updateConfigValue('admob_banner_android', bannerAndroidController.text);
      }

      // Update iOS Banner
      if (bannerIosController.text.isNotEmpty) {
        await supabaseService.updateConfigValue('admob_banner_ios', bannerIosController.text);
      }

      // Update Android Interstitial
      if (interstitialAndroidController.text.isNotEmpty) {
        await supabaseService.updateConfigValue('admob_interstitial_android', interstitialAndroidController.text);
      }

      // Update iOS Interstitial
      if (interstitialIosController.text.isNotEmpty) {
        await supabaseService.updateConfigValue('admob_interstitial_ios', interstitialIosController.text);
      }

      // Update Android Rewarded
      if (rewardedAndroidController.text.isNotEmpty) {
        await supabaseService.updateConfigValue('admob_rewarded_android', rewardedAndroidController.text);
      }

      // Update iOS Rewarded
      if (rewardedIosController.text.isNotEmpty) {
        await supabaseService.updateConfigValue('admob_rewarded_ios', rewardedIosController.text);
      }

      // Update Android App ID
      if (appIdAndroidController.text.isNotEmpty) {
        await supabaseService.updateConfigValue('admob_app_id_android', appIdAndroidController.text);
      }

      // Update iOS App ID
      if (appIdIosController.text.isNotEmpty) {
        await supabaseService.updateConfigValue('admob_app_id_ios', appIdIosController.text);
      }

      Get.snackbar(
        'نجاح',
        'تم حفظ إعدادات AdMob بنجاح',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      // Reload settings to show updated values
      await loadAdMobSettings();
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'فشل في حفظ إعدادات AdMob: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setState(() => isSaving = false);
    }
  }

  Widget buildAdMobField({
    required String label,
    required TextEditingController controller,
    required String placeholder,
    String? helperText,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: placeholder,
          helperText: helperText,
          border: const OutlineInputBorder(),
          prefixIcon: const Icon(Icons.ad_units),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إعدادات إعلانات AdMob'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: loadAdMobSettings,
            tooltip: 'تحديث',
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'معرفات التطبيق - App IDs',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 16),

                          buildAdMobField(
                            label: 'معرف تطبيق Android',
                            controller: appIdAndroidController,
                            placeholder: 'ca-app-pub-XXXXXXXXXX~XXXXXXXXXX',
                            helperText: 'معرف تطبيق AdMob للأندرويد',
                          ),

                          buildAdMobField(
                            label: 'معرف تطبيق iOS',
                            controller: appIdIosController,
                            placeholder: 'ca-app-pub-XXXXXXXXXX~XXXXXXXXXX',
                            helperText: 'معرف تطبيق AdMob للآيفون',
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'إعلانات البانر - Banner Ads',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 16),

                          buildAdMobField(
                            label: 'بانر Android',
                            controller: bannerAndroidController,
                            placeholder: 'ca-app-pub-XXXXXXXXXX/XXXXXXXXXX',
                            helperText: 'معرف إعلان بانر للأندرويد',
                          ),

                          buildAdMobField(
                            label: 'بانر iOS',
                            controller: bannerIosController,
                            placeholder: 'ca-app-pub-XXXXXXXXXX/XXXXXXXXXX',
                            helperText: 'معرف إعلان بانر للآيفون',
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'إعلانات بينية - Interstitial Ads',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 16),

                          buildAdMobField(
                            label: 'بيني Android',
                            controller: interstitialAndroidController,
                            placeholder: 'ca-app-pub-XXXXXXXXXX/XXXXXXXXXX',
                            helperText: 'معرف إعلان بيني للأندرويد',
                          ),

                          buildAdMobField(
                            label: 'بيني iOS',
                            controller: interstitialIosController,
                            placeholder: 'ca-app-pub-XXXXXXXXXX/XXXXXXXXXX',
                            helperText: 'معرف إعلان بيني للآيفون',
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'إعلانات مكافآت - Rewarded Ads',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 16),

                          buildAdMobField(
                            label: 'مكافآت Android',
                            controller: rewardedAndroidController,
                            placeholder: 'ca-app-pub-XXXXXXXXXX/XXXXXXXXXX',
                            helperText: 'معرف إعلان مكافآت للأندرويد',
                          ),

                          buildAdMobField(
                            label: 'مكافآت iOS',
                            controller: rewardedIosController,
                            placeholder: 'ca-app-pub-XXXXXXXXXX/XXXXXXXXXX',
                            helperText: 'معرف إعلان مكافآت للآيفون',
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: isSaving ? null : saveAdMobSettings,
                      icon: isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.save),
                      label: Text(isSaving ? 'جاري الحفظ...' : 'حفظ الإعدادات'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'تعليمات:',
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                        ),
                        SizedBox(height: 8),
                        Text('• احصل على معرفات الإعلانات من Google AdMob Console'),
                        Text('• اذهب إلى: https://apps.admob.com/'),
                        Text('• اختر تطبيقك واذهب إلى "Ad units"'),
                        Text('• انسخ المعرفات بالصيغة الصحيحة'),
                        Text('• احفظ الإعدادات لتطبيقها على التطبيق'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  @override
  void dispose() {
    bannerAndroidController.dispose();
    bannerIosController.dispose();
    interstitialAndroidController.dispose();
    interstitialIosController.dispose();
    rewardedAndroidController.dispose();
    rewardedIosController.dispose();
    appIdAndroidController.dispose();
    appIdIosController.dispose();
    super.dispose();
  }
}
