-- تشخيص شامل لمشكلة لوحة تحكم AdMob
-- Comprehensive diagnosis for AdMob Dashboard issue

-- 1. فحص حالة المصادقة والأذونات
SELECT
    'Authentication Check' as check_type,
    'Checking if user can write to database' as description,
    CASE WHEN EXISTS (
        SELECT 1 FROM app_config WHERE config_key = 'test_write_check'
    ) THEN '✅ Can write to database' ELSE '❌ Cannot write to database' END as status;

-- 2. اختبار كتابة بسيط
INSERT INTO app_config (config_key, config_value, description)
VALUES ('test_write_check', 'test_value_' || NOW()::text, 'Test write operation')
ON CONFLICT (config_key) DO UPDATE SET
    config_value = EXCLUDED.config_value,
    updated_at = NOW();

-- 3. فحص آخر التحديثات للإعدادات
SELECT
    'Recent Updates Check' as check_type,
    config_key,
    config_value,
    updated_at,
    CASE
        WHEN updated_at > NOW() - INTERVAL '5 minutes' THEN '✅ حديث جداً (Very Recent)'
        WHEN updated_at > NOW() - INTERVAL '1 hour' THEN '⚠️ حديث (Recent)'
        WHEN updated_at > NOW() - INTERVAL '24 hours' THEN '⚠️ قديم (Old)'
        ELSE '❌ قديم جداً (Very Old)'
    END as update_status
FROM app_config
WHERE config_key LIKE 'admob_%'
ORDER BY updated_at DESC;

-- 4. فحص إذا كانت هناك محاولات حفظ حديثة
SELECT
    'Save Attempts Check' as check_type,
    COUNT(*) as total_admob_configs,
    COUNT(CASE WHEN updated_at > NOW() - INTERVAL '1 hour' THEN 1 END) as recent_updates,
    MAX(updated_at) as last_update_time,
    MIN(updated_at) as first_update_time
FROM app_config
WHERE config_key LIKE 'admob_%';

-- 5. فحص جميع المعرفات الحالية مع تفاصيل التحقق
SELECT
    'Current AdMob Configuration' as check_type,
    config_key,
    config_value,
    LENGTH(config_value) as value_length,
    CASE
        WHEN config_value LIKE 'ca-app-pub-3940256099942544%' THEN '⚠️ TEST ID - لن تظهر إعلانات حقيقية'
        WHEN config_value LIKE 'ca-app-pub-1234567890123456%' THEN '❌ PLACEHOLDER - لم يتم التحديث'
        WHEN config_value LIKE 'YOUR_%' THEN '❌ PLACEHOLDER - لم يتم التحديث'
        WHEN config_value LIKE 'ca-app-pub-%' AND LENGTH(config_value) > 20 THEN '✅ PRODUCTION ID - يبدو صحيحاً'
        WHEN config_value LIKE 'ca-app-pub-%' THEN '⚠️ PRODUCTION ID - تحقق من الصيغة'
        ELSE '❓ UNKNOWN FORMAT - تحقق من القيمة'
    END as validation_status,
    CASE
        WHEN config_value LIKE 'ca-app-pub-%' AND config_value NOT LIKE '%3940256099942544%' THEN '✅ جاهز للاستخدام'
        ELSE '❌ يحتاج تحديث'
    END as production_ready
FROM app_config
WHERE config_key LIKE 'admob_%'
ORDER BY config_key;

-- 6. تقرير شامل للمشاكل
DO $$
DECLARE
    test_ids INTEGER := 0;
    placeholders INTEGER := 0;
    production_ids INTEGER := 0;
    recent_updates INTEGER := 0;
    total_configs INTEGER := 0;
    can_write BOOLEAN := false;
BEGIN
    SELECT COUNT(*) INTO total_configs FROM app_config WHERE config_key LIKE 'admob_%';

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

    SELECT EXISTS(SELECT 1 FROM app_config WHERE config_key = 'test_write_check') INTO can_write;

    RAISE NOTICE '=== تقرير تشخيص شامل لـ AdMob Dashboard ===';
    RAISE NOTICE 'إجمالي إعدادات AdMob: %', total_configs;
    RAISE NOTICE 'معرفات تجريبية (Test IDs): %', test_ids;
    RAISE NOTICE 'قيم placeholder: %', placeholders;
    RAISE NOTICE 'معرفات إنتاج حقيقية: %', production_ids;
    RAISE NOTICE 'تحديثات حديثة (آخر ساعة): %', recent_updates;
    RAISE NOTICE 'إمكانية الكتابة لقاعدة البيانات: %', CASE WHEN can_write THEN '✅ نعم' ELSE '❌ لا' END;

    IF can_write THEN
        RAISE NOTICE '✅ قاعدة البيانات قابلة للكتابة - المشكلة قد تكون في لوحة التحكم';
    ELSE
        RAISE NOTICE '❌ قاعدة البيانات غير قابلة للكتابة - مشكلة في الأذونات';
    END IF;

    IF recent_updates > 0 THEN
        RAISE NOTICE '✅ تم حفظ إعدادات في آخر ساعة - لوحة التحكم تعمل';
    ELSE
        RAISE NOTICE '❌ لا توجد تحديثات حديثة - لوحة التحكم لا تحفظ';
    END IF;

    IF production_ids >= 3 THEN
        RAISE NOTICE '✅ ممتاز: جميع المعرفات الأساسية جاهزة للإنتاج';
    ELSE
        RAISE NOTICE '❌ مشكلة: ينقص % معرفات إنتاج حقيقية', 3 - production_ids;
    END IF;

    IF placeholders > 0 THEN
        RAISE NOTICE '❌ خطأ: توجد قيم placeholder - لم يتم تحديث المعرفات';
    END IF;

    IF test_ids > 0 THEN
        RAISE NOTICE '⚠️ تحذير: توجد معرفات إعلانات تجريبية';
    END IF;
END $$;

-- 7. تنظيف اختبار الكتابة
DELETE FROM app_config WHERE config_key = 'test_write_check';

-- 8. عرض المعرفات المطلوبة للتحديث
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
