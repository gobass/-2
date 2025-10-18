-- Create ads table in Supabase
-- Run this in your Supabase SQL Editor

-- Create the ads table
CREATE TABLE IF NOT EXISTS ads (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    title TEXT NOT NULL,
    description TEXT,
    imageUrl TEXT,
    videoUrl TEXT,
    targetUrl TEXT,
    start_at TIMESTAMP WITH TIME ZONE NOT NULL,
    end_at TIMESTAMP WITH TIME ZONE NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    createdat TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    click_count INTEGER DEFAULT 0,
    view_count INTEGER DEFAULT 0
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_ads_title ON ads(title);
CREATE INDEX IF NOT EXISTS idx_ads_is_active ON ads(is_active);
CREATE INDEX IF NOT EXISTS idx_ads_start_at ON ads(start_at);
CREATE INDEX IF NOT EXISTS idx_ads_end_at ON ads(end_at);
CREATE INDEX IF NOT EXISTS idx_ads_createdat ON ads(createdat);

-- Enable Row Level Security (RLS)
ALTER TABLE ads ENABLE ROW LEVEL SECURITY;

-- Create policies for public access (adjust as needed for your security requirements)
CREATE POLICY "Enable read access for all users" ON ads FOR SELECT USING (true);
CREATE POLICY "Enable insert for authenticated users" ON ads FOR INSERT WITH CHECK (true);
CREATE POLICY "Enable update for authenticated users" ON ads FOR UPDATE USING (true);
CREATE POLICY "Enable delete for authenticated users" ON ads FOR DELETE USING (true);

-- Verify the table was created
SELECT table_name, table_type
FROM information_schema.tables
WHERE table_name = 'ads' AND table_schema = 'public';

-- Verify columns
SELECT column_name, data_type, is_nullable, column_default
FROM information_schema.columns
WHERE table_name = 'ads'
ORDER BY ordinal_position;
