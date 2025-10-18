-- Create series table in Supabase
-- Run this in your Supabase SQL Editor

-- Create the series table with the same structure as movies
CREATE TABLE IF NOT EXISTS series (
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
    createdat TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    archived BOOLEAN DEFAULT FALSE
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_series_title ON series(title);
CREATE INDEX IF NOT EXISTS idx_series_posterurl ON series("posterUrl");
CREATE INDEX IF NOT EXISTS idx_series_videourl ON series("videoUrl");
CREATE INDEX IF NOT EXISTS idx_series_categories ON series USING GIN("categories");
CREATE INDEX IF NOT EXISTS idx_series_createdat ON series(createdat);
CREATE INDEX IF NOT EXISTS idx_series_archived ON series(archived);

-- Enable Row Level Security (RLS)
ALTER TABLE series ENABLE ROW LEVEL SECURITY;

-- Create policies for public access (adjust as needed for your security requirements)
CREATE POLICY "Enable read access for all users" ON series FOR SELECT USING (true);
CREATE POLICY "Enable insert for authenticated users" ON series FOR INSERT WITH CHECK (true);
CREATE POLICY "Enable update for authenticated users" ON series FOR UPDATE USING (true);
CREATE POLICY "Enable delete for authenticated users" ON series FOR DELETE USING (true);

-- Verify the table was created
SELECT table_name, table_type
FROM information_schema.tables
WHERE table_name = 'series' AND table_schema = 'public';

-- Verify columns
SELECT column_name, data_type, is_nullable, column_default
FROM information_schema.columns
WHERE table_name = 'series'
ORDER BY ordinal_position;
