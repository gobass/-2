-- Merged migration script combining add_weight_column_to_ads.sql, update_episodes_schema.sql, and fix_rls_policies_final.sql

-- add_weight_column_to_ads.sql
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'ads' AND column_name = 'weight') THEN
        ALTER TABLE ads ADD COLUMN weight INTEGER DEFAULT 0;
    END IF;
END $$;

COMMENT ON COLUMN ads.weight IS 'Weight of the ad for performance calculations';

-- update_episodes_schema.sql

DO $$
BEGIN
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

    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'episodes' AND column_name = 'seriesid')
       AND EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'episodes' AND column_name = 'series_id') THEN
        ALTER TABLE episodes DROP COLUMN seriesid;
    END IF;

    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'episodes' AND column_name = 'episodenumber')
       AND EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'episodes' AND column_name = 'episode_number') THEN
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

ALTER TABLE episodes ENABLE ROW LEVEL SECURITY;

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'episodes' AND policyname = 'Enable all operations for authenticated users') THEN
        CREATE POLICY "Enable all operations for authenticated users" ON episodes FOR ALL USING (auth.role() = 'authenticated');
    END IF;
END $$;

CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.triggers WHERE trigger_name = 'update_episodes_updated_at') THEN
        CREATE TRIGGER update_episodes_updated_at
            BEFORE UPDATE ON episodes
            FOR EACH ROW
            EXECUTE FUNCTION update_updated_at_column();
    END IF;
END $$;

-- fix_rls_policies_final.sql

ALTER TABLE movies ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Allow authenticated users to insert movies" ON movies;
DROP POLICY IF EXISTS "Allow authenticated users to update movies" ON movies;

CREATE POLICY "Allow authenticated users to insert movies" ON movies
  FOR INSERT
  TO authenticated
  WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Allow authenticated users to update movies" ON movies
  FOR UPDATE
  TO authenticated
  USING (auth.role() = 'authenticated');

ALTER TABLE ads ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Allow authenticated users to insert ads" ON ads;
DROP POLICY IF EXISTS "Allow authenticated users to update ads" ON ads;

CREATE POLICY "Allow authenticated users to insert ads" ON ads
  FOR INSERT
  TO authenticated
  WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Allow authenticated users to update ads" ON ads
  FOR UPDATE
  TO authenticated
  USING (auth.role() = 'authenticated');

-- Add missing isSeries column to series table
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'series' AND column_name = 'isSeries') THEN
        ALTER TABLE series ADD COLUMN isSeries BOOLEAN DEFAULT false;
    END IF;
END $$;

-- Add missing createdat column to users table
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'users' AND column_name = 'createdat') THEN
        ALTER TABLE users ADD COLUMN createdat TIMESTAMP WITH TIME ZONE DEFAULT NOW();
    END IF;
END $$;

-- Create missing categories table
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'categories') THEN
        CREATE TABLE categories (
            id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
            name TEXT NOT NULL,
            description TEXT,
            created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
            updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
        );
    END IF;
END $$;
