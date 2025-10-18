-- ===========================================
-- NASHMI ADMIN - COMPLETE SUPABASE SETUP
-- Execute this file in Supabase SQL Editor
-- ===========================================

-- 0. CHECK EXISTING TABLES AND CLEANUP
-- ===========================================

-- Drop existing tables if they exist to avoid conflicts
DROP TABLE IF EXISTS series CASCADE;
DROP TABLE IF EXISTS ads CASCADE;
DROP TABLE IF EXISTS categories CASCADE;

-- 1. CREATE SERIES TABLE
-- ===========================================

-- Create series table with proper structure
CREATE TABLE series (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    title TEXT NOT NULL,
    posterUrl TEXT,
    videoUrl TEXT,
    categories TEXT[],
    description TEXT,
    year TEXT,
    duration TEXT,
    episodeCount INTEGER DEFAULT 0,
    rating REAL DEFAULT 0.0,
    views INTEGER DEFAULT 0,
    createdAt TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updatedAt TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes for series table
CREATE INDEX idx_series_title ON series(title);
CREATE INDEX idx_series_categories ON series USING GIN(categories);
CREATE INDEX idx_series_createdat ON series(createdAt DESC);
CREATE INDEX idx_series_rating ON series(rating DESC);

-- Enable Row Level Security for series
ALTER TABLE series ENABLE ROW LEVEL SECURITY;

-- Add missing 'archived' column to series for schema cache fix
ALTER TABLE series ADD COLUMN IF NOT EXISTS archived BOOLEAN DEFAULT FALSE;

-- Create RLS policies for series
CREATE POLICY "Enable read access for all users" ON series FOR SELECT USING (true);
CREATE POLICY "Enable insert for authenticated users only" ON series FOR INSERT WITH CHECK (auth.role() = 'authenticated');
CREATE POLICY "Enable update for authenticated users only" ON series FOR UPDATE USING (auth.role() = 'authenticated');
CREATE POLICY "Enable delete for authenticated users only" ON series FOR DELETE USING (auth.role() = 'authenticated');

-- 2. CREATE ADS TABLE
-- ===========================================

-- Create ads table with proper structure
CREATE TABLE ads (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    title TEXT NOT NULL,
    description TEXT,
    imageUrl TEXT,
    videoUrl TEXT,
    targetUrl TEXT,
    start_at TIMESTAMP WITH TIME ZONE NOT NULL,
    end_at TIMESTAMP WITH TIME ZONE NOT NULL,
    is_active BOOLEAN DEFAULT true,
    click_count INTEGER DEFAULT 0,
    view_count INTEGER DEFAULT 0,
    createdAt TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updatedAt TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes for ads table
CREATE INDEX idx_ads_is_active ON ads(is_active);
CREATE INDEX idx_ads_start_at ON ads(start_at);
CREATE INDEX idx_ads_end_at ON ads(end_at);
CREATE INDEX idx_ads_createdat ON ads(createdAt DESC);

-- Enable Row Level Security for ads
ALTER TABLE ads ENABLE ROW LEVEL SECURITY;

-- Create RLS policies for ads
CREATE POLICY "Enable read access for all users" ON ads FOR SELECT USING (true);
CREATE POLICY "Enable insert for authenticated users only" ON ads FOR INSERT WITH CHECK (auth.role() = 'authenticated');
CREATE POLICY "Enable update for authenticated users only" ON ads FOR UPDATE USING (auth.role() = 'authenticated');
CREATE POLICY "Enable delete for authenticated users only" ON ads FOR DELETE USING (auth.role() = 'authenticated');

-- 2.5. CREATE CATEGORIES TABLE
-- ===========================================

-- Create categories table with proper structure
CREATE TABLE categories (
    name TEXT PRIMARY KEY,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes for categories table
CREATE INDEX idx_categories_name ON categories(name);
CREATE INDEX idx_categories_createdat ON categories(created_at DESC);

-- Enable Row Level Security for categories
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;

-- Create RLS policies for categories
CREATE POLICY "Enable read access for all users" ON categories FOR SELECT USING (true);
CREATE POLICY "Enable insert for authenticated users only" ON categories FOR INSERT WITH CHECK (auth.role() = 'authenticated');
CREATE POLICY "Enable update for authenticated users only" ON categories FOR UPDATE USING (auth.role() = 'authenticated');
CREATE POLICY "Enable delete for authenticated users only" ON categories FOR DELETE USING (auth.role() = 'authenticated');

-- 3. CREATE/ENHANCE MOVIES TABLE WITH SERIES AND ADS SUPPORT
-- ===========================================

-- First, create the movies table if it doesn't exist
CREATE TABLE IF NOT EXISTS movies (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    title TEXT NOT NULL,
    posterUrl TEXT,
    videoUrl TEXT,
    categories TEXT[],
    description TEXT,
    year TEXT,
    duration TEXT,
    episodeCount INTEGER DEFAULT 0,
    rating REAL DEFAULT 0.0,
    views INTEGER DEFAULT 0,
    createdAt TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updatedAt TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable Row Level Security for movies
ALTER TABLE movies ENABLE ROW LEVEL SECURITY;

-- Create RLS policies for movies
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE policyname = 'Enable read access for all users' AND tablename = 'movies'
  ) THEN
    CREATE POLICY "Enable read access for all users" ON movies FOR SELECT USING (true);
  END IF;
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE policyname = 'Enable insert for authenticated users only' AND tablename = 'movies'
  ) THEN
    CREATE POLICY "Enable insert for authenticated users only" ON movies FOR INSERT WITH CHECK (auth.role() = 'authenticated');
  END IF;
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE policyname = 'Enable update for authenticated users only' AND tablename = 'movies'
  ) THEN
    CREATE POLICY "Enable update for authenticated users only" ON movies FOR UPDATE USING (auth.role() = 'authenticated');
  END IF;
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE policyname = 'Enable delete for authenticated users only' AND tablename = 'movies'
  ) THEN
    CREATE POLICY "Enable delete for authenticated users only" ON movies FOR DELETE USING (auth.role() = 'authenticated');
  END IF;
