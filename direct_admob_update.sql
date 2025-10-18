-- تحديث مباشر لإعدادات AdMob - Direct AdMob Configuration Update
-- أضف معرفاتك الحقيقية هنا - Add your real IDs here

-- استبدل القيم التالية بمعرفاتك الحقيقية من Google AdMob Console
-- Replace the following values with your real IDs from Google AdMob Console

-- معرف التطبيق - App ID
UPDATE app_config
SET config_value = 'ca-app-pub-XXXXXXXXXX~XXXXXXXXXX',
    updated_at = NOW()
WHERE config_key = 'admob_app_id_android';

UPDATE app_config
SET config_value = 'ca-app-pub-XXXXXXXXXX~XXXXXXXXXX',
    updated_at = NOW()
WHERE config_key = 'admob_app_id_ios';

-- إعلانات البانر - Banner Ads
UPDATE app_config
SET config_value = 'ca-app-pub-XXXXXXXXXX/XXXXXXXXXX',
    updated_at = NOW()
WHERE config_key = 'admob_banner_android';

UPDATE app_config
SET config_value = 'ca-app-pub-XXXXXXXXXX/XXXXXXXXXX',
    updated_at = NOW()
WHERE config_key = 'admob_banner_ios';

-- إعلانات بينية - Interstitial Ads
UPDATE app_config
SET config_value = 'ca-app-pub-XXXXXXXXXX/XXXXXXXXXX',
    updated_at = NOW()
WHERE config_key = 'admob_interstitial_android';

UPDATE app_config
SET config_value = 'ca-app-pub-XXXXXXXXXX/XXXXXXXXXX',
    updated_at = NOW()
WHERE config_key = 'admob_interstitial_ios';

-- إعلانات مكافآت - Rewarded Ads
UPDATE app_config
SET config_value = 'ca-app-pub-XXXXXXXXXX/XXXXXXXXXX',
    updated_at = NOW()
WHERE config_key = 'admob_rewarded_android';

UPDATE app_config
SET config_value = 'ca-app-pub-XXXXXXXXXX/XXXXXXXXXX',
    updated_at = NOW()
WHERE config_key = 'admob_rewarded_ios';

-- فحص النتائج - Check results
SELECT
    'Updated AdMob Configuration' as info_type,
    config_key,
    config_value,
    CASE
        WHEN config_value LIKE 'ca-app-pub-3940256099942544%' THEN '⚠️ TEST ID'
        WHEN config_value LIKE 'ca-app-pub-1234567890123456%' THEN '❌ PLACEHOLDER'
        WHEN config_value LIKE 'YOUR_%' THEN '❌ PLACEHOLDER'
        WHEN config_value LIKE 'ca-app-pub-%' THEN '✅ PRODUCTION ID'
        ELSE '❓ UNKNOWN'
    END as status,
    updated_at
FROM app_config
WHERE config_key LIKE 'admob_%'
ORDER BY config_key;
