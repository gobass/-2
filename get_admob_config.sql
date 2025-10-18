-- استعلام لاستخراج إعدادات AdMob من قاعدة البيانات
-- Query to extract AdMob configuration from database

-- التحقق من وجود جدول app_config
-- Check if app_config table exists
SELECT table_name, table_type
FROM information_schema.tables
WHERE table_name = 'app_config' AND table_schema = 'public';

-- استخراج جميع إعدادات AdMob
-- Extract all AdMob configurations
SELECT
    config_key,
    config_value,
    description,
    created_at,
    updated_at
FROM app_config
WHERE config_key LIKE 'admob_%'
ORDER BY config_key;

-- إذا لم يكن هناك بيانات، عرض رسالة
-- If no data exists, show message
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM app_config WHERE config_key LIKE 'admob_%') THEN
        RAISE NOTICE 'لا توجد إعدادات AdMob في قاعدة البيانات - No AdMob configurations found in database';
        RAISE NOTICE 'استخدم ملف setup_admob_config.sql لإنشاء الإعدادات - Use setup_admob_config.sql to create the configurations';
    END IF;
END $$;

-- عرض جميع الإعدادات في قاعدة البيانات
-- Show all configurations in database
SELECT
    config_key,
    config_value,
    description
FROM app_config
ORDER BY config_key;