END
$$;

-- Add missing columns to the movies table if they don't exist
ALTER TABLE movies ADD COLUMN IF NOT EXISTS "posterUrl" TEXT;
ALTER TABLE movies ADD COLUMN IF NOT EXISTS "videoUrl" TEXT;
ALTER TABLE movies ADD COLUMN IF NOT EXISTS "categories" TEXT[];
ALTER TABLE movies ADD COLUMN IF NOT EXISTS "description" TEXT;
ALTER TABLE movies ADD COLUMN IF NOT EXISTS "year" TEXT;
ALTER TABLE movies ADD COLUMN IF NOT EXISTS "duration" TEXT;
ALTER TABLE movies ADD COLUMN IF NOT EXISTS "episodeCount" INTEGER DEFAULT 0;
ALTER TABLE movies ADD COLUMN IF NOT EXISTS "rating" REAL DEFAULT 0.0;
ALTER TABLE movies ADD COLUMN IF NOT EXISTS "views" INTEGER DEFAULT 0;

-- Additional columns for series support
ALTER TABLE movies ADD COLUMN IF NOT EXISTS isSeries BOOLEAN DEFAULT FALSE;
ALTER TABLE movies ADD COLUMN IF NOT EXISTS episodes JSONB; -- Store episode data as JSON
ALTER TABLE movies ADD COLUMN IF NOT EXISTS seasonCount INTEGER DEFAULT 0;
ALTER TABLE movies ADD COLUMN IF NOT EXISTS lastEpisode TEXT;
ALTER TABLE movies ADD COLUMN IF NOT EXISTS nextEpisode TEXT;
ALTER TABLE movies ADD COLUMN IF NOT EXISTS downloadStatus TEXT DEFAULT 'pending'; -- pending, downloading, completed, failed

