import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdMobService {
  // Ad Unit IDs - loaded from database
  static String? _bannerAdUnitId;
  static String? _interstitialAdUnitId;

  static Future<String> get bannerAdUnitId async {
    if (_bannerAdUnitId == null) {
      // TODO: Load from database
      _bannerAdUnitId =
          'ca-app-pub-3794036444002573/6894673538'; // Temporary fallback
    }
    return _bannerAdUnitId!;
  }

  static Future<String> get interstitialAdUnitId async {
    if (_interstitialAdUnitId == null) {
      // TODO: Load from database
      _interstitialAdUnitId =
          'ca-app-pub-3794036444002573/8670789633'; // Temporary fallback
    }
    return _interstitialAdUnitId!;
  }

  BannerAd? _bannerAd;
  bool _isBannerAdLoaded = false;

  // Initialize AdMob
  Future<void> initialize() async {
    await MobileAds.instance.initialize();
  }

  // Create banner ad
  Future<BannerAd> createBannerAd() async {
    final adUnitId = await bannerAdUnitId;
    return BannerAd(
      adUnitId: adUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          _bannerAd = ad as BannerAd;
          _isBannerAdLoaded = true;
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          _isBannerAdLoaded = false;
        },
      ),
    );
  }

  // Load banner ad
  Future<void> loadBannerAd() async {
    if (_bannerAd == null) {
      _bannerAd = await createBannerAd();
    }
    await _bannerAd!.load();
  }

  // Get banner ad widget
  AdWidget? getBannerAdWidget() {
    if (_bannerAd != null && _isBannerAdLoaded) {
      return AdWidget(ad: _bannerAd!);
    }
    return null;
  }

  // Dispose banner ad
  void disposeBannerAd() {
    _bannerAd?.dispose();
    _bannerAd = null;
    _isBannerAdLoaded = false;
  }

  // Create interstitial ad
  Future<InterstitialAd?> createInterstitialAd() async {
    final adUnitId = await interstitialAdUnitId;
    InterstitialAd? interstitialAd;
    await InterstitialAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          interstitialAd = ad;
        },
        onAdFailedToLoad: (LoadAdError error) {
          interstitialAd = null;
        },
      ),
    );
    return interstitialAd;
  }

  // Show interstitial ad
  Future<void> showInterstitialAd() async {
    final interstitialAd = await createInterstitialAd();
    if (interstitialAd != null) {
      interstitialAd.show();
    }
  }
}
