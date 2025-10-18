-- Create episodes table for Nashmi Admin
CREATE TABLE IF NOT EXISTS episodes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    series_id UUID NOT NULL,
    episode_number INTEGER NOT NULL,
    title TEXT NOT NULL,
    video_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    posters TEXT,
    description TEXT,
    duration INTEGER DEFAULT 0,
    views INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

    -- Foreign key constraint to series table
    CONSTRAINT fk_episodes_series
        FOREIGN KEY (series_id)
        REFERENCES series(id)
        ON DELETE CASCADE,

    -- Unique constraint for episode number within a series
    CONSTRAINT unique_episode_per_series
        UNIQUE (series_id, episode_number)
);

-- Create index for better performance
CREATE INDEX IF NOT EXISTS idx_episodes_series_id ON episodes(series_id);
CREATE INDEX IF NOT EXISTS idx_episodes_episode_number ON episodes(episode_number);
CREATE INDEX IF NOT EXISTS idx_episodes_created_at ON episodes(created_at);

-- Enable Row Level Security (RLS)
ALTER TABLE episodes ENABLE ROW LEVEL SECURITY;

-- Create policies for episodes table
-- Allow all operations for authenticated users (adjust as needed for your security requirements)
CREATE POLICY "Enable all operations for authenticated users" ON episodes
    FOR ALL USING (auth.role() = 'authenticated');

-- Create trigger to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_episodes_updated_at
    BEFORE UPDATE ON episodes
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();
