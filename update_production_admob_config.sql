-- تحديث إعدادات AdMob للإنتاج - Production AdMob Configuration Update
-- يرجى استبدال القيم التالية بمعرفات إعلاناتك الحقيقية من Google AdMob Console
-- Please replace the following values with your actual ad unit IDs from Google AdMob Console

-- تحديث معرفات إعلانات البانر - Update Banner Ad Unit IDs
UPDATE app_config
SET config_value = 'YOUR_REAL_BANNER_AD_UNIT_ID_ANDROID',
    updated_at = NOW()
WHERE config_key = 'admob_banner_android';

UPDATE app_config
SET config_value = 'YOUR_REAL_BANNER_AD_UNIT_ID_IOS',
    updated_at = NOW()
WHERE config_key = 'admob_banner_ios';

-- تحديث معرفات إعلانات بينية - Update Interstitial Ad Unit IDs
UPDATE app_config
SET config_value = 'YOUR_REAL_INTERSTITIAL_AD_UNIT_ID_ANDROID',
    updated_at = NOW()
WHERE config_key = 'admob_interstitial_android';

UPDATE app_config
SET config_value = 'YOUR_REAL_INTERSTITIAL_AD_UNIT_ID_IOS',
    updated_at = NOW()
WHERE config_key = 'admob_interstitial_ios';

-- تحديث معرفات إعلانات مكافآت - Update Rewarded Ad Unit IDs
UPDATE app_config
SET config_value = 'YOUR_REAL_REWARDED_AD_UNIT_ID_ANDROID',
    updated_at = NOW()
WHERE config_key = 'admob_rewarded_android';

UPDATE app_config
SET config_value = 'YOUR_REAL_REWARDED_AD_UNIT_ID_IOS',
    updated_at = NOW()
WHERE config_key = 'admob_rewarded_ios';

-- تحديث معرفات التطبيق - Update App IDs
UPDATE app_config
SET config_value = 'YOUR_REAL_APP_ID_ANDROID',
    updated_at = NOW()
WHERE config_key = 'admob_app_id_android';

UPDATE app_config
SET config_value = 'YOUR_REAL_APP_ID_IOS',
    updated_at = NOW()
WHERE config_key = 'admob_app_id_ios';

-- التحقق من التحديثات - Verify updates
SELECT
    config_key,
    config_value,
    description,
    updated_at
FROM app_config
WHERE config_key LIKE 'admob_%'
ORDER BY config_key;

-- تعليمات لاستبدال المعرفات بالقيم الصحيحة:
-- Instructions for replacing with correct values:

/*
للحصول على معرفات الإعلانات الحقيقية:

1. اذهب إلى Google AdMob Console: https://apps.admob.com/
2. اختر تطبيقك من القائمة (يجب أن يكون التطبيق مُسجل مسبقاً)
3. اذهب إلى "Ad units" في القائمة الجانبية
4. انسخ معرفات الإعلانات بالصيغة التالية:
   - Banner: ca-app-pub-XXXXXXXXXX/XXXXXXXXXX
   - Interstitial: ca-app-pub-XXXXXXXXXX/XXXXXXXXXX
   - Rewarded: ca-app-pub-XXXXXXXXXX/XXXXXXXXXX
5. استبدل القيم في هذا الملف
6. شغل هذا الملف في Supabase SQL Editor

خطوات إنشاء Ad Units جديدة إذا لم تكن موجودة:

1. في AdMob Console، اذهب إلى "Ad units"
2. اضغط على "Create Ad Unit"
3. اختر نوع الإعلان:
   - Banner: للإعلانات في الأسفل/الأعلى
   - Interstitial: للإعلانات بينية (شاشة كاملة)
   - Rewarded: للإعلانات المكافئة
4. أدخل اسم الإعلان (مثل: "Banner Android")
5. انسخ معرف الإعلان الذي سيظهر
6. كرر لكل نوع إعلان ولكل منصة (Android/iOS)

ملاحظات مهمة:
- تأكد من أن التطبيق مُسجل في AdMob Console
- قد يستغرق ظهور الإعلانات 24-48 ساعة بعد التفعيل
- الإعلانات لن تظهر في وضع التطوير (debug mode)
- تأكد من أن التطبيق مُوقع للإنتاج وليس debug build
*/
