-- تحديث إعدادات AdMob في قاعدة البيانات
-- Update AdMob Configuration in Database

-- تحديث معرفات إعلانات البانر - Update Banner Ad Unit IDs
UPDATE app_config
SET config_value = 'ca-app-pub-1234567890123456/1234567890',
    updated_at = NOW()
WHERE config_key = 'admob_banner_android';

UPDATE app_config
SET config_value = 'ca-app-pub-1234567890123456/0987654321',
    updated_at = NOW()
WHERE config_key = 'admob_banner_ios';

-- تحديث معرفات إعلانات بينية - Update Interstitial Ad Unit IDs
UPDATE app_config
SET config_value = 'ca-app-pub-1234567890123456/2345678901',
    updated_at = NOW()
WHERE config_key = 'admob_interstitial_android';

UPDATE app_config
SET config_value = 'ca-app-pub-1234567890123456/3456789012',
    updated_at = NOW()
WHERE config_key = 'admob_interstitial_ios';

-- تحديث معرفات إعلانات مكافآت - Update Rewarded Ad Unit IDs
UPDATE app_config
SET config_value = 'ca-app-pub-1234567890123456/4567890123',
    updated_at = NOW()
WHERE config_key = 'admob_rewarded_android';

UPDATE app_config
SET config_value = 'ca-app-pub-1234567890123456/5678901234',
    updated_at = NOW()
WHERE config_key = 'admob_rewarded_ios';

-- تحديث معرفات التطبيق - Update App IDs
UPDATE app_config
SET config_value = 'ca-app-pub-1234567890123456~1234567890',
    updated_at = NOW()
WHERE config_key = 'admob_app_id_android';

UPDATE app_config
SET config_value = 'ca-app-pub-1234567890123456~0987654321',
    updated_at = NOW()
WHERE config_key = 'admob_app_id_ios';

-- التحقق من التحديثات - Verify updates
SELECT config_key, config_value, description
FROM app_config
WHERE config_key LIKE 'admob_%'
ORDER BY config_key;

-- تعليمات لاستبدال المعرفات بالقيم الصحيحة:
/*
لاستبدال المعرفات بالقيم الصحيحة:

1. استبدل جميع القيم ca-app-pub-1234567890123456/XXXXXXXXXX
   بمعرفات إعلاناتك الحقيقية من Google AdMob Console

2. للحصول على المعرفات الصحيحة:
   - اذهب إلى: https://apps.admob.com/
   - اختر تطبيقك من القائمة
   - اذهب إلى "Ad units" في القائمة الجانبية
   - انسخ معرفات الإعلانات بالصيغة: ca-app-pub-XXXXXXXXXX/XXXXXXXXXX

3. شغل هذا الملف في Supabase SQL Editor بعد استبدال القيم

To replace with correct values:

1. Replace all ca-app-pub-1234567890123456/XXXXXXXXXX values
   with your actual ad unit IDs from Google AdMob Console

2. To get correct IDs:
   - Go to: https://apps.admob.com/
   - Select your app from the list
   - Go to "Ad units" in the sidebar
   - Copy ad unit IDs in format: ca-app-pub-XXXXXXXXXX/XXXXXXXXXX

3. Run this file in Supabase SQL Editor after replacing values
*/
