import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'dart:io';
import 'dart:async';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
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
      _bannerAdUnitId =
          await _supabaseService.getConfigValue(
            Platform.isAndroid ? 'admob_banner_android' : 'admob_banner_ios',
          ) ??
          (Platform.isAndroid
              ? 'ca-app-pub-3940256099942544/6300978111' // Test ID fallback
              : 'ca-app-pub-3940256099942544/2934735716'); // Test ID fallback
      print('🔍 Banner Ad Unit ID loaded: $_bannerAdUnitId');
    }
    return _bannerAdUnitId!;
  }

  Future<String> get _getInterstitialAdUnitId async {
    if (_interstitialAdUnitId == null) {
      _interstitialAdUnitId =
          await _supabaseService.getConfigValue(
            Platform.isAndroid
                ? 'admob_interstitial_android'
                : 'admob_interstitial_ios',
          ) ??
          (Platform.isAndroid
              ? 'ca-app-pub-3940256099942544/1033173712' // Test ID fallback
              : 'ca-app-pub-3940256099942544/4411468910'); // Test ID fallback
    }
    return _interstitialAdUnitId!;
  }

  Future<String> get _getRewardedAdUnitId async {
    if (_rewardedAdUnitId == null) {
      _rewardedAdUnitId =
          await _supabaseService.getConfigValue(
            Platform.isAndroid
                ? 'admob_rewarded_android'
                : 'admob_rewarded_ios',
          ) ??
          (Platform.isAndroid
              ? 'ca-app-pub-3940256099942544/5224354917' // Test ID fallback
              : 'ca-app-pub-3940256099942544/1712485313'); // Test ID fallback
    }
    return _rewardedAdUnitId!;
  }

  // Hardcoded production ad unit IDs as fallback
  static const Map<String, String> _productionAdIds = {
    'banner_android': 'ca-app-pub-3940256099942544/6300978111',
    'banner_ios': 'ca-app-pub-3940256099942544/2934735716',
    'interstitial_android': 'ca-app-pub-3940256099942544/1033173712',
    'interstitial_ios': 'ca-app-pub-3940256099942544/4411468910',
    'rewarded_android': 'ca-app-pub-3940256099942544/5224354917',
    'rewarded_ios': 'ca-app-pub-3940256099942544/1712485313',
  };

  BannerAd? _bannerAd;
  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;

  bool _isBannerAdLoaded = false;

  bool get isBannerAdLoaded => _bannerAd != null && _isBannerAdLoaded;
  bool get isInterstitialAdLoaded => _interstitialAd != null;
  bool get isRewardedAdLoaded => _rewardedAd != null;

  BannerAd? get bannerAd => _bannerAd;

  // Timer for 10-minute ads
  Timer? _tenMinuteTimer;
  Timer? _fiveMinuteTimer;
  Timer? _videoAdTimer;
  int _navigationAdCount = 0;
  static const int _maxNavigationAdsPerSession = 4;

  // Initialize AdMob
  Future<void> initialize() async {
    if (!_adsEnabled) {
      print('❌ Ads disabled');
      return;
    }

    // Check if running on web - Google Mobile Ads doesn't work on web
    try {
      if (kIsWeb) {
        print('❌ Ads not supported on web platform');
        return;
      }
      if (Platform.isAndroid || Platform.isIOS) {
        print(
          '📱 Initializing AdMob for ${Platform.isAndroid ? 'Android' : 'iOS'}...',
        );

        // Configure for production ads - don't set test devices to avoid "No fill" errors
        await MobileAds.instance.updateRequestConfiguration(
          RequestConfiguration(
            // Leave testDeviceIds empty to use production ads
            tagForChildDirectedTreatment: TagForChildDirectedTreatment.no,
            tagForUnderAgeOfConsent: TagForUnderAgeOfConsent.no,
          ),
        );

        await MobileAds.instance.initialize();
        print('✅ AdMob initialized successfully');

        // تحميل الإعلانات
        print('📱 Loading ads...');
        await loadBannerAd();
        await _loadInterstitialAd();
        await _loadRewardedAd();

        // Start 10-minute timer for ads
        _startTenMinuteTimer();
        // Start 5-minute timer for banner ads
        _startFiveMinuteTimer();
        // Start navigation ads
        _startNavigationAds();
        print('✅ AdService initialization completed');

        // Show initialization status
        print('📊 AdService Status: ${getAdStatus()}');
        print('📊 Detailed Status: ${getDetailedAdStatus()}');
      } else {
        print('❌ Ads not supported on this platform');
      }
    } catch (e) {
      print('❌ Failed to initialize AdMob: $e');
      // Retry initialization after 30 seconds
      Future.delayed(const Duration(seconds: 30), () {
        print('🔄 Retrying AdMob initialization...');
        initialize();
      });
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

  void _startFiveMinuteTimer() {
    _fiveMinuteTimer?.cancel();
    _fiveMinuteTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
      print('5-minute timer triggered - loading banner ad');
      loadBannerAd();
    });
  }

  void _startNavigationAds() {
    // Navigation ads are triggered by route changes, not timers
    // This method is just for initialization consistency
    print('Navigation ads initialized - will show on route changes');
  }

  // تحميل إعلان البانر
  Future<void> loadBannerAd() async {
    try {
      final adUnitId = await _getBannerAdUnitId;
      print('📱 Loading banner ad with ID: $adUnitId');
      print(
        '📱 Banner ad current status: ${_bannerAd != null ? 'exists' : 'null'}, loaded: $_isBannerAdLoaded',
      );

      // Dispose existing ad if any
      if (_bannerAd != null) {
        _bannerAd!.dispose();
        _bannerAd = null;
        _isBannerAdLoaded = false;
      }

      _bannerAd = BannerAd(
        adUnitId: adUnitId,
        size: AdSize.banner,
        request: const AdRequest(),
        listener: BannerAdListener(
          onAdLoaded: (ad) {
            print('✅ Banner ad loaded successfully');
            _isBannerAdLoaded = true;
            print(
              '📊 Banner ad status after load: loaded = $_isBannerAdLoaded',
            );
          },
          onAdFailedToLoad: (ad, error) {
            print('❌ Banner ad failed to load: $error');
            print('❌ Error code: ${error.code}, message: ${error.message}');
            _isBannerAdLoaded = false;
            ad.dispose();
            _bannerAd = null;
            // Retry loading after 15 seconds (reduced from 30)
            Future.delayed(const Duration(seconds: 15), () {
              print('🔄 Retrying banner ad load...');
              loadBannerAd();
            });
          },
        ),
      );

      await _bannerAd!.load();
      print('📱 Banner ad load request completed');
    } catch (e) {
      print('❌ Error loading banner ad: $e');
      // Retry after error
      Future.delayed(const Duration(seconds: 15), () {
        print('🔄 Retrying banner ad load after error...');
        loadBannerAd();
      });
    }
  }

  // تحميل إعلان بينية
  Future<void> _loadInterstitialAd() async {
    try {
      final adUnitId = await _getInterstitialAdUnitId;
      print('🎬 Loading interstitial ad with ID: $adUnitId');
      print(
        '🎬 Interstitial ad current status: ${_interstitialAd != null ? 'exists' : 'null'}',
      );

      await InterstitialAd.load(
        adUnitId: adUnitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            _interstitialAd = ad;
            print('✅ Interstitial ad loaded successfully');
            print(
              '📊 Interstitial ad status after load: loaded = ${_interstitialAd != null}',
            );
          },
          onAdFailedToLoad: (error) {
            print('❌ Interstitial ad failed to load: $error');
            print('❌ Error code: ${error.code}, message: ${error.message}');
            // Retry loading after 30 seconds (reduced from 60)
            Future.delayed(const Duration(seconds: 30), () {
              print('🔄 Retrying interstitial ad load...');
              _loadInterstitialAd();
            });
          },
        ),
      );
      print('🎬 Interstitial ad load request completed');
    } catch (e) {
      print('❌ Error loading interstitial ad: $e');
      // Retry after error
      Future.delayed(const Duration(seconds: 30), () {
        print('🔄 Retrying interstitial ad load after error...');
        _loadInterstitialAd();
      });
    }
  }

  // تحميل إعلان مكافآت
  Future<void> _loadRewardedAd() async {
    try {
      final adUnitId = await _getRewardedAdUnitId;
      print('🎁 Loading rewarded ad with ID: $adUnitId');
      print(
        '🎁 Rewarded ad current status: ${_rewardedAd != null ? 'exists' : 'null'}',
      );

      await RewardedAd.load(
        adUnitId: adUnitId,
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (ad) {
            _rewardedAd = ad;
            print('✅ Rewarded ad loaded successfully');
            print(
              '📊 Rewarded ad status after load: loaded = ${_rewardedAd != null}',
            );
          },
          onAdFailedToLoad: (error) {
            print('❌ Rewarded ad failed to load: $error');
            print('❌ Error code: ${error.code}, message: ${error.message}');
            // Retry loading after 30 seconds (reduced from 60)
            Future.delayed(const Duration(seconds: 30), () {
              print('🔄 Retrying rewarded ad load...');
              _loadRewardedAd();
            });
          },
        ),
      );
      print('🎁 Rewarded ad load request completed');
    } catch (e) {
      print('❌ Error loading rewarded ad: $e');
      // Retry after error
      Future.delayed(const Duration(seconds: 30), () {
        print('🔄 Retrying rewarded ad load after error...');
        _loadRewardedAd();
      });
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
    if (_bannerAd != null && _isBannerAdLoaded) {
      print('✅ Returning loaded banner ad widget');
      return Container(height: 50, child: AdWidget(ad: _bannerAd!));
    } else {
      print('⏳ Banner ad not loaded, showing placeholder');
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
    print('🧹 Disposing AdService...');
    _tenMinuteTimer?.cancel();
    _fiveMinuteTimer?.cancel();
    _videoAdTimer?.cancel();
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
    print('✅ AdService disposed successfully');
  }

  // إيقاف مؤقت للإعلانات
  void pauseAds() {
    print('⏸️ Pausing ads...');
    _tenMinuteTimer?.cancel();
    _videoAdTimer?.cancel();
    print('✅ Ads paused');
  }

  // استئناف الإعلانات
  void resumeAds() {
    print('▶️ Resuming ads...');
    _startTenMinuteTimer();
    print('✅ Ads resumed');
  }

  // إيقاف الإعلانات بشكل كامل
  void disableAds() {
    print('🚫 Disabling ads completely...');
    _tenMinuteTimer?.cancel();
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
    _bannerAd = null;
    _interstitialAd = null;
    _rewardedAd = null;
    _isBannerAdLoaded = false;
    _navigationAdCount = 0; // Reset navigation ad count
    print('✅ Ads disabled completely');
  }

  // Reset navigation ad count (for new session)
  void resetNavigationAdCount() {
    print('🔄 Resetting navigation ad count');
    _navigationAdCount = 0;
  }

  // إحصائيات الإعلانات
  Map<String, dynamic> getAdStats() {
    return {
      'totalAds': {
        'banner': _bannerAd != null ? 1 : 0,
        'interstitial': _interstitialAd != null ? 1 : 0,
        'rewarded': _rewardedAd != null ? 1 : 0,
      },
      'loadedAds': {
        'banner': _isBannerAdLoaded ? 1 : 0,
        'interstitial': _interstitialAd != null ? 1 : 0,
        'rewarded': _rewardedAd != null ? 1 : 0,
      },
      'adUnitIds': {
        'banner': _bannerAdUnitId,
        'interstitial': _interstitialAdUnitId,
        'rewarded': _rewardedAdUnitId,
      },
      'platform': Platform.isAndroid
          ? 'Android'
          : Platform.isIOS
          ? 'iOS'
          : 'Other',
      'adsEnabled': _adsEnabled,
      'timerActive': _tenMinuteTimer?.isActive ?? false,
      'navigationAdsShown': _navigationAdCount,
      'maxNavigationAds': _maxNavigationAdsPerSession,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  // فحص صحة الإعلانات
  Future<bool> validateAds() async {
    print('🔍 Validating ads...');
    bool allValid = true;

    try {
      // فحص إعلان البانر
      if (_bannerAd != null) {
        print('✅ Banner ad exists');
      } else {
        print('❌ Banner ad missing - reloading...');
        await loadBannerAd();
        allValid = false;
      }

      // فحص إعلان بيني
      if (_interstitialAd != null) {
        print('✅ Interstitial ad exists');
      } else {
        print('❌ Interstitial ad missing - reloading...');
        await _loadInterstitialAd();
        allValid = false;
      }

      // فحص إعلان مكافآت
      if (_rewardedAd != null) {
        print('✅ Rewarded ad exists');
      } else {
        print('❌ Rewarded ad missing - reloading...');
        await _loadRewardedAd();
        allValid = false;
      }

      print(
        '🔍 Ad validation completed: ${allValid ? 'All valid' : 'Some missing'}',
      );
      return allValid;
    } catch (e) {
      print('❌ Error during ad validation: $e');
      return false;
    }
  }

  // تحديث معرفات الإعلانات من قاعدة البيانات
  Future<void> refreshAdUnitIds() async {
    print('🔄 Refreshing ad unit IDs from database...');
    _bannerAdUnitId = null;
    _interstitialAdUnitId = null;
    _rewardedAdUnitId = null;

    // إعادة تحميل جميع الإعلانات بالمعرفات الجديدة
    await reloadAllAds();
    print('✅ Ad unit IDs refreshed successfully');
  }

  // الحصول على معلومات شاملة للتشخيص
  Map<String, dynamic> getDiagnosticInfo() {
    return {
      'serviceInfo': {
        'adsEnabled': _adsEnabled,
        'platform': Platform.isAndroid
            ? 'Android'
            : Platform.isIOS
            ? 'iOS'
            : 'Other',
        'timerActive': _tenMinuteTimer?.isActive ?? false,
      },
      'adStatus': getAdStatus(),
      'detailedStatus': getDetailedAdStatus(),
      'stats': getAdStats(),
      'memoryInfo': {
        'bannerAdExists': _bannerAd != null,
        'interstitialAdExists': _interstitialAd != null,
        'rewardedAdExists': _rewardedAd != null,
        'bannerAdLoaded': _isBannerAdLoaded,
      },
      'configuration': {
        'bannerAdUnitId': _bannerAdUnitId,
        'interstitialAdUnitId': _interstitialAdUnitId,
        'rewardedAdUnitId': _rewardedAdUnitId,
      },
      'timestamp': DateTime.now().toIso8601String(),
    };
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

  // Show navigation ad (called when user navigates between screens)
  void showNavigationAd([Function? onAdDismissed]) {
    if (_navigationAdCount >= _maxNavigationAdsPerSession) {
      print(
        '🧭 Navigation ad limit reached ($_navigationAdCount/$_maxNavigationAdsPerSession) - skipping',
      );
      if (onAdDismissed != null) onAdDismissed();
      return;
    }

    print(
      '🧭 Showing navigation ad (${_navigationAdCount + 1}/$_maxNavigationAdsPerSession)...',
    );
    _navigationAdCount++;
    showInterstitialAd(onAdDismissed);
  }

  // Start video ad timer (5 minutes during video playback)
  void startVideoAdTimer() {
    print('🎬 Starting video ad timer (5 minutes)');
    _videoAdTimer?.cancel();
    _videoAdTimer = Timer(const Duration(minutes: 5), () {
      print('🎬 Video ad timer triggered - showing interstitial ad');
      showInterstitialAd();
      // Restart the timer for next 5 minutes
      startVideoAdTimer();
    });
  }

  // Stop video ad timer
  void stopVideoAdTimer() {
    print('🎬 Stopping video ad timer');
    _videoAdTimer?.cancel();
    _videoAdTimer = null;
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

  // إعادة تحميل جميع الإعلانات يدوياً
  Future<void> reloadAllAds() async {
    print('🔄 Reloading all ads manually...');
    await loadBannerAd();
    await _loadInterstitialAd();
    await _loadRewardedAd();
    print('✅ All ads reload completed');
  }

  // إعادة تحميل إعلان البانر فقط
  Future<void> reloadBannerAd() async {
    print('🔄 Reloading banner ad manually...');
    await loadBannerAd();
    print('✅ Banner ad reload completed');
  }

  // إعادة تحميل إعلان بيني فقط
  Future<void> reloadInterstitialAd() async {
    print('🔄 Reloading interstitial ad manually...');
    await _loadInterstitialAd();
    print('✅ Interstitial ad reload completed');
  }

  // إعادة تحميل إعلان مكافآت فقط
  Future<void> reloadRewardedAd() async {
    print('🔄 Reloading rewarded ad manually...');
    await _loadRewardedAd();
    print('✅ Rewarded ad reload completed');
  }

  // الحصول على تفاصيل حالة الإعلانات للتتبع
  Map<String, dynamic> getDetailedAdStatus() {
    return {
      'bannerAd': {
        'exists': _bannerAd != null,
        'loaded': _isBannerAdLoaded,
        'adUnitId': _bannerAdUnitId,
      },
      'interstitialAd': {
        'exists': _interstitialAd != null,
        'adUnitId': _interstitialAdUnitId,
      },
      'rewardedAd': {
        'exists': _rewardedAd != null,
        'adUnitId': _rewardedAdUnitId,
      },
      'adsEnabled': _adsEnabled,
      'platform': Platform.isAndroid
          ? 'Android'
          : Platform.isIOS
          ? 'iOS'
          : 'Other',
      'timestamp': DateTime.now().toIso8601String(),
    };
  }
}
