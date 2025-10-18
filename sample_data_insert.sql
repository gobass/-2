-- Sample Data Insert Script for Nashmi Admin
-- Run this in your Supabase SQL Editor after creating the tables
-- This script adds sample movies, series, and ads data

-- Insert Sample Movies
INSERT INTO movies (title, posterUrl, videoUrl, categories, description, year, duration, rating, views, hasAds, adBreaks, adProvider, adUnitId) VALUES
('فيلم الأبطال', 'https://example.com/poster1.jpg', 'https://example.com/video1.mp4',
 ARRAY['أكشن', 'مغامرات'], 'فيلم مثير مليء بالمغامرات والأكشن', '2023', '120 دقيقة', 8.5, 1500, true,
 '[{"time": "00:30:00", "duration": "00:00:30"}, {"time": "01:00:00", "duration": "00:00:30"}]', 'admob', 'ca-app-pub-1234567890123456/1234567890'),

('الرومانسية المفقودة', 'https://example.com/poster2.jpg', 'https://example.com/video2.mp4',
 ARRAY['رومانسي', 'دراما'], 'قصة حب جميلة مليئة بالعواطف', '2023', '110 دقيقة', 7.8, 1200, false, NULL, NULL, NULL),

('الكوميديا السوداء', 'https://example.com/poster3.jpg', 'https://example.com/video3.mp4',
 ARRAY['كوميدي', 'جريمة'], 'فيلم كوميدي مثير يجمع بين الفكاهة والتشويق', '2022', '95 دقيقة', 6.9, 800, true,
 '[{"time": "00:25:00", "duration": "00:00:20"}]', 'custom', NULL),

('الخيال العلمي', 'https://example.com/poster4.jpg', 'https://example.com/video4.mp4',
 ARRAY['خيال علمي', 'مغامرات'], 'رحلة في عالم المستقبل مليء بالتكنولوجيا', '2024', '135 دقيقة', 9.2, 2000, true,
 '[{"time": "00:45:00", "duration": "00:00:30"}, {"time": "01:15:00", "duration": "00:00:30"}]', 'admob', 'ca-app-pub-1234567890123456/0987654321'),

('الرعب الليلي', 'https://example.com/poster5.jpg', 'https://example.com/video5.mp4',
 ARRAY['رعب', 'تشويق'], 'ليلة مليئة بالرعب والتشويق', '2023', '100 دقيقة', 7.1, 950, false, NULL, NULL, NULL);

-- Insert Sample Series with Episodes
INSERT INTO movies (title, posterUrl, videoUrl, categories, description, year, duration, episodeCount, rating, views, isSeries, episodes, seasonCount, lastEpisode, nextEpisode, downloadStatus, hasAds, adBreaks, adProvider) VALUES
('المسلسل التاريخي - الموسم الأول', 'https://example.com/series1.jpg', 'https://example.com/series1_ep1.mp4',
 ARRAY['تاريخي', 'دراما'], 'مسلسل يروي قصة تاريخية مثيرة', '2023', '45 دقيقة', 10, 8.7, 5000, true,
 '[{"season": 1, "episode": 1, "title": "البداية", "url": "https://example.com/s1e1.mp4", "duration": "45:00", "downloaded": true},
   {"season": 1, "episode": 2, "title": "التطور", "url": "https://example.com/s1e2.mp4", "duration": "45:00", "downloaded": true},
   {"season": 1, "episode": 3, "title": "الذروة", "url": "https://example.com/s1e3.mp4", "duration": "45:00", "downloaded": false}]',
 1, 'الحلقة 2', 'الحلقة 3', 'downloading', true,
 '[{"time": "00:20:00", "duration": "00:00:30"}]', 'admob'),

('الجريمة المنظمة - الموسم الثاني', 'https://example.com/series2.jpg', 'https://example.com/series2_ep1.mp4',
 ARRAY['جريمة', 'تشويق'], 'مسلسل عن عالم الجريمة المنظمة', '2023', '50 دقيقة', 12, 9.1, 4200, true,
 '[{"season": 2, "episode": 1, "title": "العودة", "url": "https://example.com/s2e1.mp4", "duration": "50:00", "downloaded": true},
   {"season": 2, "episode": 2, "title": "الخطر", "url": "https://example.com/s2e2.mp4", "duration": "50:00", "downloaded": true},
   {"season": 2, "episode": 3, "title": "المواجهة", "url": "https://example.com/s2e3.mp4", "duration": "50:00", "downloaded": false},
   {"season": 2, "episode": 4, "title": "النهاية", "url": "https://example.com/s2e4.mp4", "duration": "50:00", "downloaded": false}]',
 2, 'الحلقة 3', 'الحلقة 4', 'completed', false, NULL, NULL);

-- Insert Sample Series
INSERT INTO series (title, posterUrl, videoUrl, categories, description, year, duration, episodeCount, rating, views) VALUES
('المسلسل التاريخي', 'https://example.com/series1.jpg', 'https://example.com/series1_ep1.mp4',
 ARRAY['تاريخي', 'دراما'], 'مسلسل يروي قصة تاريخية مثيرة', '2023', '45 دقيقة', 30, 8.7, 5000),

('الجريمة المنظمة', 'https://example.com/series2.jpg', 'https://example.com/series2_ep1.mp4',
 ARRAY['جريمة', 'تشويق'], 'مسلسل عن عالم الجريمة المنظمة', '2023', '50 دقيقة', 25, 9.1, 4200),

('الكوميديا اليومية', 'https://example.com/series3.jpg', 'https://example.com/series3_ep1.mp4',
 ARRAY['كوميدي', 'عائلي'], 'مسلسل كوميدي يومي مليء بالضحك', '2022', '30 دقيقة', 50, 7.5, 3800),

('الخيال العلمي المستقبلي', 'https://example.com/series4.jpg', 'https://example.com/series4_ep1.mp4',
 ARRAY['خيال علمي', 'مغامرات'], 'رحلة في عالم المستقبل', '2024', '55 دقيقة', 20, 8.9, 6100),

('الرومانسية الحديثة', 'https://example.com/series5.jpg', 'https://example.com/series5_ep1.mp4',
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

-- Verify data insertion
SELECT 'Movies Count' as table_name, COUNT(*) as count FROM movies
UNION ALL
SELECT 'Series Count' as table_name, COUNT(*) as count FROM series
UNION ALL
SELECT 'Ads Count' as table_name, COUNT(*) as count FROM ads;

-- Show sample data from each table
SELECT 'MOVIES' as table_type, title, categories, rating, views FROM movies LIMIT 3;
SELECT 'SERIES' as table_type, title, categories, episodeCount, rating FROM series LIMIT 3;
SELECT 'ADS' as table_type, title, is_active, click_count, view_count FROM ads LIMIT 3;
