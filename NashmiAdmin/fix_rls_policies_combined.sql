-- Combined and corrected RLS policies for movies, ads, series, and users tables

-- Enable RLS on movies table
ALTER TABLE movies ENABLE ROW LEVEL SECURITY;

-- Drop existing policies on movies
DROP POLICY IF EXISTS "Allow authenticated users to insert movies" ON movies;
DROP POLICY IF EXISTS "Allow authenticated users to update movies" ON movies;

-- Create insert policy for movies
CREATE POLICY "Allow authenticated users to insert movies" ON movies
  FOR INSERT
  TO authenticated
  WITH CHECK (auth.role() = 'authenticated');

-- Create update policy for movies
CREATE POLICY "Allow authenticated users to update movies" ON movies
  FOR UPDATE
  TO authenticated
  USING (auth.role() = 'authenticated');

-- Enable RLS on ads table
ALTER TABLE ads ENABLE ROW LEVEL SECURITY;

-- Drop existing policies on ads
DROP POLICY IF EXISTS "Allow authenticated users to insert ads" ON ads;
DROP POLICY IF EXISTS "Allow authenticated users to update ads" ON ads;

-- Create insert policy for ads
CREATE POLICY "Allow authenticated users to insert ads" ON ads
  FOR INSERT
  TO authenticated
  WITH CHECK (auth.role() = 'authenticated');

-- Create update policy for ads
CREATE POLICY "Allow authenticated users to update ads" ON ads
  FOR UPDATE
  TO authenticated
  USING (auth.role() = 'authenticated');

-- Enable RLS on series table
ALTER TABLE series ENABLE ROW LEVEL SECURITY;

-- Drop existing policies on series
DROP POLICY IF EXISTS "Allow authenticated users to insert series" ON series;
DROP POLICY IF EXISTS "Allow authenticated users to update series" ON series;

-- Create insert policy for series
CREATE POLICY "Allow authenticated users to insert series" ON series
  FOR INSERT
  TO authenticated
  WITH CHECK (auth.role() = 'authenticated');

-- Create update policy for series
CREATE POLICY "Allow authenticated users to update series" ON series
  FOR UPDATE
  TO authenticated
  USING (auth.role() = 'authenticated');

-- Enable RLS on users table
ALTER TABLE users ENABLE ROW LEVEL SECURITY;

-- Drop existing policies on users
DROP POLICY IF EXISTS "Allow authenticated users to insert users" ON users;
DROP POLICY IF EXISTS "Allow authenticated users to update users" ON users;

-- Create insert policy for users
CREATE POLICY "Allow authenticated users to insert users" ON users
  FOR INSERT
  TO authenticated
  WITH CHECK (auth.role() = 'authenticated');

-- Create update policy for users
CREATE POLICY "Allow authenticated users to update users" ON users
  FOR UPDATE
  TO authenticated
  USING (auth.role() = 'authenticated');
