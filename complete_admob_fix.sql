-- إصلاح شامل لإعدادات AdMob - Complete AdMob Configuration Fix
-- هذا الاستعلام يحل جميع المشاكل المحتملة - This query fixes all possible issues

-- 1. فحص جميع المعرفات الحالية
SELECT
    'Current AdMob Configuration' as info,
    config_key,
    config_value,
    CASE
        WHEN config_value LIKE 'ca-app-pub-%' THEN '✅ Production ID'
        WHEN config_value LIKE 'YOUR_%' THEN '❌ Placeholder'
        WHEN config_value IS NULL OR config_value = '' THEN '❌ Empty'
        ELSE '❓ Other'
    END as status,
    updated_at
FROM app_config
WHERE config_key LIKE 'admob_%'
ORDER BY config_key;

-- 2. إنشاء iOS IDs إذا لم تكن موجودة
INSERT INTO app_config (config_key, config_value, description)
SELECT key_name, 'ca-app-pub-XXXXXXXXXX/XXXXXXXXXX', 'iOS AdMob ID'
FROM (
    VALUES
        ('admob_banner_ios', 'iOS Banner Ad Unit ID'),
        ('admob_interstitial_ios', 'iOS Interstitial Ad Unit ID'),
        ('admob_rewarded_ios', 'iOS Rewarded Ad Unit ID'),
        ('admob_app_id_ios', 'iOS App ID')
) AS new_keys(key_name, description)
WHERE NOT EXISTS (
    SELECT 1 FROM app_config WHERE config_key = new_keys.key_name
);

-- 3. تحديث جميع iOS IDs
UPDATE app_config
SET config_value = 'ca-app-pub-XXXXXXXXXX/XXXXXXXXXX',
    updated_at = NOW()
WHERE config_key = 'admob_banner_ios';

UPDATE app_config
SET config_value = 'ca-app-pub-XXXXXXXXXX/XXXXXXXXXX',
    updated_at = NOW()
WHERE config_key = 'admob_interstitial_ios';

UPDATE app_config
SET config_value = 'ca-app-pub-XXXXXXXXXX/XXXXXXXXXX',
    updated_at = NOW()
WHERE config_key = 'admob_rewarded_ios';

UPDATE app_config
SET config_value = 'ca-app-pub-XXXXXXXXXX~XXXXXXXXXX',
    updated_at = NOW()
WHERE config_key = 'admob_app_id_ios';

-- 4. فحص النتائج النهائية
SELECT
    'Final AdMob Configuration' as info,
    config_key,
    config_value,
    CASE
        WHEN config_value LIKE 'ca-app-pub-%' THEN '✅ Production ID'
        WHEN config_value LIKE 'YOUR_%' THEN '❌ Placeholder'
        WHEN config_value IS NULL OR config_value = '' THEN '❌ Empty'
        ELSE '❓ Other'
    END as status,
    updated_at
FROM app_config
WHERE config_key LIKE 'admob_%'
ORDER BY config_key;

-- 5. تقرير شامل
DO $$
DECLARE
    android_count INTEGER := 0;
    ios_count INTEGER := 0;
    placeholder_count INTEGER := 0;
    production_count INTEGER := 0;
BEGIN
    SELECT COUNT(*) INTO android_count
    FROM app_config
    WHERE config_key LIKE 'admob_%android' AND config_value LIKE 'ca-app-pub-%';

    SELECT COUNT(*) INTO ios_count
    FROM app_config
    WHERE config_key LIKE 'admob_%ios' AND config_value LIKE 'ca-app-pub-%';

    SELECT COUNT(*) INTO placeholder_count
    FROM app_config
    WHERE config_key LIKE 'admob_%' AND config_value LIKE 'YOUR_%';

    SELECT COUNT(*) INTO production_count
    FROM app_config
    WHERE config_key LIKE 'admob_%' AND config_value LIKE 'ca-app-pub-%';

    RAISE NOTICE '=== تقرير إعدادات AdMob النهائي ===';
    RAISE NOTICE 'Android Production IDs: %', android_count;
    RAISE NOTICE 'iOS Production IDs: %', ios_count;
    RAISE NOTICE 'Placeholder Values: %', placeholder_count;
    RAISE NOTICE 'Total Production IDs: %', production_count;

    IF production_count >= 6 THEN
        RAISE NOTICE '✅ ممتاز! جميع المعرفات جاهزة للإنتاج';
    ELSE
        RAISE NOTICE '❌ ينقص % معرفات إنتاج', 6 - production_count;
    END IF;
END $$;
