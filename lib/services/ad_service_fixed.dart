import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'dart:io';
import 'dart:async';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'supabase_service.dart';

class AdService {
  static const bool _adsEnabled = true; // تفعيل الإعلانات

  final SupabaseService _supabaseService = Get.find<SupabaseService>();

  // Ad Unit IDs - loaded from database
  String? _bannerAdUnitId;
  String? _interstitialAdUnitId;
  String? _rewardedAdUnitId;

  Future<String> get _getBannerAdUnitId async {
    if (_bannerAdUnitId == null) {
      _bannerAdUnitId = await _supabaseService.getConfigValue(
        Platform.isAndroid ? 'admob_banner_android' : 'admob_banner_ios',
      );
      if (_bannerAdUnitId == null) {
        throw Exception('Banner Ad Unit ID not found in database');
      }
      print('🔍 Banner Ad Unit ID loaded from database: $_bannerAdUnitId');
    }
    return _bannerAdUnitId!;
  }

  Future<String> get _getInterstitialAdUnitId async {
    if (_interstitialAdUnitId == null) {
      _interstitialAdUnitId = await _supabaseService.getConfigValue(
        Platform.isAndroid
            ? 'admob_interstitial_android'
            : 'admob_interstitial_ios',
      );
      if (_interstitialAdUnitId == null) {
        throw Exception('Interstitial Ad Unit ID not found in database');
      }
      print(
        '🔍 Interstitial Ad Unit ID loaded from database: $_interstitialAdUnitId',
      );
    }
    return _interstitialAdUnitId!;
  }

  Future<String> get _getRewardedAdUnitId async {
    if (_rewardedAdUnitId == null) {
      _rewardedAdUnitId = await _supabaseService.getConfigValue(
        Platform.isAndroid ? 'admob_rewarded_android' : 'admob_rewarded_ios',
      );
      if (_rewardedAdUnitId == null) {
        throw Exception('Rewarded Ad Unit ID not found in database');
      }
      print('🔍 Rewarded Ad Unit ID loaded from database: $_rewardedAdUnitId');
    }
    return _rewardedAdUnitId!;
  }

  // Hardcoded production ad unit IDs as fallback
  static const Map<String, String> _productionAdIds = {
    'banner_android': 'ca-app-pub-3794036444002573/6894673538',
    'banner_ios': 'ca-app-pub-3794036444002573/6894673538',
    'interstitial_android': 'ca-app-pub-3794036444002573/8670789633',
    'interstitial_ios': 'ca-app-pub-3794036444002573/8670789633',
    'rewarded_android': 'ca-app-pub-3794036444002573/3251280337',
    'rewarded_ios': 'ca-app-pub-3794036444002573/3251280337',
  };

  BannerAd? _bannerAd;
  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;

  bool get isBannerAdLoaded => _bannerAd != null;
  bool get isInterstitialAdLoaded => _interstitialAd != null;
  bool get isRewardedAdLoaded => _rewardedAd != null;

  BannerAd? get bannerAd => _bannerAd;

  // Timer for 10-minute ads
  Timer? _tenMinuteTimer;

  // Initialize AdMob
  Future<void> initialize() async {
    if (!_adsEnabled) {
      print('❌ Ads disabled');
      return;
    }

    // Check if running on web - Google Mobile Ads doesn't work on web
    try {
      if (Platform.isAndroid || Platform.isIOS) {
        print(
          '📱 Initializing AdMob for ${Platform.isAndroid ? 'Android' : 'iOS'}...',
        );
        await MobileAds.instance.initialize();
        print('✅ AdMob initialized successfully');

        // تحميل الإعلانات
        print('📱 Loading ads...');
        await _loadBannerAd();
        await _loadInterstitialAd();
        await _loadRewardedAd();

        // Start 10-minute timer for ads
        _startTenMinuteTimer();
        print('✅ AdService initialization completed');
      } else {
        print('❌ Ads not supported on this platform (web)');
      }
    } catch (e) {
      print('❌ Failed to initialize AdMob: $e');
    }
  }

  // Start timer for 10-minute ads
  void _startTenMinuteTimer() {
    _tenMinuteTimer?.cancel();
    _tenMinuteTimer = Timer.periodic(const Duration(minutes: 10), (timer) {
      print('10-minute timer triggered - showing interstitial ad');
      showInterstitialAd();
    });
  }

  // تحميل إعلان البانر
  Future<void> _loadBannerAd() async {
    try {
      final adUnitId = await _getBannerAdUnitId;
      print('📱 Loading banner ad with ID: $adUnitId');

      _bannerAd = BannerAd(
        adUnitId: adUnitId,
        size: AdSize.banner,
        request: const AdRequest(),
        listener: BannerAdListener(
          onAdLoaded: (ad) {
            print('✅ Banner ad loaded successfully');
          },
          onAdFailedToLoad: (ad, error) {
            print('❌ Banner ad failed to load: $error');
            ad.dispose();
            // Retry loading after 30 seconds
            Future.delayed(const Duration(seconds: 30), () {
              print('🔄 Retrying banner ad load...');
              _loadBannerAd();
            });
          },
        ),
      );

      await _bannerAd!.load();
    } catch (e) {
      print('❌ Error loading banner ad: $e');
    }
  }

