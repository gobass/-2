-- Fix for missing 'isSeries' column in movies table
-- Run this in your Supabase SQL Editor

-- Add the isSeries column to the movies table if it doesn't exist
ALTER TABLE movies ADD COLUMN IF NOT EXISTS "isSeries" BOOLEAN DEFAULT FALSE;

-- Create index for better performance on isSeries queries
CREATE INDEX IF NOT EXISTS idx_movies_isseries ON movies("isSeries");

-- Update any existing records to have isSeries = false if they are null
UPDATE movies SET "isSeries" = FALSE WHERE "isSeries" IS NULL;

-- Verify the column was added
SELECT column_name, data_type, is_nullable, column_default
FROM information_schema.columns
WHERE table_name = 'movies' AND column_name = 'isSeries';