-- Additional columns for ads support
ALTER TABLE movies ADD COLUMN IF NOT EXISTS hasAds BOOLEAN DEFAULT FALSE;
ALTER TABLE movies ADD COLUMN IF NOT EXISTS adBreaks JSONB; -- Store ad break times as JSON
ALTER TABLE movies ADD COLUMN IF NOT EXISTS adProvider TEXT; -- admob, custom, etc.
ALTER TABLE movies ADD COLUMN IF NOT EXISTS adUnitId TEXT; -- For AdMob integration

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_movies_posterurl ON movies(posterUrl);
CREATE INDEX IF NOT EXISTS idx_movies_videourl ON movies(videoUrl);
CREATE INDEX IF NOT EXISTS idx_movies_categories ON movies USING GIN(categories);
CREATE INDEX IF NOT EXISTS idx_movies_isseries ON movies(isSeries);
CREATE INDEX IF NOT EXISTS idx_movies_episodes ON movies USING GIN(episodes);
CREATE INDEX IF NOT EXISTS idx_movies_downloadstatus ON movies(downloadStatus);
CREATE INDEX IF NOT EXISTS idx_movies_hasads ON movies(hasAds);

-- 4. INSERT SAMPLE DATA
-- ===========================================

-- Insert Sample Movies with ads support
INSERT INTO movies (id, title, posterUrl, videoUrl, categories, description, year, duration, rating, views, hasAds, adBreaks, adProvider, adUnitId) VALUES
(gen_random_uuid(), 'فيلم الأبطال', 'https://example.com/poster1.jpg', 'https://example.com/video1.mp4',
 ARRAY['أكشن', 'مغامرات'], 'فيلم مثير مليء بالمغامرات والأكشن', '2023', '120 دقيقة', 8.5, 1500, true,
 '[{"time": "00:30:00", "duration": "00:00:30"}, {"time": "01:00:00", "duration": "00:00:30"}]', 'admob', 'ca-app-pub-1234567890123456/1234567890'),

(gen_random_uuid(), 'الرومانسية المفقودة', 'https://example.com/poster2.jpg', 'https://example.com/video2.mp4',
 ARRAY['رومانسي', 'دراما'], 'قصة حب جميلة مليئة بالعواطف', '2023', '110 دقيقة', 7.8, 1200, false, NULL, NULL, NULL),

(gen_random_uuid(), 'الكوميديا السوداء', 'https://example.com/poster3.jpg', 'https://example.com/video3.mp4',
 ARRAY['كوميدي', 'جريمة'], 'فيلم كوميدي مثير يجمع بين الفكاهة والتشويق', '2022', '95 دقيقة', 6.9, 800, true,
 '[{"time": "00:25:00", "duration": "00:00:20"}]', 'custom', NULL),

(gen_random_uuid(), 'الخيال العلمي', 'https://example.com/poster4.jpg', 'https://example.com/video4.mp4',
 ARRAY['خيال علمي', 'مغامرات'], 'رحلة في عالم المستقبل مليء بالتكنولوجيا', '2024', '135 دقيقة', 9.2, 2000, true,
 '[{"time": "00:45:00", "duration": "00:00:30"}, {"time": "01:15:00", "duration": "00:00:30"}]', 'admob', 'ca-app-pub-1234567890123456/0987654321'),

(gen_random_uuid(), 'الرعب الليلي', 'https://example.com/poster5.jpg', 'https://example.com/video5.mp4',
 ARRAY['رعب', 'تشويق'], 'ليلة مليئة بالرعب والتشويق', '2023', '100 دقيقة', 7.1, 950, false, NULL, NULL, NULL);

