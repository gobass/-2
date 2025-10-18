-- فحص إعدادات AdMob الحالية في قاعدة البيانات
-- Check current AdMob configuration in database

-- 1. التحقق من وجود جدول app_config
SELECT
    'app_config table exists' as check_name,
    CASE WHEN EXISTS (
        SELECT 1 FROM information_schema.tables
        WHERE table_name = 'app_config' AND table_schema = 'public'
    ) THEN '✅ EXISTS' ELSE '❌ MISSING' END as status;

-- 2. عرض جميع إعدادات AdMob الحالية
SELECT
    'Current AdMob Configuration' as info_type,
    config_key,
    config_value,
    CASE
        WHEN config_value LIKE 'ca-app-pub-3940256099942544%' THEN '⚠️ TEST ID - لن تظهر إعلانات حقيقية'
        WHEN config_value LIKE 'ca-app-pub-1234567890123456%' THEN '❌ PLACEHOLDER - يحتاج تحديث'
        WHEN config_value LIKE 'YOUR_%' THEN '❌ PLACEHOLDER - يحتاج تحديث'
        WHEN config_value LIKE 'ca-app-pub-%' THEN '✅ PRODUCTION ID - جاهز للاستخدام'
        ELSE '❓ UNKNOWN FORMAT'
    END as status,
    description
FROM app_config
WHERE config_key LIKE 'admob_%'
ORDER BY config_key;

-- 3. تقرير المشاكل
DO $$
DECLARE
    test_ids INTEGER := 0;
    placeholders INTEGER := 0;
    production_ids INTEGER := 0;
BEGIN
    SELECT COUNT(*) INTO test_ids
    FROM app_config
    WHERE config_key LIKE 'admob_%'
    AND config_value LIKE 'ca-app-pub-3940256099942544%';

    SELECT COUNT(*) INTO placeholders
    FROM app_config
    WHERE config_key LIKE 'admob_%'
    AND (config_value LIKE 'YOUR_%' OR config_value LIKE 'ca-app-pub-1234567890123456%');

    SELECT COUNT(*) INTO production_ids
    FROM app_config
    WHERE config_key LIKE 'admob_%'
    AND config_value LIKE 'ca-app-pub-%'
    AND config_value NOT LIKE 'ca-app-pub-3940256099942544%'
    AND config_value NOT LIKE 'ca-app-pub-1234567890123456%';

    RAISE NOTICE '=== تقرير حالة إعدادات AdMob ===';
    RAISE NOTICE 'معرفات تجريبية (Test IDs): %', test_ids;
    RAISE NOTICE 'قيم placeholder: %', placeholders;
    RAISE NOTICE 'معرفات إنتاج حقيقية: %', production_ids;

    IF test_ids > 0 THEN
        RAISE NOTICE '⚠️ تحذير: توجد معرفات إعلانات تجريبية. الإعلانات لن تظهر في التطبيق المُنشر!';
    END IF;

    IF placeholders > 0 THEN
        RAISE NOTICE '❌ خطأ: توجد قيم placeholder. يجب استبدالها بمعرفات حقيقية!';
    END IF;

    IF production_ids >= 3 THEN
        RAISE NOTICE '✅ ممتاز: جميع المعرفات الأساسية (Banner, Interstitial, Rewarded) جاهزة للإنتاج';
    ELSE
        RAISE NOTICE '❌ مشكلة: ينقص % معرفات إنتاج حقيقية', 3 - production_ids;
    END IF;

    IF test_ids = 0 AND placeholders = 0 AND production_ids >= 3 THEN
        RAISE NOTICE '🎉 ممتاز! جميع إعدادات AdMob جاهزة للإنتاج';
    END IF;
END $$;

-- 4. عرض المعرفات المطلوبة للتحديث
SELECT
    'Required Real Ad Unit IDs' as info_type,
    'معرف البانر (Banner)' as ad_type,
    'ca-app-pub-XXXXXXXXXX/XXXXXXXXXX' as expected_format,
    'يجب نسخه من Google AdMob Console' as source
UNION ALL
SELECT
    'Required Real Ad Unit IDs' as info_type,
    'معرف البيني (Interstitial)' as ad_type,
    'ca-app-pub-XXXXXXXXXX/XXXXXXXXXX' as expected_format,
    'يجب نسخه من Google AdMob Console' as source
UNION ALL
SELECT
    'Required Real Ad Unit IDs' as info_type,
    'معرف المكافآت (Rewarded)' as ad_type,
    'ca-app-pub-XXXXXXXXXX/XXXXXXXXXX' as expected_format,
    'يجب نسخه من Google AdMob Console' as source
UNION ALL
SELECT
    'Required Real Ad Unit IDs' as info_type,
    'معرف التطبيق (App ID)' as ad_type,
    'ca-app-pub-XXXXXXXXXX~XXXXXXXXXX' as expected_format,
    'يجب نسخه من Google AdMob Console' as source;
