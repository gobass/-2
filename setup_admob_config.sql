-- إعداد إعلانات AdMob في قاعدة البيانات
-- Setup AdMob Configuration in Database

-- إنشاء جدول app_config إذا لم يكن موجوداً
-- Create app_config table if it doesn't exist
CREATE TABLE IF NOT EXISTS app_config (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    config_key TEXT NOT NULL UNIQUE,
    config_value TEXT NOT NULL,
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- إنشاء فهارس للأداء
-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_app_config_key ON app_config(config_key);

-- تفعيل Row Level Security
-- Enable Row Level Security (RLS)
ALTER TABLE app_config ENABLE ROW LEVEL SECURITY;

-- إنشاء سياسات الأمان
-- Create security policies
CREATE POLICY "Enable read access for all users" ON app_config FOR SELECT USING (true);
CREATE POLICY "Enable insert for authenticated users" ON app_config FOR INSERT WITH CHECK (true);
CREATE POLICY "Enable update for authenticated users" ON app_config FOR UPDATE USING (true);
CREATE POLICY "Enable delete for authenticated users" ON app_config FOR DELETE USING (true);

-- إدراج إعدادات AdMob
-- Insert AdMob configuration
-- استبدل القيم التالية بمعرفات إعلانات AdMob الخاصة بك من Google AdMob Console
-- Replace the following values with your actual AdMob ad unit IDs from Google AdMob Console

INSERT INTO app_config (config_key, config_value, description) VALUES
-- معرفات إعلانات البانر - Banner Ad Unit IDs
('admob_banner_android', 'YOUR_BANNER_AD_UNIT_ID_ANDROID', 'AdMob Banner Ad Unit ID for Android'),
('admob_banner_ios', 'YOUR_BANNER_AD_UNIT_ID_IOS', 'AdMob Banner Ad Unit ID for iOS'),

-- معرفات إعلانات بينية - Interstitial Ad Unit IDs
('admob_interstitial_android', 'YOUR_INTERSTITIAL_AD_UNIT_ID_ANDROID', 'AdMob Interstitial Ad Unit ID for Android'),
('admob_interstitial_ios', 'YOUR_INTERSTITIAL_AD_UNIT_ID_IOS', 'AdMob Interstitial Ad Unit ID for iOS'),

-- معرفات إعلانات مكافآت - Rewarded Ad Unit IDs
('admob_rewarded_android', 'YOUR_REWARDED_AD_UNIT_ID_ANDROID', 'AdMob Rewarded Ad Unit ID for Android'),
('admob_rewarded_ios', 'YOUR_REWARDED_AD_UNIT_ID_IOS', 'AdMob Rewarded Ad Unit ID for iOS'),

-- معرفات التطبيق - App IDs
('admob_app_id_android', 'YOUR_APP_ID_ANDROID', 'AdMob App ID for Android'),
('admob_app_id_ios', 'YOUR_APP_ID_IOS', 'AdMob App ID for iOS')
ON CONFLICT (config_key) DO UPDATE SET
    config_value = EXCLUDED.config_value,
    updated_at = NOW();

-- التحقق من إنشاء الجدول
-- Verify table creation
SELECT table_name, table_type
FROM information_schema.tables
WHERE table_name = 'app_config' AND table_schema = 'public';

-- التحقق من البيانات المدرجة
-- Verify inserted data
SELECT config_key, config_value, description
FROM app_config
ORDER BY config_key;

-- تعليمات للحصول على معرفات الإعلانات الصحيحة:
-- Instructions for getting correct ad unit IDs:

/*
للحصول على معرفات إعلانات AdMob الصحيحة:

1. اذهب إلى Google AdMob Console: https://apps.admob.com/
2. اختر تطبيقك من القائمة
3. اذهب إلى "Ad units" في القائمة الجانبية
4. انسخ معرفات الإعلانات التالية:
   - Banner: ca-app-pub-XXXXXXXXXX/XXXXXXXXXX
   - Interstitial: ca-app-pub-XXXXXXXXXX/XXXXXXXXXX
   - Rewarded: ca-app-pub-XXXXXXXXXX/XXXXXXXXXX
5. استبدل القيم في هذا الملف
6. شغل هذا الملف في Supabase SQL Editor

To get correct AdMob ad unit IDs:

1. Go to Google AdMob Console: https://apps.admob.com/
2. Select your app from the list
3. Go to "Ad units" in the sidebar
4. Copy these ad unit IDs:
   - Banner: ca-app-pub-XXXXXXXXXX/XXXXXXXXXX
   - Interstitial: ca-app-pub-XXXXXXXXXX/XXXXXXXXXX
   - Rewarded: ca-app-pub-XXXXXXXXXX/XXXXXXXXXX
5. Replace the values in this file
6. Run this file in Supabase SQL Editor
*/