-- Insert Sample Series with Episodes
INSERT INTO movies (id, title, posterUrl, videoUrl, categories, description, year, duration, episodeCount, rating, views, isSeries, episodes, seasonCount, lastEpisode, nextEpisode, downloadStatus, hasAds, adBreaks, adProvider) VALUES
(gen_random_uuid(), 'المسلسل التاريخي - الموسم الأول', 'https://example.com/series1.jpg', 'https://example.com/series1_ep1.mp4',
 ARRAY['تاريخي', 'دراما'], 'مسلسل يروي قصة تاريخية مثيرة', '2023', '45 دقيقة', 10, 8.7, 5000, true,
 '[{"season": 1, "episode": 1, "title": "البداية", "url": "https://example.com/s1e1.mp4", "duration": "45:00", "downloaded": true},
   {"season": 1, "episode": 2, "title": "التطور", "url": "https://example.com/s1e2.mp4", "duration": "45:00", "downloaded": true},
   {"season": 1, "episode": 3, "title": "الذروة", "url": "https://example.com/s1e3.mp4", "duration": "45:00", "downloaded": false}]',
 1, 'الحلقة 2', 'الحلقة 3', 'downloading', true,
 '[{"time": "00:20:00", "duration": "00:00:30"}]', 'admob'),

(gen_random_uuid(), 'الجريمة المنظمة - الموسم الثاني', 'https://example.com/series2.jpg', 'https://example.com/series2_ep1.mp4',
 ARRAY['جريمة', 'تشويق'], 'مسلسل عن عالم الجريمة المنظمة', '2023', '50 دقيقة', 12, 9.1, 4200, true,
 '[{"season": 2, "episode": 1, "title": "العودة", "url": "https://example.com/s2e1.mp4", "duration": "50:00", "downloaded": true},
   {"season": 2, "episode": 2, "title": "الخطر", "url": "https://example.com/s2e2.mp4", "duration": "50:00", "downloaded": true},
   {"season": 2, "episode": 3, "title": "المواجهة", "url": "https://example.com/s2e3.mp4", "duration": "50:00", "downloaded": false},
   {"season": 2, "episode": 4, "title": "النهاية", "url": "https://example.com/s2e4.mp4", "duration": "50:00", "downloaded": false}]',
 2, 'الحلقة 3', 'الحلقة 4', 'completed', false, NULL, NULL);

-- Insert Sample Series (separate table)
INSERT INTO series (id, title, posterUrl, videoUrl, categories, description, year, duration, episodeCount, rating, views) VALUES
(gen_random_uuid(), 'المسلسل التاريخي', 'https://example.com/series1.jpg', 'https://example.com/series1_ep1.mp4',
 ARRAY['تاريخي', 'دراما'], 'مسلسل يروي قصة تاريخية مثيرة', '2023', '45 دقيقة', 30, 8.7, 5000),

(gen_random_uuid(), 'الجريمة المنظمة', 'https://example.com/series2.jpg', 'https://example.com/series2_ep1.mp4',
 ARRAY['جريمة', 'تشويق'], 'مسلسل عن عالم الجريمة المنظمة', '2023', '50 دقيقة', 25, 9.1, 4200),

(gen_random_uuid(), 'الكوميديا اليومية', 'https://example.com/series3.jpg', 'https://example.com/series3_ep1.mp4',
 ARRAY['كوميدي', 'عائلي'], 'مسلسل كوميدي يومي مليء بالضحك', '2022', '30 دقيقة', 50, 7.5, 3800),

(gen_random_uuid(), 'الخيال العلمي المستقبلي', 'https://example.com/series4.jpg', 'https://example.com/series4_ep1.mp4',
 ARRAY['خيال علمي', 'مغامرات'], 'رحلة في عالم المستقبل', '2024', '55 دقيقة', 20, 8.9, 6100),

(gen_random_uuid(), 'الرومانسية الحديثة', 'https://example.com/series5.jpg', 'https://example.com/series5_ep1.mp4',
 ARRAY['رومانسي', 'دراما'], 'قصص حب في العصر الحديث', '2023', '40 دقيقة', 35, 7.8, 2900);

-- Insert Sample Ads (including AdMob)
INSERT INTO ads (title, description, imageUrl, videoUrl, targetUrl, start_at, end_at, is_active, click_count, view_count) VALUES
('إعلان AdMob - تطبيق الألعاب', 'استمتع بأفضل الألعاب على هاتفك', 'https://example.com/ad1.jpg', NULL,
 'https://play.google.com/store/apps/games', '2024-01-01 00:00:00+00', '2024-12-31 23:59:59+00', true, 150, 2500),

