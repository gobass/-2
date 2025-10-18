-- SQL Script to create tables for Nashmi Dashboard
-- Updated schema to match the Flutter app's data structure
-- Run this in your Supabase SQL editor

-- Movies table (unified for both movies and series)
CREATE TABLE IF NOT EXISTS movies (
  id TEXT PRIMARY KEY,
  title TEXT NOT NULL,
  description TEXT,
  categories TEXT[], -- Array of categories/genres
  posterUrl TEXT,
  videoUrl TEXT,
  createdAt TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  isSeries BOOLEAN DEFAULT FALSE,
  episodeCount INTEGER DEFAULT 0,
  rating REAL DEFAULT 0.0,
  views INTEGER DEFAULT 0,
  year TEXT,
  duration TEXT
);

-- Ads table
CREATE TABLE IF NOT EXISTS ads (
  id TEXT PRIMARY KEY,
  title TEXT NOT NULL,
  description TEXT,
  imageURL TEXT,
  url TEXT,
  startAt TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  endAt TIMESTAMP WITH TIME ZONE,
  isActive BOOLEAN DEFAULT TRUE,
  createdAt TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Episodes table for series
CREATE TABLE IF NOT EXISTS episodes (
  id TEXT PRIMARY KEY,
  title TEXT NOT NULL,
  videoURL TEXT,
  episodeNumber INTEGER NOT NULL,
  seriesId TEXT NOT NULL,
  createdAt TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  FOREIGN KEY (seriesId) REFERENCES movies(id) ON DELETE CASCADE
);

-- Users table (for future authentication)
CREATE TABLE IF NOT EXISTS users (
  id TEXT PRIMARY KEY,
  email TEXT UNIQUE NOT NULL,
  password_hash TEXT NOT NULL,
  role TEXT DEFAULT 'admin' CHECK (role IN ('admin', 'moderator')),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  last_login TIMESTAMP WITH TIME ZONE
);

-- Insert realistic sample data for testing
INSERT INTO movies (id, title, description, categories, posterUrl, videoUrl, isSeries, rating, views, year, duration) VALUES
-- Hollywood Movies
('movie_1', 'الرجل العنكبوت: لا طريق للوطن', 'فيلم أكشن ملحمي يجمع بين جميع أبطال عالم مارفل في قصة مثيرة', ARRAY['أكشن', 'مغامرات', 'خيال علمي'], 'https://m.media-amazon.com/images/M/MV5BZWMyYzFjYTYtNTRjYi00OGExLWE2YzgtOGRmYjAxZTU3NzBiXkEyXkFqcGdeQXVyMzQ0MzA0NTM@._V1_.jpg', 'https://example.com/spiderman.mp4', FALSE, 8.2, 1250000, '2021', '148 دقيقة'),
('movie_2', 'الجوكر', 'قصة أصل الجوكر المرعب في قصة نفسية مثيرة', ARRAY['دراما', 'جريمة', 'إثارة'], 'https://m.media-amazon.com/images/M/MV5BNGVjNWI4ZGUtNzE0MS00YTJmLWE0ZDctN2ZiYTk2YmI3NTYyXkEyXkFqcGdeQXVyMTkxNjUyNQ@@._V1_.jpg', 'https://example.com/joker.mp4', FALSE, 8.4, 2100000, '2019', '122 دقيقة'),
('movie_3', 'الكتاب الخضر', 'قصة حقيقية عن حياة الملاكم محمد علي كلاي', ARRAY['سيرة ذاتية', 'دراما', 'رياضة'], 'https://m.media-amazon.com/images/M/MV5BYjQ5NjM0Y2YtNjZkNC00ZDhkLWJjMWItN2QyNzFkMDE3ZjAxXkEyXkFqcGdeQXVyODIyOTEyMzY@._V1_.jpg', 'https://example.com/greenbook.mp4', FALSE, 8.2, 890000, '2018', '130 دقيقة'),
('movie_4', 'المنتقمون: نهاية اللعبة', 'ذروة سلسلة المنتقمون في معركة نهائية', ARRAY['أكشن', 'مغامرات', 'خيال علمي'], 'https://m.media-amazon.com/images/M/MV5BMTc5MDE2ODcwNV5BMl5BanBnXkFtZTgwMzI2NzQ2NzM@._V1_.jpg', 'https://example.com/avengers.mp4', FALSE, 8.4, 3100000, '2019', '181 دقيقة'),
('movie_5', 'الأب الروحي', 'فيلم كوميدي عن رجل أعمال يتظاهر بأنه والد لابن صديقته', ARRAY['كوميديا', 'عائلي'], 'https://m.media-amazon.com/images/M/MV5BZTQzY2Q3ZTQtYjYzMi00NGY2LWE5ZGEtNmY4NzE4NzgyYzBjXkEyXkFqcGdeQXVyMTkxNjUyNQ@@._V1_.jpg', 'https://example.com/godfather.mp4', FALSE, 9.2, 1800000, '1972', '175 دقيقة'),
('movie_6', 'الأب الروحي الجزء الثاني', 'تكملة ملحمية لفيلم الأب الروحي', ARRAY['جريمة', 'دراما'], 'https://m.media-amazon.com/images/M/MV5BMWMwMGQzZTItY2JlNC00OWZiLWIyMDctNDk2ZDQ2YjRjMWQ0XkEyXkFqcGdeQXVyNzkwMjQ5NzM@._V1_.jpg', 'https://example.com/godfather2.mp4', FALSE, 9.0, 1200000, '1974', '202 دقيقة'),

-- Arabic Movies
('movie_ar_1', 'الفيل الأزرق', 'فيلم دراما نفسية عن رجل يعاني من الاكتئاب', ARRAY['دراما', 'عربي'], 'https://example.com/blueelephant.jpg', 'https://example.com/blueelephant.mp4', FALSE, 7.8, 850000, '2014', '170 دقيقة'),
('movie_ar_2', 'المصلحة', 'فيلم تشويق عن محقق يحقق في قضية فساد', ARRAY['تشويق', 'عربي', 'دراما'], 'https://example.com/almaslaha.jpg', 'https://example.com/almaslaha.mp4', FALSE, 8.1, 650000, '2012', '125 دقيقة'),

-- Series
('series_1', 'صراع العروش', 'ملحمة خيالية ملحمية في عالم مليء بالمؤامرات والحروب', ARRAY['دراما', 'خيال', 'مغامرات'], 'https://m.media-amazon.com/images/M/MV5BYTRiNDQwYzAtMzVlZS00NTI5LWJjYjUtMzkwNTUzMWMxZTllXkEyXkFqcGdeQXVyNDIzMzcwNjc@._V1_.jpg', NULL, TRUE, 9.2, 5200000, '2011-2019', NULL),
('series_2', 'البريكينج باد', 'معلم كيمياء مصاب بالسرطان يدخل عالم المخدرات', ARRAY['جريمة', 'دراما', 'إثارة'], 'https://m.media-amazon.com/images/M/MV5BMjhiMzgxZTctNDc1Ni00OTIxLTlhMTYtZTA3ZWFkODBkNmE2XkEyXkFqcGdeQXVyNzkwMjQ5NzM@._V1_.jpg', NULL, TRUE, 9.5, 4100000, '2008-2013', NULL),
('series_3', 'الأشياء الغريبة', 'أطفال يكتشفون أسرار عالم موازي مخيف', ARRAY['خيال علمي', 'دراما', 'رعب'], 'https://m.media-amazon.com/images/M/MV5BMDZkYmVhNjMtNWU4MC00MDQxLWE3MjYtZGMzZWI1ZjhlOWJmXkEyXkFqcGdeQXVyMTkxNjUyNQ@@._V1_.jpg', NULL, TRUE, 8.7, 3800000, '2016', NULL),
('series_ar_1', 'الاختيار', 'مسلسل دراما عن حياة الرئيس محمد مرسي', ARRAY['سيرة ذاتية', 'دراما', 'عربي'], 'https://example.com/alakhtar.jpg', NULL, TRUE, 8.9, 2800000, '2020', NULL);

-- Insert realistic episodes for series
INSERT INTO episodes (id, title, videoURL, episodeNumber, seriesId) VALUES
-- Game of Thrones episodes
('got_ep1', 'شتاء قادم', 'https://example.com/got_s01e01.mp4', 1, 'series_1'),
('got_ep2', 'الملك في الشمال', 'https://example.com/got_s01e02.mp4', 2, 'series_1'),
('got_ep3', 'لورد سنو', 'https://example.com/got_s01e03.mp4', 3, 'series_1'),
('got_ep4', 'المقعد المكسور', 'https://example.com/got_s01e04.mp4', 4, 'series_1'),
('got_ep5', 'الذئب والأسد', 'https://example.com/got_s01e05.mp4', 5, 'series_1'),

-- Breaking Bad episodes
('bb_ep1', 'المحطة', 'https://example.com/bb_s01e01.mp4', 1, 'series_2'),
('bb_ep2', 'القط والفأر', 'https://example.com/bb_s01e02.mp4', 2, 'series_2'),
('bb_ep3', '...و الرغبة في الطبخ', 'https://example.com/bb_s01e03.mp4', 3, 'series_2'),
('bb_ep4', 'السرطان', 'https://example.com/bb_s01e04.mp4', 4, 'series_2'),
('bb_ep5', 'الجين الأزرق', 'https://example.com/bb_s01e05.mp4', 5, 'series_2'),

-- Stranger Things episodes
('st_ep1', 'المفقودون والمطلوبون', 'https://example.com/st_s01e01.mp4', 1, 'series_3'),
('st_ep2', 'ليزاردز', 'https://example.com/st_s01e02.mp4', 2, 'series_3'),
('st_ep3', 'هولي جولي', 'https://example.com/st_s01e03.mp4', 3, 'series_3'),
('st_ep4', 'الجسم', 'https://example.com/st_s01e04.mp4', 4, 'series_3'),
('st_ep5', 'الخارق', 'https://example.com/st_s01e05.mp4', 5, 'series_3');

-- Insert comprehensive AdMob ads (using official test ad units for development)
INSERT INTO ads (id, title, description, imageURL, url, startAt, endAt, isActive) VALUES
-- Banner Ads
('ad_banner_android', 'إعلان بانر - أندرويد', 'إعلان بانر تفاعلي للأندرويد - Ad Unit ID: ca-app-pub-3940256099942544/6300978111', 'https://storage.googleapis.com/admob-banner-placeholder.png', 'https://admob.google.com', NOW(), NOW() + INTERVAL '365 days', TRUE),
('ad_banner_ios', 'إعلان بانر - iOS', 'إعلان بانر تفاعلي للـ iOS - Ad Unit ID: ca-app-pub-3940256099942544/2934735716', 'https://storage.googleapis.com/admob-banner-placeholder.png', 'https://admob.google.com', NOW(), NOW() + INTERVAL '365 days', TRUE),

-- Interstitial Ads
('ad_interstitial_android', 'إعلان بيني - أندرويد', 'إعلان بيني كامل الشاشة - Ad Unit ID: ca-app-pub-3940256099942544/1033173712', 'https://storage.googleapis.com/admob-interstitial-placeholder.png', 'https://admob.google.com', NOW(), NOW() + INTERVAL '365 days', TRUE),
('ad_interstitial_ios', 'إعلان بيني - iOS', 'إعلان بيني كامل الشاشة للـ iOS - Ad Unit ID: ca-app-pub-3940256099942544/4411468910', 'https://storage.googleapis.com/admob-interstitial-placeholder.png', 'https://admob.google.com', NOW(), NOW() + INTERVAL '365 days', TRUE),

-- Rewarded Ads
('ad_rewarded_android', 'إعلان مكافئ - أندرويد', 'إعلان مكافئ يمنح المستخدم مكافآت - Ad Unit ID: ca-app-pub-3940256099942544/5224354917', 'https://storage.googleapis.com/admob-rewarded-placeholder.png', 'https://admob.google.com', NOW(), NOW() + INTERVAL '365 days', TRUE),
('ad_rewarded_ios', 'إعلان مكافئ - iOS', 'إعلان مكافئ يمنح المستخدم مكافآت للـ iOS - Ad Unit ID: ca-app-pub-3940256099942544/1712485313', 'https://storage.googleapis.com/admob-rewarded-placeholder.png', 'https://admob.google.com', NOW(), NOW() + INTERVAL '365 days', TRUE),

-- Native Ads
('ad_native_android', 'إعلان أصلي - أندرويد', 'إعلان أصلي يندمج مع تصميم التطبيق - Ad Unit ID: ca-app-pub-3940256099942544/2247696110', 'https://storage.googleapis.com/admob-native-placeholder.png', 'https://admob.google.com', NOW(), NOW() + INTERVAL '365 days', TRUE),

-- App Open Ads
('ad_app_open_android', 'إعلان فتح التطبيق - أندرويد', 'إعلان يظهر عند فتح التطبيق - Ad Unit ID: ca-app-pub-3940256099942544/9257395921', 'https://storage.googleapis.com/admob-app-open-placeholder.png', 'https://admob.google.com', NOW(), NOW() + INTERVAL '365 days', TRUE);

-- Enable Row Level Security (RLS) for production
-- ALTER TABLE movies ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE ads ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE episodes ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE users ENABLE ROW LEVEL SECURITY;

-- Create policies for public access (for development)
-- CREATE POLICY "Allow public read access" ON movies FOR SELECT USING (true);
-- CREATE POLICY "Allow public insert access" ON movies FOR INSERT WITH CHECK (true);
-- CREATE POLICY "Allow public update access" ON movies FOR UPDATE USING (true);
-- CREATE POLICY "Allow public delete access" ON movies FOR DELETE USING (true);

-- Repeat similar policies for other tables as needed

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_movies_isseries ON movies(isSeries);
CREATE INDEX IF NOT EXISTS idx_movies_created_at ON movies(createdAt);
CREATE INDEX IF NOT EXISTS idx_movies_rating ON movies(rating);
CREATE INDEX IF NOT EXISTS idx_movies_views ON movies(views);
CREATE INDEX IF NOT EXISTS idx_ads_active ON ads(isActive);
CREATE INDEX IF NOT EXISTS idx_ads_dates ON ads(startAt, endAt);
CREATE INDEX IF NOT EXISTS idx_episodes_series ON episodes(seriesId);