  // تحميل إعلان بينية
  Future<void> _loadInterstitialAd() async {
    try {
      final adUnitId = await _getInterstitialAdUnitId;
      print('🎬 Loading interstitial ad with ID: $adUnitId');

      await InterstitialAd.load(
        adUnitId: adUnitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            _interstitialAd = ad;
            print('✅ Interstitial ad loaded successfully');
          },
          onAdFailedToLoad: (error) {
            print('❌ Interstitial ad failed to load: $error');
            // Retry loading after 60 seconds
            Future.delayed(const Duration(seconds: 60), () {
              print('🔄 Retrying interstitial ad load...');
              _loadInterstitialAd();
            });
          },
        ),
      );
    } catch (e) {
      print('❌ Error loading interstitial ad: $e');
    }
  }

  // تحميل إعلان مكافآت
  Future<void> _loadRewardedAd() async {
    try {
      final adUnitId = await _getRewardedAdUnitId;
      print('🎁 Loading rewarded ad with ID: $adUnitId');

      await RewardedAd.load(
        adUnitId: adUnitId,
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (ad) {
            _rewardedAd = ad;
            print('✅ Rewarded ad loaded successfully');
          },
          onAdFailedToLoad: (error) {
            print('❌ Rewarded ad failed to load: $error');
            // Retry loading after 60 seconds
            Future.delayed(const Duration(seconds: 60), () {
              print('🔄 Retrying rewarded ad load...');
              _loadRewardedAd();
            });
          },
        ),
      );
    } catch (e) {
      print('❌ Error loading rewarded ad: $e');
    }
  }

  // عرض إعلان بيني
  void showInterstitialAd([Function? onAdDismissed]) {
    print('🎬 Attempting to show interstitial ad...');
    print('🎬 Interstitial ad loaded: ${_interstitialAd != null}');

    if (_interstitialAd != null) {
      print('🎬 Showing interstitial ad');
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdShowedFullScreenContent: (ad) {
          print('🎬 Interstitial ad showed successfully');
        },
        onAdDismissedFullScreenContent: (ad) {
          print('🎬 Interstitial ad dismissed');
          ad.dispose();
          _loadInterstitialAd(); // تحميل إعلان جديد
          if (onAdDismissed != null) onAdDismissed();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          print('🎬 Interstitial ad failed to show: $error');
          ad.dispose();
          _loadInterstitialAd();
          if (onAdDismissed != null) onAdDismissed();
        },
      );

      _interstitialAd!.show();
      _interstitialAd = null;
    } else {
      print('❌ Interstitial ad not ready - loading new one');
      _loadInterstitialAd();
      if (onAdDismissed != null) onAdDismissed();
    }
  }

  // عرض إعلان مكافآت
  void showRewardedAd(Function(bool) onRewardEarned) {
    print('🎁 Attempting to show rewarded ad...');
    print('🎁 Rewarded ad loaded: ${_rewardedAd != null}');

    if (_rewardedAd != null) {
      print('🎁 Showing rewarded ad');
      _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdShowedFullScreenContent: (ad) {
          print('🎁 Rewarded ad showed successfully');
        },
        onAdDismissedFullScreenContent: (ad) {
          print('🎁 Rewarded ad dismissed');
          ad.dispose();
          _loadRewardedAd();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          print('🎁 Rewarded ad failed to show: $error');
          ad.dispose();
          _loadRewardedAd();
          onRewardEarned(false);
        },
      );

      _rewardedAd!.show(
        onUserEarnedReward: (ad, reward) {
          print('🎁 User earned reward: ${reward.amount} ${reward.type}');
          onRewardEarned(true);
        },
      );
      _rewardedAd = null;
    } else {
      print('❌ Rewarded ad not ready - loading new one');
      _loadRewardedAd();
      onRewardEarned(false);
    }
  }

  // فحص إذا كان يجب عرض إعلان بيني
  bool shouldShowInterstitial() {
    return _adsEnabled && _interstitialAd != null;
  }

  // الحصول على ويدجت إعلان البانر
  Widget getBannerAdWidget() {
    if (_bannerAd != null) {
      return AdWidget(ad: _bannerAd!);
    } else {
      return Container(
        height: 50,
        color: Colors.grey[900],
        child: const Center(
          child: Text(
            'جاري تحميل الإعلان...',
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ),
      );
    }
  }

  // تنظيف الموارد
  void dispose() {
    _tenMinuteTimer?.cancel();
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
    print('AdService disposed');
  }

  // Force show interstitial ad for testing
  void forceShowInterstitialAd([Function? onAdDismissed]) {
    print('🧪 Force showing interstitial ad for testing');
    showInterstitialAd(onAdDismissed);
  }

  // Force show rewarded ad for testing
  void forceShowRewardedAd(Function(bool) onRewardEarned) {
    print('🧪 Force showing rewarded ad for testing');
    showRewardedAd(onRewardEarned);
  }

  // Get ad status for debugging
  Map<String, dynamic> getAdStatus() {
    return {
      'bannerLoaded': _bannerAd != null,
      'interstitialLoaded': _interstitialAd != null,
      'rewardedLoaded': _rewardedAd != null,
      'adsEnabled': _adsEnabled,
      'platform': Platform.isAndroid
          ? 'Android'
          : Platform.isIOS
          ? 'iOS'
          : 'Other',
    };
  }
}
