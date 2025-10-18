-- Fix Row Level Security (RLS) policies for movies and ads tables to allow authorized inserts and updates

-- Enable RLS on movies table if not enabled
ALTER TABLE movies ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if any
DROP POLICY IF EXISTS "Allow authenticated users to insert and update movies" ON movies;

-- Create policy to allow authenticated users to insert and update movies
DROP POLICY IF EXISTS "Allow authenticated users to insert and update movies" ON movies;

CREATE POLICY "Allow admins full access to movies" ON movies
  FOR ALL
  TO authenticated
  USING (auth.role() = 'admin');

-- Enable RLS on ads table if not enabled
ALTER TABLE ads ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if any
DROP POLICY IF EXISTS "Allow authenticated users to insert and update ads" ON ads;

CREATE POLICY "Allow admins full access to ads" ON ads
  FOR ALL
  TO authenticated
  USING (auth.role() = 'admin');
