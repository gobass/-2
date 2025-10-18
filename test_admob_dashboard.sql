-- اختبار لوحة تحكم AdMob - Test AdMob Dashboard
-- هذا الاستعلام يتحقق من حالة حفظ الإعدادات

-- 1. فحص آخر تحديث للإعدادات
SELECT
    'Last Updates' as info_type,
    config_key,
    config_value,
    updated_at,
    CASE
        WHEN updated_at > NOW() - INTERVAL '1 hour' THEN '✅ حديث (Recent)'
        WHEN updated_at > NOW() - INTERVAL '24 hours' THEN '⚠️ قديم (Old)'
        ELSE '❌ قديم جداً (Very Old)'
    END as update_status
FROM app_config
WHERE config_key LIKE 'admob_%'
ORDER BY updated_at DESC;

-- 2. فحص إذا كانت هناك محاولات حفظ حديثة
SELECT
    'Recent Activity' as info_type,
    COUNT(*) as total_updates,
    MAX(updated_at) as last_update,
    MIN(updated_at) as first_update
FROM app_config
WHERE config_key LIKE 'admob_%'
  AND updated_at > NOW() - INTERVAL '24 hours';

-- 3. عرض جميع المعرفات الحالية مع حالة التحقق
SELECT
    'Current AdMob IDs' as info_type,
    config_key,
    config_value,
    CASE
        WHEN config_value LIKE 'ca-app-pub-3940256099942544%' THEN '⚠️ TEST ID - لن تظهر إعلانات'
        WHEN config_value LIKE 'ca-app-pub-1234567890123456%' THEN '❌ PLACEHOLDER - لم يتم التحديث'
        WHEN config_value LIKE 'YOUR_%' THEN '❌ PLACEHOLDER - لم يتم التحديث'
        WHEN config_value LIKE 'ca-app-pub-%' THEN '✅ PRODUCTION ID - جاهز'
        ELSE '❓ UNKNOWN FORMAT'
    END as status,
    CASE
        WHEN config_value LIKE 'ca-app-pub-%' AND config_value NOT LIKE 'ca-app-pub-3940256099942544%' THEN '✅ يبدو صحيحاً'
        ELSE '❌ يحتاج تحديث'
    END as validation
FROM app_config
WHERE config_key LIKE 'admob_%'
ORDER BY config_key;

-- 4. تقرير المشاكل
DO $$
DECLARE
    test_ids INTEGER := 0;
    placeholders INTEGER := 0;
    production_ids INTEGER := 0;
    recent_updates INTEGER := 0;
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

    SELECT COUNT(*) INTO recent_updates
    FROM app_config
    WHERE config_key LIKE 'admob_%'
    AND updated_at > NOW() - INTERVAL '1 hour';

    RAISE NOTICE '=== تقرير حالة AdMob Dashboard ===';
    RAISE NOTICE 'معرفات تجريبية (Test IDs): %', test_ids;
    RAISE NOTICE 'قيم placeholder: %', placeholders;
    RAISE NOTICE 'معرفات إنتاج حقيقية: %', production_ids;
    RAISE NOTICE 'تحديثات حديثة (آخر ساعة): %', recent_updates;

    IF recent_updates > 0 THEN
        RAISE NOTICE '✅ تم حفظ إعدادات في آخر ساعة - Dashboard يعمل';
    ELSE
        RAISE NOTICE '❌ لا توجد تحديثات حديثة - Dashboard قد لا يحفظ';
    END IF;

    IF test_ids > 0 THEN
        RAISE NOTICE '⚠️ تحذير: توجد معرفات إعلانات تجريبية';
    END IF;

    IF placeholders > 0 THEN
        RAISE NOTICE '❌ خطأ: توجد قيم placeholder - لم يتم تحديث المعرفات';
    END IF;

    IF production_ids >= 3 THEN
        RAISE NOTICE '✅ ممتاز: جميع المعرفات الأساسية جاهزة للإنتاج';
    END IF;
END $$;
