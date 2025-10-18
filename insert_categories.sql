-- Insert initial categories into the categories table
-- Run this in your Supabase SQL Editor to populate the categories table

INSERT INTO categories (name, created_at) VALUES
('أكشن', NOW()),
('دراما', NOW()),
('كوميدي', NOW()),
('رعب', NOW()),
('رومانسي', NOW()),
('خيال علمي', NOW()),
('وثائقي', NOW()),
('مغامرة', NOW()),
('جريمة', NOW()),
('عائلي', NOW()),
('تاريخي', NOW()),
('تشويق', NOW());

-- Verify the insertion
SELECT 'Categories Count' as table_name, COUNT(*) as count FROM categories;
SELECT name, created_at FROM categories ORDER BY created_at DESC;
