-- Migration script to add the missing 'weight' column to the 'ads' table
-- Run this in your Supabase SQL Editor

-- Add the weight column to the ads table if it doesn't exist
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'ads' AND column_name = 'weight') THEN
        ALTER TABLE ads ADD COLUMN weight INTEGER DEFAULT 0;
    END IF;
END $$;

-- Optional: Add a comment to the column for documentation
COMMENT ON COLUMN ads.weight IS 'Weight of the ad for performance calculations';
