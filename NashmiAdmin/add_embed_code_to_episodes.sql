-- Migration to add embed_code column to episodes table
-- Run this in your Supabase SQL Editor

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'episodes' AND column_name = 'embed_code') THEN
        ALTER TABLE episodes ADD COLUMN embed_code TEXT;
    END IF;
END $$;
