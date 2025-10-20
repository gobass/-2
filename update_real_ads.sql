-- Update app_config table with REAL AdMob ad unit IDs from your AdMob account
-- Using Android ad unit IDs for both Android and iOS platforms (since you only have Android ads)

-- Banner Ads (using Android ID for both platforms)
UPDATE app_config SET config_value = 'ca-app-pub-3794036444002573/6894673538' WHERE config_key = 'admob_banner_android';
UPDATE app_config SET config_value = 'ca-app-pub-3794036444002573/6894673538' WHERE config_key = 'admob_banner_ios';

-- Interstitial Ads (using Android ID for both platforms)
UPDATE app_config SET config_value = 'ca-app-pub-3794036444002573/8670789633' WHERE config_key = 'admob_interstitial_android';
UPDATE app_config SET config_value = 'ca-app-pub-3794036444002573/8670789633' WHERE config_key = 'admob_interstitial_ios';

-- Rewarded Ads (using Android ID for both platforms)
UPDATE app_config SET config_value = 'ca-app-pub-3794036444002573/3251280337' WHERE config_key = 'admob_rewarded_android';
UPDATE app_config SET config_value = 'ca-app-pub-3794036444002573/3251280337' WHERE config_key = 'admob_rewarded_ios';

-- App IDs (using Android production App ID for both platforms)
UPDATE app_config SET config_value = 'ca-app-pub-3794036444002573~6625241143' WHERE config_key = 'admob_app_id_android';
UPDATE app_config SET config_value = 'ca-app-pub-3794036444002573~6625241143' WHERE config_key = 'admob_app_id_ios';

-- App Open Ads (using Android App Open ID for both platforms)
UPDATE app_config SET config_value = 'ca-app-pub-3794036444002573/8589036761' WHERE config_key = 'admob_app_open_android';
UPDATE app_config SET config_value = 'ca-app-pub-3794036444002573/8589036761' WHERE config_key = 'admob_app_open_ios';

-- Additional ad unit IDs for future use (commented out)
-- Native Ads: ca-app-pub-3794036444002573/7925022511, ca-app-pub-3794036444002573/7811157623
-- Extra Interstitial: ca-app-pub-3794036444002573/7330444343, ca-app-pub-3794036444002573/7653275337, ca-app-pub-3794036444002573/1531731875, ca-app-pub-3794036444002573/8004273901, ca-app-pub-3794036444002573/2004830008
