-- تشخيص حالة إعدادات الإعلانات - Ad Configuration Diagnostic
-- يساعد في تحديد المشاكل في إعدادات AdMob

-- 1. التحقق من وجود جدول app_config
SELECT
    'app_config table exists' as check_name,
    CASE WHEN EXISTS (
        SELECT 1 FROM information_schema.tables
        WHERE table_name = 'app_config' AND table_schema = 'public'
    ) THEN '✅ EXISTS' ELSE '❌ MISSING' END as status;

-- 2. التحقق من إعدادات AdMob
SELECT
    'AdMob configurations' as check_name,
    CASE WHEN COUNT(*) > 0 THEN '✅ FOUND' ELSE '❌ MISSING' END as status,
    COUNT(*) as count
FROM app_config
WHERE config_key LIKE 'admob_%';

-- 3. عرض جميع إعدادات AdMob
SELECT
    config_key,
    config_value,
    CASE
        WHEN config_value LIKE 'ca-app-pub-3940256099942544%' THEN '⚠️ TEST ID'
        WHEN config_value LIKE 'YOUR_%' THEN '❌ PLACEHOLDER'
        WHEN config_value LIKE 'ca-app-pub-%' THEN '✅ PRODUCTION ID'
        ELSE '❓ UNKNOWN'
    END as id_type,
    description
FROM app_config
WHERE config_key LIKE 'admob_%'
ORDER BY config_key;

-- 4. التحقق من وجود معرفات Android
SELECT
    'Android AdMob IDs' as check_name,
    CASE WHEN COUNT(*) >= 3 THEN '✅ COMPLETE' ELSE '❌ INCOMPLETE' END as status,
    COUNT(*) as count
FROM app_config
WHERE config_key LIKE 'admob_%android'
AND config_value NOT LIKE 'YOUR_%'
AND config_value NOT LIKE 'ca-app-pub-3940256099942544%';

-- 5. التحقق من وجود معرفات iOS
SELECT
    'iOS AdMob IDs' as check_name,
    CASE WHEN COUNT(*) >= 3 THEN '✅ COMPLETE' ELSE '❌ INCOMPLETE' END as status,
    COUNT(*) as count
FROM app_config
WHERE config_key LIKE 'admob_%ios'
AND config_value NOT LIKE 'YOUR_%'
AND config_value NOT LIKE 'ca-app-pub-3940256099942544%';

-- 6. التحقق من صحة صيغة معرفات الإعلانات
SELECT
    config_key,
    config_value,
    CASE
        WHEN config_value ~ '^ca-app-pub-[0-9]{16}~[0-9]{10}$' THEN '✅ VALID APP ID'
        WHEN config_value ~ '^ca-app-pub-[0-9]{16}/[0-9]{10}$' THEN '✅ VALID AD UNIT ID'
        WHEN config_value LIKE 'YOUR_%' THEN '❌ PLACEHOLDER'
        WHEN config_value LIKE 'ca-app-pub-3940256099942544%' THEN '⚠️ TEST ID'
        ELSE '❌ INVALID FORMAT'
    END as validation_status
FROM app_config
WHERE config_key LIKE 'admob_%';

-- 7. تقرير المشاكل المحتملة
DO $$
DECLARE
    test_ids INTEGER;
    placeholders INTEGER;
    missing_android INTEGER;
    missing_ios INTEGER;
BEGIN
    SELECT COUNT(*) INTO test_ids
    FROM app_config
    WHERE config_key LIKE 'admob_%'
    AND config_value LIKE 'ca-app-pub-3940256099942544%';

    SELECT COUNT(*) INTO placeholders
    FROM app_config
    WHERE config_key LIKE 'admob_%'
    AND config_value LIKE 'YOUR_%';

    SELECT COUNT(*) INTO missing_android
    FROM app_config
    WHERE config_key LIKE 'admob_%android'
    AND (config_value LIKE 'YOUR_%' OR config_value LIKE 'ca-app-pub-3940256099942544%');

    SELECT COUNT(*) INTO missing_ios
    FROM app_config
    WHERE config_key LIKE 'admob_%ios'
    AND (config_value LIKE 'YOUR_%' OR config_value LIKE 'ca-app-pub-3940256099942544%');

    RAISE NOTICE '=== AD DIAGNOSTIC REPORT ===';
    RAISE NOTICE 'Test IDs found: %', test_ids;
    RAISE NOTICE 'Placeholders found: %', placeholders;
    RAISE NOTICE 'Missing Android IDs: %', missing_android;
    RAISE NOTICE 'Missing iOS IDs: %', missing_ios;

    IF test_ids > 0 THEN
        RAISE NOTICE '⚠️ WARNING: Test ad unit IDs detected. These only show in test mode.';
    END IF;

    IF placeholders > 0 THEN
        RAISE NOTICE '❌ ERROR: Placeholder values found. Replace with real AdMob IDs.';
    END IF;

    IF missing_android > 0 THEN
        RAISE NOTICE '❌ ERROR: Missing or invalid Android ad unit IDs.';
    END IF;

    IF missing_ios > 0 THEN
        RAISE NOTICE '❌ ERROR: Missing or invalid iOS ad unit IDs.';
    END IF;

    IF test_ids = 0 AND placeholders = 0 AND missing_android = 0 AND missing_ios = 0 THEN
        RAISE NOTICE '✅ SUCCESS: All AdMob configurations appear to be properly set.';
    END IF;
END $$;
