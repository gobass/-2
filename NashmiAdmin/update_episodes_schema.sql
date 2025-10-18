-- Migration script for Supabase - Only add missing columns
-- Run this in your Supabase SQL Editor

-- Rename columns safely (only if they exist with old names and new names don't exist)
DO $$
BEGIN
    -- Check if old column names exist and new ones don't, then rename them
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'episodes' AND column_name = 'episodenumber')
       AND NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'episodes' AND column_name = 'episode_number') THEN
        ALTER TABLE episodes RENAME COLUMN episodenumber TO episode_number;
    END IF;

    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'episodes' AND column_name = 'seriesid')
       AND NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'episodes' AND column_name = 'series_id') THEN
        ALTER TABLE episodes RENAME COLUMN seriesid TO series_id;
    END IF;

    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'episodes' AND column_name = 'videourl')
       AND NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'episodes' AND column_name = 'video_url') THEN
        ALTER TABLE episodes RENAME COLUMN videourl TO video_url;
    END IF;

    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'episodes' AND column_name = 'createdat')
       AND NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'episodes' AND column_name = 'created_at') THEN
        ALTER TABLE episodes RENAME COLUMN createdat TO created_at;
    END IF;

    -- Handle case where both old and new columns exist (migration was partially run)
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'episodes' AND column_name = 'seriesid')
       AND EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'episodes' AND column_name = 'series_id') THEN
        -- Drop the old column if both exist
        ALTER TABLE episodes DROP COLUMN seriesid;
    END IF;

    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'episodes' AND column_name = 'episodenumber')
       AND EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'episodes' AND column_name = 'episode_number') THEN
        -- Drop the old column if both exist
        ALTER TABLE episodes DROP COLUMN episodenumber;
    END IF;

    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'episodes' AND column_name = 'videourl')
       AND EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'episodes' AND column_name = 'video_url') THEN
        ALTER TABLE episodes DROP COLUMN videourl;
    END IF;

    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'episodes' AND column_name = 'createdat')
       AND EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'episodes' AND column_name = 'created_at') THEN
        ALTER TABLE episodes DROP COLUMN createdat;
    END IF;
END $$;

-- Add only missing columns
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'episodes' AND column_name = 'description') THEN
        ALTER TABLE episodes ADD COLUMN description TEXT;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'episodes' AND column_name = 'series_id') THEN
        ALTER TABLE episodes ADD COLUMN series_id UUID;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'episodes' AND column_name = 'video_url') THEN
        ALTER TABLE episodes ADD COLUMN video_url TEXT;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'episodes' AND column_name = 'created_at') THEN
        ALTER TABLE episodes ADD COLUMN created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW();
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'episodes' AND column_name = 'updated_at') THEN
        ALTER TABLE episodes ADD COLUMN updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW();
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'episodes' AND column_name = 'duration') THEN
        ALTER TABLE episodes ADD COLUMN duration INTEGER DEFAULT 0;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'episodes' AND column_name = 'views') THEN
        ALTER TABLE episodes ADD COLUMN views INTEGER DEFAULT 0;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'episodes' AND column_name = 'is_active') THEN
        ALTER TABLE episodes ADD COLUMN is_active BOOLEAN DEFAULT true;
    END IF;
END $$;

-- Create indexes only if they don't exist
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE tablename = 'episodes' AND indexname = 'idx_episodes_series_id') THEN
        CREATE INDEX idx_episodes_series_id ON episodes(series_id);
    END IF;

    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE tablename = 'episodes' AND indexname = 'idx_episodes_episode_number') THEN
        CREATE INDEX idx_episodes_episode_number ON episodes(episode_number);
    END IF;

    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE tablename = 'episodes' AND indexname = 'idx_episodes_created_at') THEN
        CREATE INDEX idx_episodes_created_at ON episodes(created_at);
    END IF;
END $$;

-- Enable RLS
ALTER TABLE episodes ENABLE ROW LEVEL SECURITY;

-- Create policy only if it doesn't exist
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'episodes' AND policyname = 'Enable all operations for authenticated users') THEN
        CREATE POLICY "Enable all operations for authenticated users" ON episodes FOR ALL USING (auth.role() = 'authenticated');
    END IF;
END $$;

-- Create trigger function
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create trigger only if it doesn't exist
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.triggers WHERE trigger_name = 'update_episodes_updated_at') THEN
        CREATE TRIGGER update_episodes_updated_at
            BEFORE UPDATE ON episodes
            FOR EACH ROW
            EXECUTE FUNCTION update_updated_at_column();
    END IF;
END $$;
