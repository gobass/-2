-- Fix Row Level Security (RLS) policies for movies and ads tables to allow authorized inserts and updates

-- Enable RLS on movies table if not enabled
ALTER TABLE movies ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if any
DROP POLICY IF EXISTS "Allow authenticated users to insert movies" ON movies;
DROP POLICY IF EXISTS "Allow authenticated users to update movies" ON movies;

-- Create policy to allow authenticated users to insert movies
CREATE POLICY "Allow authenticated users to insert movies" ON movies
  FOR INSERT
  TO authenticated
  WITH CHECK (auth.role() = 'authenticated');

-- Create policy to allow authenticated users to update movies
CREATE POLICY "Allow authenticated users to update movies" ON movies
  FOR UPDATE
  TO authenticated
  USING (auth.role() = 'authenticated');

-- Enable RLS on ads table if not enabled
ALTER TABLE ads ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if any
DROP POLICY IF EXISTS "Allow authenticated users to insert ads" ON ads;
DROP POLICY IF EXISTS "Allow authenticated users to update ads" ON ads;

-- Create policy to allow authenticated users to insert ads
CREATE POLICY "Allow authenticated users to insert ads" ON ads
  FOR INSERT
  TO authenticated
  WITH CHECK (auth.role() = 'authenticated');

-- Create policy to allow authenticated users to update ads
CREATE POLICY "Allow authenticated users to update ads" ON ads
  FOR UPDATE
  TO authenticated
  USING (auth.role() = 'authenticated');
