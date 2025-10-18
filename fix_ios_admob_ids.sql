-- إصلاح iOS AdMob IDs - Fix iOS AdMob IDs
-- تحديث مباشر وواضح - Direct and clear update

-- 1. فحص الحالة الحالية أولاً
SELECT
    'Current Status' as info,
    config_key,
    config_value,
    CASE
        WHEN config_value LIKE 'ca-app-pub-%' THEN '✅ Production ID'
        WHEN config_value LIKE 'YOUR_%' THEN '❌ Placeholder'
        ELSE '❓ Other'
    END as status
FROM app_config
WHERE config_key LIKE 'admob_%'
ORDER BY config_key;

-- 2. تحديث iOS Banner ID
UPDATE app_config
SET config_value = 'ca-app-pub-XXXXXXXXXX/XXXXXXXXXX',
    updated_at = NOW()
WHERE config_key = 'admob_banner_ios';

-- 3. تحديث iOS Interstitial ID
UPDATE app_config
SET config_value = 'ca-app-pub-XXXXXXXXXX/XXXXXXXXXX',
    updated_at = NOW()
WHERE config_key = 'admob_interstitial_ios';

-- 4. تحديث iOS Rewarded ID
UPDATE app_config
SET config_value = 'ca-app-pub-XXXXXXXXXX/XXXXXXXXXX',
    updated_at = NOW()
WHERE config_key = 'admob_rewarded_ios';

-- 5. تحديث iOS App ID
UPDATE app_config
SET config_value = 'ca-app-pub-XXXXXXXXXX~XXXXXXXXXX',
    updated_at = NOW()
WHERE config_key = 'admob_app_id_ios';

-- 6. فحص النتائج النهائية
SELECT
    'Final Status' as info,
    config_key,
    config_value,
    CASE
        WHEN config_value LIKE 'ca-app-pub-%' THEN '✅ Production ID'
        WHEN config_value LIKE 'YOUR_%' THEN '❌ Placeholder'
        ELSE '❓ Other'
    END as status,
    updated_at
FROM app_config
WHERE config_key LIKE 'admob_%'
ORDER BY config_key;
