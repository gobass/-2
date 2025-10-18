-- Fix for missing columns in movies table
-- Run this in your Supabase SQL Editor

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
ALTER TABLE movies ADD COLUMN IF NOT EXISTS "isSeries" BOOLEAN DEFAULT FALSE;
ALTER TABLE movies ADD COLUMN IF NOT EXISTS "episodes" JSONB; -- Store episode data as JSON
ALTER TABLE movies ADD COLUMN IF NOT EXISTS "seasonCount" INTEGER DEFAULT 0;
ALTER TABLE movies ADD COLUMN IF NOT EXISTS "lastEpisode" TEXT;
ALTER TABLE movies ADD COLUMN IF NOT EXISTS "nextEpisode" TEXT;
ALTER TABLE movies ADD COLUMN IF NOT EXISTS "downloadStatus" TEXT DEFAULT 'pending'; -- pending, downloading, completed, failed

-- Additional columns for ads support
ALTER TABLE movies ADD COLUMN IF NOT EXISTS "hasAds" BOOLEAN DEFAULT FALSE;
ALTER TABLE movies ADD COLUMN IF NOT EXISTS "adBreaks" JSONB; -- Store ad break times as JSON
ALTER TABLE movies ADD COLUMN IF NOT EXISTS "adProvider" TEXT; -- admob, custom, etc.
ALTER TABLE movies ADD COLUMN IF NOT EXISTS "adUnitId" TEXT; -- For AdMob integration

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_movies_posterurl ON movies("posterUrl");
CREATE INDEX IF NOT EXISTS idx_movies_videourl ON movies("videoUrl");
CREATE INDEX IF NOT EXISTS idx_movies_categories ON movies USING GIN("categories");
CREATE INDEX IF NOT EXISTS idx_movies_isseries ON movies("isSeries");
CREATE INDEX IF NOT EXISTS idx_movies_episodes ON movies USING GIN("episodes");
CREATE INDEX IF NOT EXISTS idx_movies_downloadstatus ON movies("downloadStatus");
CREATE INDEX IF NOT EXISTS idx_movies_hasads ON movies("hasAds");

-- Verify all columns exist
SELECT column_name, data_type, is_nullable, column_default
FROM information_schema.columns
WHERE table_name = 'movies'
ORDER BY ordinal_position;
