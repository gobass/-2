-- استرجاع البيانات من جداول Supabase
-- Execute this in Supabase SQL Editor or use with Supabase CLI

-- 1. استرجاع جميع الأفلام من جدول movies
SELECT
    id,
    title,
    slug,
    description,
    categories,
    year,
    duration,
    posterUrl,
    videoUrl,
    isActive,
    tags,
    views,
    createdat
FROM movies
ORDER BY createdat DESC;

-- 2. استرجاع جميع المسلسلات من جدول series
SELECT
    id,
    title,
    slug,
    description,
    categories,
    year,
    duration,
    posterUrl,
    video_url,
    tags,
    views,
    rating,
    total_episodes,
    isSeries,
    createdat
FROM series
ORDER BY createdat DESC;

-- 3. استرجاع جميع الإعلانات من جدول ads
SELECT
    id,
    title,
    description,
    imageUrl,
    videoUrl,
    targetUrl,
    start_at,
    end_at,
    adMobAppId,
    adUnitId,
    is_active,
    frequency,
    weight,
    createdat
FROM ads
ORDER BY createdat DESC;

-- 4. استرجاع حلقات المسلسلات من جدول episodes
SELECT
    e.id,
    e.series_id,
    s.title as series_title,
    e.episode_number,
    e.title,
    e.video_url,
    e.created_at,
    e.posters,
    e.description,
    e.duration,
    e.views,
    e.is_active,
    e.updated_at
FROM episodes e
LEFT JOIN series s ON e.series_id = s.id
ORDER BY e.series_id, e.episode_number;

-- 5. استرجاع المستخدمين من جدول users
SELECT
    id,
    name,
    email,
    status,
    createdAt,
    updatedAt
FROM users
ORDER BY createdAt DESC;

-- 6. استرجاع التصنيفات من جدول categories
SELECT
    name,
    created_at
FROM categories
ORDER BY created_at DESC;

-- 7. إحصائيات سريعة
SELECT
    'Movies' as table_name, COUNT(*) as count FROM movies
UNION ALL
SELECT 'Series' as table_name, COUNT(*) as count FROM series
UNION ALL
SELECT 'Episodes' as table_name, COUNT(*) as count FROM episodes
UNION ALL
SELECT 'Ads' as table_name, COUNT(*) as count FROM ads
UNION ALL
SELECT 'Users' as table_name, COUNT(*) as count FROM users
UNION ALL
SELECT 'Categories' as table_name, COUNT(*) as count FROM categories;