('إعلان AdMob - متجر إلكتروني', 'تسوق عبر الإنترنت بأفضل الأسعار', 'https://example.com/ad2.jpg', NULL,
 'https://example.com/shop', '2024-01-15 00:00:00+00', '2024-06-15 23:59:59+00', true, 89, 1800),

('إعلان فيديو - سيارة جديدة', 'اكتشف السيارة الجديدة من تويوتا', NULL, 'https://example.com/car_ad.mp4',
 'https://example.com/cars', '2024-02-01 00:00:00+00', '2024-08-01 23:59:59+00', true, 234, 3200),

('إعلان AdMob - تطبيق الموسيقى', 'استمع للموسيقى المفضلة لديك', 'https://example.com/ad3.jpg', NULL,
 'https://play.google.com/store/apps/music', '2024-01-01 00:00:00+00', '2024-12-31 23:59:59+00', true, 67, 1200),

('إعلان صورة - منتج تجميل', 'منتجات تجميل طبيعية 100%', 'https://example.com/ad4.jpg', NULL,
 'https://example.com/beauty', '2024-03-01 00:00:00+00', '2024-09-01 23:59:59+00', true, 123, 2100),

('إعلان AdMob - تطبيق الرياضة', 'تابع آخر الأخبار الرياضية', 'https://example.com/ad5.jpg', NULL,
 'https://play.google.com/store/apps/sports', '2024-01-01 00:00:00+00', '2024-12-31 23:59:59+00', true, 98, 1600);

-- Insert Sample Categories
INSERT INTO categories (name, created_at) VALUES
('أكشن', NOW()),
('دراما', NOW()),
('كوميدي', NOW()),
('رعب', NOW()),
('رومانسي', NOW()),
('خيال علمي', NOW()),
('وثائقي', NOW()),
('مغامرة', NOW()),
('جريمة', NOW()),
('عائلي', NOW()),
('تاريخي', NOW()),
('تشويق', NOW());

-- 5. VERIFICATION QUERIES
-- ===========================================

-- Verify all tables exist and show their structure
SELECT 'MOVIES TABLE STRUCTURE' as info;
SELECT column_name, data_type, is_nullable, column_default
FROM information_schema.columns
WHERE table_name = 'movies'
ORDER BY ordinal_position;

SELECT 'SERIES TABLE STRUCTURE' as info;
SELECT column_name, data_type, is_nullable, column_default
FROM information_schema.columns
WHERE table_name = 'series'
ORDER BY ordinal_position;

SELECT 'ADS TABLE STRUCTURE' as info;
SELECT column_name, data_type, is_nullable, column_default
FROM information_schema.columns
WHERE table_name = 'ads'
ORDER BY ordinal_position;

SELECT 'CATEGORIES TABLE STRUCTURE' as info;
SELECT column_name, data_type, is_nullable, column_default
FROM information_schema.columns
WHERE table_name = 'categories'
ORDER BY ordinal_position;

-- Show data counts
SELECT 'DATA COUNTS' as info;
SELECT 'Movies Count' as table_name, COUNT(*) as count FROM movies
UNION ALL
SELECT 'Series Count' as table_name, COUNT(*) as count FROM series
UNION ALL
SELECT 'Ads Count' as table_name, COUNT(*) as count FROM ads
UNION ALL
SELECT 'Categories Count' as table_name, COUNT(*) as count FROM categories;

-- Show sample data
SELECT 'SAMPLE MOVIES' as info;
SELECT title, categories, rating, views, hasAds, isSeries FROM movies LIMIT 3;

SELECT 'SAMPLE SERIES' as info;
SELECT title, categories, episodeCount, rating FROM series LIMIT 3;

SELECT 'SAMPLE ADS' as info;
SELECT title, is_active, click_count, view_count FROM ads LIMIT 3;

-- ===========================================
-- SETUP COMPLETE!
-- All tables created, columns added, and sample data inserted.
-- Your Nashmi Admin should now work without errors.
-- ===========================================
