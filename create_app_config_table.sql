-- Create app_config table for storing AdMob settings and other app configurations
CREATE TABLE IF NOT EXISTS app_config (
    id SERIAL PRIMARY KEY,
    config_key VARCHAR(100) UNIQUE NOT NULL,
    config_value TEXT,
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    config_key TEXT NOT NULL UNIQUE,
    config_value TEXT NOT NULL,
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_app_config_key ON app_config(config_key);

-- Enable Row Level Security (RLS)
ALTER TABLE app_config ENABLE ROW LEVEL SECURITY;

-- Create policies for public read access
CREATE POLICY "Enable read access for all users" ON app_config FOR SELECT USING (true);
CREATE POLICY "Enable insert for authenticated users" ON app_config FOR INSERT WITH CHECK (true);
CREATE POLICY "Enable update for authenticated users" ON app_config FOR UPDATE USING (true);
CREATE POLICY "Enable delete for authenticated users" ON app_config FOR DELETE USING (true);

-- Insert default AdMob configuration
INSERT INTO app_config (config_key, config_value, description) VALUES
('admob_banner_android', 'ca-app-pub-3940256099942544/6300978111', 'AdMob Banner Ad Unit ID for Android'),
('admob_banner_ios', 'ca-app-pub-3940256099942544/2934735716', 'AdMob Banner Ad Unit ID for iOS'),
('admob_interstitial_android', 'ca-app-pub-3940256099942544/1033173712', 'AdMob Interstitial Ad Unit ID for Android'),
('admob_interstitial_ios', 'ca-app-pub-3940256099942544/4411468910', 'AdMob Interstitial Ad Unit ID for iOS'),
('admob_rewarded_android', 'ca-app-pub-3940256099942544/5224354917', 'AdMob Rewarded Ad Unit ID for Android'),
('admob_rewarded_ios', 'ca-app-pub-3940256099942544/1712485313', 'AdMob Rewarded Ad Unit ID for iOS'),
('admob_app_id_android', 'ca-app-pub-3940256099942544~3347511713', 'AdMob App ID for Android'),
('admob_app_id_ios', 'ca-app-pub-3940256099942544~1458002511', 'AdMob App ID for iOS')
ON CONFLICT (config_key) DO NOTHING;

-- Verify the table was created
SELECT table_name, table_type
FROM information_schema.tables
WHERE table_name = 'app_config' AND table_schema = 'public';

-- Verify data
SELECT config_key, config_value, description FROM app_config ORDER BY config_key;
