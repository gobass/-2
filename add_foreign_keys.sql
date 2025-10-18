-- Add Foreign Key Constraints to Supabase Tables
-- Execute this in Supabase SQL Editor

-- Add foreign key constraint for episodes.series_id -> series.id
ALTER TABLE episodes
ADD CONSTRAINT fk_episodes_series_id
FOREIGN KEY (series_id) REFERENCES series(id) ON DELETE CASCADE;

-- Verify the foreign key was added
SELECT
    tc.table_name,
    tc.constraint_name,
    tc.constraint_type,
    kcu.column_name,
    ccu.table_name AS foreign_table_name,
    ccu.column_name AS foreign_column_name
FROM
    information_schema.table_constraints AS tc
    JOIN information_schema.key_column_usage AS kcu
      ON tc.constraint_name = kcu.constraint_name
      AND tc.table_schema = kcu.table_schema
    JOIN information_schema.constraint_column_usage AS ccu
      ON ccu.constraint_name = tc.constraint_name
      AND ccu.table_schema = tc.table_schema
WHERE
    tc.constraint_type = 'FOREIGN KEY'
    AND tc.table_name IN ('episodes', 'movies', 'series', 'ads', 'users', 'categories');
