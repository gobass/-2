-- Add missing isSeries column to series table manually
ALTER TABLE series ADD COLUMN IF NOT EXISTS "isSeries" BOOLEAN DEFAULT false;
