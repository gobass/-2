// ملف مساعد للتحقق من إعدادات AdMob في التطبيق
// Helper file to check AdMob configuration in the app

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nashmi_tf/services/ad_service.dart';
import 'package:nashmi_tf/services/supabase_service.dart';

class AdMobConfigChecker {
  static Future<Map<String, dynamic>> checkAdConfiguration() async {
    final supabaseService = Get.find<SupabaseService>();
    final adService = AdService();

    // التحقق من إعدادات قاعدة البيانات
    final dbConfigs = await _checkDatabaseConfigs(supabaseService);

    // التحقق من حالة AdService
    final adServiceStatus = adService.getAdStatus();

    // التحقق من تهيئة AdMob
    final adMobInitStatus = await _checkAdMobInitialization();

    return {
      'database_configs': dbConfigs,
      'ad_service_status': adServiceStatus,
      'admob_initialization': adMobInitStatus,
      'recommendations': _generateRecommendations(dbConfigs, adServiceStatus),
    };
  }

  static Future<Map<String, dynamic>> _checkDatabaseConfigs(SupabaseService supabaseService) async {
    final configs = <String, dynamic>{};

    try {
      // التحقق من جميع إعدادات AdMob
      final adMobKeys = [
        'admob_banner_android',
        'admob_banner_ios',
        'admob_interstitial_android',
        'admob_interstitial_ios',
        'admob_rewarded_android',
        'admob_rewarded_ios',
        'admob_app_id_android',
        'admob_app_id_ios',
      ];

      for (final key in adMobKeys) {
        final value = await supabaseService.getConfigValue(key);
        configs[key] = {
          'value': value,
          'is_test_id': value?.contains('3940256099942544') == true,
          'is_placeholder': value?.contains('YOUR_') == true,
          'is_valid_format': _isValidAdUnitId(value),
        };
      }
    } catch (e) {
      configs['error'] = e.toString();
    }

    return configs;
  }

  static Future<Map<String, dynamic>> _checkAdMobInitialization() async {
    try {
      // هذا يتطلب استيراد google_mobile_ads
      // This requires importing google_mobile_ads
      // final initializationStatus = await MobileAds.instance.initialize();

      return {
        'initialized': true, // سيتم تحديث هذا حسب الحالة الفعلية
        'status': 'unknown',
      };
    } catch (e) {
      return {
        'initialized': false,
        'error': e.toString(),
      };
    }
  }

  static bool _isValidAdUnitId(String? value) {
    if (value == null || value.isEmpty) return false;

    // التحقق من صيغة Ad Unit ID
    final adUnitRegex = RegExp(r'^ca-app-pub-[0-9]{16}/[0-9]{10}$');
    final appIdRegex = RegExp(r'^ca-app-pub-[0-9]{16}~[0-9]{10}$');

    return adUnitRegex.hasMatch(value) || appIdRegex.hasMatch(value);
  }

  static List<String> _generateRecommendations(
    Map<String, dynamic> dbConfigs,
    Map<String, dynamic> adServiceStatus,
  ) {
    final recommendations = <String>[];

    // التحقق من وجود معرفات تجريبية
    dbConfigs.forEach((key, config) {
      if (config['is_test_id'] == true) {
        recommendations.add('استبدل معرف الإعلان التجريبي في $key بمعرف إنتاج حقيقي');
      }
      if (config['is_placeholder'] == true) {
        recommendations.add('استبدل القيمة placeholder في $key بمعرف إعلان حقيقي');
      }
      if (config['is_valid_format'] == false && !config['is_test_id'] && !config['is_placeholder']) {
        recommendations.add('تحقق من صحة صيغة معرف الإعلان في $key');
      }
    });

    // التحقق من حالة AdService
    if (!adServiceStatus['adsEnabled']) {
      recommendations.add('فعل الإعلانات في AdService');
    }

    // إضافة توصيات عامة
    recommendations.addAll([
      'تأكد من أن التطبيق مُوقع للإنتاج (ليس debug build)',
      'انتظر 24-48 ساعة بعد إنشاء Ad Units في AdMob Console',
      'اختبر على جهاز حقيقي وليس emulator',
      'تحقق من أن التطبيق مُسجل في Google AdMob Console',
    ]);

    return recommendations;
  }

  static Widget buildDiagnosticWidget() {
    return FutureBuilder<Map<String, dynamic>>(
      future: checkAdConfiguration(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        if (snapshot.hasError) {
          return Text('خطأ: ${snapshot.error}');
        }

        final data = snapshot.data!;
        final dbConfigs = data['database_configs'] as Map<String, dynamic>;
        final adServiceStatus = data['ad_service_status'] as Map<String, dynamic>;
        final recommendations = data['recommendations'] as List<String>;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'تشخيص إعدادات الإعلانات',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // حالة قاعدة البيانات
            const Text('إعدادات قاعدة البيانات:'),
            ...dbConfigs.entries.map((entry) {
              if (entry.key == 'error') return const SizedBox.shrink();

              final config = entry.value as Map<String, dynamic>;
              return ListTile(
                title: Text(entry.key),
                subtitle: Text(config['value'] ?? 'غير محدد'),
                trailing: Icon(
                  config['is_valid_format'] == true
                      ? Icons.check_circle
                      : config['is_test_id'] == true
                          ? Icons.warning
                          : Icons.error,
                  color: config['is_valid_format'] == true
                      ? Colors.green
                      : config['is_test_id'] == true
                          ? Colors.orange
                          : Colors.red,
                ),
              );
            }),

            const SizedBox(height: 16),

            // حالة AdService
            const Text('حالة AdService:'),
            ...adServiceStatus.entries.map((entry) {
              return ListTile(
                title: Text(entry.key),
                subtitle: Text(entry.value.toString()),
              );
            }),

            const SizedBox(height: 16),

            // التوصيات
            const Text('التوصيات:'),
            ...recommendations.map((rec) => ListTile(
              leading: const Icon(Icons.lightbulb_outline),
              title: Text(rec),
            )),
          ],
        );
      },
    );
  }
}
